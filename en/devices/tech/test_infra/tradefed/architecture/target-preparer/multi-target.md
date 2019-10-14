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

# Multi-Target Preparer

Similar to
[Target Preparer](/devices/tech/test_infra/tradefed/architecture/target-preparer),
multi-target preparer allows setup of multiple devices together. For example,
this would be used when connecting two devices via Bluetooth for testing.

## Base interface

The base interface is
[IMultiTargetPreparer](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/targetprep/multi/IMultiTargetPreparer.java),
which allows implementing a `setUp` method that will be executed. We recommend
implementing our basic abstract class
[BaseMultiTargetPreparer](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/targetprep/multi/BaseMultiTargetPreparer.java),
which provides a built-in disablement feature to easily disable a preparer.

Multi-target preparers also directly provide a `tearDown` method for any cleanup
operation.

## Recommendation

We recommend each preparer be limited to a single main function. This allows
for easier re-use of preparers.

You should also check the list of available preparers before adding a new one to
avoid duplicating work. Preparers are available in:

[tools/tradefederation/core/src/com/android/tradefed/targetprep/multi/](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/targetprep/multi)

There is no limit to the number of devices that a multi-target preparer can
set up. All the devices are available in the `IInvocationContext` of the
interface to implement.

## XML configuration

The object tag will be `multi_target_preparer`, for example:

```xml
<multi_target_preparer class="com.android.tradefed.targetprep.multi.HelloWorldMultiTargetPreparer">
</multi_target_preparer>
```

## Operation order

1.  `multi_target_preparer` executes `setUp` **after** `target_preparer`
1.  `multi_target_preparer` executes `tearDown` **before** target cleaners

This does not always allow performance of all setup steps, so it is possible in
theXML to define the multi-target preparer as `multi_pre_target_preparer` and
execute it before `target_preparers`.

```xml
<multi_pre_target_preparer class="com.android.tradefed.targetprep.multi.HelloWorldMultiTargetPreparer">
</multi_pre_target_preparer>
```

The overall operation order is as followed:

1.  multi_pre_target_preparer(s) setUp
1.  target_preparer(s) setUp
1.  multi_target_preparer(s) setUp
1.  multi_target_preparer(s) tearDown
1.  target_preparer(s) tearDown
1.  multi_pre_target_preparer(s) tearDown

Any multi-target preparer can be declared as `multi_target_preparer` or
`multi_pre_target_preparer` depending of what order of setup is required.
