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

# Adding a New Native Test Example

If you are new to Android platform development, you might find this complete
example of adding a brand new native test from scratch useful to demonstrate the
typical workflow involved. In addition, if you are also unfamiliar with the
gtest framework for C++, please review the [gtest project
site](https://github.com/google/googletest) for additional documentation.

This guide uses the follow test to serve as an sample:

[Hello World Native Test](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/native/)

It's recommended to browse through the code first to get a rough impression
before proceeding.

## Deciding on a source location

Typically your team will already have an established pattern of places to check
in code, and places to add tests. Most team owns a single git repository, or
share one with other teams but have a dedicated sub directory that contains
component source code.

Assuming the root location for your component source is at `<component source
root>`, most components have `src` and `tests` folders under it, and some
additional files such as `Android.mk` (or broken up into additional `.bp`
files).

Since you are adding a brand new test, you'll probably need to create the
`tests` directory next to your component `src`, and populate it with content.

In some cases, your team might have further directory structures under `tests`
due to the need to package different suites of tests into individual binaries.
And in this case, you'll need to create a new sub directory under `tests`.

To illustrate, here's a typical directory outline for components with a single
`tests` folder:

```
\
 <component source root>
  \-- Android.bp (component makefile)
  \-- AndroidTest.bp (test config file)
  \-- src (component source)
  |    \-- foo.cpp
  |    \-- ...
  \-- tests (test source root)
      \-- Android.bp (test makefile)
      \-- src (test source)
          \-- foo_test.cpp
          \-- ...
```

and here's a typical directory outline for components with multiple test source
directories:

```
\
 <component source root>
  \-- Android.bp (component makefile)
  \-- AndroidTest.bp (test config file)
  \-- src (component source)
  |    \-- foo.cpp
  |    \-- ...
  \-- tests (test source root)
      \-- Android.bp (test makefile)
      \-- testFoo (sub test source root)
      |   \-- Android.bp (sub test makefile)
      |   \-- src (sub test source)
      |       \-- test_foo.cpp
      |       \-- ...
      \-- testBar
      |   \-- Android.bp
      |   \-- src
      |       \-- test_bar.cpp
      |       \-- ...
      \-- ...
```

Regardless of the structure, you'll end up populating the `tests` directory or
the newly created sub directory with files similar to what's in `native`
directory in the sample gerrit change. The sections below will explain in
further details of each file.

## Source code

See the [Hello World Native
Test](https://android.googlesource.com/platform/platform_testing/+/master/tests/example/native/HelloWorldTest.cpp)
for an example.

Annotated source code is listed below:

```c++
#include <gtest/gtest.h>
```

Header file include for gtest. Note that the include file dependency is
automatically resolved by using `BUILD_NATIVE_TEST` in the makefile

```c++
#include <stdio.h>

TEST(HelloWorldTest, PrintHelloWorld) {
    printf("Hello, World!");
}
```

gtests are written by using `TEST` macro: the first parameter is the test case
name, and the second is test name; together with test binary name, they form the
hierarchy below when visualized in result dashboard:

```
<test binary 1>
| \-- <test case 1>
| |   \-- <test 1>
| |   \-- <test 2>
| |   \-- ...
| \-- <test case 2>
| |   \-- <test 1>
| |   \-- ...
| \-- ...
<test binary 2>
|
...
```

For more information on writing tests with gtest, see its documentation:

*   https://github.com/google/googletest/blob/master/googletest/docs/Primer.md

## Simple configuration file

Each new test module must have a configuration file to direct
the build system with module metadata, compile-time dependencies and packaging
instructions. In most cases, the Soong-based, Blueprint file option is 
sufficient. See [Simple Test Configuration](blueprints.md) for details.

## Complex configuration file

Important: The instructions in this section are needed only for CTS tests or those
that require special setup, such as disabling Bluetooth or collecting sample data.
All other cases can be covered through the
[Simple Test Configuration](blueprints.md). See the
[Complex Test Configuration](compatibility/tests/development/test-config) for
more details applicable to this section.

To use Trade Federation instead, write a test configuration
file for Android's test harness, [Trade Federation](/devices/tech/test_infra/tradefed/).

The test configuration can specify special device setup options and default
arguments to supply the test class.

## Build and test locally

For the most common use cases, employ
[Atest](https://android.googlesource.com/platform/tools/tradefederation/+/master/atest/README.md).

For more complex cases requiring heavier customization, follow the
[instrumentation instructions](instrumentation.md).
