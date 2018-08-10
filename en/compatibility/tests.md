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

# Tests

As an open source operating system, Android offers many testing and debugging
tools. First, take a moment to understand the
[basics](https://android.googlesource.com/platform/platform_testing/+/master/docs/basics/index.md){: .external}
of testing and then explore the options below.

## Atest

[Atest](https://android.googlesource.com/platform/tools/tradefederation/+/master/atest/README.md){: .external}
is a command line tool that allows users to build, install and run Android tests
locally.

## Compatibility Test Suite (CTS)

The [Compatibility Test Suite](/compatibility/cts/) (CTS) is a free,
commercial-grade test suite that runs on a desktop machine and executes test
cases directly on attached devices or an emulator.

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
