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

# How to report metrics or data from a Tradefed test

This page describes how to report metrics along with test results when writing
a test in Tradefed.

The benefit of logging through Tradefed pipeline is to find your metrics along
side your functional results. The logging of metrics can be done very naturally
within tests, which makes it convenient for test writers to add more
instrumentation.

## DeviceTestCase - JUnit3 style

If your test extends [DeviceTestCase](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/DeviceTestCase.java)
in a JUnit3-style kind of test, you can call the method
`addTestMetric(String key, String value)` from inside any test cases to report
a metric. This can be called multiple times as long as the key is unique.

Example:

```java
    public static class TestMetricTestCase extends DeviceTestCase {

        public void testPass() {
            addTestMetric("key1", "metric1");
        }

        public void testPass2() {
            addTestMetric("key2", "metric2");
        }
    }
```

If you want to log a file to be available in the `result_reporters`, you can
call the method `addTestLog(String dataName, LogDataType dataType, InputStreamSource dataStream)`
from inside any test cases to report a file to log.

Example:

```java
    public static class TestLogTestCase extends DeviceTestCase {

        public void testPass() {
            try (InputStreamSource source = getDevice().getScreenshot()) {
                addTestLog("screenshot", LogDataType.PNG, source);
            }
        }
    }
```

## TestCase - regular JUnit3 test

If you want to report metrics inside Tradefed from a regular JUnit3 TestCase
class, it will need to be converted to a `MetricTestCase` instead which is the
exact same class with an extra method: `addTestMetric(String key, String value)`

## DeviceJUnit4ClassRunner - JUnit4 style

If your JUnit4 style test is running with
[DeviceJUnit4ClassRunner](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/DeviceJUnit4ClassRunner.java),
then you can also log metrics within a test case (inside @Test) to be reported
by Tradefed. You will need to use `TestMetrics` rules to report your metrics.

Example:

```java
    @RunWith(DeviceJUnit4ClassRunner.class)
    public static class Junit4TestClass {

        @Rule
        public TestMetrics metrics = new TestMetrics();

        @Test
        public void testPass5() {
            // test log through the rule.
            metrics.addTestMetric("key", "value");
        }

        @Test
        public void testPass6() {
            metrics.addTestMetric("key2", "value2");
        }
    }
```

In order to report files, you will use the `TestLogData` rule to report it.

Example:

```java
    @RunWith(DeviceJUnit4ClassRunner.class)
    public static class Junit4TestClass {

        @Rule
        public TestLogData logs = new TestLogData();

        @Test
        public void testPass5() {
            // test log through the rule.
            try (InputStreamSource source = getDevice().getScreenshot()) {
                logs.addTestLog("screenshot", LogDataType.PNG, source);
            }
        }
    }
```

## IRemoteTest - pure Tradefed Test

If you are writing your own Tradefed Test class or runner you will implemement
[IRemoteTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IRemoteTest.java)
and get a `ITestInvocationListener` through the `run()` method. This listener
can be used to log metrics as follows:

```java
    listener.testLog(String dataName, LogDataType type of data, InputStreamSource data);
```

## Tradefed metrics collectors

Tradefed provides a dedicated `metrics_collector` object to collect metrics in
parallel of the tests.

### On the host side

[BaseDeviceMetricCollector](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/device/metric/BaseDeviceMetricCollector.java)
can be implemented to collect any metrics from the host-side and report them
as part of the test invocation. A number of generic collectors are already
available for different use cases, but we always welcome new contributions.

In order to specify the collector to be used in your Tradefed invocation, you
simply need to add the object to your Tradefed XML configuration:

Example:

```xml
  <metrics_collector class="com.android.tradefed.device.metric.AtraceCollector">
      <option name="categories" value="freq"/>
  </metrics_collector>
```

Some currently existing collectors:
*   [TemperatureCollector](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/device/metric/TemperatureCollector.java)
that collects the temperature periodically during the test run.
*   [AtraceCollector](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/device/metric/AtraceCollector.java)
that collects using 'atrace' for each test case.

### On the device side

When running device-side tests (Instrumentations, UIAutomator tests, etc.),
having a collector on the host-side collecting asynchronously might not be
ideal. For example, a screenshot taken asynchronously will most likely miss the
wanted screen and be useless.

In order to meet these use cases, a device-side version of our collectors exists
and can be use in any 'AndroidJUnitRunner' instrumentation.
[BaseMetricListener](https://android.googlesource.com/platform/platform_testing/+/refs/heads/master/libraries/device-collectors/src/main/java/android/device/collectors/BaseMetricListener.java)
can be implemented in order to automatically report metrics that are collected
in a way fully compatible with the Tradefed reporting pipeline.

If you are using the '[AndroidJUnitTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/AndroidJUnitTest.java)'
runner from Tradefed, you can simply specify the following command line option
to have your collector running with your tests:

```shell
  --device-listeners android.device.collectors.ScreenshotListener
```

CAUTION: In order for the collector classes to be resolved at runtime, your
instrumentation APK will most likely need to statically include them by adding
to your makefile the following:

```shell
  LOCAL_STATIC_JAVA_LIBRARIES += collector-device-lib
```

Contributions to device-side collectors are also welcome.

### Special consideration for suites

For suites like CTS that have a top-level configuration running some module
configurations, there is no need to specify `metrics_collector` in each module
configuration (`AndroidTest.xml`). It is actually forbidden.

To ensure the metric collection is applied equally to each module,
only the top-level configuration (for example, `cts.xml`) can specify
`metrics_collector` as explained above. These collectors will be applied and run
against each module of the suite.

### How to collect device log files from a module?

A setup is available in order for a device side test to notify that some files
should be collected.

`AndroidTest.xml` can specify a collector that will look for file on the
device and pull them.

```xml
  <metrics_collector class="com.android.tradefed.device.metric.FilePullerLogCollector">
      <!-- repeatable: Pattern of key of a FILE we listen on that should be pulled -->
      <option name = "pull-pattern-keys" value = "ScreenshotListener_.*" />

      <!-- repeatable: The key of the DIRECTORY to pull -->
      <option name = "directory-keys" value = "<example-key: /sdcard/atrace_logs>" />
  </metrics_collector>
```

By specifying these patterns and key, the collector if it sees the key will
attempt to pull and log the associated file.

In order for these keys to be generated, a device-side test (instrumentation)
should specify the file that should be logged. It is done in a similar
manner as the host-side (described above).

1.  Add the `collector-device-lib` to your test APK in the make files:

```shell
  LOCAL_STATIC_JAVA_LIBRARIES += collector-device-lib
```

1.  Use the @rule we provide to log files:

```java
    @RunWith(AndroidJUnit4.class)
    public static class Junit4TestClass {

        @Rule
        public TestLogData logs = new TestLogData();

        @Test
        public void testPass5() {
            // test log through the rule.
            File logFile = new File("whatever");
            logs.addTestLog("KEY", logFile);
        }
    }
```

The `KEY` name in the example above is the name under which the file will be
reported. This is the name you should match in the
`FilePullerDeviceMetricCollector` to get it automatically pulled. it should be
a unique name.

NOTE: Once the file is pulled, `FilePullerDeviceMetricCollector` automatically
cleans it from the device.

## Where to find the metrics?

It depends of the `result_reporter` specified in your XML configuration.
