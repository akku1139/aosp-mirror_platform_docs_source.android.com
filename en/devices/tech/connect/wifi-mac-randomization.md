Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
  Copyright 2018 The Android Open Source Project

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

# Privacy: MAC Randomization

Starting in Android 8.0, Android devices use randomized MAC addresses when probing
for new networks while not currently associated with a network. In Android
{{ androidPVersionNumber }}, you can enable a developer option (it's
**disabled** by default) to cause the device to use a randomized MAC address
when connecting to a Wi-Fi network.

In Android {{ androidQVersionNumber }}, MAC randomization is enabled by default
for client mode, SoftAp, and Wi-Fi Direct.

MAC randomization prevents listeners from using MAC addresses to build a history
of device activity, thus increasing user privacy.

Additionally, MAC addresses are randomized as part of
[Wi-Fi Aware](/devices/tech/connect/wifi-aware) and
[Wi-Fi RTT](/devices/tech/connect/wifi-rtt) operations.

## Implementation

To implement MAC randomization on your device:

1.  Work with a Wi-Fi chip vendor to implement the following HAL methods:

    +   `IWifiStaIface#setMacAddress`: Configures the MAC address of the
        interface. The default implementation brings the interface down, changes
        the MAC address, and brings the interface back up.
    +   `IWifiStaIface#getFactoryMacAddress`: Gets the factory MAC of `wlan0`
        using an `ioctl` call.
    +   `ISupplicantP2pIface#setMacRandomization`: Sets P2P MAC randomization
        on/off in the supplicant.

1.  Set
    [`config_wifi_connected_mac_randomization_supported`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/res/res/values/config.xml){: .external}
    to `true` in the Settings `config.xml` (this can be done in a device
    custom overlay).

    +   This flag is used to control whether client-mode MAC randomization is
        enabled.

1.  Set
    [`config_wifi_p2p_mac_randomization_supported`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/res/res/values/config.xml){: .external}
    to `true` in the Settings `config.xml` (this can be done in a device
    custom overlay).

    +   This flag is used to control whether Wi-Fi direct MAC randomization is
        enabled.

1.  Test your implementation using the methods described in
    [Validation](#validation).

The System UI must:

+   Have an option to enable or disable randomization for each SSID.
+   Have MAC randomization enabled by default for all newly added networks.

Use the
[reference implementation](https://android.googlesource.com/platform/packages/apps/Settings/+/master/src/com/android/settings/wifi/details/WifiPrivacyPreferenceController.java){: .external}
of Settings UI to implement new prompts.

Devices running Android {{ androidPVersionNumber }} or lower might not have
support for Wi-Fi MAC randomization. When upgrading such devices to Android
{{ androidQVersionNumber }}, the Wi-Fi MAC randomization feature can be disabled
by setting the `WIFI_HIDL_FEATURE_DISABLE_AP_MAC_RANDOMIZATION` flag to true in
the Wi-Fi vendor HAL make file.

## Validation

To validate that the feature is working as intended, run both an integration
test (ACTS) and a manual test.

To run an integration test, use the ACTS file,
`WifiMacRandomizationTest.py`, located in
`tools/test/connectivity/acts/tests/google/wifi`, to verify that the device uses
the randomized MAC address and correctly stores the randomized MAC address for
each network.

To run a manual test:

1.  Verify that MAC randomization is enabled on the device by checking that
    `config_wifi_connected_mac_randomization_supported` is set to `true` in the
    device overlay.
1.  Connect to a Wi-Fi network.
1.  Tap the network to go to the Network details page. Verify that MAC
    randomization is turned on. Verify that the MAC address displayed is a
    randomized MAC, which has the locally generated bit set to 1 and the
    multicast bit set to 0.
1.  Turn MAC randomization off. Connect to the same network and verify
    that the factory MAC is being used.
1.  Delete the network by tapping **Forget** on the Network details page.
1.  Connect to the same network and verify that the **same** randomized MAC
    address is being used.

    Note: Randomized MAC addresses are generated per SSID and are persistent.

To test MAC randomization on a pre-Android {{ androidQVersionNumber }} device
(capable of supporting MAC randomization) upgrading to Android
{{ androidQVersionNumber }} or higher:

1.  Have at least one saved network on a device running
    Android {{ androidPVersionNumber }} or lower.
1.  Flash the Android {{ androidQVersionNumber }} system image.
1.  In the Wi-Fi picker, verify that MAC randomization is turned off for all
    saved networks.
1.  Turn MAC randomization on. Connect to the same network and verify
    that the randomized MAC is being used.

Note: You may experience up to a three-second delay when connecting to a
network due to the driver flushing saved scan results when the
interface goes down. If this is the case, check with your silicon
partners to resolve the issue.
