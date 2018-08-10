Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
    Copyright 2018 The Android Open Source Project
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

# Deprecating health@1.0

The framework will continue to work with health@1.0 until it is fully deprecated
according to the standard
[HAL deprecation schedule](/devices/architecture/vintf/fcm#hal-version-deprecation).
When health@1.0 is deprecated (entry removed from
[framework compatibility matrix](https://source.android.com/devices/architecture/vintf/comp-matrices)),
`healthd` and `libbatterymonitor` must also be removed from system to avoid
unknown behaviors for healthd. As health@1.0 is an optional HAL and all
`healthd` dependencies to health@1.0 are guarded by NULL checks, nothing should
break on deprecation.

When Android removes the legacy code path (healthd, health@1.0), Health@1.0 HAL
is deprecated according to deprecation schedule. In addition, Android also
removes the following:

1.  healthd dependency in framework
1.  healthd
1.  health@1.0 HAL definition library from system
1.  health@1.0 entry in framework compatibility matrix

## Removing healthd

For devices launching with Android {{ androidPVersionNumber }} and devices
upgrading to Android {{ androidPVersionNumber }} that provide the Health 2.0 HAL
in the new vendor image, we recommend removing `healthd` from the system image
to save disk space and speed boot time.

To do so:

1.  Remove `healthd` and `healthd.rc` from the system image by adding the
    following line to the device-specific implementation in Soong:

        ```
        cc_binary {
            name: "android.hardware.health@2.0-service.device_name"
            overrides: ["healthd"],
            // ...
        }
        ```

        Or, if the module is in Make:

        ```yaml
        LOCAL_MODULE_NAME := \
            android.hardware.health@2.0-service.device_name
        LOCAL_OVERRIDES_MODULES := healthd
        ```

    If the default implementation `android.hardware.health@2.0-service` is
    installed, implement a device-specific
    `android.hardware.health@2.0-service.device_name` instead. For more
    information, see [Implementing Health](/devices/tech/health/implementation).

1.  Add the following lines to `BoardConfig.mk` to remove the backup instance
    from framework manifest. This ensures the framework manifest correctly
    reflects the HALs on the device and allows the relevant VTS tests to pass.

    ```make
    DEVICE_FRAMEWORK_MANIFEST_FILE += \
        system/libhidl/vintfdata/manifest_healthd_exclude.xml
    ```
