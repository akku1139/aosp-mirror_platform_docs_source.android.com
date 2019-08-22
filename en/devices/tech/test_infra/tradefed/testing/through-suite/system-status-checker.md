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

# Check System Status

System status checkers (SSCs) are defined at the suite-level configuration and
run between each module. They perform checks to determine if the module changed
and didn't restore some given states, for example changing a system property
value.

SSCs are mainly used to ensure that module writers do not forget to clean up
after their tests; but if they do, provide a trace of it so it can be addressed.

A secondary use is to also restore the original state when possible, for
example dismissing the keyguard if it was left open.

## System status checker XML definition

```xml
<system_checker class="com.android.tradefed.suite.checker.KeyguardStatusChecker" />
<system_checker class="com.android.tradefed.suite.checker.LeakedThreadStatusChecker" />
```

SSCs are defined under the `system_checker` tag in the Tradefed configuration
XML.

## Implementation

Every SSC must implement the
[ISystemStatusChecker interface](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/suite/checker/ISystemStatusChecker.java),
which provides the two main methods `preExecutionCheck` and `postExecutionCheck`
running before and after each module execution.

It is possible for a checker to implement only one of the two, or to implement
both if there is a need to check the state before the module and compare it
to the state after the module.

Several [example implementations](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/suite/checker)
exist in Tradefed. Each implementation is recommended to focus on a single check
to improve re-usability.

Each operation returns a
[StatusCheckerResult](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/suite/checker/StatusCheckerResult.java)
that allows the harness to decide if additional information, like a bugreport,
should be captured.

## Where are they defined in CTS?

CTS system status checkers are defined in:
[/test/suite_harness/tools/cts-tradefed/res/config/cts-system-checkers.xml](https://android.googlesource.com/platform/test/suite_harness/+/refs/heads/master/tools/cts-tradefed/res/config/cts-system-checkers.xml)

## How to find checker failures

By default, system checker failures show only in the logs and as bugreports
captured for the invocation with name following the format:
`bugreport-checker-post-module-<module name>.zip`

This allows you to find out after which module the bugreport was generated.

It is possible to make the system checker report as a test failure itself by
setting the `--report-system-checkers` option to `true`. This will result in
a test run showing as failed with the reason for failure being the status
checker particular check.
