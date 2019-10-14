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

# Test through Tradefed

Execution of tests in Tradefed is conducted by *test runners* that allow the
control of Android *devices* for necessary testing steps.

## 1. Write a new test runner

Here you will learn the basics that go into writing a new Tradefed test runner.
This is particularly useful if you plan to support a brand new type of test, and
you need a new runner to be developed from scratch.

See [Write a Tradefed Test Runner](new-test-runner) for instructions.

## 2. Write a shardable test runner

You may also learn how to make your test runner shardable. A shardable test
runner allows the infrastructure to distribute the full test execution over
several devices (collocated or not). This is useful when the corpus of
tests is large, and you want to parallelize the execution and speed completion.

See [Write an IRemoteTest test runner that can be sharded](sharded-runner) for
steps.

## 3. Write a host-driven test

Host-driven tests are a common use case where test execution is driven from
the host-side and queries the device as needed for the test. This is useful when
device operation required by the test affects the device state itself, for
example rebooting the device.

The test runner type can be used within Tradefed or when running through a
suite.

See [Write an Host-driven test in Trade Federation](host-driven-test) for
instructions.

## 4. Report metrics from tests

It's fairly common for a test to report metrics in addition to the execution
results. Depending on the test runner, there are several methods to report the
metrics.

See [Report metrics or data from a Tradefed test](report-metrics) for examples.

## 5. Automated log collection

Some logs are commonly used for debugging issues, for example: Logcat. So
Tradefed offers an automated mechanism to collect them easily.

See [Automated log on failure collection](log-on-failure) for use.

## 6. Automatic test retry

You may enable Tradefed to automatically retry failures or run some tests
several times in iterations.

See [Automatic Test Retry](auto-retry) for more details.
