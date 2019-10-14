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

# Implementing Synchronized App Transitions

Synchronized App Transitions is a feature in Android {{ androidPVersionNumber }}
that enhances the existing app transition architecture. When a user opens,
closes, or switches between apps, the SystemUI or Launcher (homescreen) process
sends a request to control the animation frame-by-frame with guaranteed
synchronization between view animations and window animations. When the SystemUI
or Launcher draws a new frame as part of an animation, it requests a different
transform on the animating app surface that determines how the app is composed
on the screen, and marks the request, a surface transaction, to be synchronized
with the frame it's currently drawing.

This allows for new app transition animations that are not possible on Android
8.x and lower. For example, the
[app launch animation](/devices/tech/display/images/app-launch-animation.mp4)
can transform homescreen icons seamlessly into the app surface and the
[notification launch animation](/devices/tech/display/images/notification-launch-animation.mp4)
can transform notifications into the app surface.

## Examples and source

See the following references for this feature.

+   [`ActivityOptions.makeRemoteAnimation`](https://android.googlesource.com/platform/frameworks/base/+/33a701a55c28dd20390acee1ba7881a500830d7d/core/java/android/app/ActivityOptions.java#843){: .external}
+   [`RemoteAnimationAdapter`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/view/RemoteAnimationAdapter.java){: .external}  
+   [`RemoteAnimationRunner`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/view/IRemoteAnimationRunner.aidl){: .external}  
+   [`Activity.registerRemoteAnimations`](https://android.googlesource.com/platform/frameworks/base/+/f84e2f60fec6f6d2ecfb3b90ddf075101f4b902f/core/java/android/app/Activity.java#7672){: .external}  

For a reference implementation for the notification launch animation, see
[`ActivityLaunchAnimator.java`](https://android.googlesource.com/platform/frameworks/base/+/master/packages/SystemUI/src/com/android/systemui/statusbar/notification/ActivityLaunchAnimator.java){: .external}.

## Implementation

You can implement this feature on Launcher/System UI as required or you can use
the AOSP implementation in SystemUI/Launcher3.

Note: This feature increases the load on the GPU and CPU during animations.

## Validation

To validate the performance of the animations, measure the performance of the
controlling app, i.e. SystemUI or Launcher, during the animations as described
in
[Test UI performance](https://developer.android.com/training/testing/performance){: .external}.
