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

# Test Command Scheduler

In Tradefed, every single test request goes through the
[Command Scheduler](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/command/CommandScheduler.java)
to be run. So the Command Scheduler is a key component of the harness needed to
run tests.

## Life Cycle

When a test request is presented to Tradefed (for example, input from the
console), it will go through the following events before being run:

1.  *Test request is parsed*  - A test request is usually composed of an XML
    Tradefed configuration reference followed by options.
    For example: `> run host --class com.android.tradefed.build.BuildInfoTest`
1.  *Device Manager is requested for device(s) matching the test request* -
    Device Manager [allocates a device](/devices/tech/test_infra/tradefed/architecture/device-manager/device-allocation)
    that matches the test requests. For example, if a Pixel device is requested
    then Device Manager will look for an available Pixel device.
1.  *Test request + device(s) starts as an invocation* - Testing is starting.
1.  *Device release* - Once the invocation is finished, the device allocated will
    be released and can be allocated for other tests.

## Tradefed invocation

An invocation in Tradefed refers to when a test command is currently executing.
Devices included in the invocation are marked as `allocated` and cannot be used
by other tests to run.

TF will execute the following steps in this order:

1.  [Build and test artifacts download](/devices/tech/test_infra/tradefed/architecture/build-provider)
1.  [Target preparation](/devices/tech/test_infra/tradefed/architecture/target-preparer)
1.  [Test execution](/devices/tech/test_infra/tradefed/architecture/advanced/test-runner)
1.  [Target clean up](/devices/tech/test_infra/tradefed/architecture/target-preparer)
1.  [Result reporting](/devices/tech/test_infra/tradefed/architecture/result-reporter)

Each step is described in more detail within the
[Architecture section](/devices/tech/test_infra/tradefed/architecture).
