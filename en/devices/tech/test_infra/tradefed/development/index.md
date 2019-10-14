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

# Developing Tradefed

This section is aimed at Tradefed developers. If you are interested in extending
TF or adding new test support, this is the section for you.

## Open source

If you plan to use the open source variant of Trade Federation, use these
commands to check out and build the AOSP `master` branch of Trade Federation:

```shell
cd <sourceroot>
mkdir master
cd master
repo init -u https://android.googlesource.com/platform/manifest -b master
repo sync -c -j8
source build/envsetup.sh
tapas tradefed-all
make -j8
```


See [Development Environment](/devices/tech/test_infra/tradefed/fundamentals/machine_setup.html)
for more details.

All open-sourceable Trade Federation code is stored in the
[tools/tradefederation/](https://android.googlesource.com/platform/tools/tradefederation/)
git project of AOSP. Please keep the
[open source guidelines](/setup/contribute/code-style)
in mind when writing code and submitting changes.

Alternatively, if you are creating tests/utilities that use Trade Federation but
aren't working on the framework itself, consider placing your work inside one of
the [Trade Federation contrib projects](contribute-noncore) to speed approvals.

## Coding style

Trade Federation follows the
[Android coding style guidelines](/source/code-style.html),
with the following clarifications: interface names are prefixed with 'I' e.g.
ITestDevice.

## Developing using Eclipse

If you are interested in using Eclipse in developing Tradefed, refer to
[Set up Eclipse IDE](eclipse) for tips on
setting up your environment.

## Running Tradefed's tests

You made a change to Trade Federation and you are searching how to test it? see
[Running Trade Federation's tests](tf-unit-tests).

## Architecture

If you seek a deeper understanding of the innerworkings of Tradefed, see the
[Architecture](/devices/tech/test_infra/tradefed/architecture) section.
