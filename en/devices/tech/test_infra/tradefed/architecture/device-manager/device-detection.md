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

# Device detection in Tradefed

A new device connection triggers a series of asynchronous events that are not
obvious yet worth understanding.

## Physically connected

Tradefed uses the `ddmlib` library (a Java `adb` library) to provide the basic
interaction with `adb` and devices. Part of this solution is the
[IDeviceChangeListener interface](https://android.googlesource.com/platform/tools/base/+/refs/heads/master/ddmlib/src/main/java/com/android/ddmlib/AndroidDebugBridge.java)
that allows reception of new device events, such as:

*   `deviceConnected`: When a new device is seen by `adb`
*   `deviceDisconnected`: When a device is not reporting to `adb` anymore
*   `deviceChanged`: When a major device state occurs (such as device offline or
    device online)

These events are enough at the `adb` level to decide whether or not a device is
connected, online, or offline. But for the test harness, we need a stronger
state than this to ensure a device is truly ready to start running tests; it
should not be impacted by potential state flakiness that can come with a newly
connected device.

This is the sequence of events in Tradefed:

1.  Device is recognized as `deviceConnected` and open to regular events from
    `adb`
1.  An internal Tradefed event is created that will:
    *   Check if the device is known already; Tradefed keeps internal reference
        to some devices (especially the one current allocated and running tests)
        to avoid TF losing track of them randomly.
    *   Check if the device is `ONLINE` or `OFFLINE`.

1.  If device is:
    *   `OFFLINE`: Device will be switched to Tradefed `CONNECTED_OFFLINE`
    state, which doesn't allow the device to run tests yet. If the device is
    online later, it will go through the `ONLINE` cycle. If we receive a
    `deviceDisconnect` event, the device will simply be removed from the list.

    *   `ONLINE` (as seen by adb): Device will be put in the state
    `CONNECTED_ONLINE` and will have its availability checked for test
    allocation: `checking_availability`.

1.  If `availability` check is successful, the device will be marked as
    available for test allocation; it will be able to run tests. If not, the
    device will be marked as `unavailable` for allocation and cannot receive any
    tests.

All of these states are reflected in the Tradefed console when listing the
devices via: `tf> list devices`

It's important to note that when the device is currently allocated for a test,
most of the above will not occur and Tradefed will determine the device state
internally. So it's possible for a device to disappear from `adb devices` while
still being listed by Tradefed. That can happen when a test is rebooting the
device for example.

## Virtual device connected via "adb connect"

When a remote virtual device is created, Tradefed connects to it using `adb
connect`. This will usually trigger the device showing in `adb devices` as
`<some ip>:<port number>` and will follow the same sequence as physically
connected devices.

## Device tracking when a `deviceConnected` event occurs

When `deviceConnected` occurs, `ddmlib` creates a new reference
[IDevice](https://android.googlesource.com/platform/tools/base/+/refs/heads/master/ddmlib/src/main/java/com/android/ddmlib/IDevice.java)
to track the newly connected device.

Tradefed uses that reference and wraps it in its own implementation of device
interface
[ITestDevice](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/device_build_interfaces/com/android/tradefed/device/ITestDevice.java)
to provide more advanced service. But the underlying IDevice is always the one
coming from `ddmlib`.

This means if a new device is connected, a new ITestDevice is created and
associated with the IDevice. When this happens during an invocation and the
ITestDevice is being used, the underlying IDevice is still replaced so
testing can proceed on the proper reference. This is done seamlessly each time a
device is disconnected/reconnected (for example, during a reboot).
