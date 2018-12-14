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

# Android Platform Testing

This content is geared toward Android platform developers.
Before understanding how testing is done on the Android platform,
please refer to the [Android platform architecture](/devices/architecture)
for an overview.

## What's new

### Test development workflow

The [Test Development Workflow](/compatibility/tests/development) subsection now
contains introductory materials including end-to-end examples for all primary
test types.

### Simple test configuration

The [Soong build system](https://android.googlesource.com/platform/build/soong/)
was introduced in Android 8.0 (Oreo) with support for `android_test` arriving in
Android Q, now available in the Android Open Source Project (AOSP) master
branch. Soong's Blueprint-based configuration is far simpler than the previous
Make solution.

### Atest

[Atest](/compatibility/tests/development/atest)
is a command line tool that allows users to build, install and run Android tests
locally. It is the recommended standard for initial testing of your feature.

## What and how to test

A platform test typically interacts with one or more of the Android system
services, or Hardware abstraction layer (HAL) layers, exercises the
functionalities of the subject under test, and asserts correctness of the
testing outcome.

As such, a platform test may:

1.  exercise framework APIs via application framework; specific APIs being
    exercised may include:
    *   public APIs intended for third-party applications
    *   hidden APIs intended for privileged applications, namely system APIs
    *   private APIs (@hide, or protected, package private)
1.  invoke Android system services via raw binder/IPC proxies directly
1.  interact directly with HALs via low-level APIs or IPC interfaces

Types 1 and 2 are typically written as [instrumentation
tests](/compatibility/tests/development/instrumentation), while
type 3 are usually written as [native
tests](/compatibility/tests/development/native) using the
[gtest](https://github.com/google/googletest){: .external} framework.

To learn more, see our end-to-end examples:

*   [instrumentation targeting an application](/compatibility/tests/development/instr-app-e2e.md)
*   [self-instrumentation](/compatibility/tests/development/instr-self-e2e.md)
*   [native test](/compatibility/tests/development/native-func-e2e.md)

Become familiar with these tools, as they are intrinsic to testing in Android.

## Compatibility Test Suite (CTS)

[Android Compatibility Test Suite](/compatibility/cts/)
is a suite of various types of tests, used to ensure compatibility of
Android framework implementations across OEM partners, and across platform
releases. **The suite also includes instrumentation tests and native tests
(also using gtest framework).**

CTS and platform tests are not mutually exclusive, and here are some general
guidelines:

*   if a test is asserting correctness of framework API functions/behaviors, and
    it should be enforced across OEM partners, it should be in CTS
*   if a test is intended to catch regressions during platform development
    cycle, and may require privileged permission to carry out, and may be
    dependent on implementation details (as released in AOSP), it should only be
    platform tests

## Vendor Test Suite (VTS)

The [Vendor Test Suite](/compatibility/vts/) (VTS) automates HAL and OS kernel
testing. To use VTS to test an Android native system implementation, set up a
testing environment then test a patch using a VTS plan.

## Trade Federation Testing Infrastructure

[Trade Federation](/devices/tech/test_infra/tradefed/) (tradefed or TF for
short) is a continuous test framework designed for running tests on Android
devices. TF can run functional tests locally, at your desk, within your platform
checkout. There are two required files to run a test in TF, a java test source
and an XML config. See
[RebootTest.java](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/master/src/com/android/example/RebootTest.java){: .external}
and
[reboot.xml](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/master/res/config/example/reboot.xml){: .external}
for examples.

## Debugging

The [Debugging](/devices/tech/debug/) section summarizes useful tools and related
commands for debugging, tracing, and profiling native Android platform code when
developing platform-level features.
