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

# Device states in Tradefed

## Android devices

Android devices in Tradefed can go through several states made available through
the Device Manager. There are two main categories of statesfor Android devices:
Allocation state and Online State.

All of these states can be checked in the
[Tradefed Console](/devices/tech/test_infra/tradefed/fundamentals/console)
using `l d` or `list devices`.

```
tf >l d
Serial        State         Allocation   Product   Variant   Build    Battery
84TX0081B     ONLINE        Available    blueline  blueline  MASTER   100
HT6550300002  ONLINE        Available    sailfish  sailfish  MASTER   94
876X00GNG     UNAUTHORIZED  Unavailable  unknown   unknown   unknown  unknown
HT6570300047  UNAUTHORIZED  Unavailable  unknown   unknown   unknown  unknown
```

### Allocation states

Allocation states are are Tradefed-specific states to monitor device use. They
are described by
[DeviceAllocationState](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/remote/src/com/android/tradefed/device/DeviceAllocationState.java)
and can be any of:

*   UNKNOWN: An intermediate state used during transitions to decide if the
    device should be removed from the tracking list. This would happen when a
    device is disconnected from `adb`.
*   IGNORED: Device cannot be selected for the TF session because it was
    filtered out. Most likely TF was started with `ANDROID_SERIAL` exported, so
    it limits the scope of devices that can be picked.
*   AVAILABLE: Device is ready to be selected for a test.
*   UNAVAILABLE: Device is connected but not ready to run tests. It usually
    shows as `offline` in `adb`.
*   ALLOCATED: Device is currently running a test and cannot be selected.
*   CHECKING_AVAILABILITY: Device was just connected, and TF checks whether it
    is properly online and can be made available. If not, it will be made
    unavailable.

### Online states

Oneline states represent the actual state of the device as seen by
`adb devices`. They are described by
[TestDeviceState](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/device/TestDeviceState.java)
and can be:

*   FASTBOOT
*   ONLINE
*   RECOVERY
*   NOT_AVAILABLE

Tradefed online states are linked to the underlying `adb` library we use, `ddmlib`.
It describes the states with [DeviceState](https://android.googlesource.com/platform/tools/base/+/refs/heads/master/ddmlib/src/main/java/com/android/ddmlib/IDevice.java).

