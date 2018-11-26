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

# JAR (Java) Host Tests

JAR host tests should be implemented to provide complete code coverage of your
software. Follow the instructions to [Build local unit
tests](https://developer.android.com/training/testing/unit-testing/local-unit-tests){: .external}.
Write small unit tests to validate a specific function and nothing more.

## Example

The following Blueprint file provides a simple Hello World JAR host test example to
copy and adapt to your needs:
[platform_testing/tests/example/jarhosttest/Android.bp](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/jarhosttest/Android.bp)

This corresponds to the actual test code found at:
[platform_testing/tests/example/jarhosttest/test/android/test/example/helloworld/HelloWorldTest.java](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/jarhosttest/test/android/test/example/helloworld/HelloWorldTest.java)

A snapshot of the Blueprint file is included here for convenience:

   ```
   java_test_host {
    name: "HelloWorldHostTest",

    test_suites: ["general-tests"],

    srcs: ["test/**/*.java"],

    static_libs: [
        "junit",
        "mockito",
    ],
}
   ```

Note the `java_host_test` declaration at the beginning indicates this is a JAR
host test.

## Settings

The following settings garner explanation:

   ```
    name: "HelloWorldHostTest",
   ```


The `name` setting is required when the `java_test_host` module type is specified
(at the start of the block). It gives a name to your module, and the resulting
JAR will be named the same and with a `.jar` suffix, e.g. in this case, the
resulting test JAR is named as `HelloWorldHostTest.jar`.  In addition, this also
defines a make target name for your module, so that you can use `make [options]
<HelloWorldHostTest>` to build your test module and all its dependencies.


```
    test_suites: ["general-tests"],
```

The `test_suites` setting makes the test easily discoverable by the Trade
Federation test harness. Other suites can be added here such as CTS so that this
test may be shared.

   ```
    static_libs: [
        "junit",
    ],
   ```

The `static_libs` setting instructs the build system to incorporate the contents
of the named modules into the resulting apk of current module. This means that
each named module is expected to produce a `.jar` file, and its content will be
used for resolving classpath references during compile time, as well as
incorporated into the resulting apk.
