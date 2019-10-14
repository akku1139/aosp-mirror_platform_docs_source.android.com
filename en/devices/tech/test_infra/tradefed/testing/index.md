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

# Write and Run Tradefed Tests

This section is aimed at developers, or test writers, providing guidance on test
execution, as well as writing tests. The instructions are split into two broad
categories of tests:

*   Tests executing
    [directly through Tradefed](through-tf/).
*   Tests executing in the
    [context of a suite](through-suite/),
    for example the
    [Android Compatibility Test Suite (CTS)](/compatibility/cts).

We detail some features that are applicable to both suite and non-suite tests,
for example:

*   [Automatic Retries](through-tf/auto-retry) for tests.

We also provide some generic end-to-end examples about how to run some of the
more common test types, such as:

*   Execute the [instrumentation tests from an existing APK](through-tf/instrumentation).

The end-to-end examples above do not require a local checkout of Android. You
can simply
[download Tradefed](/devices/tech/test_infra/tradefed/fundamentals/machine_setup#download-tradefed)
and use them directly.
