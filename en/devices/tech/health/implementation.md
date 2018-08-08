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

# Implementing Health

All `healthd` code has been refactored into health@2.0-impl and
`libhealthservice`, then modified to implement health@2.0 HAL. These two
libraries are linked statically by health@2.0-service, enabling it to do the
work previously done by `healthd` (i.e. run the `healthd_mainloop` and do
polling). In init, the health@2.0-service registers an implementation of the
interface `IHealth` to `hwservicemanager`. When upgrading devices with an
Android 8.x vendor image and an Android {{ androidPVersionNumber }} framework,
health@2.0 service might not be provided by the vendor image. This is enforced
by the
[deprecation schedule](/devices/architecture/vintf/fcm#hal-version-deprecation).

To resolve this issue:

1.  `healthd` registers `IHealth` to `hwservicemanager` (despite being a system
    daemon). `IHealth` is added to the system manifest, with instance name
    "backup".
1.  Framework and `storaged` communicate with `healthd` via `hwbinder` instead
    of `binder`.
1.  Code for framework and `storaged` are changed to fetch the instance
    "default" if available, then "backup".
    *   C++ client code uses the logic defined in `libhealthhalutils`.
    *   Java client code uses the logic defined in `HealthServiceWrapper`.
1.  After IHealth/default is widely available and Android 8.1 vendor images are
    deprecated, IHealth/backup and `healthd` can be deprecated. For more
    details, see [Deprecating health@1.0](/devices/tech/health/deprecation).

## Board-specific build variables for healthd

`BOARD_PERIODIC_CHORES_INTERVAL_*` are board-specific variables used to build
`healthd`. As part of system/vendor build split, board-specific values
**cannot** be defined for system modules. In health@2.0, vendors can override
these two values in `healthd_mode_ops->init` (by dropping `libhealthservice`
dependency in `health@2.0-service.<device>` and re-implementing this function).

## Static implementation library

Unlike other HAL implementation libraries, the implementation library
health@2.0-impl is a **static** library to which health@2.0-service, charger,
recovery, and legacy healthd link.

health@2.0.impl implements `IHealth` as described above and is meant to wrap
around `libbatterymonitor` and <code>libhealthd.<var>BOARD</var></code>. These
users of health@2.0-impl must not use `BatteryMonitor` or the functions in
`libhealthd` directly; instead, these calls should be replaced with calls into
the `Health` class, an implementation of the`IHealth` interface. To generalize
further, `healthd_common` code is also included in health@2.0-impl. The new
`healthd_common` contains the rest of common code between health@2.0-service,
charger, and `healthd` and calls into IHealth methods instead of BatteryMonitor.

## Implementing Health 2.0 service

When implementing health@2.0 service for a device, if the default implementation
is:

*   Sufficient for the device, use `android.hardware.health@2.0-service`
    directly.
*   Not sufficient for the device, create the
    `android.hardware.health@2.0-service.(device)` executable and include:

    ```
    #include <health2/service.h>
    int main() { return health_service_main(); }
    ```

Then:

+   If board-specific `libhealthd:`

    +   Does exist, link to it.
    +   Does not exist, provide empty implementations for `healthd_board_init`
        and `healthd_board_battery_update` functions.

+   If board-specific `BOARD_PERIODIC_CHORES_INTERVAL_*` variables:

    +   Are defined, create a device-specific `HealthServiceCommon.cpp` (copied
        from `hardware/interfaces/health/2.0/utils/libhealthservice`) and
        customize it in `healthd_mode_service_2_0_init`.
    +   Are not defined, link to `libhealthservice` statically.

+   If device:

    +   Should implement `getStorageInfo` and `getDiskStats` APIs, provide the
        implementation in `get_storage_info` and `get_disk_stats` functions.
    +   Should not implement those APIs, link to `libstoragehealthdefault`
        statically.

*   Update necessary SELinux permissions.

For details, refer to
[hardware/interfaces/health/2.0/README.md](https://android.googlesource.com/platform/hardware/interfaces/+/master/health/2.0/README.md).

## Health clients

health@2.0 has the following clients:

+   **charger**. The usage of `libbatterymonitor` and `healthd_common` code is
    wrapped in health@2.0-impl.
+   **recovery**. The linkage to `libbatterymonitor` is wrapped in
    health@2.0-impl. All calls to `BatteryMonitor` are replaced by calls into
    `Health` implementation class.
+   **BatteryManager**. `BatteryManager.queryProperty(int id)` was the only
    client of `IBatteryPropertiesRegistrar.getProperty` which was provided by
    `healthd` and directly reads `/sys/class/power_supply`.

    As a security consideration, apps are not allowed to call into health HAL
    directly. In Android {{ androidPVersionNumber }}, the binder service
    `IBatteryPropertiesRegistrar` is provided by `BatteryService` instead of
    `healthd` and `BatteryService` delegates the call to health HAL to retrieve
    the requested information.

+   **BatteryService**. In Android {{ androidPVersionNumber }}, `BatteryService`
    uses `HealthServiceWrapper` to determine the health service instance to use
    ("default" instance from vendor or "backup" instance from healthd). It then
    listens for health events via `IHealth.registerCallback`.

+   **Storaged**. In Android {{ androidPVersionNumber }}, `storaged` uses
    `libhealthhalutils` to determine the health service instance to use
    ("default" instance from vendor or "backup" instance from healthd). It then
    listens for health events via `IHealth.registerCallback` and retrieves
    storage information.

## SELinux changes

The new health@2.0 HAL includes the following SELinux changes:

+   Adds health@2.0-service to `file_contexts`.
+   Allows `system_server` and `storaged` to use `hal_health`.
+   Allows `system_server` (`BatteryService`) to register
    `batteryproperties_service` (`IBatteryPropertiesRegistrar`).
+   Allows `healthd` to provide `hal_health`.
+   Removes rules that allow `system_server` / `storaged` to call into `healthd`
    via binder.
+   Removes rules that allow `healthd` to register `batteryproperties_service`
    (`IBatteryPropertiesRegistrar`).

For devices with their own implementation, some vendor SELinux changes may be
necessary. Example:

```
# device/<manufacturer>/<device>/sepolicy/vendor/file_contexts
/vendor/bin/hw/android\.hardware\.health@2\.0-service.<device> u:object_r:hal_health_default_exec:s0

# device/<manufacturer>/<device>/sepolicy/vendor/hal_health_default.te
# Add device specific permissions to hal_health_default domain, especially
# if it links to board-specific libhealthd or implements storage APIs.
```

## Kernel interfaces

The `healthd` daemon and the default implementation
`android.hardware.health@2.0-service` access the following kernel interfaces to
retrieve battery information:

+   `/sys/class/power_supply/*/capacity`
+   `/sys/class/power_supply/*/charge_counter`
+   `/sys/class/power_supply/*/charge_full`
+   `/sys/class/power_supply/*/current_avg`
+   `/sys/class/power_supply/*/current_max`
+   `/sys/class/power_supply/*/current_now`
+   `/sys/class/power_supply/*/cycle_count`
+   `/sys/class/power_supply/*/health`
+   `/sys/class/power_supply/*/online`
+   `/sys/class/power_supply/*/present`
+   `/sys/class/power_supply/*/status`
+   `/sys/class/power_supply/*/technology`
+   `/sys/class/power_supply/*/temp`
+   `/sys/class/power_supply/*/type`
+   `/sys/class/power_supply/*/voltage_max`
+   `/sys/class/power_supply/*/voltage_now`

Any device-specific health HAL implementation that uses `libbatterymonitor`
accesses these kernel interfaces by default, unless overridden in
`healthd_board_init(struct healthd_config*)`.

If these files are missing or are inaccessible from `healthd` or from the
default service (e.g. the file is a symlink to a vendor-specific folder that
denies access because of misconfigured SELinux policy), they may not function
correctly. Hence, additional vendor-specific SELinux changes may be necessary
even though the default implementation is used.

## Testing

Android {{ androidPVersionNumber }} includes new [VTS tests](/compatibility/vts)
written specifically for the health@2.0 HAL. If a device declares to provide
health@2.0 HAL in the device manifest, it must pass the corresponding VTS tests.
Tests are written for both the default instance (to ensure that the device
implements the HAL correctly) and the backup instance (to ensure that `healthd`
continues to function correctly before it is removed).
