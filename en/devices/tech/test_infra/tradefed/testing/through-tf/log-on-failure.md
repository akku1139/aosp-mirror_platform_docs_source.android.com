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

# Automated log on failure collection

When debugging tests, a set of logs is always needed to get a basic picture of
the failure and the device under test.
Sources include: Logcat, Tradefed host log, screenshot, etc.

In order to make it generic and painless for any test writer to get those logs,
Tradefed has a built-in mechanism to help collecting them.

## Configuration

To automatically collect some logs on failure, you can add the following option
to your Tradefed command line:

```shell
--auto-collect LOGCAT_ON_FAILURE
or
--auto-collect SCREENSHOT_ON_FAILURE
```

To see the full list of possible values, checkout
[AutoLogCollector](https://android.googlesource.com/platform/tools/tradefederation/+/master/src/com/android/tradefed/device/metric/AutoLogCollector.java)

For convenience, logcat and screenshot each have a direct flag:

```shell
--logcat-on-failure
and
--screenshot-on-failure
```

##  Note on suite modules (AndroidTest.xml)

Modules cannot direcly specify this option in the `AndroidTest.xml`, but they
can use a [module controller](/devices/tech/test_infra/tradefed/testing/through-suite/module-controller)
instead.
