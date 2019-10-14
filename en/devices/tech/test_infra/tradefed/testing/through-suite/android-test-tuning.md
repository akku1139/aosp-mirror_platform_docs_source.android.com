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

# Configure Sharding

This page describes what is possible to tune for a suite module
(`AndroidTest.xml`) via sharding and get the best speed performance during
continuous execution in the lab. We will attempt to describe the options in a
generic manner with the rational for using each.

When running continuously a suite in the lab, the suite is usually sharded
across several devices to reduce the overall completion time. The harness
typically attempts to balance the execution time of each shard to minimize the
overall completion time (when the last shard finishes); but due to the nature of
some tests, we do not always have enough introspection and need the module owner
to tune some behavior.

## Shardable or not shardable?

It is possible to tag a module (`AndroidTest.xml`) with
`<option name="not-shardable" value="true" />` to notify the harness that it
should not be sharded.

In a typical module, letting the harness shard your module
(the default behavior) is the right thing to do. But in some cases, you might
want to override that behavior:

*   When the setup of your module is expensive:

Sharding a module results in the preparation (install APK, push file, etc.)
possibly run once per device involved. If your module setup is long and
expensive and not worth being replicated compared to the test's runtime, you
should tag your module as not-shardable.

*   When the number of tests in your module is low:

Sharding a module results in all the test cases possibly executing independently
on different devices. This relates to the first point; if your number of tests
is low, you might end up with a single test or no test in some shards, which
would make any preparation step quite expensive. Installing an APK for a single
test case is usually not worth it, for example.

## Instrumentation tests: Max number of shards?

An instrumentation test running through [AndroidJUnitTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/test_framework/com/android/tradefed/testtype/AndroidJUnitTest.java)
does not expose to the harness how many tests are part of the instrumentation
until we actually install and run the APK. These operations are costly and
cannot be executed at sharding time for all the modules part of the suite.

The harness might over-shard the instrumentation test and end up with some
empty shards; sharding an instrumentation test with five tests in six shards
results in five shards with one test and one shard with no tests. Each of these
shards would require a costly APK installation.

So when the number of tests in the instrumentation test APK is low, tagging the
module with `<option name="not-shardable" value="true" />` would allow the
harness to know sharding that module is not worth it.

The `AndroidJUnitTest` runner has a special option allowing it to specify the
max number of shards it is allowed to shard into:
`<option name="ajur-max-shard" value="5" />`.

This allows you to specify a maximum number of times the instrumentation can be
sharded regardless of the number of shards requested at the invocation level. By
default, the instrumentation will be sharded into the number of shards requested
for the invocation.

For example, if your instrumentation test APK contains only two test cases but
you still want to shard it, having a `ajur-max-shard` value of `2` would ensure
you are not creating empty shards.
