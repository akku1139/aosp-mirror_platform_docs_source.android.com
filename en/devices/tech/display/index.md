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

# Android Display

This section covers AOSP implementation of various Android display settings,
including app shortcuts, circular launcher icons, do not disturb (DND),
multi-window (split-screen, free-form, and picture-in-picture), high dynamic
range (HDR) video, night light, and retail demo mode. See the subpages of this
section for details.

## Adaptive Icons

Adaptive Icons maintain a consistent shape intra-device but vary from device to
device with only one icon asset provided by the developer. Additionally, icons
support two layers (foreground and background) that can be used for motion to
provide visual delight to users.

## App shortcuts

The Android 7.1.1 release allows developers to define action-specific shortcuts
in their apps that can be displayed in a launcher. These app shortcuts let users
quickly start common or recommended tasks within an app.

## Circular icons

Circular launcher icons are supported in Android 7.1.1 and later. Circular
launcher icons are not enabled by default. To use circular icons in your device
implementation, you must edit the resource overlay on your device to enable
them.

## Color management

Android 8.1 adds support for color management that can be used to provide a
consistent experience across display technologies. Applications running on
Android 8.1 can access the full capabilities of a wide gamut display to get the
most out of a display device.

## Display cutouts

Android 9 adds support for implementing different types of display cutouts on
devices. Display cutouts allow you to create immersive, edge-to-edge experiences
while still allowing space for important sensors on the front of devices.

## Do not disturb

Android 7.0 supports do not disturb (DND) configurations for third-party
automatic rules, controlling alarms, suppressing visual distractions, and
customizing DND settings.

## HDR video playback

High dynamic range (HDR) video is the next frontier in high-quality video
decoding, bringing unmatched scene reproduction qualities. Android 7.0 gained
initial HDR support, which includes the creation of proper constants for the
discovery and setup of HDR video pipelines.

## Multi-display

Android {{ androidQVersionNumber }} enables multi-screen and foldable handheld
devices, utilization of external displays, and other form-factors. Multi-
display also enables a number of Automotive-specific features such as driver
screens, passenger screens, and rear-seat entertainment.

## Multi-window

In Android 7.0 and later, users can have multiple apps simultaneously displayed
on their device screen with the new platform feature, multi-window. In addition
to the default implementation of multi-window, Android also supports a few
varieties of multi-window.

## Night light

Android 7.1.1 includes a feature called Night Light that reduces the amount of
blue light emitted by the device display to better match the natural light of
the user's time of day and location. Android 8.0 includes a feature that gives
users more control over the intensity of the Night Light effect.

## Picture-in-picture

Android 8.0 includes support for picture-in-picture (PIP) for Android handheld
devices. PIP allows users to resize an app with an ongoing activity into a small
window.

## Retail demo mode

Android 7.1.1 and later offer system-level support for retail mode so users can
readily examine the devices in action. Android 8.1 revises this support to
create demo users via Device Policy Manager.

## Rotate suggestions

In Android 8.0, users could toggle between auto-rotate and portrait rotation
modes using a Quicksettings tile or Display settings. Android 9 updated portrait
rotation mode to eliminate unintentional rotations by pinning the current screen
rotation even if the device position changes.

## Split-screen interactions

In Android 7.0 and later, users can have multiple apps simultaneously displayed
on their device screen with the platform feature multi-window. Android 8.0
improves split-screen by refining the feature and adding more functionality to
it.

## Synchronized app transitions

Synchronized App Transitions is a feature in Android 9 that enhances the
existing app transition architecture. When a user opens, closes, or switches
between apps, the SystemUI or Launcher (homescreen) process sends a request to
control the animation frame-by-frame with guaranteed synchronization between
view animations and window animations.

## Text classification

Text classification uses machine learning techniques to help developers classify
text. Android 9 extended the text classification framework introduced in Android
8.1 with the new Text Classifier service. The Text Classifier service is the
recommended way for OEMs to provide text classification system support.

## Widgets and shortcuts

The flow API for adding shortcuts and widgets in Android 8.0 allows application
developers to add shortcuts and widgets from inside the app instead of relying
on the widget tray. It also deprecates the old method (sending a broadcast) of
adding shortcuts for security reasons.
