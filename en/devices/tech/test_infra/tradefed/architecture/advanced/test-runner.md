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

# Structure of a Test Runner

Test Runner is the execution unit of the invocation flow. This is where tests
actually run.

## Interfaces

Test Runners are defined via the
[IRemoteTest interface](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/invocation_interfaces/com/android/tradefed/testtype/IRemoteTest.java),
which provides a simple `run` method to implement that will be called when the
tests is to run.

This allows the simplest definition of a test run to occur. But in practice,
test writers will need more information to properly write their tests, typically
build and device information. This is where the following interfaces come handy.

### Basic

These two interfaces are the most widely used today, as they represent the basic
needs of most tests.

*   [IBuildReceiver](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IBuildReceiver.java)
    allows the test to get the `IBuildInfo` object created at the
    [build provider](/devices/tech/test_infra/tradefed/architecture/build-provider/)
    step containing all the information and artifacts related to the test setup.
*   [IDeviceTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IDeviceTest.java)
    allows TF to receive the `ITestDevice` object that represents the device
    under test and provides an API to interact with it.

### Advanced

There are additional interfaces that allow more complex interaction between the
test harness and the test runner:

*   [ITestFilterReceiver](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/ITestFilterReceiver.java),
    which allows the test to receive a set of filters for running certain
    tests only. This is useful in running a subset of the tests.
*   [ITestCollector](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/ITestCollector.java),
    which allows a test runner to only dry-run the tests instead of actually
    executing them. This is useful in collecting the list of all test
    cases.

## Existing test runners

A variety of test runners already exists, some for major test types:

*   [AndroidJUnitTest / InstrumentationTest](/reference/tradefed/com/android/tradefed/testtype/AndroidJUnitTest)
    (associated with AJUR on the device side)
*   [GTest](/reference/tradefed/com/android/tradefed/testtype/GTest) (device and host side) with [googletest library](https://github.com/google/googletest)
*   [Host-driven tests](/reference/tradefed/com/android/tradefed/testtype/HostTest) (Java tests that execute on the host and call the device
    from there)
*   [Pure Java unit tests](/reference/tradefed/com/android/tradefed/testtype/HostTest) (our runner does both)
*   [Python tests](/reference/tradefed/com/android/tradefed/testtype/python/PythonBinaryHostTest)
*   [Google Benchmark tests](/reference/tradefed/com/android/tradefed/testtype/GoogleBenchmarkTest) with [benchmark library](https://github.com/google/benchmark)

A large number of custom test runners exist besides the above; they serve
specialized purposes for some functional testing, for example Boot Test.

## Writing new a test runner

More guidance of writing a new test runner is available in the
[writing tests section](/devices/tech/test_infra/tradefed/testing/through-tf/new-test-runner).
