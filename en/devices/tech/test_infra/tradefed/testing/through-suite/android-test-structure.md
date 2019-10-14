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

# AndroidTest.xml Structure

The overall structure of the module configuration follows a similar pattern
to the regular Tradefed XML configuration but with some restrictions due to
the fact that they run as part of a suite.

## List of allowed tags

`AndroidTest.xml` or more broadly module configuration can contain only the
following XML tags: `target_preparer`, `multi_target_preparer`, `test`.

Although that list looks restrictive, it allows you to precisely define
test module setup needs and the test to run.

NOTE: See [Tradefed XML configuration](/devices/tech/test_infra/tradefed/architecture/xml-config)
if you need a refresher on the different tags.

Onjects such as `build_provider` or `result_reporter` will raise a
`ConfigurationException` if attempted to be run from inside a module
configuration. This is meant to avoid the expectation of these
objects actually performing some task from within a module.

## Example module configuration

```xml
<configuration description="Config for CTS Gesture test cases">
    <option name="test-suite-tag" value="cts" />
    <target_preparer class="com.android.tradefed.targetprep.suite.SuiteApkInstaller">
        <option name="cleanup-apks" value="true" />
        <option name="test-file-name" value="CtsGestureTestCases.apk" />
    </target_preparer>
    <test class="com.android.tradefed.testtype.AndroidJUnitTest" >
        <option name="package" value="android.gesture.cts" />
        <option name="runtime-hint" value="10m50s" />
    </test>
</configuration>
```

This configuration describes a test that requires `CtsGestureTestCases.apk` to
be installed and will run an instrumentation against the `android.gesture.cts`
package.

## What about build infos or downloads?

The definition of the allowed tags might give the incorrect impression that a
module will not get any build information. **This is not true**.

The build information is provided from the suite-level setup and will be
shared by **all** the modules of the suite. This allows a single top-level setup
for the suite in order to run all the modules part of the suite.

For example, instead of each
[Compatibility Test Suite (CTS)](/compatibility/cts)
module individually querying the device information, types, etc., the CTS
suite-level setup (`cts.xml`) does it once and each module will receive that
information if they request it.

In order for the objects in a module to receive the build information, they need
to do the same as in regular Tradefed configuration: implement the
`IBuildReceiver` interface to receive the `IBuildInfo`. See
[testing with device](/devices/tech/test_infra/tradefed/testing/through-tf/new-test-runner#testing_with_a_device)
for more details.
