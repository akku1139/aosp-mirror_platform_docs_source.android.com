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

# Set up Suite

Suite in Tradefed refers to setup where several tests are running under a common
test runner that drives the overall execution.

In Tradefed, suites are driven through the
[ITestSuite](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/suite/ITestSuite.java)
class, which allows tests to be added and removed independently of how they are
run.

## Definitions

*   Suite: Set of *test modules* configured to run under a similar *top-level
    setup* to report their results under a single invocation.
*   Top-level setup: Setup applied to the device(s) before running any of the
    test modules.
*   Main configuration: The suite-level Tradefed XML configuration that
    describes which modules should run and which *top-level setup* should be
    used.
*   Module-level setup: Setup applied to the device(s) right before running the
    module. These are also known as *module-specific setups*.
*   Module configuration: Refers to the `AndroidTest.xml` Tradefed XML
    configuration that describes the modules and which *module-level setup*
    should be done.
*   Module: Test unit composed of a setup step (*module-level setup*), a test
    execution step and a tear down step.

*   Intra-module retry: Automatic retry done by the harness inside the module.
*   Suite retry: Full rerun of the suite's previously failed tests.

## ITestSuite structure

[ITestSuite](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/suite/ITestSuite.java)
in Tradefed refers to the common base class driving a suite execution. It is
shared by all major test suites (CTS, GTS, etc.) and ensures a consistent
execution experience across all suites.

We will sometimes refer to *ITestSuite* as the *suite runner*.

The suite runner follows these steps when executing:

1.  Load the module's configuration and determine which set should run.
1.  Run each module:
    a. Run module-level setup
    b. Run module tests
    c. Run module-level tear down
1.  Report the results

## Top-level setup

From a Tradefed point of view, ITestSuite is just another test. It is a complex
one but is still just a test like any other `IRemoteTest`. So when specifying
the suite runner in a Tradefed configuration, Tradefed will follow the usual
pattern of the configuration: running `build_provider`, `target_preparer`, test
(our suite in this case), and `target_cleaner`.

This sequence in the Tradefed configuration containing the ITestSuite is the
top-level setup.

Example:

```xml
<configuration description="Common config for Compatibility suites">

    <build_provider class="com.android.compatibility.common.tradefed.build.CompatibilityBuildProvider" />
    <!-- Setup applied before the suite: so everything running in the suite will
    have this setup beforehand -->
    <target_preparer class="com.android.tradefed.targetprep.RunCommandTargetPreparer">
        <option name="run-command" value="settings put global package_verifier_enable 0" />
        <option name="teardown-command" value="settings put global package_verifier_enable 1"/>
    </target_preparer>

    <!-- Our ITestSuite implementation -->
    <test class="com.android.compatibility.common.tradefed.testtype.suite.CompatibilityTestSuite" />

    <result_reporter class="com.android.compatibility.common.tradefed.result.ConsoleReporter" />
</configuration>
```

## Module metadata

We call *Module Metadata* extra information specified in the test module
`AndroidTest.xml`. They allow you to specify additional information regarding
the module, and modules can be filtered using the metadata.

Example metadata:

```xml
<option name="config-descriptor:metadata" key="component" value="framework" />
<option name="config-descriptor:metadata" key="parameter" value="instant_app" />
```

Example filter on metadata:

```shell
--module-metadata-include-filter component=framework
```

The above would run all the modules with a *framework* as *component* metadata.

Full `AndroidTest.xml` example:

```xml
<configuration description="Config for CTS Gesture test cases">
    <option name="test-suite-tag" value="cts" />
    <!-- Metadata -->
    <option name="config-descriptor:metadata" key="component" value="framework" />
    <option name="config-descriptor:metadata" key="parameter" value="instant_app" />
    <!-- End: metadata -->
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

## Parameterized module

A special metadata type is `parameter`.

```xml
<option name="config-descriptor:metadata" key="parameter" value="instant_app" />
```

This metadata specifies that the module will need to be executed in a different
*mode*, for example as an instant app, instead of a standard app mode.

All the possible modes or parameters are described by
[ModuleParameters](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/suite/params/ModuleParameters.java)
and have an associated handler in
[ModuleParametersHelper](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/suite/params/ModuleParametersHelper.java)
that allows you to change the module setup to execute in the particular mode.

For example, the instant app mode will force the APK installation as
instant mode.

In order for the parameterization to occur, the command line needs to enable it
via:

```shell
--enable-parameterized-modules
```

It is also possible to run a single given mode via:

```shell
--enable-parameterized-modules --module-parameter <Mode>

--enable-parameterized-modules --module-parameter INSTANT_APP
```

When a parameterized version of a module runs, it will report its results
under a parameterized module name, for example CtsGestureTestCases[instant] vs.
base CtsGestureTestCases.
