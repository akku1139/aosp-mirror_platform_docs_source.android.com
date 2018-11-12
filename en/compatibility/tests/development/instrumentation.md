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

# Instrumentation Tests

First read [Test your app](https://developer.android.com/studio/test/){: .external}
on developer.android.com. Take note there are some differences in
how instrumentation tests are used in platform testing.

In summary, an instrumentation test provides a special test execution
environment as launched via the `am instrument` command, where the targeted
application process is restarted and initialized with basic application context,
and an instrumentation thread is started inside the application process VM. Your
test code starts execution on this instrumentation thread and is provided with
an `Instrumentation` instance that provides access to the application context
and APIs to manipulate the application process under test.


## Key concepts

*   an instrumentation must be declared in an application package, with an
    [`<instrumentation>`](https://developer.android.com/guide/topics/manifest/instrumentation-element.html)
    tag nested under the `<manifest>` tag of the application package manifest.
*   an application package manifest may technically contain multiple
    `<instrumentation>` tags, though it's not commonly used in this fashion.
*   each `<instrumentation>` must contain:
    *   an `android:name` attribute: it should be the name of a subclass of
        [`Instrumentation`](https://developer.android.com/reference/android/app/Instrumentation.html)
        that's included in the test application, which is typically the test
        runner that's being used, e.g.:
        `android.support.test.runner.AndroidJUnitRunner`
    *   an `android:targetPackage` attribute must be defined. Its value should
        be set to the application package under test.

## Summary of steps

1.  Below are common destinations for hermetic tests against framework services:

    ```
    frameworks/base/core/tests/coretests
    frameworks/base/services/tests/servicestests
    ```

    If you are adding a brand new instrumentation module for your component, see

    *   [Self-Instrumenting Tests: A Complete Example](instr-self-e2e.md)
    *   [Instrumentation Targeting an Application: A Complete Example]
        (instr-app-e2e.md)

1.  Following the existing convention if you are adding tests into one of the
    locations above. If you are setting up a new test module, please follow the
    setup of `AndroidManifest.xml` and `Android.mk` in one of the locations
    above

1.  See
    [frameworks/base/core/tests/coretests/](https://android.googlesource.com/platform/frameworks/base.git/+/master/core/tests/coretests/)
    for an example.
    Note these lines install extra apps:

    ```
 <option name="test-file-name" value="FrameworksCoreTests.apk" />
 <option name="test-file-name" value="BstatsTestApp.apk" />
    ```

1.  Do not forget to mark your test as `@SmallTest`, `@MediumTest` or
    `@LargeTest`

1.  Build the test module with make, e.g.:

    ```
    make FrameworksCoreTests -j
    ```

1. Run the tests:
   *  The simplest solution is to use
      [Atest](https://android.googlesource.com/platform/tools/tradefederation/+/master/atest/README.md){: .external}
      like so:

      ```
      atest FrameworksCoreTests
      ```
   *  Or for more complex tests, use the Trade Federation test harness:

    ```
    make tradefed-all -j
    tradefed.sh run template/local_min --template:map test=FrameworksCoreTests
    ```

1.  If using Trade Fed, manually install and run the tests:
    1. Install the generated apk:

    ```
    adb install -r ${OUT}/data/app/FrameworksCoreTests/FrameworksCoreTests.apk
    ```

    Tip: you use `adb shell pm list instrumentation` to find the
    instrumentations inside the apk just installed

    1.  Run the tests with various options:

        1.  all tests in the apk

            ```
            adb shell am instrument -w com.android.frameworks.coretests\
              /android.support.test.runner.AndroidJUnitRunner
            ```

        1.  all tests under a specific Java package

            ```
            adb shell am instrument -w -e package android.animation \
              com.android.frameworks.coretests\
              /android.support.test.runner.AndroidJUnitRunner
            ```

        1.  all tests under a specific class

            ```
            adb shell am instrument -w -e class \
              android.animation.AnimatorSetEventsTest \
              com.android.frameworks.coretests\
              /android.support.test.runner.AndroidJUnitRunner
            ```

        1.  a specific test method

            ```
            adb shell am instrument -w -e class \
              android.animation.AnimatorSetEventsTest#testCancel \
              com.android.frameworks.coretests\
              /android.support.test.runner.AndroidJUnitRunner
            ```

Your test can make an explicit assertion on pass or fail using `JUnit` APIs; in
addition, any uncaught exceptions will also cause a functional failure.

To emit performance metrics, your test code can call
[`Instrumentation#sendStatus`](http://developer.android.com/reference/android/app/Instrumentation.html#sendStatus\(int, android.os.Bundle\))
to send out a list of key-value pairs. It's important to note that:

1.  metrics can be integer or floating point
1.  any non-numerical values will be discarded
1.  your test apk can be either functional tests or metrics tests, however
    mixing both are not currently supported
