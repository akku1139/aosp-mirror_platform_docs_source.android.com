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

# Write a Tradefed Test Runner

This page describes how to write a new test runner in Tradefed.

## Background

If you are curious about the place of test runners in the Tradefed architecture,
see [Structure of a Test Runner](/devices/tech/test_infra/tradefed/architecture/advanced/test-runner).

This is not a prerequisite to writing a new test runner; test runners can be
written in isolation.

## Bare minimum: Implementing the interface

The bare minimum to qualify as a Tradefed test runner is to implement the
[IRemoteTest interface](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IRemoteTest.java)
and more specifically the `run(ITestInvocationListener listener)` method.

This method is the one invoked by the harness when using the test runner,
similar to a Java Runnable.

Every part of that method is considered part of the test runner execution.

### Reporting results from the test runner

The `run` method in the base interface give access to a listener object of
type `ITestInvocationListener`. This object is the key to reporting structured
results from the test runner to the harness.

By reporting structured results, a test runner has the following properties:

*   Report a proper list of all the tests that ran, how long they took and if
    they individually passed, failed or some other states.
*   Report metrics associated with the tests if applicable, for example
    installation-time metrics.
*   Fit in most of the infrastructure tooling, for example display results and
    metrics, etc.
*   Usually easier to debug since there is a more granular trace of the
    execution.

That said, reporting structured results is optional; a test runner might
simply want to assess the state of the entire run as PASSED or FAILED without
any details of the actual execution.

NOTE: It is more difficult to implement a runner that follows the sequence of
events, but we do recommend doing so given the benefits listed above.

The following events can be called on the listener to notify the harness of the
current progress of executions:

*   testRunStarted: Notify the beginning of a group of test cases that are
    related together.
    *   testStarted: Notify the beginning of a test case starting.
    *   testFailed/testIgnored: Notify the change of state of the test case
        in progress. A test case without any change of state is considered
        passed.
    *   testEnded: Notify the end of the test case.
*   testRunFailed: Notify that the overall status of the group of test cases
    execution is a failure. A *test run* can be a *pass* or a *fail*
    **independently of the test cases results** depending on what the
    execution was expecting. For example, a binary running several test cases
    could report all *pass* test cases but with an error exit code (for any
    reasons: leaked files, etc.).
*   testRunEnded: Notify the end of the group of test cases.

Maintaining and ensuring the proper order of the callbacks is the
responsibility of the test runner implementer, for example ensuring that
`testRunEnded` is called in case of exception using a `finally` clause.

Test cases callbacks (`testStarted`, `testEnded`, etc.) are optional. A test
run might occur without any test cases.

You might notice that this structure of events is inspired from
[typical JUnit structure](https://junit.org/junit4/javadoc/4.12/org/junit/runner/notification/RunListener.html).
This is on purpose to keep things close to something basic that developers
usually have knowledge about.

### Reporting logs from the test runner

If you are writing your own Tradefed test class or runner, you will implement
[IRemoteTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IRemoteTest.java)
and get a `ITestInvocationListener` through the `run()` method. This listener
can be used to log files as follows:

```java
    listener.testLog(String dataName, LogDataType type_of_data, InputStreamSource data);
```

## Testing with a device

The minimum interface above allows to run very simple tests that are isolated
and do not require any particular resources, for example Java unit tests.

Test writers who want to go to the next step of *device testing* will need the
following interfaces:

*   [IDeviceTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IDeviceTest.java)
    allows to receive the `ITestDevice` object that represents the device under
    test and provides the API to interact with it.
*   [IBuildReceiver](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IBuildReceiver.java)
    allows the test to get the `IBuildInfo` object created at the
    [build provider step](/devices/tech/test_infra/tradefed/architecture/build_provider)
    containing all the information and artifacts related to the test setup.

Test runners are usually interested in these interfaces in order to get
artifacts related to the execution, for example extra files, and get the
device under test that will be targeted during the execution.

### Testing with multiple devices

Tradefed supports running tests on multiple devices at the same time. This is
useful when testing components that require an external interaction, like a
phone and a watch pairing.

In order to write a test runner that can use multiple devices, you will need
to implement the
[IMultiDeviceTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IMultiDeviceTest.java),
which will allow to receive a map of `ITestDevice` to `IBuildInfo` that contains
the full list of device representations and their associated build information.

The setter from the interface will always be called before the `run` method, so
it's safe to assume that the structure will be available when `run` is called.

### Tests aware of their setups

NOTE: This is not a very common use case. It is documented for completeness,
but you will not usually need it.

Some test runner implementations might need information about the overall setup
in order to work properly, for example some metadata about the invocation, or
which `target_preparer` ran before, etc.

In order to achieve this, a test runner can access the `IConfiguration` object
it is part of and that it's executed in. See the
[configuration object](/devices/tech/test_infra/tradefed/architecture/xml-config/config-object)
description for more details.

For the test runner implementation, you will need to implement the
[IConfigurationReceiver](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/config/IConfigurationReceiver.java)
to receive the `IConfiguration` object.

## Flexible test runner

Test runners can provide a flexible way of running their tests if they have a
granular control over them, for example a JUnit tests runner can individually
run each unit test.

This allows the larger harness and infrastructure to leverage that fine control
and users to run partially the test runner via *filtering*.

Filtering support is described in the
[ITestFilterReceiver interface](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/ITestFilterReceiver.java),
which allows to receive sets of `include` and `exclude` filters for the tests
that should or should not run.

Our convention is that a test will be run IFF it matches one or more of the
include filters AND does not match any of the exclude filters. If no include
filters are given, all tests should be run as long as they do not match any of
the exclude filters.

NOTE: We encourage test runners to be written in a way that supports this
filtering as it provides a huge added value in the larger infrastructure. But
we understand that in some cases it's not possible to do so.
