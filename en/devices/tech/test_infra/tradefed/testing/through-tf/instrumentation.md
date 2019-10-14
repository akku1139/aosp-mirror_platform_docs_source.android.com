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

# Running Instrumentation Tests from existing APKs

These instructions assume you have the `Trade Federation` package available
locally; if not,
[follow the download instructions](/devices/tech/test_infra/tradefed/fundamentals/machine_setup#download-tradefed)
to obtain it.

Then use the following command to install the APK of instrumentation tests,
execute the tests, and display the tests that are running:

```shell
./tradefed.sh run instrumentations --apk-path <path of your apk>
```

With output resembling:

```shell
07-17 10:55:32 D/InvocationToJUnitResultForwarder: Starting test: android.animation.cts.ValueAnimatorTest#testOfArgb
07-17 10:55:33 D/InvocationToJUnitResultForwarder: Starting test: android.animation.cts.ValueAnimatorTest#testIsRunning
07-17 10:55:34 D/InvocationToJUnitResultForwarder: Starting test: android.animation.cts.ValueAnimatorTest#testGetCurrentPlayTime
07-17 10:55:35 D/InvocationToJUnitResultForwarder: Starting test: android.animation.cts.ValueAnimatorTest#testStartDelay
07-17 10:55:35 I/InvocationToJUnitResultForwarder: Run ended in 2m 20s
```

You can optionally specify `--serial <device serial number>` to run
against a given device. The serial number of your device can be otained
using `adb devices`.

See the
[Testing through Tradefed section](/devices/tech/test_infra/tradefed/testing/through-tf)
for more details about Tradefed executions.
