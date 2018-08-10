Project: /_project.yaml
Book: /_book.yaml

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

# Wi-Fi HAL

The Wi-Fi framework has three Wi-Fi HAL surfaces represented by three different
HIDL packages:

+   Vendor HAL: A HAL surface for Android-specific commands. The HIDL files are
    in `hardware/interfaces/wifi/1.x`.
+   Supplicant HAL: A HAL surface for **wpa_supplicant**. The HIDL files are in
    `hardware/interfaces/supplicant/1.x`.
+   Hostapd HAL: A HAL surface for **hostapd**. The HIDL files are in
    `hardware/interfaces/hostapd/1.x`.

## Vendor HAL

The Vendor HAL provides Android-specific commands. It is optional (not required)
for infrastructure Station (STA) and Soft AP (SAP) modes to function. However,
it is mandatory for [Wi-Fi Aware](/devices/tech/connect/wifi-aware) and for
[Wi-Fi RTT](/devices/tech/connect/wifi-rtt) services.

Pre-HIDL (i.e. pre-Android 8.0) Android used a HAL mechanism now called _legacy
HAL_. The Android source code currently provides a default implementation of
HIDL using a shim running on top of the legacy HAL.

The legacy HAL headers are located in
`hardware/libhardware_legacy/include/hardware_legacy/`. The legacy HAL based
implementation is located in `hardware/interfaces/wifi/1.2/default`.

## Supplicant HAL

The Supplicant HAL provides a HIDL interface for the **wpa_supplicant** daemon.

The wpa_supplicant source code is located in
`external/wpa_supplicant_8/wpa_supplicant`. The wpa_supplicant code providing
the HIDL interface is located in the `hidl` sub-directory.

## Hostapd HAL

The Hostapd HAL provides a HIDL interface for the **hostapd** daemon.

The hostapd source code is located in `external/wpa_supplicant_8/hostapd`. The
hostapd code providing the HIDL interface is located in the `hidl`
sub-directory.

## Wi-Fi multi-interface concurrency

Different Android devices can support different combinations of Wi-Fi interfaces
concurrently. The supported combinations are defined in the HAL and are exposed
to the framework. The specification format is defined in
`android/hardware/interfaces/wifi/1.0/IWifiChip.hal`. For example, a device may
support one STA and one interface of either NAN
([Wi-Fi Aware](https://developer.android.com/guide/topics/connectivity/wifi-aware))
or P2P
([Wi-Fi Direct](https://developer.android.com/guide/topics/connectivity/wifip2p))
type (but not both). This would be expressed as:

`[{STA} <= 1, {NAN,P2P} <= 1]`

The concurrency specification format is flexible and generic. It can express
combinations that are not yet supported by the framework. The reference HAL has
configurations for several combinations which may be activated with build flags.
For configuration instructions, see:

+   [Wi-Fi STA/AP Concurrency](/devices/tech/connect/wifi-sta-ap-concurrency)
+   [Wi-Fi Aware](/devices/tech/connect/wifi-aware)
