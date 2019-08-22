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

This page is intented for Trade Federation's users who wants to use TF with
multiple devices during their tests. This is an advanced use case of TF and we
recommend being familiar with
[normal usage](https://source.android.com/devices/tech/test_infra/tradefed/fundamentals/full_example).

[TOC]

## What is different with multiple devices?

Several things are different when configuring and running multi-device tests
in Trade Federation, in particular:

*   [XML configurations](https://source.android.com/devices/tech/test_infra/tradefed/architecture/xml-config)
*   [Command line options](https://source.android.com/devices/tech/test_infra/tradefed/fundamentals/options)

It's worth mentioning that any existing one-device configuration should work
exactly the same as before but can also work as a special one device use case
in respect to everything described in this page.

### Multiple Device Configuration

We will assume that you are already familiar with the typical TF test
configuration.

Here is what a typical test configuration with 2 devices would look like:

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
    `<device_requirements>`, `<device_options>` if they are needed, are expected
    to be inside the `<device>` tag, an exception will be thrown otherwise.
*   the `name` attribute for `<device>` is mandatory and should be unique among
    all the devices present in the configuration. It is used to reference the
    particular device associated to it. You will be able in your test to use
    this name to target a particular device.
*   `<option>` can have global scope when at the root of the configuration or
    only a device scope when specified inside the `<device>` tag.

Every other rules that were applicable to single device configuration is still
applicable.

[See the Hello World example for more details.](#multi_devices_hello_world_example)

### Command line update

When specifying options on the TF command line, it is now also possible to
specify a device scope using `{<device name>}`. Where `<device name>` is the
name specified in the XML configuration.

In the example above the following options were allowed:

*   `--com.android.tradefed.targetprep.DeviceSetup:disable`
*   `--device-setup:disable`

It is now also possible to target only one of the device `build_provider`
objects using the device name:

* `--{device2}device-setup:disable`

In this example, only `device2` will skip the device setup.

### How is TF going to select the devices?

In order of device appearance in the configuration, Trade Federation will look
for a device matching the `device_requirements` (typically the device flavor,
product, etc.). Each time a device is allocated it tries to allocate the next
one, if it is not possible to allocate all the devices, they will all be
released and the command will be re-attempted when all devices are matched.

[See the Hello World example for more details.](#example)

### How is TF going to prepare the devices?

The preparation step of devices will be mostly the same as before, each device
will be prepared calling the `<target_preparer>` in order of appearance inside
the `<device>`.

A new addition has been made with `<multi_target_preparer>` which is specified
at the root of the configuration and allows for preparation steps that requires
multiple devices, like pairing of devices. It runs *after* the `target_preparer`
step.

An alternative is `<pre_multi_target_preparer>` that runs *before* the
`target_preparer` step.

### I want to write a multi-device test!

When writing a regular single-device test, you used to implement the
[IDeviceTest](https://source.android.com/reference/tradefed/com/android/tradefed/testtype/IDeviceTest)
interface. You can now implement the
[IMultiDeviceTest](https://source.android.com/reference/tradefed/com/android/tradefed/testtype/IMultiDeviceTest)
to receive a map of all the devices allocated and the
[IBuildInfo](https://source.android.com/reference/tradefed/com/android/tradefed/build/IBuildInfo)
associated or you can also implement the
[IInvocationContextReceiver](https://source.android.com/reference/tradefed/com/android/tradefed/testtype/IInvocationContextReceiver)
to receive the full invocation metadata for your test.

You will then be able to use the usual
[ITestDevice](https://source.android.com/reference/tradefed/com/android/tradefed/device/ITestDevice)
APIs that TF put at disposition for test writing.

We haven't added any APIs to do operation from one device to another like
`device1.sync(device2)` since we are not sure of all the current use cases. If
you think you have a compeling use case for us to add that could benefit
everybody, please reach out to us on the
[android-platform](https://groups.google.com/forum/?fromgroups#!forum/android-platform)
list.

### Multi devices hello world Example

We added a Hello World-like example configuration:
[multi-devices.xml](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/master/res/config/example/multi-devices.xml)
There is also an example of `multi_target_preparer` implementation
[HelloWorldMultiTargetPreparer](https://source.android.com/reference/tradefed/com/android/tradefed/targetprep/multi/HelloWorldMultiTargetPreparer)
that shows how to receive the list of devices and their builds.

This is a full example that involves:

*   Allocating two devices
*   Have a multi_target_preparer accessing both devices
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
via `adb devices`.

When the invocation is in progress you can monitor it like before using `list i`
and `list d`:

```none
tf >list i
Command Id  Exec Time  Device                          State
1           0m:35      [00b4e73b4cbcd162, LP5A390056]  fetching build
tf >list d
Serial            State      Product   Variant   Build   Battery
00b4e73b4cbcd162  Allocated  bullhead  bullhead  NRD90O  100
LP5A390056        Allocated  shamu     shamu     NRD90I  100
```

You should be able to see all the devices involved in each invocation, and all
the devices and their respective state.

Note that in this example we called the two devices in the configuration
`device1` and `device2`, you should give a more descriptive name if possible
depending on the type of device you are really expecting to be set.
