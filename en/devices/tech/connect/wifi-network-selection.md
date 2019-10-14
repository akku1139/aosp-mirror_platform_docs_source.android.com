Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
  Copyright 2019 The Android Open Source Project

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

# Android Wi-Fi Network Selection

This page outlines the algorithms and procedures used in
Android {{ androidQVersionNumber }} for selecting
and switching between Wi-Fi networks. Android continuously evaluates the quality
of the connected network and assesses the quality of available networks.

Note: The details provided on this page aren't comprehensive and may change in
future Android releases. The Android source code is the final _source of
truth_.

## Life of an automatic connection {:#process}

This describes the process of how an Android device assesses and
connects to available Wi-Fi networks.

1.  The device scans for available networks in one of the following ways
    depending on whether the screen is on or off.

    -   **Screen on:** The Android connectivity subsystem triggers
        regular [scans](#scans) to detect available networks
        (connectivity scans). These scans can also be triggered by other system
        components such as the location system or an app (including the Settings app).
    -   **Screen off:** The host CPU programs the firmware with a list of
        preferred networks using preferred network offload scans (PNO) before
        the host CPU goes to sleep. The firmware wakes the host if it finds any
        of the preferred networks.

1.  Scan results are evaluated.

    -   If the device is connected to a Wi-Fi network, the framework
        evaluates whether the network is good enough, meaning that the
        received signal strength indicator (RSSI) is
        above
        [tunable](/devices/tech/connect/wifi-debug#configuration_tuning)
        thresholds, isn't an open network, and uses the 5&nbsp;GHz band. If the
        network is good, no further action is taken.
    -   If the connected Wi-Fi network isn't good enough or if the
        device isn't connected to a network, the framework calls
        [network evaluators](#network-evaluators) to generate a list of
        candidate Wi-Fi networks to connect to based on the scan results. The
        network evaluators find existing Wi-Fi configurations or create new
        configurations for the candidate networks.

1.  The framework runs the
    [candidate scorer](#candidate-scorers)
    to generate a score for each service set identifier (SSID) candidate. The
    SSID candidates can
    include multiple basic service set identifier (BSSID) candidates
    (generated by the network evaluators).
    The candidate with the highest score is the _winning candidate_.
1.  The framework executes the
    [user connect choice](#user-connect-choice)
    algorithm, which may make the user-selected network the new winning
    candidate.
1.  The framework determines whether the winning candidate matches the
    currently connected network. To be considered a match, one of the following
    must be met:

    -   The winning candidate and the connected Wi-Fi network have
        the same BSSID.
    -   If firmware roaming is available (including BSSID blacklist
        capability), the winning candidate and the connected network have the
        same SSID and security type.

    If the winning candidate matches the currently connected network, no
    further action is taken. If the winning candidate doesn't match the
    network, the device is associated to the winning candidate.

## Evaluation of a connected network {:#network-eval}

The Android framework or firmware periodically evaluates the quality of the
connected network. This describes how the connected network is evaluated when
the screen is on or off.

### Screen on {:#eval-on}

The Android framework evaluates the connected network in the following way:

1.  The Wi-Fi service polls RSSI and link-layer stats every 3 seconds.
1.  The Wi-Fi service calculates a connected score based on the RSSI and
    link-layer stats.
1.  The Wi-Fi service passes the score to the connectivity service, which
    uses the score to determine whether to connect to a Wi-Fi network or to
    another available network type, such as a cellular network.

### Screen off {:#eval-off}

The framework doesn't perform any evaluation on the connected network. The
firmware evaluates the network quality and if the network quality is bad, the
firmware may roam or (eventually) disassociate from the network and wake up the
host.

## Connectivity scans {:#scans}

Scans are performed automatically based on whether the device has the screen on,
has the screen off and is connected to Wi-Fi, or has the screen off and isn't
connected to Wi-Fi.

### Screen on {:#scans-on}

The framework triggers exponential backoff scans at 20, 40, 80, and 160 seconds
when the screen is turned on. Subsequent scans are performed at 160 second
intervals.

The exponential backoff scans are reset and restart at 20 seconds whenever the
screen state changes, that is, when the screen is toggled on or off.

### Screen off and connected to Wi-Fi {:#scans-on-connected}

When the screen is off and the device is connected to a Wi-Fi network, the
firmware performs roaming scans. The framework doesn't perform any scans
when the screen is off.

### Screen off and not connected to Wi-Fi (disconnected state) {:#scans-on-disconnected}

When the screen is off and Wi-Fi is disconnected, scanning behavior depends on
whether the device supports
[preferred network offload (PNO)](/devices/tech/connect/wifi-scan). The
framework doesn't perform any scans when the screen is off.

If PNO is supported, the firmware performs scans for SSIDs. The framework
configures the firmware with a list of SSIDs to scan for and a list of channels
on which to scan. If a configured SSID is found, the firmware wakes the
framework.

If PNO isn't supported, the device remains unassociated with any network until
the screen is turned on.

## Network evaluators {:#network-evaluators}

Network evaluators find or create configurations
([`WifiConfiguration`](https://developer.android.com/reference/android/net/wifi/WifiConfiguration){: .external})
for networks that are currently available (based on scan results) and that can
be associated to with the information (for example, credentials) available to
the device.

The following network evaluators are available.

+   **Saved network evaluator:** Evaluates all saved networks.
+   **Suggested network evaluator:** Evaluates all networks provided by apps
    using the
    [Suggestion API](https://developer.android.com/guide/topics/connectivity/wifi-suggest.md){: .external}.
+   **Passpoint network evaluator:** Using the scan results and the ANQP
    cache, evaluates all installed Passpoint profiles. Also automatically
    generates Passpoint profiles for any observed EAP-SIM, EAP-AKA, or EAP-AKA'
    networks that match the installed SIM. Auto generation only considers
    EAP-SIM/AKA/AKA' networks for which encrypted IMSI is possible (where an
    encryption configuration is available).
+   **Carrier Wi-Fi network evaluator:** Evaluates all
    [carrier Wi-Fi](/devices/tech/connect/carrier-wifi) configurations. Only
    considers EAP-SIM/AKA/AKA' networks for which encrypted IMSI is possible
    (where an encryption configuration is available).
+   **Externally scored network evaluator:** OEM mechanism to provide network
    connectivity options to the
    device. For more information, see
    [External network rating provider](/devices/tech/connect/wifi-infrastructure#external_network_rating_provider).

Each network evaluator normally generates only one candidate network per BSSID
but can generate multiple candidate networks. A single configuration
(`WifiConfiguration`) can be associated with multiple candidate networks, for
example, multiple evaluators may generate a candidate for the same network.

## Candidate scorers {:#candidate-scorers}

Candidate scorers evaluate and provide a score for each network candidate. The
score is based on the following:

+   An RSSI above
    [`ScoringParams#getGoodRssi()`](https://android.googlesource.com/platform/frameworks/opt/net/wifi/+/refs/heads/master/service/java/com/android/server/wifi/ScoringParams.java#335){: .external}
    gets a minimal score boost.
+   A candidate that matches the current network gets a score boost. A
    candidate that also matches the current network's BSSID gets a larger score
    boost.
+   A secure network is scored higher than an open network.
+   A 5&nbsp;GHz candidate is scored higher than 2.4&nbsp;GHz candidates.
+   A candidate network that was recently selected by the user or by an app
    gets a score boost. The score boost starts out large and fades to zero over
    a duration of eight hours.
+   The network evaluator that nominated the candidate. Certain evaluators
    score higher than others. For example, the saved network evaluator is
    scored higher than the externally scored network evaluator.

The framework may have several candidate scorers installed but only one
can be active at a time. The other scorers can be used for metrics (to
investigate alternative algorithms). In Android {{ androidQVersionNumber }},
the default is
[`CompatibilityScorer`](https://android.googlesource.com/platform/frameworks/opt/net/wifi/+/refs/heads/master/service/java/com/android/server/wifi/CompatibilityScorer.java){: .external},
which closely matches the behavior of the Android 9 (Pie) scoring algorithm.

## Score cards {:#score-cards}

Score cards, introduced in Android {{ androidQVersionNumber }}, record on-device
statistics about BSSIDs. Score cards are persisted using the
[`IpMemoryStore`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/services/net/java/android/net/IpMemoryStore.java){: .external}
service.

Score cards aren't used in Android {{ androidQVersionNumber }} network
selection.

## User connect choice {:#user-connect-choice}

Android has a user connect choice algorithm that allows the selection process
to prefer Wi-Fi networks that a user has explicitly connected to. For example,
this can be a home network that the user has connected to. Users may prefer such
networks over public networks even when the performance is lower than a public
network because they provide additional services such as the ability to control
home devices.

The user's preference for a network is captured by marking all the visible Wi-Fi
configurations at the time the user selects a network. If one of the marked
Wi-Fi configurations is selected during the automatic selection process and a
user-selected network is available, the user connect choice algorithm overrides
the selection with the user-selected network.