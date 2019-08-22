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

# Device-Side Metric Collection

When running device-side tests (instrumentations, UI Automator tests, etc.),
host-side collectors might not be ideal because it is difficult to synchronize
metric collection to a test running on a device. For example, a screenshot
taken asynchronously will most likely miss the wanted screen and be useless.

In order to meet these use cases, a device-side version of our collectors exists
and can be used in any 'AndroidJUnitRunner' instrumentation.
[BaseMetricListener](https://android.googlesource.com/platform/platform_testing/+/refs/heads/master/libraries/device-collectors/src/main/java/android/device/collectors/BaseMetricListener.java)
can be implemented in order to automatically report metrics that are collected
in a way fully compatible with the Tradefed reporting pipeline.

This library is decoupled from Tradefed itself and can be used without Tradefed.

If you are using the '[AndroidJUnitTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/AndroidJUnitTest.java)'
runner from Tradefed, you can simply specify the following command line option
to have your collector running with your tests:

```shell
  --device-listeners android.device.collectors.ScreenshotListener
```

CAUTION: In order for the collector classes to be resolved at runtime, your
instrumentation APK will most likely need to statically include them by adding
the following to your makefile:

```shell
  LOCAL_STATIC_JAVA_LIBRARIES += collector-device-lib
```

## Implementation

When implementing on top of the base class `BaseMetricListener`, you may choose
when you would like to collect your metrics during the lifecycle of the
instrumentation:

*   When a test run starts: `onTestRunStart`
*   When a test case starts: `onTestStart`
*   When a test case ends: `onTestEnd`
*   When a test case fails: `onTestFail`
*   When a test run ends: `onTestRunEnd`

## Interaction

The collection of metrics on the device side is made synchronously to the
instrumentation execution itself, and metrics are passed back to the
instrumentation results and parsed by Tradefed to be reported as part of the
invocation.
