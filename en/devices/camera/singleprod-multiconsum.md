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

# Single Producer Multiple Consumer Camera Buffer Transport

This feature introduces a set of methods that allows camera clients to add and
remove output surfaces dynamically while the capture session is active and
camera streaming is ongoing. A new output can map to a specific, user-selected
[shared camera](https://developer.android.com/reference/android/hardware/camera2/params/OutputConfiguration#enableSurfaceSharing\(\))
stream. After a surface is added, it can be removed at any time.

The general idea is to share the buffers associated with a particular camera
stream within several output surfaces. An internal reference counter keeps track
of the buffers as they become ready for further processing on the consumer side.
When all consumers complete their respective tasks the buffer gets dequeued and
is available for the camera.

![Buffer sharing](/devices/camera/images/buffer-sharing.png)

**Figure 1.** Buffer sharing

Figure 1 depicts one example scenario where the buffers processed by camera
stream 2 are dynamically attached and detached, reference counted, and managed
by the stream splitter component inside a dedicated shared output stream within
the camera service.

## Examples and source

The core implementation of this feature can be found in the
[`Camera3StreamSplitter`](https://android.googlesource.com/platform/frameworks/av/+/master/services/camera/libcameraservice/device3/Camera3StreamSplitter.cpp)
module. Documentation on this feature can be found in the developer reference:

+   [`updateOutputConfiguration()`](https://developer.android.com/reference/android/hardware/camera2/CameraCaptureSession.html#updateOutputConfiguration\(android.hardware.camera2.params.OutputConfiguration\))
+   [`addSurface()`](https://developer.android.com/reference/android/hardware/camera2/params/OutputConfiguration#addSurface\(android.view.Surface\))
+   [`removeSurface()`](https://developer.android.com/reference/android/hardware/camera2/params/OutputConfiguration#removeSurface\(android.view.Surface\))

## Implementation

No implementation is required on the Camera HAL side as this feature is
implemented on the framework side.

## Validation

Your implementation must pass CTS cases that cover this feature from the
[MultiViewTest](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/MultiViewTest.java)
module and the
[native JNI library](https://android.googlesource.com/platform/cts/+/master/tests/camera/libctscamera2jni/native-camera-jni.cpp)
for the native API.
