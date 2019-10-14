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

# 5G Non-Standalone (NSA)

Devices running Android {{ androidQVersionNumber }} or higher can support 5G
non-standalone (NSA). 5G NSA
is a solution for 5G networks where the network is supported by the existing 4G
infrastructure. On Android {{ androidQVersionNumber }}, devices can display a
5G icon on the status bar
when a device connects to a 5G network.

## Implementation

### Carrier configuration

To configure how 5G icons are displayed on the status bar, carriers can use the
[`KEY_5G_ICON_CONFIGURATION_STRING`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/telephony/java/android/telephony/CarrierConfigManager.java#2459){: .external}
key in `CarrierConfig`.

There are four states in 5G NSA:

1.  Device connected to 5G cell as the secondary cell and using
    millimeter wave.
1.  Device connected to 5G cell as the secondary cell but not using
    millimeter wave.
1.  Device camped on a network that has 5G capability (device doesn't have
    to be connected to a 5G cell as a secondary cell) and the use of 5G isn't
    restricted.
1.  Device camped on a network that has 5G capability (device doesn't have
    to be connected to a 5G cell as a secondary cell) but the use of 5G is
    restricted.

The configuration string contains multiple key-value pairs separated by commas.
For each pair, the key and value are separated by a colon. The keys in the
configuration string correspond to one of the four 5G states described above
and must be one of the following:

1.  `connected_mmwave`
1.  `connected`
1.  `not_restricted`
1.  `restricted`

The values in the configuration string must be valid icon names that match the
names of icons in the `/packages/SystemUI/res/` directory. Two default icons
for 5G NSA are available: `5G` and `5G_PLUS`.

![5G NSA icons](/devices/tech/connect/images/5g-nsa-icons.png)

**Figure 1.** Default `5G` and `5G_PLUS` 5G icons

The following is an example of a configuration string for 5G icons in
`CarrierConfig`.

```
connected_mmwave:5G_PLUS,connected:5G,not_restricted:None,restricted:None
```

### System UI

To customize the icons that carriers can use for a specific status, add a
`MobileIconGroup` object in
[`TelephonyIcons.java`](https://android.googlesource.com/platform/frameworks/base/+/master/packages/SystemUI/src/com/android/systemui/statusbar/policy/TelephonyIcons.java#25){: .external}.
The icon name in `MobileIconGroup` must match the icon name used in
`CarrierConfig`. The following shows an example of how to add a customized icon
with the name "5G_PLUS" to `MobileIconGroup`.

```
static final MobileIconGroup NR_5G_PLUS = new MobileIconGroup(
            "5G_PLUS",
            null,
            null,
            AccessibilityContentDescriptions.PHONE_SIGNAL_STRENGTH,
            0,
            0,
            0,
            0,

AccessibilityContentDescriptions.PHONE_SIGNAL_STRENGTH[0],
            R.string.data_connection_5g_plus,
            TelephonyIcons.ICON_5G_PLUS,
            true);
```

## Validation

To validate your implementation, make sure a 5G icon is displayed on the status
bar when the device is connected to a 5G cell.

