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

# Target Preparers

Target Preparers are invoked before the tests in the
[test level](/devices/tech/test_infra/tradefed/testing/through-suite/setup#definitions)
in which they are defined. This allows the setup of any device for tests to run
smoothly.

## Base interface

The base interface is
[ITargetPreparer](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/targetprep/ITargetPreparer.java),
which allows implementation of a `setUp` method that will be executed. We
recommend implementing our basic abstract class
[BaseTargetPreparer](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/targetprep/BaseTargetPreparer.java),
which provides a built-in disablement feature to easily disable a preparer.

## Cleaner interface

The natural extension of `setUp` is `tearDown` and is provided by a different
interface
[ITargetCleaner](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/targetprep/ITargetCleaner.java). That provides the `tearDown` interface
that allows cleaning up anything that was done in `setUp` after the test
execution.

The `BaseTargetPreparer` class also extends `ITargetCleaner`.

## Recommendations

We recommend each preparer be limited to a single main function, for example
installing an APK or running a command. This allows for easier re-use of
preparers.

You should also check the list of available preparers before adding a new one to
avoid duplicating work. Preparers are available in [tools/tradefederation/core/src/com/android/tradefed/targetprep/](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/targetprep/).

## XML configuration

The object tag will be `target_preparer`, for example:

```xml
<target_preparer class="com.android.tradefed.targetprep.InstallApkSetup">
    <option name="install-arg" value="-d"/>
</target_preparer>
```

Also refer to
[Suite Setup](/devices/tech/test_infra/tradefed/testing/through-suite/setup)
for context.

### Top-level setup

If specified in a top-level setup, the preparer will be run only once for each
device. An example is
[cts-common.xml](https://android.googlesource.com/platform/test/suite_harness/+/refs/heads/master/tools/cts-tradefed/res/config/cts-common.xml),
which is a top-level setup for Android Compatibility Test Suite (CTS) tests.

### Module-level setup

If specified at the module level, the preparer will always be run before that
module. An example is
[backup/AndroidTest.xml](https://android.googlesource.com/platform/cts/+/refs/heads/master/tests/backup/AndroidTest.xml),
which defines how Tradefed runs the `backup` CTS module.

Note that while the preparer will run before the module, it will run *after* any
[System Status Checkers](/devices/tech/test_infra/tradefed/testing/through-suite/system-status-checker).
