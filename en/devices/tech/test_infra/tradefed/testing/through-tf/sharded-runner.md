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

# Write a Sharded IRemoteTest Test Runner

When writing a test runner, it's important to think about scalability. Ask
yourself, "if my test runner had to run 200K test cases" how long would it take?

Sharding is one of the answers available in Trade Federation. It requires
splitting all the tests the runner needs into several chunks that can be
parallelized.

This page describes how to make your runner shardable for Tradefed.

## Interface to implement

The single most important interface to implement to be considered shardable by
TF is
[IShardableTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/IShardableTest.java),
which contains two methods: `split(int numShard)` and `split()`.

If your sharding is going to depend on the number of shards requested, you
should implement `split(int numShard)`. Otherwise, implement `split()`.

When a TF test command is executed with sharding parameters `--shard-count` and
`--shard-index`, TF iterates through all `IRemoteTest` to look for ones
implementing `IShardableTest`. If found, it will call `split` to
get a new `IRemoteTest` object to run a subset of test cases for a specific
shard.

## What should I know about the split implementation?

*   You runner may shard upon some conditions only; in that case return `null`
    when you did not shard.
*   Try to split as much as it makes sense: split your runner into unit of
    execution that makes sense for it. It really depends of your runner. For
    example:
    [HostTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/HostTest.java)
    is sharded at the Class level, each test class is put in a separate shard.
*   If it makes sense, add some options to control the sharding a little bit.
    For example:
    [AndroidJUnitTest](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/AndroidJUnitTest.java)
    has a `ajur-max-shard` to specify the maximum number of shards it could
    split in, regardless of the number requested.

## Detailed example implementation

Here is an example code snippet implementing `IShardableTest` you can
reference. The full code is avaiable at
(https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/InstalledInstrumentationsTest.java)

```java
/**
 * Runs all instrumentation found on current device.
 */
@OptionClass(alias = "installed-instrumentation")
public class InstalledInstrumentationsTest
        implements IDeviceTest, IResumableTest, IShardableTest {
    ...

    /** {@inheritDoc} */
    @Override
    public Collection<IRemoteTest> split(int shardCountHint) {
        if (shardCountHint > 1) {
            Collection<IRemoteTest> shards = new ArrayList<>(shardCountHint);
            for (int index = 0; index < shardCountHint; index++) {
                shards.add(getTestShard(shardCountHint, index));
            }
            return shards;
        }
        // Nothing to shard
        return null;
    }

    private IRemoteTest getTestShard(int shardCount, int shardIndex) {
        InstalledInstrumentationsTest shard = new InstalledInstrumentationsTest();
        try {
            OptionCopier.copyOptions(this, shard);
        } catch (ConfigurationException e) {
            CLog.e("failed to copy instrumentation options: %s", e.getMessage());
        }
        shard.mShardIndex = shardIndex;
        shard.mTotalShards = shardCount;
        return shard;
    }
    ...
}
```

This example simply creates a new instance of itself and sets shard
parameters to it. However, the splitting logic can be totally different from
test to test; and as long as it is deterministic and yields collectively
exhaustive subsets, it is okay.

## Independence

Shards need to be independent! Two shards created by your implementation of
`split` in your runner should not have dependencies on each other or share
resources.

Shards splitting needs to be deterministic! This is also mandatory, given the
same conditions, your `split` method should always return the exact same list of
shards in the same order.

NOTE: Since each shard can run on different TF instances, it is critical to
ensure the `split` logic yields subsets that are mutually exclusive and
collectively exhaustive in a deterministic manner.

## How to shard a test locally

To shard a test on a local TF, you can simply add the `--shard-count` option to
the command line.

```
tf >run host --class com.android.tradefed.UnitTests --shard-count 3
```

Then TF will automatically spawn commands for each shard and run them.

```
tf >l i
Command Id  Exec Time  Device          State
3           0m:03      [null-device-2]  running stub on build 0 (shard 1 of 3)
3           0m:03      [null-device-1]  running stub on build 0 (shard 0 of 3)
3           0m:03      [null-device-3]  running stub on build 0 (shard 2 of 3)
```

## Test result aggregation

Since TF does not do any test result aggregation for sharded invocations, you
need to make sure your reporting service supports it.
