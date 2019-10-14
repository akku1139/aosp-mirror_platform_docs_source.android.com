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

# Simple Build Configuration

Each new test module must have a configuration file to direct the build system
with module metadata, compile-time dependencies and packaging instructions.
Android now uses the [Soong build system](https://android.googlesource.com/platform/build/soong/+/master/README.md) for simpler
test configuration.

Soong uses Blueprint or `.bp` files, which are JSON-like simple declarative
descriptions of modules to build. This format replaces the Make-based system
used in previous releases. See the [Soong reference files](https://ci.android.com/builds/latest/branches/aosp-build-tools/targets/linux/view/soong_build.html)
on the [Continuous Integration Dashboard](https://ci.android.com/) for full details.

To accommodate custom testing or use the
Android [Compatibility Test Suite](/compatibility/cts) (CTS), follow
[Complex Test Configuration](/compatibility/tests/development/test-config)
instead.

## Example

The entries below come from this example Blueprint configuration file:
[/platform_testing/tests/example/instrumentation/Android.bp](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/instrumentation/Android.bp)

A snapshot is included here for convenience:

```
android_test {
    name: "HelloWorldTests",
    srcs: ["src/**/*.java"],
    sdk_version: "current",
    static_libs: ["android-support-test"],
    certificate: "platform",
    test_suites: ["device-tests"],
}
```

Note the `android_test` declaration at the beginning indicates this is a test.
Including `android_app` would conversely indicate this is instead a build
package.

## Settings

The following settings garner explanation:

```
    name: "HelloWorldTests",
```

The `name` setting is required when the `android_test` module type is specified
(at the start of the block). It gives a name to your module, and the resulting
APK will be named the same and with a `.apk` suffix, e.g. in this case,
resulting test apk is named as `HelloWorldTests.apk`.  In addition, this also
defines a make target name for your module, so that you can use `make [options]
<HelloWorldTests>` to build your test module and all its dependencies.

```
    static_libs: ["android-support-test"],
```

The `static_libs` setting instructs the build system to incorporate the contents
of the named modules into the resulting apk of current module. This means that
each named module is expected to produce a `.jar` file, and its content will be
used for resolving classpath references during compile time, as well as
incorporated into the resulting apk.

In this example, things that might be generally useful for tests:

The `android-support-test` is the prebuilt for the Android Test Support Library,
which includes the new test runner `AndroidJUnitRunner`: a replacement for the
now deprecated built-in `InstrumentationTestRunner`, with support for JUnit4
testing framework. Read more at
[Test apps on Android](https://developer.android.com/training/testing/){:
.external}.

If you are building a new instrumentation module, you should always start with
the `android-support-test` library as your test runner. The platform source tree
also includes other useful testing frameworks such as `ub-uiautomator`,
`mockito-target`, `easymock` and more.

```
    certificate: "platform",
```

The `certificate` setting instructs the build system to sign the apk with the same
certificate as the core platform. This is needed if your test uses a signature
protected permission or API. Note that this is suitable for platform continuous
testing, but should *not* be used in CTS test modules. Note that this example
uses this certificate setting only for the purpose of illustration: the test code
of the example does not actually need for the test apk to be signed with the
special platform certificate.

If you are writing an instrumentation for your component that lives outside of
system server, that is, it's packaged more or less like a regular app apk,
except that it's built into system image and may be a privileged app, chances
are that your instrumentation will be targeting the app package (see below
section about manifest) of your component. In this case, your application
makefile may have its own `certificate` setting, and your instrumentation
module should retain the same setting. This is because to target your
instrumentation on the app under test, your test apk and app apk must be signed
with the same certificate.

In other cases, you don't need to have this setting at all: the build system
will simply sign it with a default built-in certificate, based on the build
variant, and it's typically called the `dev-keys`.

```
    test_suites: ["device-tests"],
```

The `test_suites` setting makes the test easily discoverable by the Trade
Federation test harness. Other suites can be added here such as CTS so that this
test may be shared.

```
${ANDROID_PRODUCT_OUT}/testcases/HelloWorldTests/HelloWorldTests.apk
```
