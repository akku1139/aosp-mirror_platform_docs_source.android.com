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

# Android Settings Menu

This section describes the options available to you for implementing and
customizing the Android settings menu.

## Settings home screen

In Android 7.0 and higher, the Settings home page is enhanced with suggested
settings and customizable status notifications. The feature is implemented
automatically, and device implementers can configure it.

The source code for these enhancements is in these files:

*  [frameworks/base/packages/SettingsLib/src/com/android/settingslib/suggestions/SuggestionParser.java](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/packages/SettingsLib/src/com/android/settingslib/suggestions/SuggestionParser.java)
*  [frameworks/base/packages/SettingsLib/src/com/android/settingslib/drawer/TileUtils.java](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/packages/SettingsLib/src/com/android/settingslib/drawer/TileUtils.java)

## Android settings design guidelines

This documentation highlights the principles and guidelines for anyone who is
either designing Android platform settings or any developers designing
settings for their Android app.

## Patterns and components

In Android 8.0, the Settings menu gained several components and widgets that
cover common uses. Device manufacturers and developers are encouraged to use the
common components when extending the Settings app so new user interfaces stay
consistent with the existing Settings UI.

## Information architecture

Android 8.0 introduced a new information architecture for the Settings app to
simplify the way settings are organized and make it easier for users to quickly
find settings to customize their Android devices. Android 9 introduced some
improvements to provide more Settings functionality and easier implementation.

## Personalized settings

The Android Settings app provides a list of suggestions to the users in Android
8.0. These suggestions typically promote features of the phone, and they are
customizable (e.g., "Set Do Not Disturb schedule" or "Turn on Wi-Fi Calling").

## Universal search

Android 8.0 adds expanded search capabilities for the Settings menu. This
document describes how to add a setting and ensure it is properly indexed for
Settings search.
