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

# Pass options to suite and modules

First, ensure you understand [Option Handling](/devices/tech/test_infra/tradefed/fundamentals/options)
in Tradefed.

[Suite setup](setup.md) describes the two layers that exist in the
suite structure:

*   The top-level suite
*   The modules

In a non-suite Tradefed context, there is no need to think about it; every
option goes to the full invocation. In a suite context, modules are kept
isolated from the suite; so not all options are available at their level.

## Pass options to the top-level suite

The top-level suite behaves like standard Tradefed configuration: the full
configuration including the suite runner receives all the options like a
non-suite Tradefed configuration.

## Pass options to the modules

Modules by default *do not receive any* of the options passed to the command.
They need to be explicitly targeted to receive the options through the
`module-arg` option. This isolation of the modules options makes debugging
easier.

Example:

```shell
cts-tradefed run cts --module-arg <module-name>:<option-name>:<option-value>

cts-tradefed run cts --module-arg CtsGestureTestCases:collect-tests-only:true
```

The syntax ensures that the targeted module will receive the given option.

There are additional ways to pass options to modules such as `test-arg`, which
allows you to pass options to the test runner of each module based on the runner
type or class.

Example:

```shell
cts-tradefed run cts --test-arg <test-class>:<option-name>:<option-value>

cts-tradefed run cts --test-arg com.android.tradefed.testtype.JarHosttest:collect-tests-only:true
```

The syntax does not target a particular module but rather all the test runners
of the given class. `test-arg` considers only implementations of
[IRemoteTest](/reference/tradefed/com/android/tradefed/testtype/IRemoteTest)
as potential receiver of the options.
