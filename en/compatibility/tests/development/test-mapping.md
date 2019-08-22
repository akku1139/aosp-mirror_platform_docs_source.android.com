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

# Test Mapping

This is a brief introduction of Test Mapping and an explanation of how to get
started configuring tests easily in the Android Open Source Project (AOSP).

## What is Test Mapping?

Test Mapping is a Gerrit-based approach that allows developers to create pre-
and post-submit test rules directly in the Android source tree and leave the
decisions of branches and devices to be tested to the test infrastructure
itself. Test Mapping definitions are JSON files named TEST_MAPPING that can be
placed in any source directory.

[Atest](atest) can use the TEST_MAPPING files to run presubmit tests in the
associated directories. With Test Mapping, you can add the same set of tests to
presubmit checks with a simple change inside the Android source tree.

See these examples:

[Add presubmit tests to TEST_MAPPING for services.core](https://android.googlesource.com/platform/frameworks/base/+/master/services/core/java/com/android/server/pm/dex/TEST_MAPPING)

[Add presubmit tests to TEST_MAPPING for tools/dexter using imports](https://android.googlesource.com/platform/tools/dexter/+/refs/heads/master/TEST_MAPPING)

Test Mapping relies on the
[Trade Federation (TF) Test Harness](/devices/tech/test_infra/tradefed) for
tests execution and results reporting.

## Defining test groups

Test Mapping groups tests via a **test group**. The name of a test group can be
any string. For example, *presubmit* can be for a group of tests to run when
validating changes. And *postsubmit* tests can be used to validate the
builds after changes are merged.

## Packaging build script rules

In order for the [Trade Federation Test Harness](/devices/tech/test_infra/tradefed)
to run Test Mapping's test modules for a given build, these modules must have
**test_suite** set for [Soong](blueprints) or **LOCAL_COMPATIBILITY_SUITE** set
for Make to one of these two suites:

*   **device-tests** - built against a specific device CPU
*   **general-tests** - built against any application binary interface (ABI)

When in doubt, put gtests in _device-tests_ and APK tests in _general-tests_.

Examples:

```
Android.bp: test_suites: ["device-tests"],
Android.mk: LOCAL_COMPATIBILITY_SUITE := device-tests
```


## Creating Test Mapping files

For the directory requiring test coverage, simply add a TEST_MAPPING JSON file
resembling the example below. These rules will ensure the tests run in presubmit
checks when any files are touched in that directory or any of its subdirectories.

### Following an example

Here is a sample TEST_MAPPING file:

```
{
  "presubmit": [
    {
      "name": "CtsWindowManagerDeviceTestCases",
      "options": [
        {
          "include-annotation": "android.platform.test.annotations.RequiresDevice"
        }
      ],
      "file_patterns": ["(/|^)Window[^/]*\\.java", "(/|^)Activity[^/]*\\.java"]
    },
    {
      "name" : "net_test_avrcp",
      "host" : true
    }
  ],
  "postsubmit": [
    {
      "name": "CtsWindowManagerDeviceTestCases"
    }
  ],
  "imports": [
    {
      "path": "frameworks/base/services/core/java/com/android/server/am"
    }
  ]
}
```

### Setting attributes

In the above example, `presubmit` and `postsubmit` are the names of each **test
group**. See
[Defining test groups](#defining_test_groups) for more information about test
groups.

The **name** of the **test module** or **Trade Federation integration test
name** (resource path to the test XML file, e.g.,
[uiautomator/uiautomator-demo](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/master/res/config/uiautomator/uiautomator-demo.xml))
can be set in the value of the `name` attribute. Note the **name** field cannot
use class `name` or test method `name`. To narrow down the tests to run, you can
use options such as `include-filter` here. See
([include-filter sample usage](https://android.googlesource.com/platform/frameworks/base/+/master/services/core/java/com/android/server/pm/dex/TEST_MAPPING#7)).

The **host** setting of a test indicates whether the test is a deviceless test
running on host or not. The default value is **false**, meaning the test
requires a device to run. The supported test types are
[HostGTest](/compatibility/tests/development/native) for native tests and
[HostTest](/compatibility/tests/development/jar) for JUnit tests.

The **file_patterns** attribute allows you to set a list of regex strings for
matching the relative path of any source code file (relative to the directory
containing the TEST_MAPPING file). In above example, test `CtsWindowManagerDeviceTestCases`
will run in presubmit only when any java file starts with Window or Activity,
which exists in the same directory of the TEST_MAPPING file or any of its sub
directories, is changed. Backslashes \ need to be escaped as they are in a
JSON file.

The **imports** attribute allows you to include tests in other TEST_MAPPING files
without copying the content. Note that the TEST_MAPPING files in the parent
directories of the imported path will also be included. Test Mapping allows
nested imports; this means two TEST_MAPPING files can import each other, and
Test Mapping is able to properly merge the included tests.

The **options** attribute contains additional TradeFed command line options.

To get a complete list of available options for a given test, run:

<pre>
<code class="devsite-terminal">tradefed.sh run commandAndExit [test_module] --help</code>
</pre>

Refer to
[TradeFed Option Handling ](/devices/tech/test_infra/tradefed/fundamentals/options)
for more details about how options work.

## Running tests with Atest

To execute the presubmit test rules locally:

1.  Go to the directory containing the TEST_MAPPING file.
1.  Run the command:

<pre>
<code class="devsite-terminal">atest</code>
</pre>

All presubmit tests configured in the TEST_MAPPING files of the current
directory and its parent directories are run. Atest will locate and run two tests
for presubmit (A and B).

This is the simplest way to run presubmit tests in TEST_MAPPING files in the
current working directory (CWD) and parent directories. Atest will locate and
use the TEST_MAPPING file in CWD and all of its parent directories, unless a
TEST_MAPPING file has `inherit_parent` set to false.

### Structuring source code

The following example shows how TEST_MAPPING files can be configured across the
source tree.

```
src
├── project_1
│   └── TEST_MAPPING
├── project_2
│   └── TEST_MAPPING
└── TEST_MAPPING
```

Content of `src/TEST_MAPPING`:

```
{
  "presubmit": [
    {
      "name": "A"
    }
  ]
}
```

Content of `src/project_1/TEST_MAPPING`:

```
{
  "presubmit": [
    {
      "name": "B"
    }
  ],
  "postsubmit": [
    {
      "name": "C"
    }
  ],
  "other_group": [
    {
      "name": "X"
    }
  ]}
```

Content of `src/project_2/TEST_MAPPING`:

```
{
  "presubmit": [
    {
      "name": "D"
    }
  ],
  "import": [
    {
      "path": "src/project_1"
    }
  ]}
```

### Specifying target directories

You can specify a target directory to run tests in TEST_MAPPING files in that
directory. The following command will run two tests (A, B).

<pre>
<code class="devsite-terminal">atest --test-mapping src/project_1</code>
</pre>

### Running postsubmit test rules

You can also use this command to run the postsubmit test rules defined in
TEST_MAPPING in `src_path` (default to CWD)
and its parent directories:

<pre>
<code class="devsite-terminal">atest [--test-mapping] [src_path]:postsubmit</code>
</pre>

### Running only tests that require no device

You can use option **--host** for Atest to only run tests configured against the
host that require no device. Without this option, Atest will run both tests, the
ones requiring device and the ones running on host and require no device. The
tests will be run in two separate suites.

<pre>
<code class="devsite-terminal">atest [--test-mapping] --host</code>
</pre>

### Identifying test groups

You can specify test groups in the Atest command. The following command will run
all **postsubmit** tests related to files in directory src/project_1, which
contains only one test (C).

Or you can use **:all** to run all tests regardless of group. The following
command runs four tests (A, B, C, X):

<pre>
<code class="devsite-terminal">atest --test-mapping src/project_1:all</code>
</pre>

### Including subdirectories

By default, running tests in TEST_MAPPING with Atest will run only presubmit
tests configured in the TEST_MAPPING file in CWD (or
given directory) and its parent directories. If you want to run tests in all
TEST_MAPPING files in the sub-directories, use the option `--include-subdir` to
force Atest to include those tests too.

<pre>
<code class="devsite-terminal">atest --include-subdir</code>
</pre>

Without the `--include-subdir` option, Atest will run only test A. With the
`--include-subdir` option, Atest will run two tests (A, B).

### Line-level comment is supported

You can add a line-level `//`-format comment to flesh out the TEST_MAPPING file
with a description of the setting that follows. [ATest](https://source.android.com/compatibility/tests/development/atest) and Trade Federation will
preprocess the TEST_MAPPING to a valid JSON format without comments. To keep
the JSON file clean and easy to read, only line-level `//`-format comment is
supported.

Example:

```
{
  // For presubmit test group.
  "presubmit": [
    {
      // Run test on module A.
      "name": "A"
    }
  ]
}
```
