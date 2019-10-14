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

# WPA3 and Wi-Fi Enhanced Open

Android {{ androidQVersionNumber }} introduces support for the Wi-Fi Alliance's
(WFA) Wi-Fi Protected Access version 3 (WPA3) and Wi-Fi Enhanced Open
standards. For more
information, see
[*Security* on the WFA site](https://www.wi-fi.org/discover-wi-fi/security){: .external}.

WPA3 is a new Wi-Fi Alliance (WFA) security standard for personal and enterprise
networks. It aims to improve overall Wi-Fi security by using modern security
algorithms and stronger cipher suites. WPA3 has two parts:

+   **WPA3-Personal:** Uses simultaneous authentication of equals (SAE)
    instead of pre-shared key (PSK), providing users with stronger security
    protections against attacks such as offline dictionary attacks, key
    recovery, and message forging.
+   **WPA3-Enterprise:** Offers stronger authentication and link-layer
    encryption methods, and an optional 192-bit security mode for sensitive
    security environments.

Wi-Fi Enhanced Open is a new Wi-Fi Alliance (WFA) security standard for public
networks based on opportunistic wireless encryption (OWE). It provides
encryption and privacy on open, non-password-protected networks in areas such as
cafes, hotels, restaurants, and libraries. Enhanced Open doesn't provide
authentication.

WPA3 and Wi-Fi Enhanced Open improve overall Wi-Fi security, providing better
privacy and robustness against known attacks. As many devices don't yet support
these standards or haven't yet had software upgrades to support these features,
WFA has proposed the following transition modes:

+   **WPA2/WPA3 transition mode:** The serving access point supports both
    standards concurrently. In this mode, Android {{ androidQVersionNumber }}
    devices use WPA3 to connect, and devices running Android 9 or lower use
    WPA2 to connect to the same access point.
+   **OWE transition mode:** The serving access point supports both OWE and open
    standards concurrently. In this mode, Android {{ androidQVersionNumber }}
    devices use OWE to connect, and devices running Android 9 or lower connect
    to the same access point without any encryption.

WPA3 and Wi-Fi Enhanced Open are only supported in client mode.

## Implementation

To support WPA3 and Wi-Fi Enhanced Open, implement the supplicant HAL interface
design language (HIDL) provided in the Android Open Source Project (AOSP) at
[`hardware/interfaces/wifi/supplicant/1.2/`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/wifi/supplicant/1.2/){: .external}.

Note: The supplicant HAL version must be version 1.2 or higher.

The following are required to support WPA3 and OWE:

+   Linux kernel patches to support SAE and OWE

    +   cfg80211
    +   nl80211

+   [`wpa_supplicant`](https://android.googlesource.com/platform/external/wpa_supplicant_8/+/refs/heads/master){: .external}
    with support for SAE, SUITEB192 and OWE
+   Wi-Fi driver with support for SAE, SUITEB192, and OWE
+   Wi-Fi firmware with support for SAE, SUITEB192, and OWE
+   Wi-Fi chip with support for WPA3 and OWE

Public APIs are available in Android {{ androidQVersionNumber }} to allow apps
to determine device support for these features:

+   [`WifiManager#isWpa3SaeSupported`](https://developer.android.com/reference/kotlin/android/net/wifi/WifiManager#iswpa3saesupported){: .external}
+   [`WifiManager#isWpa3SuiteBSupported`](https://developer.android.com/reference/kotlin/android/net/wifi/WifiManager#iswpa3suitebsupported){: .external}
+   [`WifiManager#isEnhancedOpenSupported`](https://developer.android.com/reference/kotlin/android/net/wifi/WifiManager#isenhancedopensupported){: .external}

[`WifiConfiguration.java`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/wifi/java/android/net/wifi/WifiConfiguration.java#140){: .external}
contains new key management types, as well as pairwise ciphers, group ciphers,
group management ciphers, and Suite B ciphers, which are required for OWE,
WPA3-Personal, and WPA3-Enterprise.

## Enabling WPA3 and Wi-Fi Enhanced Open

To enable WPA3-Personal, WPA3-Enterprise, and Wi-Fi Enhanced Open in the Android
framework:

+   **WPA3-Personal:** Include the `CONFIG_SAE` compilation option in the
    `wpa_supplicant` [configuration file](https://android.googlesource.com/platform/external/wpa_supplicant_8/+/refs/heads/master/wpa_supplicant/android.config){: .external}.

    <pre class="devsite-click-to-copy">
    # WPA3-Personal (SAE)
    CONFIG_SAE=y
    </pre>

+   **WPA3-Enterprise:** Include the `CONFIG_SUITEB192` and `CONFIG_SUITEB`
    compilation options in the `wpa_supplicant` configuration file.

    <pre class="devsite-click-to-copy">
    # WPA3-Enterprise (SuiteB-192)
    CONFIG_SUITEB=y
    CONFIG_SUITEB192=y
    </pre>

+   **Wi-Fi Enhanced Open:** Include the `CONFIG_OWE` compilation option in the
    `wpa_supplicant` configuration file.

    <pre class="devsite-click-to-copy">
    # Opportunistic Wireless Encryption (OWE)
    # Experimental implementation of draft-harkins-owe-07.txt
    CONFIG_OWE=y
    </pre>

If WPA3-Personal, WPA3-Enterprise, or Wi-Fi Enhanced Open aren't enabled, users
won't be able to manually add, scan, or connect to these types of networks.

## Validation

To test your implementation, run the following tests.

### Unit tests

Run
[`SupplicantStaIfaceHalTest`](https://android.googlesource.com/platform/frameworks/opt/net/wifi/+/refs/heads/master/tests/wifitests/src/com/android/server/wifi/SupplicantStaIfaceHalTest.java){: .external}
to verify the behavior of the capability flags for WPA3 and OWE.

<pre class="devsite-terminal devsite-click-to-copy">
atest SupplicantStaIfaceHalTest
</pre>

Run
[`WifiManagerTest`](https://android.googlesource.com/platform/cts/+/refs/heads/master/tests/tests/net/src/android/net/wifi/cts/WifiManagerTest.java){: .external}
to verify the behavior of the public APIs for this feature.

<pre class="devsite-terminal devsite-click-to-copy">
atest WifiManagerTest
</pre>

### Integration test (ACTS)

To run an integration test, use the Android Comms Test Suite (ACTS) file,
[`WifiWpa3OweTest.py`](https://android.googlesource.com/platform/tools/test/connectivity/+/refs/heads/master/acts/tests/google/wifi/WifiWpa3OweTest.py),
located in `tools/test/connectivity/acts/tests/google/wifi`.

### VTS tests

Run
[`VtsHalWifiSupplicantV1_2Host`](https://android.googlesource.com/platform/test/vts-testcase/hal/+/refs/heads/master/wifi/supplicant/V1_2/host/VtsHalWifiSupplicantV1_2HostTest.py){: .external}
to test the behavior of the supplicant HAL v1.2.

<pre class="devsite-terminal devsite-click-to-copy">
vts-tradefed run commandAndExit vts --skip-all-system-status-check --primary-abi-only --skip-preconditions --module VtsHalWifiSupplicantV1_2Host
</pre>
