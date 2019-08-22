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

# Result Reporter Summary

Result reporters have the ability to generate a summary through their
`getSummary` callback.

It is possible for other result reporters to have access to all summaries
through the
[ITestSummaryListener interface](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/result/ITestSummaryListener.java),
which allows them to use other reporters' results.

NOTE: Result reporters run in order of definition in the Tradefed XML
configuration. So a reporter usually only has access to summaries of reporters
running before itself. This is not a very common scenario, and is used in
limited ways by core result reporters.
