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

# Android Permissions

Use the features described in this section to grant permissions properly in
Android.

## Ambient capabilities

Capabilities allow Linux processes to drop most root-like privileges while
retaining the subset of privileges that they require to perform their function.
Ambient capabilities bring configuration into a single file.

## Discretionary Access Control

Newer versions of Android (Android 8.0 and higher) support a new method for
extending filesystem capabilities, This new method has supports multiple source
locations for configuration files,build-time sanity checking of OEM AID values,
generation of a custom OEM AID header that can be used in source files, and
more.

## Library namespaces

Android 7.0 introduced namespaces for native libraries to limit internal API
visibility and resolve situations when apps accidentally end up using platform
libraries instead of their own.

## Privileged permission whitelisting

Privileged applications are system applications located in the /system/priv-app
directory on the system image. Starting in Android 8.0, implementors can
explicitly whitelist privileged apps in the system configuration XML files.

## Runtime permissions

The Android application permission model in Android 6.0 and later is designed to
make permissions more understandable, useful, and secure for users. The model
moved Android applications that require dangerous permissions from an
install-time permission model to runtime permission model.

## USB HAL

The Android O release moves handling of USB commands out of `init` scripts and
into a native USB daemon for better configuration and code reliability. For the
Gadget function configuration, `init` scripts (property triggers) are used to
perform device-specific gadget operations.

## Visual Voicemail

Android 6.0 (Marshmallow) brought an implementation of visual voicemail (VVM)
support integrated into the Dialer, allowing compatible Carrier VVM services to
hook into the Dialer with minimal configuration.
