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

# Trade Federation Global Configuration

The Trade Federation (TF) Global Configuration is a file that is loaded once
upon TF initialization. This configuration file is used to define the
environment for that instance of TF.

## Loading the Global Configuration file

The TF Global Configuration file is an XML file and can be specified by setting
the local environment variable `TF_GLOBAL_CONFIG`. If `TF_GLOBAL_CONFIG` is
not specified, TF will try to locate a file named `tf_global_config.xml` in its
current working path. If that fails, TF will load the default Global
Configuration file. For example, you can launch TF with your custom global
configuration via the following command:

```
TF_GLOBAL_CONFIG=/path/to/my/custom/good_tf_global_conf.xml tradefed.sh
```

## Example Global Configuration File

```
<configuration description="Example Global Config">
  <device_manager class="com.android.tradefed.device.DeviceManager">
    <option name="max-null-devices" value="10" />
  </device_manager>
</configuration>
```

The example above sets the number of "null-device" placeholders to 10 instead of
the default value define in the `DeviceManager`.
