Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
  Copyright 2018 The Android Open Source Project

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

# Test Development Workflow

To integrate tests into a platform continuous testing service, they should meet
the guidelines on this page and follow this recommended flow.

1.  Use the [Soong build system](https://android.googlesource.com/platform/build/soong/)
    for [Simple Test Configuration](/compatibility/tests/development/blueprints).
1.  Employ [Test Mapping](/compatibility/tests/development/test-mapping) to
    easily create pre- and post-submit test rules directly in the Android source tree.
1.  Run tests locally using [Atest](/compatibility/tests/development/atest).

## Test types

Supported test types are:

*   [Instrumentation tests](/compatibility/tests/development/instrumentation)
    support both functional and metrics tests. See
    [Test your app](https://developer.android.com/studio/test/){: .external} for
        general app testing guidance.
*   [Native tests](/compatibility/tests/development/native) support these types:
    *   [Native functional
        tests](/compatibility/tests/development/native-func-e2e) using the
        [gtest](https://github.com/google/googletest){: .external} framework
    *   [Native metric tests](/compatibility/tests/development/metrics.md) are
        native benchmark tests using
        [google-benchmark](https://github.com/google/benchmark){: .external}
*   [JAR host tests](/compatibility/tests/development/jar)
    using JUnit

Functional tests make assertions of pass or fail on test cases, while metrics
tests generally perform an action repeatedly to collect timing metrics.

With standardized input/output format, the need for customized result parsing
and post-processing per test is eliminated, and generic test harnesses can be
used for all tests that fit into the convention. See the [Trade Federation
Overview](/devices/tech/test_infra/tradefed) for the continuous test framework
included with Android.

## Test case guidelines

Test cases executed via continuous testing service are expected to be
**hermetic** meaning all dependencies are declared and provided with the tests.
See [Hermetic Servers on the Google Testing Blog](https://testing.googleblog.com/2012/10/hermetic-servers.html){: .external}
for an understanding of this principle. In short, hermetic tests require **no**:

* Google account sign-in
* connectivity configured (telephony/Wi-Fi/Bluetooth/NFC)
* test parameters passed in
* setup or tear down performed by test harness for a specific test case
