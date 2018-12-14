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

# Self-Instrumenting Tests Example

When an instrumentation test is started, its target package is
restarted with instrumentation code injected and initiated for execution. One
exception is that the target package here cannot be the Android application
framework itself, i.e. the package `android`, because doing so would lead to the
paradoxical situation where Android framework would need to be restarted, which
is what supports the system functions, including the instrumentation itself.

This means that an instrumentation test cannot inject itself into Android
framework, a.k.a. the system server, for execution. In order to test the Android
framework, the test code can invoke only public API surfaces, or those exposed
via Android Interface Definition Language
[AIDL](https://developer.android.com/guide/components/aidl.html){: .external} available
in the platform source tree. For this category of tests, it's not meaningful to
target any particular package. Therefore, it's customary for such
instrumentations to be declared to target its own test application package, as
defined in its own `<manifest>` tag of `AndroidManifest.xml`.

Depending on the requirements, test application packages in this category may
also:

*   Bundle activities needed for testing.
*   Share the user ID with the system.
*   Be signed with the platform key.
*   Be compiled against the framework source rather than the public SDK.

This category of instrumentation tests is sometimes referred to as
self-instrumentation. Here are some examples of self-instrumentation tests in
the platform source:

*   [frameworks/base/core/tests/](https://android.googlesource.com/platform/frameworks/base/+/master/core/tests/)
*   [frameworks/base/services/tests/servicestests](https://android.googlesource.com/platform/frameworks/base/+/master/services/tests/servicestests/)


The example covered here is writing a new instrumentation test with target
package set at its own test application package. This guide uses the following
test to serve as an example:

*   [Hello World Instrumentation Test](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/instrumentation/)

It's recommended to browse through the code first to get a rough impression
before proceeding.

## Deciding on a source location

Typically your team will already have an established pattern of places to check
in code, and places to add tests. Most team owns a single git repository, or
share one with other teams but have a dedicated sub directory that contains
component source code.

Assuming the root location for your component source is at `<component source
root>`, most components have `src` and `tests` folders under it, and some
additional files such as `Android.mk` (or broken up into additional `.mk` files),
the manifest file `AndroidManifest.xml`, and the test configuration file
'AndroidTest.xml'.

Since you are adding a brand new test, you'll probably need to create the
`tests` directory next to your component `src`, and populate it with content.

In some cases, your team might have further directory structures under `tests`
due to the need to package different suites of tests into individual apks. And
in this case, you'll need to create a new sub directory under `tests`.

Regardless of the structure, you'll end up populating the `tests` directory or
the newly created sub directory with files similar to what's in
`instrumentation` directory in the sample gerrit change. The sections below will
explain in further details of each file.

## Manifest file

Just like a regular application, each instrumentation test module needs a
manifest file. If you name the file as `AndroidManifest.xml` and provide it next
to `Android.mk` for your test tmodule, it will get included automatically by the
`BUILD_PACKAGE` core makefile.

Before proceeding further, it's highly recommended to go through the
[App Manifest Overview](https://developer.android.com/guide/topics/manifest/manifest-intro.html){: .external}
first.

This gives an overview of basic components of a manifest file and their
functionalities. See the example at
[platform_testing/tests/example/instrumentation/AndroidManifest.xml](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/instrumentation/AndroidManifest.xml).

A snapshot is included here for convenience:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="android.test.example.helloworld"

    <uses-sdk android:minSdkVersion="21" android:targetSdkVersion="21" />

    <application>
        <uses-library android:name="android.test.runner" />
    </application>

    <instrumentation android:name="android.support.test.runner.AndroidJUnitRunner"
                     android:targetPackage="android.test.example.helloworld"
                     android:label="Hello World Test"/>

</manifest>
```

Some select remarks on the manifest file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="android.test.example.helloworld"
```

The `package` attribute is the application package name: this is the unique
identifier that the Android application framework uses to identify an
application (or in this context: your test application). Each user in the system
can only install one application with that package name.

Furthermore, this `package` attribute is the same as what
[`ComponentName#getPackageName()`](https://developer.android.com/reference/android/content/ComponentName.html#getPackageName\(\))
returns, and also the same you would use to interact with various `pm` sub
commands via `adb shell`.

Please also note that although the package name is typically in the same style
as a Java package name, it actually has very few things to do with it. In other
words, your application (or test) package may contain classes with any package
names, though on the other hand, you could opt for simplicity and have your top
level Java package name in your application or test identical to the application
package name.

```xml
android:sharedUserId="android.uid.system"
```

This declares that at installation time, this apk should be granted the same
user id, i.e. runtime identity, as the core platform. Note that this is
dependent on the apk being signed with same certificate as the core platform
(see `LOCAL_CERTIFICATE` in above section), yet they are different concepts:

*   some permissions or APIs are signature protected, which requires same
    signing certificate
*   some permissions or APIs requires the `system` user identity of the caller,
    which requires the calling package to share user id with `system`, if it's a
    separate package from core platform itself

```xml
<uses-library android:name="android.test.runner" />
```

This is required for all Instrumentation tests since the related classes are
packaged in a separate framework jar library file, therefore requires additional
classpath entries when the test package is invoked by application framework.

```xml
android:targetPackage="android.test.example.helloworld"
```

You might have noticed that the `targetPackage` here is declared the same as the
`package` attribute declared in the `manifest` tag of this file. As mentioned in
[testing basics](../basics/index.md), this category of instrumentation test are
typically intended for testing framework APIs, so it's not very meaningful for
them to have a specific targeted application package, other then itself.

## Simple configuration file

Each new test module must have a configuration file to direct
the build system with module metadata, compile-time dependencies and packaging
instructions. In most cases, the Soong-based, Blueprint file option is
sufficient. See [Simple Test Configuration](blueprints.md) for details.

## Complex configuration file

Important: The instructions in this section are needed only for CTS tests or those
that require special setup, such as disabling Bluetooth or collecting sample data.
All other cases can be covered through the
[Simple Test Configuration](blueprints). See the
[Complex Test Configuration](test-config) for
more details applicable to this section.

For these more complex cases, you also need to write a test configuration
file for Android's test harness, [Trade Federation](/devices/tech/test_infra/tradefed/).

The test configuration can specify special device setup options and default
arguments to supply the test class. See the example at
[/platform_testing/tests/example/instrumentation/AndroidTest.xml](/platform_testing/+/master/tests/example/instrumentation/AndroidTest.xml).

A snapshot is included here for convenience:

```xml
<configuration description="Runs sample instrumentation test.">
  <target_preparer class="com.android.tradefed.targetprep.TestFilePushSetup"/>
  <target_preparer class="com.android.tradefed.targetprep.TestAppInstallSetup">
    <option name="test-file-name" value="HelloWorldTests.apk"/>
  </target_preparer>
  <target_preparer class="com.android.tradefed.targetprep.PushFilePreparer"/>
  <target_preparer class="com.android.tradefed.targetprep.RunCommandTargetPreparer"/>
  <option name="test-suite-tag" value="apct"/>
  <option name="test-tag" value="SampleInstrumentationTest"/>

  <test class="com.android.tradefed.testtype.AndroidJUnitTest">
    <option name="package" value="android.test.example.helloworld"/>
    <option name="runner" value="android.support.test.runner.AndroidJUnitRunner"/>
  </test>
</configuration>
```

Some select remarks on the test configuration file:

```xml
<target_preparer class="com.android.tradefed.targetprep.TestAppInstallSetup">
  <option name="test-file-name" value="HelloWorldTests.apk"/>
</target_preparer>
```
This tells Trade Federation to install the HelloWorldTests.apk onto the target
device using a specified target_preparer. There are many target preparers
available to developers in Trade Federation and these can be used to ensure
the device is setup properly prior to test execution.

```xml
<test class="com.android.tradefed.testtype.AndroidJUnitTest">
  <option name="package" value="android.test.example.helloworld"/>
  <option name="runner" value="android.support.test.runner.AndroidJUnitRunner"/>
</test>
```
This specifies the Trade Federation test class to use to execute the test and
passes in the package on the device to be executed and the test runner
framework which is JUnit in this case.

Look here for more information on [Test Module Configs](test-config.md)

## JUnit4 features

Using `android-support-test` library as test runner enables adoptation of new
JUnit4 style test classes, and the sample gerrit change contains some very basic
use of its features. See the example at
[/platform_testing/tests/example/instrumentation/src/android/test/example/helloworld/HelloWorldTest.java](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/instrumentation/src/android/test/example/helloworld/HelloWorldTest.java).

While testing patterns are usually specific to component teams, there are some
generally useful usage patterns.

```java
@RunWith(JUnit4.class)
public class HelloWorldTest {
```

A significant difference in JUnit4 is that tests are no longer required to
inherit from a common base test class; instead, you write tests in plain Java
classes and use annotation to indicate certain test setup and constraints. In
this example, we are instructing that this class should be run as a JUnit4 test.

```java
    @BeforeClass
    public static void beforeClass() {
    ...
    @AfterClass
    public static void afterClass() {
    ...
    @Before
    public void before() {
    ...
    @After
    public void after() {
    ...
    @Test
    @SmallTest
    public void testHelloWorld() {
    ...
```

The `@Before` and `@After` annotations are used on methods by JUnit4 to perform
pre test setup and post test teardown. Similarly, the `@BeforeClass` and
`@AfterClass` annotations are used on methods by JUnit4 to perform setup before
executing all tests in a test class, and teardown afterwards. Note that the
class-scope setup and teardown methods must be static. As for the test methods,
unlike in earlier version of JUnit, they no longer need to start the method name
with `test`, instead, each of them must be annotated with `@Test`. As usual,
test methods must be public, declare no return value, take no parameters, and
may throw exceptions.

**Important**: the test methods themselves are annotated with `@Test`
annotation; and note that for tests to be executed via APCT, they must be
annotated with test sizes: the example annotated method `testHelloWorld` as
`@SmallTest`. The annotation may be applied at method scope, or class scope.

## Accessing `instrumentation`

Although not covered in the basic hello world example, it's fairly common for an
Android test to require access `Instrumentation` instance: this is the core API
interface that provides access to application contexts, activity lifecycle
related test APIs and more.

Because the JUnit4 tests no longer require a common base class, it's no longer
necessary to obtain `Instrumentation` instance via
`InstrumentationTestCase#getInstrumentation()`, instead, the new test runner
manages it via [`InstrumentationRegistry`](https://developer.android.com/reference/android/support/test/InstrumentationRegistry.html)
where contextual and environmental setup created by instrumentation framework is
stored.

To access the instance of `Instrumentation` class, simply call static method
`getInstrumentation()` on `InstrumentationRegistry` class:

```java
Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation()
```

## Build and test locally

For the most common use cases, employ
[Atest](/compatibility/tests/development/atest).

For more complex cases requiring heavier customization, follow the
[instrumentation instructions](instrumentation.md).
