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

# Session Parameters

The session parameters feature reduces delays by enabling camera clients to
actively configure the subset of costly request parameters, i.e. session
parameters, as part of the capture session initialization phase. With this
feature, your HAL implementations receive the client parameters during the
stream configuration phase instead of the first capture request and can,
depending on their values, prepare and build the internal pipeline more
efficiently.

## Examples and source

A reference session parameter implementation is already part of the
[CameraHal](https://android.googlesource.com/platform/hardware/qcom/camera/+/master/msm8998/QCamera2/HAL3/QCamera3HWI.cpp).
This HAL uses the legacy Hal API.
The [binderized](https://source.android.com/devices/architecture/hal-types)
CameraHal that implements the camera HIDL API must use the respective HIDL
[sessionParams](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/device/3.4/types.hal#111)
entry to access any new incoming session parameters during stream configuration.

Camera clients can query the keys of all supported session parameters by calling
[`getAvailableSessionKeys()`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#getAvailableSessionKeys())
and eventually set their initial values via
[`setSessionParameters()`](https://developer.android.com/reference/android/hardware/camera2/params/SessionConfiguration#setSessionParameters\(android.hardware.camera2.CaptureRequest\)).

## Implementation

Your CameraHal implementation must populate the
[`ANDROID_REQUEST_AVAILABLE_SESSION_KEYS`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#99)
within the respective static camera metadata and provide a subset of
[`ANDROID_REQUEST_AVAILABLE_REQUEST_KEYS`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#1016),
which contains a list of keys that are difficult to apply per-frame and can
result in unexpected delays when modified during the capture session lifetime.

Typical examples include parameters that require a time-consuming hardware
reconfiguration or an internal camera pipeline change. Control over session
parameters can still be exerted in capture requests but clients should be aware
of and expect delays in their application.

The framework monitors all incoming requests and if it detects a change in the
value of a session parameter, it internally reconfigures the camera. The new
stream configuration passed to CameraHal then includes the updated session
parameter values, which are used to configure the camera pipeline more
efficiently.

## Customization

You can define tags in the available session parameter list that is populated on
the CameraHal side. This feature is not active if CameraHal leaves the
available session parameter list empty.

## Validation

CTS includes the following new cases for testing session parameters:

+   [`CameraDeviceTest#testSessionConfiguration`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java#795)
+   [`CameraDeviceTest#testCreateSessionWithParameters`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java#1038)
+   [`CameraDeviceTest#testSessionParametersStateLeak`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java#870)
+   [`NativeCameraDeviceTest#testCameraDevicePreviewWithSessionParameters`](https://android.googlesource.com/platform/cts/+/master/tests/camera/libctscamera2jni/native-camera-jni.cpp#2140)

In general, once a certain parameter is part of the session key list, its
current value is included as part of the session parameters passed during stream
configuration at the HAL layer.

Session parameters must be carefully selected. The values should not change
frequently, if at all, between stream configurations. Parameters that change
frequently, such as capture intent, are ill-suited and adding them to the
session parameter list could cause CTS failures due to excessive internal
re-configuration.
