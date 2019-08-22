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

# Build Provider in Tradefed

Build Providers in TF are represented by the [IBuildProvider Interface](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/build/IBuildProvider.java).
Any implementation of the interface can be used in a test configuration. This
flexible design allows interacting with any type of system.

Build Provider creates [Build Info](/devices/tech/test_infra/tradefed/architecture/build-provider/build-info)
populated with all the resources needed by the setup and tests.

## Local build providers

When running locally, several possible configurations exist:

*   Find and use a locally built device image: [LocalDeviceBuildProvider](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/build/LocalDeviceBuildProvider.java).
    This is typically used to flash a locally built Android
    image before running its tests.
*   Find and use locally built test cases: [BootstrapBuildProvider](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/build/BootstrapBuildProvider.java).
    This is typically used to run tests against an
    already flashed and ready device. This is the provider used by
    [Atest](/compatibility/tests/development/atest) during local testing.

## Configuration

Use the object tag `build_provider`. For example:

```xml
<build_provider class="com.android.tradefed.build.BootstrapBuildProvider" />
```
