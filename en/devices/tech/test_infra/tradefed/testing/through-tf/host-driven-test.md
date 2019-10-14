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

# Write a Host-Driven Test in Trade Federation

This page describes how to write a JUnit4-style device test driven by the host.
This means that the host side of the harness is going to trigger actions against
the device.

Note that we consider "host-side" tests and "host-driven" tests to be slightly
different:

*   host-driven test: Is a test running on the host that interacts with one or
    more devices. The system under test (SUT) is not on the host itself but is
    being tested from the host.
*   host-side test: Is a test purely running on the host and testing something
    only on the host, for example unit tests.

## Why create a host-driven test rather than an instrumentation test?

Some tests might require you to affect the device overall state, like issuing a
reboot command. In the instrumentation test case, a reboot would kill the
instrumentation, the test could not continue, and no results would be available.

Host-driven tests can also drive additional setup steps that require interaction
with external devices on which the test depends on.

A host-driven test can handle these use cases and allow for advanced testing of
the device with more scenarios. If you are in that situation, writing a
host-driven test makes the most sense.

## How are host-driven tests written in TF?

Here is a sample:

```java
@RunWith(DeviceJUnit4ClassRunner.class)
public class SampleHostJUnit4DeviceTest extends BaseHostJUnit4Test {
    @Before
    public void setUp() throws Exception {
       // Some setup
    }

    @Test
    public void testCheckWeHaveDevice() throws Exception {
        Assert.assertNotNull(getDevice());
    }
}
```

Host-driven tests in Trade Federation are driven by the [DeviceJUnit4ClassRunner]
(https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/test_framework/com/android/tradefed/testtype/DeviceJUnit4ClassRunner.java)
JUnit4 test runner. The overall structure of the test class is the same as a
regular JUnit4 test:

*   `@BeforeClass`
*   `@Before`
*   `@Test`
*   `@After`
*   `@AfterClass`
*   `Assume`, `Assert`

Extending [BaseHostJunit4Test]
(https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/test_framework/com/android/tradefed/testtype/junit4/BaseHostJUnit4Test.java)
is a way to inherit useful testing utilities API such as:

*   `installPackage`: Allows to install an APK on the target device.
*   `installPackageAsUser`: Allows to install an APK as a user on the target
     device.
*    `uninstallPackage`: Allows to uninstall an APK.
*    `isPackageInstalled`: Check whether a package is installed or not.
*    `hasDeviceFeature`: Check whether device supports a feature or not.
     (`pm list features`)
*    `runDeviceTests(DeviceTestRunOptions options)`: Run an instrumentation
     test against a target device using [DeviceTestRunOptions](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/test_framework/com/android/tradefed/testtype/junit4/DeviceTestRunOptions.java)
     to handle all the possible options.

Also provide access to the Tradefed device object:

*   `getDevice()`: Returns a TF device object for manipulating the device.
*   `getBuild()`: Returns a build info TF object to get information about the
    build.
*   `getAbi()`: Returns the ABI the test is running against.

## How to configure a host-driven test in TF?

In Tradefed XML configuration file, host-driven tests are run through the
[HostTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/test_framework/com/android/tradefed/testtype/HostTest.java)
runner.

```xml
<test class="com.android.tradefed.testtype.HostTest" >
    <option name="class" value="android.sample.cts.SampleHostJUnit4DeviceTest" />
</test>
```
