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

# Design an Android Device

Being open source, Android offers a near-infinite combination of hardware and
software for you to develop devices undreamt by even the operating system's
creators.

Still, for your users to have a coherent experience as they adopt additional
Android devices, consider following established standards while designing and
customizing your implementation.

1. Review the fundamental principles of Android platform development within
   [Architecture](/devices/architecture/), particularly the
   [HIDL](/devices/architecture/hidl/) format introduced in Android 8.0 and the
   [modular system components](/devices/architecture/modular-system) introduced
   in Android {{ androidQVersionNumber }}.

1. Ensure your devices meet requirements to be deemed
   [compatible](/compatibility/overview) with Android’s core specification, the
   [Android Compatibility Definition Document](/compatibility/cdd).

1. See the [Display](/devices/tech/display/) features and
   [Settings](/devices/tech/settings/settings-guidelines) guidelines for
   help with the user interface.

1. Take advantage of all of the [tests](/compatibility/tests) available to debug
   and improve your Android devices.

1. Follow [security best practices](/security/best-practices) to keep your users
   and devices safe.

1. Familiarize yourself with
   [App Design](https://developer.android.com/design/){: .external} principles and
   [Material Design](https://material.io/design/){: .external} techniques when
   developing user-facing applications.
