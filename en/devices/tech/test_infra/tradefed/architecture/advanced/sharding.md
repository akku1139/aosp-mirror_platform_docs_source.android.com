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

# Shard Tests

When the test corpus is large or the execution time becomes long, we offer the
possibility of splitting the tests across several devices: *sharding*.

Sharding has [prerequisites](/devices/tech/test_infra/tradefed/testing/through-tf/sharded-runner)
for the test runner to support sharding.

The majority of the main test runners already supports sharding so no additional
work is required. These already support sharding: instrumentation tests,
host-side driven tests, GTest.

There are two types of sharding we support in Tradefed: local and distributed.
They share some similarities, so we will describe the common properties and then
the specifics of each.

## Common properties

Both forms of sharding assume the same properties from the tests runners: Shards
need to be *independent* and *deterministic*. The first step of both shardings is
to build the complete ordered list of the tests and then split them into
different groups/shards.

The main difference of the sharding forms is in the way they execute the tests.
More details in the sections below.

## Local sharding

*Local sharding* means all the devices involved in the execution of the sharded
invocation are connected to the same physical host.

### Execution

Local sharding takes advantage of all the devices being connected to the same
host by creating a pool of tests that needs to be executed and having each
device polling tests when it is free (i.e. done with the previous test).
This results in an optimized device utilization. We also call it
*dynamic sharding*.

### Options

```shell
--shard-count XX
```

## Distributed sharding

*Distributed sharding* means all the devices involved in the execution of the
sharded invocation can live anywhere and be connected to different physical
hosts.

### Execution

Distributed sharding occurs upon building the list of tests, and the content of
each shard will proceed to execute only the currently requested shard. So all
distributed shards build the same list at first and then execute a mutually
exclusive subset of it, which results in all the tests being executed.

The main property of this form being the sharda are completely unaware of each
other and can fail independently.

### Options

```shell
--shard-count XX --shard-index XX
```

## Token sharding

Token sharding can be used with local sharding only. The flag will be
inoperational in non-local sharding use cases. Sometimes one of the devices
involved in sharding holds special resources that others don't, such as a SIM
card. Some tests might only work when that special resource is available and
would fail otherwise.

*Token sharding* is our solution to such use cases. Test modules are able to
declare which special resource they need in their `AndroidTest.xml`, and
Tradefed will route the tests to a device that has the resource.

## XML configuration

```XML
<option name="config-descriptor:metadata" key="token" value="SIM_CARD" />
```

The `value` of the token matches Tradefed's
[TokenProperty](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/invoker/shard/token/TokenProperty.java)
and is associated with a handler in
[TokenProviderHelper](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/invoker/shard/token/TokenProviderHelper.java).

This allows for test modules to be run against devices that can properly execute the tests.

### What if no devices can run the test?

If no devices available have the resource matching the test module,
the test module will be failed and skipped since it cannot execute properly.

For example, if a test module requests a SIM card to run but no devices have a
SIM card the test module fails.

### Implementation

Pass this feature flag to the main Tradefed command line:

```shell
--enable-token-sharding
```
