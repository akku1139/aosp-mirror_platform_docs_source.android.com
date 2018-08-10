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

# Supporting Batteryless Devices

This page describes how Android handles products that have either removable
batteries or no internal batteries. The latter devices are instead connected to
an external power source, such as an AC power outlet or USB port on another
device.


## Is a battery present?

The following code may be used by applications to detect whether the device has
a battery currently present:

    ```
    final Intent batteryInfo = registerReceiver(null, new
    IntentFilter(Intent.ACTION_BATTERY_CHANGED));

    return batteryInfo.getBooleanExtra(BatteryManager.EXTRA_PRESENT, true);
    ```

## Batteryless device behavior

If Android does not detect a battery device for your product, then the following
battery-related default values are used. Note the defaults have changed in the
Android {{ androidPVersionNumber }} release. This table shows the differences.

<table>
  <tr>
   <th>Battery state
   </th>
   <th>Android {{ androidPVersionNumber }} and higher
   </th>
   <th>Android 8.1 and lower
   </th>
  </tr>
  <tr>
   <td><em>Present</em>
   </td>
   <td>false
   </td>
   <td>true
   </td>
  </tr>
  <tr>
   <td><em>Status</em>
   </td>
   <td>unknown
   </td>
   <td>charging
   </td>
  </tr>
  <tr>
   <td><em>Remaining capacity</em>
   </td>
   <td>0
   </td>
   <td>100%
   </td>
  </tr>
  <tr>
   <td><em>Health</em>
   </td>
   <td>unknown
   </td>
   <td>good
   </td>
  </tr>
  <tr>
   <td><em>AC charger online status</em>
   </td>
   <td>not modified
   </td>
   <td>forced to true
   </td>
  </tr>
</table>


Manufacturers may alter the default settings using a kernel
[power_supply](https://www.kernel.org/doc/Documentation/power/power_supply_class.txt){: .external}
driver or [Health HAL](/devices/tech/health/).

### Android {{ androidPVersionNumber }} and higher

Android {{ androidPVersionNumber }} removes some previous code for batteryless
devices that by default pretended a battery was present, was being charged at
100%, and was in good health with a normal temperature reading on its
thermistor.

Most framework APIs that deal with this information continue to handle common
situations the same as previously: the system will be considered to be
_charging_ (that is, not running on battery power), and will not be considered
to have a low battery. If the user interface draws the battery icon, it will
appear with an exclamation point, and battery percentage will be shown as 0%.
But the device will not shut down due to low battery, and jobs that require
charging or good battery will be scheduled.


### Android 8.1 and lower

Because the battery status is unknown, the Android framework APIs will consider
the system to be _charging_ (or, not running on battery power) and will not be
considered to have a low battery. If the user interface renders the battery
icon, it will appear with an exclamation point, and battery percentage will be
shown as 0%. But the device will not shut down due to low battery, and jobs that
require charging or good battery will be scheduled.


## Implementation

The Android {{ androidPVersionNumber }} default code may work properly for your
device, but it is recommended to make either a kernel or a HAL change to
accurately reflect the power and battery state for your product, as described
above. If Android {{ androidPVersionNumber }} and higher does not detect a [Linux power supply
class](https://www.kernel.org/doc/Documentation/power/power_supply_class.txt){: .external}
charger device, then by default all charger types (AC, USB, Wireless) will have
status _offline_. If all chargers are offline but there is no battery device
detected, the system will still be considered to be charging in the sense that
it is running on external, not battery power, as described previously.

If your product does not have a battery and is always connected to a power
source, it's best to implement a Linux kernel power_supply class _charger_
driver for the AC or USB power source that sets its _online_ `sysfs` attribute
to `true`. Or you can configure the AC charger online property in a Health HAL
for your device. To do this implement a Health HAL as described in [Implementing
Health 2.0](/devices/tech/health/implementation).

This custom Health HAL implements a custom version of `Health::getHealthInfo()`
that modifies the value of `BatteryProperties.chargerAcOnline = true`.

To get started, copy file
<code>[hardware/interfaces/health/2.0/default/Health.cpp](https://android.googlesource.com/platform/hardware/interfaces/+/master/health/2.0/default/Health.cpp)</code>
to your own Health HAL implementation and modify it according to the [Health 2.0
README](https://android.googlesource.com/platform/hardware/interfaces/+/master/health/2.0/README).
