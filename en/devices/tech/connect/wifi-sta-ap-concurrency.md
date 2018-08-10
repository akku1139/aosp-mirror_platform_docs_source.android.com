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

# Wi-Fi STA/AP concurrency

Android {{ androidPVersionNumber }} introduces the ability for devices to
operate in STA and AP mode concurrently. For devices supporting Dual Band
Simultaneous (DBS), this feature opens up new capabilities such as not
disrupting STA Wi-Fi when a user wants to enable hotspot (softAP).

## Examples and source

Wi-Fi STA/AP concurrency is supported in the default AOSP Android framework
code. It is also supported by the reference HAL implementation described in
[Wi-Fi HAL](/devices/tech/connect/wifi-hal). The
`WIFI_HIDL_FEATURE_DUAL_INTERFACE` build-time flag described in the
Implementation section below enables an interface concurrency specification
indicating concurrent support for STA and AP.

## Implementation

To implement Wi-Fi STA/AP concurrency on your device:

1.  Turn on a build-time flag to enable support for two interfaces in the HAL.
    The flag is located in `device/<oem>/<device>/BoardConfig-common.mk`.

    +   **WIFI_HIDL_FEATURE_DUAL_INTERFACE := true**

1.  Expose two network interfaces:

    +   **wlan0** and **wlan1**

Note: To avoid performance issues, only use this feature on devices with a Wi-Fi
chip that supports multiple independent hardware MACs (radio chains).

## Validation

To validate that the feature is working as intended, run both an integration
test (ACTS) and a manual test.

The ACTS file, `WifiStaApConcurrencyTest.py`, located in
`tools/test/connectivity/acts/tests/google/wifi`, contains a set of tests which
bring up different combinations of STAs and APs.

To manually validate this feature, turn the STA and AP interfaces on and off
independently from UI.

If both AP and STA are on the same subnet, routing issues on the
device-under-test (DUT) may occur. To avoid collisions, try moving the AP to a
different subnet.

Some Wi-Fi chip vendors place the radio in time-sharing mode if STA and AP are
on the same band but on different channels. This leads to a severe drop in
performance. To address this issue, the chip can use Channel Switch Avoidance
(CSA) to either:

*   Move the AP to the same channel as the STA
*   Move the AP to a different band from the STA
