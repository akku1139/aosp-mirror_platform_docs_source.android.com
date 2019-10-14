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

# Wi-Fi Preferred Network Offload Scanning

Wi-Fi preferred network offload (PNO) scans are low-powered Wi-Fi scans that
occur at regular intervals when a device is disconnected from Wi-Fi and the
screen is off. PNO scans are used to find and
connect to saved networks. These scans are scheduled by the framework using the
`NL80211_CMD_START_SCHED_SCAN` command. For more information, see
[nl80211.h](https://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git/tree/include/uapi/linux/nl80211.h){: .external}.

## Optimizing power usage with device mobility information

On devices running Android {{ androidPVersionNumber }} or lower, when the device
is disconnected from Wi-Fi and the screen is off, PNO scans occur at 20 second
intervals for the first three scans, then slow down to one scan every 60 seconds
for all subsequent scans. PNO scanning stops when a saved network is found or
the screen is turned on.

Android {{ androidQVersionNumber }} introduces an optional API method named
[`setDeviceMobilityState()`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/wifi/java/android/net/wifi/WifiManager.java#4656){: .external}
in `WifiManager` that increases the interval between
PNO scans based on the device's mobility state to reduce power consumption.

The possible mobility states are:

-   [`DEVICE_MOBILITY_STATE_UNKNOWN`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/wifi/java/android/net/wifi/WifiManager.java#4612){: .external}:
    Unknown mobility
-   [`DEVICE_MOBILITY_STATE_HIGH_MVMT`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/wifi/java/android/net/wifi/WifiManager.java#4623){: .external}:
    On a bike or in a motor vehicle
-   [`DEVICE_MOBILITY_STATE_LOW_MVMT`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/wifi/java/android/net/wifi/WifiManager.java#4634){: .external}:
    Walking or running
-   [`DEVICE_MOBILITY_STATE_STATIONARY`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/wifi/java/android/net/wifi/WifiManager.java#4644){: .external}:
    Not moving

If the device is stationary, the Android framework increases the
interval between PNO scans from 60 seconds to 180 seconds to reduce power
consumption. This optimization is made on the assumption that the device is
unlikely to find any new networks in PNO scans when the device is not moving.

If the device is in any other mobility state or if the method isn't called, the
device uses the default PNO scan behavior.

### Implementation

To implement this power-optimizing feature on a device running Android
{{ androidQVersionNumber }} or higher, derive the device mobility information
and call the `setDeviceMobilityState()` method from a custom system app.
