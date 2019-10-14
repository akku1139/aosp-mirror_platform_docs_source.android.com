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

# Device allocation in Tradefed

When starting a test (for example, an instrumentation test), it might need a
device to be able to run properly. Or the test (such as some Java unit tests)
might not need a device at all. Still others or might even need multi-devices
(like phone + watch tests). In all those cases, the Device Manager is
responsible for allocating the required devices to the test so it runs
properly. We call this phase the *device allocation* or *device selection* step.

The allocation is driven by
[DeviceSelectionOptions](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/device/DeviceSelectionOptions.java)
that allow a test to declare any properties it needs from a device, including:

*   Battery level
*   Device type
*   Product type
*   Serial number

and more.

## Using real devices

This is the default setting that will be allocated to all tests that don't
specify any device properties. A physical random device marked
[AVAILABLE](/devices/tech/test_infra/tradefed/architecture/device-manager#allocation_states)
will be picked and assigned to the test.

## Using no devices

When no devices are needed by the test, it can specify `--null-device` or `-n`
on its command line, or `<option name="null-device" value="true" />` in its
configuration XML. This allocates a stub placeholder NullDevice that
represents no device was allocated.
