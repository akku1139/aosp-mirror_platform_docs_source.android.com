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

# Wi-Fi Easy Connect

Android {{ androidQVersionNumber }} introduces support for the Wi-Fi Easy
Connect protocol, also known as the device provisioning protocol (DPP).
[Wi-Fi Easy Connect](https://www.wi-fi.org/discover-wi-fi/wi-fi-easy-connect){: .external}
was introduced by the Wi-Fi Alliance (WFA) as an alternative to
Wi-Fi Protected Setup (WPS). WPS was deprecated in Android 9.

Wi-Fi Easy Connect provides a simple and secure method to:

+   Onboard Wi-Fi devices (including headless devices) to a network
    without entering a password.
+   Join Wi-Fi networks without knowing or entering a password.

Bootstrapping and authentication is configured using a URI, which is acquired
by scanning a QR code (using a camera), or is configured out-of-band,
for example, using BLE or NFC.

Wi-Fi Easy Connect uses an encrypted channel to send Wi-Fi credentials between
devices, and because public action frames are used, devices can use existing
access points.

Android {{ androidQVersionNumber }} supports Wi-Fi Easy Connect only in
initiator mode (responder mode is
not supported). These modes of operation are supported:

+   **Initiator-Configurator:** Send network credentials to a new device
    by scanning its QR code.
+   **Initiator-Enrollee:** Join a network by scanning the network QR code.

Android {{ androidQVersionNumber }} supports the pre-shared key (PSK) protocol
for WPA2 and the simultaneous authentication of equals (SAE) protocol for WPA3.

Wi-Fi Easy Connect is only supported in client mode (SoftAP mode is not
supported).

## Implementation

To support Wi-Fi Easy Connect, implement the supplicant HAL interface design
language (HIDL) provided in the Android Open Source Project (AOSP) at
[`hardware/interfaces/wifi/supplicant/1.2/`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/wifi/supplicant/1.2/){: .external}
or a later version.

The following are required to support DPP:

+   Linux kernel patches to support DPP:

    +   cfg80211
    +   nl80211

+   [`wpa_supplicant`](https://android.googlesource.com/platform/external/wpa_supplicant_8/+/refs/heads/master){: .external}
    with support for DPP
+   Wi-Fi driver with support for DPP
+   Wi-Fi firmware with support for DPP

Public APIs are available in Android {{ androidQVersionNumber }} for use by
apps:

+   [`WifiManager#isEasyConnectSupported`](https://developer.android.com/reference/android/net/wifi/WifiManager#isEasyConnectSupported()){: .external}:
    Queries the framework to determine whether the device supports Wi-Fi Easy
    Connect.
+   [`Activity#startActivityForResult(ACTION_PROCESS_WIFI_EASY_CONNECT_URI)`](https://developer.android.com/reference/android/provider/Settings.html#ACTION_PROCESS_WIFI_EASY_CONNECT_URI){: .external}:
    Allows apps to integrate Wi-Fi Easy Connect into their onboarding/setup flow.

### Enabling Wi-Fi Easy Connect

To enable Wi-Fi Easy Connect in the Android framework, include the
`CONFIG_DPP` compilation
option in the `wpa_supplicant` configuration file,
[`android.config`](https://android.googlesource.com/platform/external/wpa_supplicant_8/+/refs/heads/master/wpa_supplicant/android.config){: .external}:

<pre class="devsite-click-to-copy">
# Easy Connect (Device Provisioning Protocol - DPP)
CONFIG_DPP=y
</pre>

## Validation

To test your implementation, run the following tests.

### Unit tests

Run
[`DppManagerTest`](https://android.googlesource.com/platform/frameworks/opt/net/wifi/+/refs/heads/master/tests/wifitests/src/com/android/server/wifi/DppManagerTest.java){: .external}
to verify the behavior of the capability flags for DPP.

<pre class="devsite-terminal devsite-click-to-copy">
atest DppManagerTest
</pre>

### Integration test (ACTS)

To run an integration test, use the Android Comms Test Suite (ACTS) file,
[`WifiDppTest.py`](https://android.googlesource.com/platform/tools/test/connectivity/+/refs/heads/master/acts/tests/google/wifi/WifiDppTest.py){: .external},
located in `tools/test/connectivity/acts/tests/google/wifi`.

### VTS tests

Run
[`VtsHalWifiSupplicantV1_2Host`](https://android.googlesource.com/platform/test/vts-testcase/hal/+/refs/heads/master/wifi/supplicant/V1_2/host/VtsHalWifiSupplicantV1_2HostTest.py){: .external}
to test the behavior of the supplicant HAL v1.2.

<pre class="devsite-terminal devsite-click-to-copy">
vts-tradefed run commandAndExit vts --skip-all-system-status-check --primary-abi-only --skip-preconditions --module VtsHalWifiSupplicantV1_2Host
</pre>
