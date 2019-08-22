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

# Develop an Android Device

As an open source operating system, Android offers device and chip manufacturers
[hardware abstraction layers (HALs)](/devices/architecture) to be implemented as
interfaces for common mobile OS functions.

These HALs now come in the even more portable and persistent
[HAL interface definition language (HIDL)](/devices/architecture/hidl). HIDL
enables the framework to be replaced without rebuilding the HALs.

## Audio
Android's [audio](/devices/audio) HAL connects the higher-level, audio-specific
framework APIs to the underlying audio driver and hardware.

## Camera
The [camera](/devices/camera) subsystem includes implementations for camera
pipeline components while the camera HAL provides interfaces for use in
implementing your version of these components.

## Connectivity
This section describes implementation of standard Android
[connectivity](/devices/tech/connect) protocols and describes use of related
features, including Bluetooth, NFC, Wi-Fi, Telephony, and more.

##  Graphics
The Android framework offers a variety of [graphics](/devices/graphics)-rendering
APIs for 2D and 3D that interact with manufacturer implementations of graphics
drivers.

## Interaction/Input
The Android [interaction/input](/devices/input/) subsystem consists of an event
pipeline that traverses multiple layers of the system and supports automotive,
neural networks, peripherals, sensors, and TV.

## Media
Android includes Stagefright, a [media](/devices/media/) playback engine at the
native level that has built-in software-based codecs for popular media formats.

## Storage
All versions of Android support traditional [storage](/devices/storage/) with
support for adoptable storage arriving in Android 6.0.
