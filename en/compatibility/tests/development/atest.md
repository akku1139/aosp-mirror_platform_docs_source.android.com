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

# Atest

Atest is a command line tool that allows users to build, install, and run
Android tests locally, greatly speeding test re-runs without requiring knowledge
of [Trade Federation test harness](/devices/tech/test_infra/tradefed) command
line options. This page explains how to use Atest to run Android tests.

For general information on writing tests for Android, see
[Android Platform Testing](/compatibility/tests/index.md).

For information on the overall structure of Atest, see
[Atest Developer Guide](https://android.googlesource.com/platform/tools/tradefederation/+/master/atest/docs/atest_structure.md){: .external}.

And to add a feature to Atest, follow
[Atest Developer Workflow](https://android.googlesource.com/platform/tools/tradefederation/+/master/atest/docs/developer_workflow.md){: .external}.

## Setting up your environment

To run Atest, follow the steps in the sections below to set up your environment.

### Set environment variable

Set test_suite for [Soong](/compatibility/tests/development/blueprints) or
LOCAL_COMPATIBILITY_SUITE for Make per
[Packaging build script rules](/compatibility/tests/development/test-mapping#packaging_build_script_rules).

### 1. Run envsetup.sh

From the root of the Android source checkout, run:

<pre>
<code class="devsite-terminal">source build/envsetup.sh</code>
</pre>

### 2. Run lunch

Run the `$ lunch` command to bring up a menu of supported devices. Find the
device and run that command.

For example, if you have an ARM device connected, run the following command:

<pre>
<code class="devsite-terminal">lunch aosp_arm64-eng</code>
</pre>

This sets various environment variables required for running Atest and adds the
Atest command to your `$PATH`.

## Basic usage

Atest commands take the following form:

<pre>
<code class="devsite-terminal">atest [<var>optional-arguments</var>] <var>test-to-run</var></code>
</pre>

### Optional arguments

You can use the following optional arguments with Atest commands.

| Option | Long option              | Description                              |
| :----: | :----------------------- | ---------------------------------------- |
| `-b`   | `--build`                | Builds test targets.                     |
| `-i`   | `--install`              | Installs test artifacts (APKs) on        |
:        :                          : device.                                  :
| `-t`   | `--test`                 | Runs the tests.                          |
| `-s`   | `--serial`               | Runs the tests on the specified device.  |
:        :                          : One device can be tested at a time.      :
| `-d`   | `--disable-teardown`     | Disables test teardown and cleanup.      |
| <c>    | `--info`                 | Shows the relevant info of the specified |
:        :                          : targets and exits.                       :
| <c>    | `--dry-run`              | A synonym of --info.                     |
| `-m`   | `--rebuild-module-info`  | Forces a rebuild of the module-info.json |
:        :                          : file.                                    :
| `-w`   | `--wait-for-debugger`    | Waits for debugger prior to execution.   |
:        :                          : Only for instrumentation tests.          :
| `-v`   | `--verbose`              | Displays DEBUG level logging.            |
| <c>    | `--generate-baseline`    | Generates baseline metrics, runs 5       |
:        :                          : iterations by default.                   :
| <c>    | `--generate-new-metrics` | Generates new metrics, run 5 iterations  |
:        :                          : by default.                              :
| <c>    | `--detect-regression`    | Runs regression detection algorithm.     |
| <c>    | `--[CUSTOM_ARGS]`        | Specifies custom args for the test       |
:        :                          : runners.                                 :
| `-a`   | `--all-abi`              | Runs the tests for all available device  |
:        :                          : architectures.                           :
| `-h`   | `--help`                 | Shows help message and exits.            |
| <c>    | `--host`                 | Runs the test completely on the host     |
:        :                          : without a device.<br>(Note\: Running a   :
:        :                          : host test that requires a device with    :
:        :                          : --host will fail.)                       :

For more information on `-b`, `-i` and `-t`, see
[Specifying steps: build, install, or run.](#specifying_steps_build_install_or_run)

### Tests to run

You can run one or more tests using <var>test-to-run</var>. To run multiple
tests, separate test references with spaces. For example:

<pre>
<code class="devsite-terminal">atest <var>test-to-run-1</var> <var>test-to-run-2</var></code>
</pre>

Here are some examples:

<pre>
<code class="devsite-terminal">atest FrameworksServicesTests</code>
<code class="devsite-terminal">atest example/reboot</code>
<code class="devsite-terminal">atest FrameworksServicesTests CtsJankDeviceTestCases</code>
<code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests</code>
</pre>

For more information on how to reference a test, see
[Identifying tests.](#identifying_tests)

## Identifying tests

You can specify the <var>test-to-run</var> argument with the test's module name,
Module:Class, class name, TF integration test, file path or package name.

### Module name

To run an entire test module, use its module name. Input the name as it appears
in the `LOCAL_MODULE` or `LOCAL_PACKAGE_NAME` variables in that test's
`Android.mk` or `Android.bp` file.

Note: Use **TF Integration Test** to run non-module tests integrated directly
into TradeFed.

Examples:

<pre>
<code class="devsite-terminal">atest FrameworksServicesTests</code>
<code class="devsite-terminal">atest CtsJankDeviceTestCases</code>
</pre>

### Module:Class

To run a single class within a module, use **Module:Class**. **Module** is the
same as described in [Module name](#module_name). **Class** is the name of the
test class in the `.java` file and can be the fully qualified class name or the
basic name.

Examples:

<pre>
<code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests</code>
<code class="devsite-terminal">atest FrameworksServicesTests:com.android.server.wm.ScreenDecorWindowTests</code>
<code class="devsite-terminal">atest CtsJankDeviceTestCases:CtsDeviceJankUi</code>
</pre>

### Class name

To run a single class without explicitly stating a module name, use the class
name.

Examples:

<pre>
<code class="devsite-terminal">atest ScreenDecorWindowTests</code>
<code class="devsite-terminal">atest CtsDeviceJankUi</code>
</pre>

Using the **Module:Class** reference is recommended whenever possible since
Atest requires more time to search the complete source tree for potential
matches if no module is stated.

Examples (ordered from fastest to slowest):

<pre>
<code class="devsite-terminal">atest FrameworksServicesTests:com.android.server.wm.ScreenDecorWindowTests</code>
<code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests</code>
<code class="devsite-terminal">atest ScreenDecorWindowTests</code>
</pre>

### TF integration test

To run tests that are integrated directly into TradeFed (non-modules), input the
name as it appears in the output of the `tradefed.sh list configs` command. For
example:

To run the
[`reboot.xml` test](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/master/res/config/example/reboot.xml){: .external}:

<pre>
<code class="devsite-terminal">atest example/reboot</code>
</pre>

To run the
[`native-benchmark.xml` test](https://android.googlesource.com/platform/tools/tradefederation/+/master/res/config/native-benchmark.xml){: .external}:

<pre>
<code class="devsite-terminal">atest native-benchmark</code>
</pre>

### File path

You can run both module-based tests and integration-based tests by inputting the
path to their test file or directory as appropriate. You can also run a single
class by specifying the path to the class's Java file. Both relative and
absolute paths are supported.

Example: Two ways to run the `CtsJankDeviceTestCases` module via path

1.  Run module from android <var>repo-root</var>:

    <pre>
    <code class="devsite-terminal">atest cts/tests/jank</code>
    </pre>

2.  From android <var>repo-root</var>/cts/tests/jank:

    <pre>
    <code class="devsite-terminal">atest .</code>
    </pre>

Example: Run a specific class within `CtsJankDeviceTestCases` module via path.
From android <var>repo-root</var>:

<pre>
<code class="devsite-terminal">atest cts/tests/jank/src/android/jank/cts/ui/CtsDeviceJankUi.java</code>
</pre>

Example: Run an integration test via path. From android <var>repo-root</var>:

<pre>
<code class="devsite-terminal">atest tools/tradefederation/contrib/res/config/example/reboot.xml</code>
</pre>

### Package name

Atest supports searching tests by package name.

Examples:

<pre>
<code class="devsite-terminal">atest com.android.server.wm</code>
<code class="devsite-terminal">atest android.jank.cts</code>
</pre>

## Specifying steps: Build, install, or run

You can specify which steps to run by using the `-b`, `-i`, and `-t` options. If
you don't specify an option, then all steps run.

Note: You can run `-b` and `-t` alone, but `-i` needs `-t` to run.

-   Build targets only: <code>atest -b <var>test-to-run</var></code>
-   Run tests only: <code>atest -t <var>test-to-run</var></code>
-   Install apk and run tests: <code>atest -it <var>test-to-run</var></code>
-   Build and run, but don't install: <code>atest -bt
    <var>test-to-run</var></code>

Atest can force a test to skip the cleanup/teardown step. Many tests, such as
CTS, clean up the device after the test is run, so trying to rerun your test
with `-t` will fail without the `--disable-teardown` parameter. Use `-d` before
`-t` to skip the test clean up step and test iteratively.

<pre>
<code class="devsite-terminal">atest -d <var>test-to-run</var></code>
<code class="devsite-terminal">atest -t <var>test-to-run</var></code>
</pre>

Note: `-t` disables both **setup/install** and **teardown/cleanup** of the
device so you can rerun your test with <code>atest -t
<var>test-to-run</var></code> as many times as you want.

## Running specific methods

You can run specific methods within a test class. Although the whole module
needs to be built, this reduces the time needed to run the tests. To run
specific methods, identify the class using any of the ways supported for
identifying a class (Module:Class, file path, etc) and append the name of the
method.

<pre>
<code class="devsite-terminal">atest <var>reference-to-class</var>#<var>method1</var></code>
</pre>

You can specify multiple methods with commas.

<pre>
<code class="devsite-terminal">atest <var>reference-to-class</var>#<var>method1</var>,<var>method2</var>,<var>method3</var></code>
</pre>

Examples:

<pre>
<code class="devsite-terminal">atest com.android.server.wm.ScreenDecorWindowTests#testMultipleDecors</code>
<code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests#testFlagChange,testRemoval</code>
</pre>

The following two examples show the preferred ways to run a single method,
`testFlagChange`. These examples are preferred over only using the class name
because specifying the module or the Java file location allows Atest to find the
test much faster:

1.  Using Module:Class

    <pre>
    <code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests#testFlagChange</code>
    </pre>

1.  From android <var>repo-root</var>

    <pre>
    <code class="devsite-terminal">atest frameworks/base/services/tests/servicestests/src/com/android/server/wm/ScreenDecorWindowTests.java#testFlagChange</code>
    </pre>

Multiple methods can be run from different classes and modules:

<pre>
<code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests#testFlagChange,testRemoval ScreenDecorWindowTests#testMultipleDecors</code>
</pre>

## Running multiple classes

To run multiple classes, separate them with spaces in the same way as running
multiple tests. Atest builds and runs classes efficiently, so specifying a
subset of classes in a module improves performance over running the whole
module.

Examples:

-   Two classes in the same module:

    <pre>
    <code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests FrameworksServicesTests:DimmerTests</code>
    </pre>

-   Two classes in different modules:

    <pre>
    <code class="devsite-terminal">atest FrameworksServicesTests:ScreenDecorWindowTests CtsJankDeviceTestCases:CtsDeviceJankUi</code>
    </pre>

## Running native tests

Atest can run native tests.

Examples:

-   Input tests:

    <pre>
    <code class="devsite-terminal">atest -a libinput_tests inputflinger_tests</code>
    </pre>

Use `-a` to run the tests for all available device architectures, which in this
example is armeabi-v7a (ARM 32-bit) and arm64-v8a (ARM 64-bit).

## Detecting metrics regression

You can generate pre-patch or post-patch metrics without running regression
detection. You can specify the number of iterations, but the default is five.

Examples:

<pre>
<code class="devsite-terminal">atest <var>test-to-run</var> --generate-baseline <var>[optional-iteration]</var></code>
<code class="devsite-terminal">atest <var>test-to-run</var> --generate-new-metrics <var>[optional-iteration]</var></code>
</pre>

Local regression detection can be run in three options:

1.  Generate baseline (pre-patch) metrics and place them in a folder. Atest runs
    the tests through the specified iterations, generates post-patch metrics,
    and compares those against existing metrics.

    Example:

    <pre>
    <code class="devsite-terminal">atest <var>test-to-run</var> --detect-regression <var>/path/to/baseline</var> --generate-new-metrics <var>[optional-iteration]</var></code>
    </pre>

2.  Using a folder containing previously generated post-patch metrics, Atest
    runs the tests _n_ iterations, generates a new set of pre-patch metrics, and
    compares those against those provided.

    Note: The developer needs to revert the device/tests to pre-patch state to
    generate baseline metrics.

    Example:

    <pre>
    <code class="devsite-terminal">atest <var>test-to-run</var> --detect-regression <var>/path/to/new</var> --generate-baseline <var>[optional-iteration]</var></code>
    </pre>

3.  Using two folders containing both pre-patch and post-patch metrics, Atest
    runs the regression detection algorithm without any tests.

    Example:

    <pre>
    <code class="devsite-terminal">atest --detect-regression <var>/path/to/baseline</var> <var>/path/to/new</var></code>
    </pre>
