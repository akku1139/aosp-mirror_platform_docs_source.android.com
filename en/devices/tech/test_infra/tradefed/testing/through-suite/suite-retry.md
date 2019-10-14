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

# Use Suite Retry

A suite tends to include several test modules and can reach quite a large
test corpus size. For example, the [Android Compatibility Test Suite (CTS)](/compatibility/cts)
includes hundreds of modules and hundreds of thousands test cases.

It becomes possible for a large amount of tests to fail due to poor isolation
or devices going into a bad state.

The suite retry feature is meant to address those cases: It allows you to retry
the failures only instead of the full suites in order to rule out flakiness and
poor isolation. If a test is consistently failing, the retry will also fail; and
you get a much stronger signal that there is a real issue.

## Implement suite retry

The retry of results involves reading the previous results and re-running the
previous invocation.

The main interface driving the retry is [ITestSuiteResultLoader](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/suite/retry/ITestSuiteResultLoader.java),
which allows you to load a previous result, and the previous command line.

The [RetryRescheduler](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/suite/retry/RetryRescheduler.java)
then uses this information to recreate the previous command and populate some
filters in order to re-run only the previous failures or not executed tests.

## Example suite retry: CTS

The retry configuration in CTS is:

```xml
<configuration description="Runs a retry of a previous CTS session.">
    <object type="previous_loader" class="com.android.compatibility.common.tradefed.result.suite.PreviousResultLoader" />
    <test class="com.android.tradefed.testtype.suite.retry.RetryRescheduler" />

    <logger class="com.android.tradefed.log.FileLogger">
        <option name="log-level-display" value="WARN" />
    </logger>
</configuration>
```

This is applicable to most of the suites that extend it, for example
[VTS](/compatibility/vts)).

It would be invoked via:

```shell
cts-tradefed run retry --retry <session>
```

The session would be found by listing the previous results in the CTS console:

```shell
cts-tf > l r
Session  Pass  Fail  Modules Complete  Result Directory     Test Plan  Device serial(s)  Build ID   Product
0        2092  30    148 of 999        2018.10.29_14.12.57  cts        [serial]          P          Pixel
```

The exact original command will be reloaded and re-run with extra filters. This
means that if your original command included some options, they would also
be part of the retry.

For example:

```shell
cts-tradefed run cts-dev -m CtsGestureTestCases
```

The retry of the above would always be bounded to `CtsGestureTestCases` since
we are retrying a command that involved only it.

## Configure retry for CTS-style suite

In order for the retry to work, the previous results need to be exported in
proto format. The following needs to be added:

```xml
<result_reporter class="com.android.compatibility.common.tradefed.result.suite.CompatibilityProtoResultReporter" />
```

This needs to be added to the XML configuration of the main command, and it will
result in a `test-record.pb` file to be created in the result folder.

The CTS retry then loads data from a combination of the `test-record.pb` and
the existing `test_result.xml` to prepare the retry invocation.
