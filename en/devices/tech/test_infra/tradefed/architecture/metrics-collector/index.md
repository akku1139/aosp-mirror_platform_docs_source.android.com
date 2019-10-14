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

# Host-Driven Metrics Collector

Host-driven metrics collectors run on the host and not on the device side. They
interact with the device from the host side to collect the metrics they are
targeting.

## Metrics collector design

The base class that all collectors will extend is
[BaseDeviceMetricCollector](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/device/metric/BaseDeviceMetricCollector.java),
which helps provide the same shared basic functionalities:

*   Filtering
*   Disabling
*   Collection on test cases vs. test runs

Collectors follow a [result reporter](/devices/tech/test_infra/tradefed/architecture/result-reporter)
model since they synchronize with the test execution on the host. In other
words, if tests are host-driven, collectors will be executed before the test
proceeds to the next execution step.

For example, if the collector executes on `testEnded`, before the execution
proceeds to the next test with `testStart` the collector(s) will execute.

## Implement a host-driven metrics collector

When implementing on top of the base class `BaseDeviceMetricCollector` you
may decide when you would like to collect your metrics during the lifecycle:

*   When a test run starts: `onTestRunStart`
*   When a test case starts: `onTestStart`
*   When a test case ends: `onTestEnd`
*   When a test run ends: `onTestRunEnd`

## How to do asynchronous collection

In addition to the synchronous methods, TF provides a base class to implement
that performs periodic asynchronous collection,
[ScheduledDeviceMetricCollector](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/test_framework/com/android/tradefed/device/metric/ScheduledDeviceMetricCollector.java),
which provides a `collect` method to be implemented that will be run
periodically.

The period is customizable by options.

## XML configuration

The object tag will be `metrics_collector`, for example:

```xml
<metrics_collector class="com.android.tradefed.device.metric.AtraceCollector">
    <option name="categories" value="freq"/>
</metrics_collector>
```

## Recommendations

First take a look at the [existing list of collectors](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/test_framework/com/android/tradefed/device/metric)
to ensure you are not duplicating work. We try to ensure maximum reusability, so
having each collector performing a single type of collection allows more mixing
and matching of different collectors during test execution.
