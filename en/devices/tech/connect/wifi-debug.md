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

# Testing, Debugging, and Tuning Wi-Fi

This page describes how to test, debug, and tune the Wi-Fi implementation using the
tools provided in AOSP.

## Testing

To test the Wi-Fi framework, AOSP provides a mix of unit tests, integration
tests (ACTS), and CTS tests.

### Unit tests

AOSP includes functional and unit tests for the default Wi-Fi framework: both
for the Wi-Fi Manager (app-side code) and the Wi-Fi Service.

Wi-Fi Manager tests:

+   Located in `frameworks/base/wifi/tests`
+   Run using the following shell executable (read the file for more execution
    options):

    ```
    % ./frameworks/base/wifi/tests/runtest.sh
    ```

Wi-Fi Service tests:

+   Located in `frameworks/opt/net/wifi/tests/wifitest`
+   Run using the following shell executable (read the file for more execution
    options):

    ```
    % ./frameworks/opt/net/wifi/tests/wifitests/runtest.sh
    ```

### Android Comms Test Suite

The Android Comms Test Suite (ACTS) performs automated testing of connectivity
stacks, such as Wi-Fi, Bluetooth, and cellular services. The testing tool
requires adb and Python, and it can be found in `tools/test/connectivity/acts`.

The ACTS tests for Wi-FI are found in
`tools/test/connectivity/acts/tests/google/wifi`, with an example test
configuration in the same directory: `example_config.json`.

### CTS Tests

The [Compatibility Test Suite](/compatibility/cts/) (CTS) includes tests for the
Wi-Fi framework. These are located in
`cts/tests/tests/net/src/android/net/wifi`. The Wi-Fi CTS tests require the
device-under-test to be associated with an Access Point at the start of the test
run.

## Enhanced logging options for debugging

Android {{ androidPVersionNumber }} improves Wi-Fi logging to make it easier to
debug Wi-Fi issues. In Android {{ androidPVersionNumber }}, driver/firmware ring
buffers can always be on. Bug reports may automatically be triggered when a bad
state is detected (only in userdebug and eng builds). When the latest Wi-Fi HAL
(version 1.2) is used, firmware debug buffers are stored in the HAL instead of
the framework to save IPC costs.

### Implementation

For a reference implementation, see the
[default implementation](https://android.googlesource.com/platform/hardware/interfaces/+/master/wifi/1.2/default/wifi_chip.cpp){: .external}
in the vendor HAL.

You can disable firmware logging by setting the resource,
`config_wifi_enable_wifi_firmware_debugging`, to false.

### Integration test (ACTS)

The integration test can be found at
`/tools/test/connectivity/acts/tests/google/wifi/WifiDiagnosticsTest.py`.

Verified firmware dumps are persisted in the appropriate tombstone directory in
flash for userdebug builds. Dumpstate collects from this directory when creating
a bug report.

### Manual test

Run this manual test to verify that old files in the
[tombstone directory](/devices/tech/debug/#debuggerd) are being deleted.

1.  Turn on Wi-Fi.
1.  Connect to a network.
1.  Generate a [bug report](/setup/contribute/read-bug-reports).
1.  Inspect the bugreport zip file and verify that
    `/lshal-debug/android.hardware.wifi@1.2__IWifi_default.txt` holds the
    archived firmware logs.

## Configuration tuning

To control the signal strength at which a device associates to or
disassociates from a network, the Wi-Fi framework uses the *entry* and *exit*
RSSI thresholds.

The *entry* and *exit* thresholds are stored as overloadable configuration
parameters with the following names (where the `bad` parameter refers to the
*exit* RSSI threshold):

*   `config_wifi_framework_wifi_score_bad_rssi_threshold_5GHz`
*   `config_wifi_framework_wifi_score_entry_rssi_threshold_5GHz`
*   `config_wifi_framework_wifi_score_bad_rssi_threshold_24GHz`
*   `config_wifi_framework_wifi_score_entry_rssi_threshold_24GHz`

The parameters are stored in
`<root>/frameworks/base/core/res/res/values/config.xml` and may be overloaded
using the overlay file
`<root>/device/<dev_dir>/overlay/frameworks/base/core/res/res/values/config.xml`.

Note: The `bad` configuration parameters (for 2.4GHz and 5GHz bands) were
introduced pre-Android 8.1. The `entry` configuration parameters were introduced
in Android 8.1 with the default values equal to the corresponding bad
parameters. These defaults result in pre-Android 8.1 behavior where no
hysteresis is used in network selection. To take advantage of the hysteresis
functionality introduced in Android 8.1, set the `entry` parameters to 3dB or
more above the `bad` parameters using the overlay file specified above.

You can test new thresholds by configuring the device using adb commands.
(Alternatively, you can create a build with new overlays but using adb commands
provide a faster testing turnaround.)

```
% adb shell settings put global wifi_score_params \
                             [rssi2|rssi5]=<bad>:<entry>:<low>:<good>
```

For example, the following command configures new threshold parameters (the
values used in this sample command are the configured defaults in the AOSP
codebase):

```
% adb shell settings put global wifi_score_params \
                       rssi2=-85:-85:-73:-60,rssi5=-82:-82:-70:-57
```

To restore the built-in parameter values (i.e. remove the overrides) use the
following adb command:

```
% adb shell settings delete global wifi_score_params
```
