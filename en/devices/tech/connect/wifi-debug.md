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

# Testing and Debugging

This page describes how to test and debug the Wi-Fi implementation using the
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

## Enhanced logging options

Android {{ androidPVersionNumber }} improves Wi-Fi logging to make it easier to
debug Wi-Fi issues. In Android {{ androidPVersionNumber }}, driver/firmware ring
buffers can always be on. Bug reports may automatically be triggered when a bad
state is detected (only in userdebug and eng builds). When the latest Wi-Fi HAL
(version 1.2) is used, firmware debug buffers are stored in the HAL instead of
the framework to save IPC costs.

### Implementation

For a reference implementation, see the
[default implementation](https://android.googlesource.com/platform/hardware/interfaces/+/master/wifi/1.2/default/wifi_chip.cpp#1388)
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

Run this manual test to verify that old files in the [tombstone directory](/devices/tech/debug/#debuggerd) are
being deleted.

1.  Turn on Wi-Fi.
1.  Connect to a network.
1.  Generate a [bug report](/setup/contribute/read-bug-reports).
1.  Inspect the bugreport zip file and verify that
    `/lshal-debug/android.hardware.wifi@1.2__IWifi_default.txt` holds the
    archived firmware logs.
