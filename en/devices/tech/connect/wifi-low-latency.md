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

# Wi-Fi Low-Latency Mode

Android {{ androidQVersionNumber }} extends the Wi-Fi lock API to allow
latency-sensitive apps to configure Wi-Fi to a
[low-latency mode](https://developer.android.com/reference/android/net/wifi/WifiManager#WIFI_MODE_FULL_LOW_LATENCY){: .external}.
The low-latency mode starts when all of the following conditions are met:

+   Wi-Fi is enabled and the device has internet access.
+   The app has created and acquired a Wi-Fi lock, and is running in the
    foreground.
+   The screen is on.

To support low-latency mode on devices, device manufacturers must update the
WLAN driver and vendor HAL. In low-latency mode, power save (also known as
doze state in the IEEE 802.11 standard) is explicitly disabled by the framework.
The scanning and roaming parameters in the driver and firmware layers can be
optimized to further reduce Wi-Fi latency. The exact optimizations are
implementation specific.

Android has a
[high-performance Wi-Fi lock mode](https://developer.android.com/reference/android/net/wifi/WifiManager#WIFI_MODE_FULL_HIGH_PERF){: .external}
(introduced in API level 12) that is separate from the low-latency mode.

## Implementation

The Wi-Fi low-latency mode feature is in
[`android.hardware.wifi@1.3`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/wifi/1.3/){: .external}.
To support this feature, provide implementations for the following functions in
[`IWifiChip.hal`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/wifi/1.3/IWifiChip.hal){: .external}:

+   `getCapabilities_1_3() generates (WifiStatus status,
    bitfield<ChipCapabilityMask> capabilities)`
+   `setLatencyMode(LatencyMode mode) generates (WifiStatus status)`

A reference implementation can be found in
[`wifi_legacy_hal.cpp`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/wifi/1.3/default/wifi_legacy_hal.cpp){: .external}
with the following functions:

+   `wifi_error wifi_get_supported_feature_set(wifi_interface_handle
    iface,  feature_set *set)`
+   `wifi_error wifi_set_latency_mode(wifi_interface_handle handle,
    wifi_latency_mode mode)`

In low-latency mode, power save is explicitly disabled by
[`WifiLockManager`](https://android.googlesource.com/platform/frameworks/opt/net/wifi/+/refs/heads/master/service/java/com/android/server/wifi/WifiLockManager.java){: .external}
in the Android framework.
To support this, the WLAN driver must support the NL80211 command,
`NL80211_CMD_SET_POWER_SAVE`, to enable and disable power save. When Wi-Fi power
save is disabled, the Wi-Fi system must stay in the awake state and be ready to
send or receive packets with minimum delay.

Note: Low-latency mode is fully supported on devices that support
`android.hardware.wifi@1.3`. For devices running Android
{{ androidQVersionNumber }} that don't support
`android.hardware.wifi@1.3`, `WifiLockManager` only disables power save when
the low-latency mode Wi-Fi lock is acquired by the app and is active.

## Disabling the feature

To turn off the low-latency mode feature, update the underlying code of
`getCapabilities_1_3()` such that `capabilities & SET_LATENCY_MODE = 0`, where
`SET_LATENCY_MODE` is defined in `IWifiChip.hal`. When this feature is disabled,
the framework only disables power save when the low-latency mode is active.

## Validation

To test that low-latency mode works when enabled, run the following automated
tests and manual ping latency tests.

### Automated testing

Run the following VTS and CTS tests:

+   VTS:
    [`hardware/interfaces/wifi/1.3/vts/functional/wifi_chip_hidl_test.cpp`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/wifi/1.3/vts/functional/wifi_chip_hidl_test.cpp){: .external}
+   CTS:
    [`cts/tests/tests/net/src/android/net/wifi/cts/WifiLockTest.java`](https://android.googlesource.com/platform/cts/+/refs/heads/master/tests/tests/net/src/android/net/wifi/cts/WifiLockTest.java){: .external}

### Manual testing

#### Required test equipment and environment

For manual testing, the following setup is required:

+   Wi-Fi access point (AP)
+   Device-under-test (DUT) phone and test computer

    +   The DUT must be connected to the access point over Wi-Fi.
    +   The test computer must be connected to the access point over Wi-Fi or
        Ethernet.
    +   The test computer must be connected to the DUT over USB.

#### Uplink ping test

1.  Enable low latency mode.

    <pre class="prettyprint">
    <code class="devsite-terminal">adb root</code>
    <code class="devsite-terminal">adb shell cmd wifi force-low-latency-mode enabled</code>
    </pre>

1.  Make sure your computer is connected with the phone through ADB. From
    the ADB shell, ping the gateway continuously for 3 hours at 1 second
    intervals.
1.  Save the test output in a text file and use a spreadsheet or a Python
    script to generate a histogram of the ping latency test results.
1.  Repeat steps 1 through 3 with latency mode disabled.

    <pre class="prettyprint">
    <code class="devsite-terminal">adb root</code>
    <code class="devsite-terminal">adb shell cmd wifi force-low-latency-mode disabled</code>
    </pre>

1.  Compare the test results to ensure that the average ping latency value is
    reduced when the low-latency mode is enabled.

Note: Optionally, to determine whether end-to-end latency has improved overall,
repeat the test using a well-known host address such as google.com.

#### Downlink ping test

1.  Enable low-latency mode.

    <pre class="prettyprint">
    <code class="devsite-terminal">adb root</code>
    <code class="devsite-terminal">adb shell cmd wifi force-low-latency-mode enabled</code>
    </pre>

1.  From the command line of the test computer, ping the phone's IP
    address continuously for 3 hours at 1 second intervals.
1.  Save the test output in a text file and use a spreadsheet or a Python
    script to generate a histogram of the ping latency test results.
1.  Repeat steps 1 through 3 with latency mode disabled.

    <pre class="prettyprint">
    <code class="devsite-terminal">adb root</code>
    <code class="devsite-terminal">adb shell cmd wifi force-low-latency-mode disabled</code>
    </pre>

1.  Compare the test results to ensure that the average ping latency value is
    reduced when the low-latency mode is enabled.

Note: Optionally, to determine whether end-to-end latency is improved,
repeat the ping test with a well-known host address such as google.com.

#### Other tests

Repeat the above tests in different environments. For example, at
home or in the office.
