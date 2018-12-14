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

# Targeting an Application Example

This category of instrumentation test isn't that different from those targeting
the regular Android applications. It's worth noting that the test application
that included the instrumentation needs to be signed with the same certificate
as the application that it's targeting.

Note that this guide assumes that you already have some knowledge in the
platform source tree workflow. If not, please refer to
https://source.android.com/source/requirements. The example
covered here is writing an new instrumentation test with target package set at
its own test application package. If you are unfamiliar with the concept, please
read through the [Platform testing introduction](../development/index.md).

This guide uses the follow test to serve as an sample:

*   frameworks/base/packages/Shell/tests

It's recommended to browse through the code first to get a rough impression
before proceeding.

## Deciding on a source location

Because the instrumentation test will be targeting an application, the convention
is to place the test source code in a `tests` directory under the root of your
component source directory in platform source tree.

See more discussions about source location in the [end-to-end example for
self-instrumenting tests](instr-self-e2e.md).

## Manifest file

Just like a regular application, each instrumentation test module needs a
manifest file. If you name the file as `AndroidManifest.xml` and provide it next
to `Android.mk` for your test tmodule, it will get included automatically by the
`BUILD_PACKAGE` core makefile.

Before proceeding further, it's highly recommended to go through the
[App Manifest Overview](https://developer.android.com/guide/topics/manifest/manifest-intro.html){: .external}
first.

This gives an overview of basic components of a manifest file and their
functionalities.

Latest version of the manifest file for the sample gerrit change can be accessed
at:
https://android.googlesource.com/platform/frameworks/base/+/master/packages/Shell/tests/AndroidManifest.xml

A snapshot is included here for convenience:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.android.shell.tests">

    <application>
        <uses-library android:name="android.test.runner" />

        <activity
            android:name="com.android.shell.ActionSendMultipleConsumerActivity"
            android:label="ActionSendMultipleConsumer"
            android:theme="@android:style/Theme.NoDisplay"
            android:noHistory="true"
            android:excludeFromRecents="true">
            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="*/*" />
            </intent-filter>
        </activity>
    </application>

    <instrumentation android:name="android.support.test.runner.AndroidJUnitRunner"
        android:targetPackage="com.android.shell"
        android:label="Tests for Shell" />

</manifest>
```

Some select remarks on the manifest file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.android.shell.tests">
```

The `package` attribute is the application package name: this is the unique
identifier that the Android application framework uses to identify an
application (or in this context: your test application). Each user in the system
can only install one application with that package name.

Since this is a test application package, independent from the application
package under test, a different package name must be used: one common convention
is to add a suffix `.test`.

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
<uses-library android:name="android.test.runner" />
```

This is required for all Instrumentation tests since the related classes are
packaged in a separate framework jar library file, therefore requires additional
classpath entries when the test package is invoked by application framework.

```xml
android:targetPackage="com.android.shell"
```

This sets the target package of the instrumentation to `com.android.shell.tests`.
When the instrumentation is invoked via `am instrument` command, the framework
restarts `com.android.shell.tests` process, and injects instrumentation code into
the process for test execution. This also means that the test code will have
access to all the class instances running in the application under test and may
be able to manipulate state depends on the test hooks exposed.

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

For more complex tests, you also need to write a test configuration
file for Android's test harness, [Trade Federation](/devices/tech/test_infra/tradefed/).

The test configuration can specify special device setup options and default
arguments to supply the test class.

Latest version of the config file for the sample gerrit change can be accessed
at:
https://android.googlesource.com/platform/frameworks/base/+/master/packages/Shell/tests/AndroidTest.xml

A snapshot is included here for convenience:

```xml
<configuration description="Runs Tests for Shell.">
    <target_preparer class="com.android.tradefed.targetprep.TestAppInstallSetup">
        <option name="test-file-name" value="ShellTests.apk" />
    </target_preparer>

    <option name="test-suite-tag" value="apct" />
    <option name="test-tag" value="ShellTests" />
    <test class="com.android.tradefed.testtype.AndroidJUnitTest" >
        <option name="package" value="com.android.shell.tests" />
        <option name="runner" value="android.support.test.runner.AndroidJUnitRunner" />
    </test>
</configuration>
```

Some select remarks on the test configuration file:

```xml
<target_preparer class="com.android.tradefed.targetprep.TestAppInstallSetup">
  <option name="test-file-name" value="ShellTests.apk"/>
</target_preparer>
```
This tells Trade Federation to install the ShellTests.apk onto the target
device using a specified target_preparer. There are many target preparers
available to developers in Trade Federation and these can be used to ensure
the device is setup properly prior to test execution.

```xml
<test class="com.android.tradefed.testtype.AndroidJUnitTest">
  <option name="package" value="com.android.shell.tests"/>
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
use of its features.

Latest source code for the sample gerrit change can be accessed at:
frameworks/base/packages/Shell/tests/src/com/android/shell/BugreportReceiverTest.javast.java

While testing patterns are usually specific to component teams, there are some
generally useful usage patterns.

```java
@SmallTest
@RunWith(AndroidJUnit4.class)
public final class FeatureFactoryImplTest {
```

A significant difference in JUnit4 is that tests are no longer required to
inherit from a common base test class; instead, you write tests in plain Java
classes and use annotation to indicate certain test setup and constraints. In
this example, we are instructing that this class should be run as an Android
JUnit4 test.

The `@SmallTest` annotation specified a test size for the entire test class: all
test methods added into this test class inherit this test size annotation.
pre test class setup, post test tear down, and post test class tear down:
similar to `setUp` and `tearDown` methods in JUnit4.
`Test` annotation is used for annotating the actual test.

Important: the test methods themselves are annotated with `@Test`
annotation; and note that for tests to be executed via APCT, they must be
annotated with test sizes. Such annotation may be applied at method scope, or
class scope.

```java
    @Before
    public void setup() {
    ...
    @Test
    public void testGetProvider_shouldCacheProvider() {
    ...
```

The `@Before` annotation is used on methods by JUnit4 to perform pre test setup.
Although not used in this example, there's also `@After` for post test teardown.
Similarly, the `@BeforeClass` and `@AfterClass` annotations are can be used on
methods by JUnit4 to perform setup before executing all tests in a test class,
and teardown afterwards. Note that the class-scope setup and teardown methods
must be static.

As for the test methods, unlike in earlier version of JUnit, they no longer need
to start the method name with `test`, instead, each of them must be annotated
with `@Test`. As usual, test methods must be public, declare no return value,
take no parameters, and may throw exceptions.

```java
        Context context = InstrumentationRegistry.getTargetContext();
```

Because the JUnit4 tests no longer require a common base class, it's no longer
necessary to obtain `Context` instances via `getContext()` or
`getTargetContext()` via base class methods; instead, the new test runner
manages them via [`InstrumentationRegistry`](https://developer.android.com/reference/android/support/test/InstrumentationRegistry.html)
where contextual and environmental setup created by instrumentation framework is
stored. Through this class, you can also call:

*   `getInstrumentation()`: the instance to the `Instrumentation` class
*   `getArguments()`: the command line arguments passed to `am instrument` via
    `-e <key> <value>`

## Build and test locally

For the most common use cases, employ
[Atest](/compatibility/tests/development/atest).

For more complex cases requiring heavier customization, follow the
[instrumentation instructions](instrumentation.md).
