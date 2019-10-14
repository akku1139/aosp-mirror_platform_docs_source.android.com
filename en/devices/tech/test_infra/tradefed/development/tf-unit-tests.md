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

# Include Unit Tests

This section explains how to run Trade Federation tests after making a change to
the project. This includes:

*   Where to add the new unit test classes
*   Running unit tests in Eclipse and outside the Eclipse IDE
*   Running the functional tests
*   Running some of TF presubmit validation locally

## Add unit tests

In the Android Open Source Project (AOSP), add the unit tests class in:
[tools/tradefederation/core/tests/src/com/android/tradefed/UnitTests.java](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/tests/src/com/android/tradefed/UnitTests.java)

IMPORTANT: Adding your new unit test classes to these locations will result in
them automatically running in presubmit without additional setup.

## Run unit tests

All the AOSP unit tests and functional tests for Trade Federation are located in
the
[`tools/tradefederation/core/tests`](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/tests/)
project.

Inside Eclipse, to run an individual unit test, simply right-click the test and
select **Run As > JUnit**. To run all unit tests, run the
**com.android.tradefed.UnitTests** suite.

You can also start the unit test from the command line in the Tradefed source
tree after building, like so:
`tools/tradefederation/core/tests/run_tradefed_tests.sh`

Unit tests can be executed standalone, but functional tests should be executed
by using Trade Federation itself; they require an Android device. All functional
tests should follow the naming convention `*FuncTest`.

## Run functional tests

To run a functional test from Eclipse:

1.  Ensure a device is connected to the host and that `adb` and if necessary
    `fastboot` are in Eclipse's PATH. The easiest way to do this is to launch
    Eclipse from a shell setup with the proper PATH.
1.  Create a Java application. Run configuration via **Run > Run
    configurations**.
1.  Set project to `google-tradefederation-tests` and the main class to
    `com.android.tradefed.command.CommandRunner`.
1.  Provide the following command line arguments in the *Arguments* tab: `host
    --class <full path of test class to run>`
1.  Click **Run**.

To run functional tests outside Eclipse.

1.  Build Trade Federation.
1.  Connect an Android device to the host.
1.  Run `tools/tradefederation/core/tests/run_tradefed_func_tests.sh`
1.  Optionally, choose the device by appending `--serial <serial no>` as it
    appears in the output of `adb devices`.

## Running TF presubmit tests against local changes

If you want to run in a similar way as the TF presubmit, use this:

```
tools/tradefederation/core/tests/run_tradefed_aosp_presubmit.sh
```

This will trigger all the TF presubmit tests against your locally built TF to
help you validate that your change is not breaking any tests.

TF presubmit tests are a superset of the unit tests above, but it is slower to
run them. So it is recommended to run the unit tests during development for
quicker validation and to run the presubmits before uploading the CL.
