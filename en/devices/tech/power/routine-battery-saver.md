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

# Routine Battery Saver

Android {{ androidQVersionNumber }} introduces a battery saver schedule option
called **based on routine**. This option allows an app chosen by the OEM to
provide signals to the system for more intelligent battery saver scheduling.
This option requires configuration, and is optional to implement.

## Device configuration

### Provider specification

To notify the Settings UI that the device is configured correctly, use your
config overlay to override the value `config_batterySaverScheduleProvider` with
the package name of your app.

For example, if you want the app package `com.google.android.apps.turbo` to
control the **based on routine** setting, then you would set this config value:

```
<string name="config_batterySaverScheduleProvider" translatable="false">
com.google.android.apps.turbo</string>
```

Now the phone should show the **based on routine** option. To verify, build your
image, flash it to a phone, and navigate to **Settings > Battery > Battery
Saver > Battery Saver Schedule**. The **based on routine** option should appear.

### Default off threshold

The new `config_dynamicPowerSavingsDefaultDisableThreshold` field specifies a
battery level at which the system turns off battery saver, if it was turned on
by the **based on routine** scheduler. The system default is 80%, but you can
change it.

Important: Set this value lower than 100. This disable threshold serves as a
fallback in case something goes wrong with the provider app, causing it to
always try to trigger battery saver.

## App configuration

### Permissions

The APIs needed for the app to turn on battery saver from the app are protected
by the permission `android.permission.POWER_SAVER`. This is a
signature/privileged permission, so grant the app you want to be able to trigger
battery saver this permission in your `privapp-whitelist`.

An example of granting the `privapp` permission to an app:

```
<privapp-permissions package="com.google.android.apps.turbo">
   <permission name="android.permission.POWER_SAVER"/>
</privapp-permissions>
```

If you don't pre-grant this permission to the version of the app on the system
image, the app can't acquire the permission or properly call the APIs. The
system doesn't provide any feedback beyond the usual permission errors, so
verify that you can call the APIs and observe their effects.

### Installation

For **based on routine** to work properly, you must pre-install the app on the
system image with the required permission. Give only one app the `POWER_SAVER`
permission and allow it to control the **based on routine** APIs. Behavior of
the feature when more than one app tries to use the permission and APIs is
unsupported and unspecified.

## Triggering battery saver

### APIs

Assuming setup is successful so far, the OEM app specified in the config should
be able to successfully call the associated method in PowerManager to trigger
battery saver:

```
public boolean setDynamicPowerSaveHint(boolean powerSaveHint, int disableThreshold)
```

If the **based on routine** battery saver schedule option is enabled and the app
calls this method with a `true` value for `powerSaveHint`, then battery saver
turns on. Specify `disableThreshold` so that if the app can't communicate with
the system, the system still knows at which battery percentage it's safe to turn
off battery saver.

This API is subject to user overrides and battery saver snoozing in the same way
as the percentage-based automatic battery saver. See the
[API documentation](https://www.google.com/url?q=https://android.googlesource.com/platform/frameworks/base/%2B/refs/heads/master/core/java/android/os/PowerManager.java&sa=D&ust=1561505210635000&usg=AFQjCNHmYZbszVZarWJcvy9c0C0lrc_cSA){: .external}
for more information.

To verify the APIs are called successfully, query settings global to verify that
the backing setting changed value
[according to the API calls](https://www.google.com/url?q=https://android.googlesource.com/platform/frameworks/base/%2B/refs/heads/master/core/java/android/provider/Settings.java&sa=D&ust=1561505210630000&usg=AFQjCNGZwaaAYHjWE6NR1OH1blX8xi6HHw){: .external}.

For example, if the user selected **routine battery saver** mode and the app is
calling `setDynamicPowerSaveHint(true, 10)`, the global settings should have
these values:

```
automatic_power_save_mode: 1
dynamic_power_savings_disable_threshold: 10
dynamic_power_savings_enabled: 1
```

If you then call `setDynamicPowerSaveHint(false, 25)`, the values should be:

```
automatic_power_save_mode: 1
dynamic_power_savings_disable_threshold: 25
dynamic_power_savings_enabled: 0
```

You can check these values using this `adb` command:

```
adb shell settings get global <setting-name>
```

### Verification

There's no automated way to verify this feature because there's no way to know
what behavior an OEM will use to decide when to trigger routine battery saver
mode. OEMs are thus responsible for testing their integration to make sure that
the behavior meets expectations. In particular, verify that the device can
fulfill the following tasks:

*   The user selects **based on percentage** in the battery saver schedule UI
    and selects 15%. Battery saver should come on automatically ONLY when
    hitting 15% battery.
*   The user selects **based on routine** in the battery saver schedule UI. When
    the app calls the API with `true`, battery saver turns on. Additionally,
    battery saver automatically turns off if the device is charged to the
    indicated threshold level and unplugged.
*   The user selects **none** in the battery saver schedule UI. Battery saver
    should NEVER come on automatically.
*   If the app turns on battery saver and the user manually overrides battery
    saver to be off again (using Quick Settings, Settings, etc.), it should STAY
    OFF until the user either turns it back on again manually or plugs the
    device in.
