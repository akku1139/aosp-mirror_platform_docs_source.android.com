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

# Native Tests

A native test for the platform typically accesses lower-level HALs or
performs raw IPC against various system services. Therefore, the testing approach
is usually tightly coupled with the service under test.

Build native tests using the [gtest](https://github.com/google/googletest){: .external}
framework. This is a prerequisite for integration with continuous testing
infrastructure.

## Examples

Here are some examples of native tests in the platform source:

*   [frameworks/av/camera/tests](https://android.googlesource.com/platform/frameworks/av/+/master/camera/tests/)
*   [frameworks/native/libs/gui/tests](https://android.googlesource.com/platform/frameworks/native/+/master/libs/gui/tests/)

## Summary of steps

1. See sample native test module setup at:
   [frameworks/base/libs/hwui/tests/unit/](https://android.googlesource.com/platform/frameworks/base/+/master/libs/hwui/tests/unit/)
1. Test module configuation should use the `BUILD_NATIVE_TEST` build rule so
   gtest dependencies are included automatically
1. Write a test configuration. See the
   [simple](/compatibility/tests/development/blueprints) and
   [complex](/compatibility/tests/development/test-config) options.
1. Build the test module with `mmm` or `mma` (depends on if it's an
incremental or full build), e.g.:

   ```shell
   make hwui_unit_tests -j
   ```
1.  Use [Atest](/compatibility/tests/development/atest) to run the test locally:

    ```
    atest hwui_unit_tests
    ```

1.  Run the test with the Trade Federation test harness:

    ```
    make tradefed-all -j
    tradefed.sh run template/local_min --template:map test=hwui_unit_tests
    ```
1.  Manually install and run:
   1. Push the generated test binary onto device:

      ```shell
      adb push ${OUT}/data/nativetest/hwui_unit_tests/hwui_unit_tests \
        /data/nativetest/hwui_unit_tests/hwui_unit_tests
      ```
   1. Execute the test by invoking test binary on device:

      ```shell
      adb shell /data/nativetest/hwui_unit_tests/hwui_unit_tests
   ```

   This launches the native test. You can also add the `--help` parameter to your test
   binary to find out more about the different ways to customize test execution.
   Finally, see the [gtest advanced
   guide](https://github.com/google/googletest/blob/master/googletest/docs/advanced.md)
   for more parameters and their use.
