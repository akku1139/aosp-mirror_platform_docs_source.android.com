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

# Overview of Trade Federation Architecture

This section describes the internals of Tradefed and their relationships. See
the linked subpages for more details.

## 1. Test Configuration (XML configs)

### Overview

Test configurations in Tradefed are described in an XML format. Understanding
the structure of the configuration is key to running and customizing tests.

### Structure of TF configurations

*   [High-level structure](/devices/tech/test_infra/tradefed/architecture/xml-config)
*   [Templates and includes](/devices/tech/test_infra/tradefed/architecture/xml-config/template-include)
*   [Configuration object](/devices/tech/test_infra/tradefed/architecture/xml-config/config-object)

### Global TF configurations

Global Configuration is a special Tradefed XML configuration that is loaded when
Tradefed starts via the `TF_GLOBAL_CONFIG` environment variable. It loads
objects related to the Tradefed instance scope that will affect the overall
harness behavior.

[Global Configuration details](/devices/tech/test_infra/tradefed/architecture/advanced/global-config)

### Keystore

Keystore allows injection of command line options to Tradefed coming from
a keystore in order to avoid referencing the value directly on the command line.
This can be used to hide passwords from the command line by retrieve passwords
from the keystore directly.

[Keystore details](/devices/tech/test_infra/tradefed/architecture/advanced/keystore)

## 2. Device manager
The Device Manager is responsible for keeping track of the state of devices on a
running instance of Tradefed. Aspects such as allocation status and online
status are monitored.

*   [Device States](/devices/tech/test_infra/tradefed/architecture/device-manager)
*   [Device Allocation](/devices/tech/test_infra/tradefed/architecture/device-manager/device-allocation)
*   [Device Detection Sequence](/devices/tech/test_infra/tradefed/architecture/device-manager/device-detection)

## 3. Test Command Scheduler

The Test Command Scheduler in Tradefed takes commands to run, associates them
with devices, and starts a test invocation.

*   [Test Command life cycle](/devices/tech/test_infra/tradefed/architecture/advanced/command-scheduler)

## 4. Build provider

Build Provider is the first step of any test invocation. It downloads resources
needed to set up and run the tests (build images, test APKs, and more.). It also
references them in a `BuildInfo` object that will be passed to the test. Locally
available resources can also be linked in the `BuildInfo` object.

*   [Build Providers Details](/devices/tech/test_infra/tradefed/architecture/build-provider)
*   [Build Info Details](/devices/tech/test_infra/tradefed/architecture/build-provider/build-info)

## 5. Target Preparer and Cleaner

Target Preparer offers optional actions that can be taken to configure the
target under test into a certain state, for example flashing the device, setting
certain properties, and connecting to Wi-Fi.

*   [Add a new target preparer/cleaner](/devices/tech/test_infra/tradefed/architecture/target-preparer)
*   [Add a new multi target preparer](/devices/tech/test_infra/tradefed/architecture/target-preparer/multi-target)

## 6. Test Runner

A Test Runner in Tradefed refers to the object responsible for the actual test
execution. Different test runners drive test execution in different ways; for
example, an instrumentation test runner will be very different from a JUnit test
runner.

*   [Test Runner Structure](/devices/tech/test_infra/tradefed/architecture/advanced/test-runner)

## 7. Result Reporter

Result Reporter in Tradefed refers to the object that will send the results to a
particular destination. Each implementation is usually specialized for different
result back-ends. And the Result Reporter is in charge of converting the
Tradefed results format into the destination format.

This flexible design allows any test to report to any of the results
destinations and to easily have more tests added in an isolated way.

*   [Add a Result Reporter](/devices/tech/test_infra/tradefed/architecture/result-reporter)
*   [Result Reporter and Logs](/devices/tech/test_infra/tradefed/architecture/result-reporter/log-reporter)
*   [Result Reporter Summary](/devices/tech/test_infra/tradefed/architecture/result-reporter/summary)

## 8. Metrics Collector

Metrics Collector is a special object in Tradefed, orthogonal to the test
execution. It allows collection of information at different points of the test
lifecycle (for example, test start, test end). Since the collector is decoupled
from the test itself, the points can be swapped, added, and removed without
having to change the test itself.

*   [Host-driven metrics collectors](/devices/tech/test_infra/tradefed/architecture/metrics-collector)
*   [Device side metrics collectors](/devices/tech/test_infra/tradefed/architecture/metrics-collector/device-collector)

## 9. Host-wide setup

This section describes setups that are applicable to a full Tradefed instance's
running. These options affect the behavior of the harness as a whole in order to
adapt to different environments, for example being in a restricted network.

*   [Global configuration](/devices/tech/test_infra/tradefed/architecture/advanced/global-config)
*   [Host Options](/devices/tech/test_infra/tradefed/architecture/host-setup/host-options)

--------------------------------------------------------------------------------

## 10. Additional features

The following sections describe general usage of Tradefed rather than Tradefed
objects.

### Tradefed sharding

When the test corpus is large or takes a long time to execute, it's possible to
split it across several devices. We refer to this split as *sharding*. This
section describes how sharding works and how it is configured.

[Sharding details](/devices/tech/test_infra/tradefed/architecture/advanced/sharding)

### Using SL4A

Tradefed supports the scripting layer for Android, SL4A; this is an automation
toolset for calling Android APIs in a platform-independent manner.

[SL4A with Tradefed details](/devices/tech/test_infra/tradefed/architecture/advanced/scripting-sl4a)

### Dynamic @Option download

In some cases, the files needed by a test or some particular operation are not
available locally. This feature allows Tradefed to get these files from a remote
location without going through a Build Provider.

[Dynamic @option download](/devices/tech/test_infra/tradefed/architecture/advanced/protocols-global-config)
