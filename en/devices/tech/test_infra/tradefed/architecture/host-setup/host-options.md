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

# Tradefed Host Options

Host options in Tradefed (TF) refer to options that are applied at the host level
(one TF instance), and affect the behavior of the harness itself. These options
usually do not affect tests themselves but rather support operations the harness
provides.


[Host Options](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/global_configuration/com/android/tradefed/host/HostOptions.java){: .external}
define a range of options that allows customization of TF behavior, such as:

*   How many devices can be flashed concurrently. This is useful for physical
    hosts with limited resources.
*   The directory files should be downloaded to. If the default temporary
    folder is not the right place for any reason, it's possible to change it.

[Read more about global configuration](/devices/tech/test_infra/tradefed/architecture/advanced/global-config).
