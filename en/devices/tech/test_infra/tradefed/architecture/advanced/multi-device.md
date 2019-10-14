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

# Run Tests with Multiple Devices

This page helps you use the Trade Federation Test Harness with multiple devices
during testing. This is an advanced use case of TF. You should first become
familiar with normal usage as described in the
[end-to-end example](/devices/tech/test_infra/tradefed/fundamentals/full_example).

## What is different with multiple devices?

Several things are different when configuring and running multi-device tests
in Trade Federation, in particular:

*   [XML configurations](/devices/tech/test_infra/tradefed/architecture/xml-config)
*   [Command line options]/devices/tech/test_infra/tradefed/fundamentals/options)

Any existing one-device configuration is valid for multi-device mode.

TODO: Clarify the sentence immediately above by adding an example of a
one-device use case as it pertains to multi-device mode in a second sentence.

## Multiple device configuration

This document assumes you are already familiar with the typical TF test
configuration. Here is what a typical test configuration with two devices looks
like:

```xml
<configuration description="A simple multi-devices example in Tradefed">

    <device name="device1">
        <target_preparer class="com.android.tradefed.targetprep.DeviceSetup" />
    </device>

    <device name="device2">
        <target_preparer class="com.android.tradefed.targetprep.DeviceSetup" />
    </device>

    <option name="log-level" value="verbose" />
    <test class="com.android.tradefed.HelloWorldMultiDevices" />

    <logger class="com.android.tradefed.log.FileLogger" />
    <result_reporter class="com.android.tradefed.result.ConsoleResultReporter" />

</configuration>
```

Several things need to be mentioned about the structure:

*   For each device that will be needed, a `<device>` is expected.
*   `<build_provider>`, `<target_preparer>`, `<device_recovery>`,
    `<device_requirements>`, and `<device_options>` if needed must be included
    within the `<device>` tag; an exception will be thrown otherwise.
*   the `name` attribute for `<device>` is mandatory and should be unique among
    all the devices present in the configuration. It is used to reference the
    particular device associated with it. This allows your test to target a
    particular device.
*   `<option>` can have either a global scope when at the root of the
    configuration or be limited to device scope when specified inside the
    `<device>` tag.

All other rules applicable to single-device configuration are still applicable
here. See the [Hello World example](#multi_devices_hello_world_example) below
for more details.

## Command line update

When specifying options on the TF command line, it is also possible to
specify a device scope using `{<device name>}` where `<device name>` is the
name specified in the XML configuration.

In the example above, the following options were allowed:

*   `--com.android.tradefed.targetprep.DeviceSetup:disable`
*   `--device-setup:disable`

You may target only one of the device `build_provider` objects using the device
name, like so:

`--{device2}device-setup:disable`

In this example, `device2` skips the device setup while `device1` doesn't.

## How does TF select the devices?

Trade Federation looks for a device matching the `device_requirements`
(typically the device flavor, product, etc.) in order of device appearance in
the configuration. Each time a device is allocated, TF tries to allocate the
next one. If it is not possible to allocate all of the devices, they will all be
released and the command will be re-attempted when all devices are matched.

## How does TF prepare the devices?

The preparation step for multi-devices is mostly the same as for single devices.
Each device is prepared by calling the `<target_preparer>` in order of
appearance inside the `<device>`.

You may also use `<multi_target_preparer>` specified at the root of the
configuration that enables preparation steps requiring multiple devices, such as
pairing of devices. It runs *after* the `target_preparer` step.

An alternative is `<pre_multi_target_preparer>` that runs *before* the
`target_preparer` step.

*   `<pre_multi_target_preparer>` should be used for setup that *must* be done
    before individual device setup.
*   `<multi_target_preparer>` should be used for setup that must be done after
    individual device setupts.

For examples:
  flash device 1 (target_preparer)
  flash device 2 (target_preparer)
  bluetooth connect both devices (multi_target_preparer)

## Write a multi-device test

When writing a regular single-device test, you implement the
[IDeviceTest](/reference/tradefed/com/android/tradefed/testtype/IDeviceTest)
interface.

For the tests to receive the devices under test, you can implement either
[IMultiDeviceTest](/reference/tradefed/com/android/tradefed/testtype/IMultiDeviceTest) or [IInvocationContextReceiver](/reference/tradefed/com/android/tradefed/testtype/IInvocationContextReceiver).

IMultiDeviceTest gives you a direct map of device to its
[IBuildInfo](/reference/tradefed/com/android/tradefed/build/IBuildInfo) while
IInvocationContextReceiver later gives you the complete context
(device, IBuildInfo & metadata).

You will then be able to use the usual
[ITestDevice](/reference/tradefed/com/android/tradefed/device/ITestDevice)
APIs that TF put at disposition for test writing.

No APIs yet exist to conduct operations from one device to another, such as
`device1.sync(device2)`. If you think you have a compeling use case to be
supported, send your reasoning to the
[android-platform](https://groups.google.com/forum/?fromgroups#!forum/android-platform)
list.

## Multi devices hello world Example

We added a Hello World-like example configuration:
[multi-devices.xml](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/master/res/config/example/multi-devices.xml)
There is also an example of `multi_target_preparer` implementation
[HelloWorldMultiTargetPreparer](/reference/tradefed/com/android/tradefed/targetprep/multi/HelloWorldMultiTargetPreparer)
that shows how to receive the list of devices and their builds.

This is a full example that involves:

*   Allocating two devices
*   Accessing both devices through a `multi_target_preparer`
*   Running a test that use the two devices

Once you have built Tradefed, you can use the following command in TF shell:

`run example/multi-devices`

You should see some output containing the following:

```none
08-15 10:52:43 I/HelloWorldMultiDevices: Hello World! device '00b4e73b4cbcd162' with build id '3146108'
08-15 10:52:43 I/HelloWorldMultiDevices: Hello World! device 'LP5A390056' with build id '3146108'
08-15 10:52:43 I/HelloWorldMultiDevices: Hello World! device '00b4e73b4cbcd162' from context with build 'com.android.tradefed.build.DeviceBuildInfo@c99cbc1'
08-15 10:52:43 I/HelloWorldMultiDevices: Hello World! device 'LP5A390056' from context with build 'com.android.tradefed.build.DeviceBuildInfo@b41f20c5'
```

You need two devices connected in order to run the above. This can be checked
via: `adb devices`

When the invocation is in progress, you can monitor it like single devices with
`list i` and `list d`:

```none
tf >list i
Command Id  Exec Time  Device                          State
1           0m:35      [00b4e73b4cbcd162, LP5A390056]  fetching build
tf >list d
Serial            State      Product   Variant   Build   Battery
00b4e73b4cbcd162  Allocated  bullhead  bullhead  NRD90O  100
LP5A390056        Allocated  shamu     shamu     NRD90I  100
```

You should be able to see the devices involved in each invocation, as well as
all of the available devices and their respective state.

Note that in this example we called the two devices in the configuration
`device1` and `device2`; you should give a more descriptive name if possible
depending on the type of device you are really expecting to be set.
