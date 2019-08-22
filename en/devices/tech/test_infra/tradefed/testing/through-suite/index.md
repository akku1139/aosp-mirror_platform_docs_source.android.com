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

# Test through a suite

## 1. Set up suite

Tests running through a suite differs from a standard test running directly
through Tradefed test runner.

See [Set up Suite](setup.md) for definitions and instructions.

## 2. Pass options to suite and modules

Various command lines and arguments can be used to pass options to the
suite-level or the module-levels.

See [Pass options to the suite and the modules](option-passing.md) for
instructions.

## 3. System Status Checker

System Status Checker is a component running between each module that can check
and clean up some states that the module might have forgotten to clean, for
example a module leaving a keyguard on.

See [System status checker](system-status-checker.md) for implementation and
use.

## 4. AndroidTest.xml structure

Each `AndroidTest.xml` file represents one test module. This section describes
the structure of an `AndroidTest.xml` configuration file, how they differ from
regular Tradefed configuration, and what is allowed and not allowed.

See [AndroidTest.xml structure](android-test-structure.md) for allowed tags and
an example configuration.

## 5. Tune sharding configuration

This section explains how to tune sharding aspects of your module configuration
and describes the benefits associated with each of them:

*   Declare your module shardable or not
*   Tune the possible number of shards for your module

See [Tune AndroidTest.xml modules](android-test-tuning.md) for details.

## 6. Controller

Module controllers are special objects that can be specified in
`AndroidTest.xml` to alter some aspect of the module's behavior. For example,
you may completely skip the module if some conditions are not met.

See [Module controllers](module-controller.md) for implementation and logging.

## 7. Retry

Suite Retry allows you to re-run a previous invocation of failed tests in order
to rule out flakiness or poor isolation that may have caused the first failure.

See [Suite Retry](suite-retry.md) for examples and use.
