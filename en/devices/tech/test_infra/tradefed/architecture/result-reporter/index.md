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

# Creating a new Result Reporter

This section describes the basics of how to implement a new result reporter and
configure it for a test.

## Core interface

In order to define a new result reporter in Tradefed, a class must implement
the
[ITestInvocationListener](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/result/ITestInvocationListener.java)
interface that allows receiving and handling different stages of the
invocation:

*   invocationStarted
*   invocationEnded
*   invocationFailed

Result reporters also handle the different stages of each test run:

*   testRunStarted
*   testStarted
*   testFailed/testIgnored
*   testEnded
*   testRunFailed
*   testRunEnded

Given all these events, there are two main types of result reporters, those that:

*   Care only about reporting the final complete results.
*   Take action on partial results.

### Result Reporter that reports final complete results

This type is the most common case when it comes to interacting with an external
service that receives the results. The reporter simply receives and accumulates
the results and then sends them all on `invocationEnded` to the result end-point.

It is recommended those reporters extend `CollectingTestListener` instead
of the base interface in order to avoid re-implementing saving and storing the
results until `invocationEnded`.

### Result Reporter that reports partial results

This type is usually used for a streaming approach of the results, when results
are received and pushed to some other places right away. For example, a reporter
that logs the results to the console would be of this type.

This type is specific to which type of handling is required on the events,
so implementing the base interface is usually the recommended way.

### XML configuration

The object tag will be `result_reporter`. For example:

```xml
<result_reporter class="com.android.tradefed.result.ConsoleResultReporter">
    <option name="suppress-passed-tests" value="true"/>
</result_reporter>
```
