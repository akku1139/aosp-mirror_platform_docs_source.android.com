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

# Handling log files from a Result Reporter

In some cases, having access to only the test results is not enough; having
the log files is necessary to complete the overall results.

## Log interface

Any result reporter or [test event](/devices/tech/test_infra/tradefed/architecture/result-reporter#core_interface)
can have access to the logs by implementing
[ILogSaverListener](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/invocation_interfaces/com/android/tradefed/result/ILogSaverListener.java),
which allows a reporter to receive the logs through different callbacks:

*   `testLogSaved`: Called right away when a file is logged. This notifies a
    new file has been logged. This is called at any time.
*   `logAssociation`: Called in order with the test events. This ensures
    strong association between the file being logged and the events in progress.

By implementing this interface, the result reporter can have access to the
logged file references and use them.

## When to use logAssociation

`logAssociation` is a slightly more complicated event as it relies on the
context of the events to be properly interpreted. For example, if the
`testStart` has been called, the log from `logAssociation` belongs to the test
case in progress.

This strong association allows correct placement of logs.
