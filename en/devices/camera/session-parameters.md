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

# Session Parameters

The session parameters feature reduces delays by enabling camera clients to
actively configure the subset of costly request parameters, that is, session
parameters, as part of the capture session initialization phase. With this
feature, your HAL implementations receive the client parameters during the
stream configuration phase instead of the first capture request and can,
depending on their values, prepare and build the internal pipeline more
efficiently.

In Android {{ androidQVersionNumber }}, you can improve performance by using
the optional session reconfiguration query feature for more control over the
internal session parameter reconfiguration logic. For more information, see
[Session reconfiguration query](#session_reconfiguration_query).

## Examples and source

A reference session parameter implementation is already part of the
[CameraHal](https://android.googlesource.com/platform/hardware/qcom/camera/+/master/msm8998/QCamera2/HAL3/QCamera3HWI.cpp){: .external}.
This HAL uses the legacy Hal API.
The [binderized](/devices/architecture/hal-types)
CameraHal that implements the camera HIDL API must use the respective HIDL
[sessionParams](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/device/3.4/types.hal#111){: .external}
entry to access any new incoming session parameters during stream configuration.

Camera clients can query the keys of all supported session parameters by calling
[`getAvailableSessionKeys()`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#getAvailableSessionKeys()){: .external}
and eventually set their initial values via
[`setSessionParameters()`](https://developer.android.com/reference/android/hardware/camera2/params/SessionConfiguration#setSessionParameters(android.hardware.camera2.CaptureRequest)){: .external}.

## Implementation

Your CameraHal implementation must populate the
[`ANDROID_REQUEST_AVAILABLE_SESSION_KEYS`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#98){: .external}
within the respective static camera metadata and provide a subset of
[`ANDROID_REQUEST_AVAILABLE_REQUEST_KEYS`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#1016){: .external},
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

+   [`CameraDeviceTest#testSessionConfiguration`](https://android.googlesource.com/platform/cts/+/a3676a2dfa0630204be80a3c1f1cbbe6db2c3925/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java#793){: .external}
+   [`CameraDeviceTest#testCreateSessionWithParameters`](https://android.googlesource.com/platform/cts/+/a3676a2dfa0630204be80a3c1f1cbbe6db2c3925/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java#868){: .external}  
+   [`CameraDeviceTest#testSessionParametersStateLeak`](https://android.googlesource.com/platform/cts/+/42f4eb187e216363208b96b726ec4287ce512231/tests/camera/src/android/hardware/camera2/cts/CameraDeviceTest.java#870){: .external}
+   [`NativeCameraDeviceTest#testCameraDevicePreviewWithSessionParameters`](https://android.googlesource.com/platform/cts/+/a3676a2dfa0630204be80a3c1f1cbbe6db2c3925/tests/camera/libctscamera2jni/native-camera-jni.cpp#2140){: .external}  

In general, after a certain parameter is part of the session key list, its
current value is included as part of the session parameters passed during stream
configuration at the HAL layer.

Session parameters must be carefully selected. The values should not change
frequently, if at all, between stream configurations. Parameters that change
frequently, such as capture intent, are ill-suited and adding them to the
session parameter list could cause CTS failures due to excessive internal
re-configuration.

## Session reconfiguration query

Android {{ androidQVersionNumber }} introduces an optional session
reconfiguration query feature to
improve performance as internal stream reconfigurations resulting from session
parameter value modifications can reduce performance. To address this concern,
HIDL
[`ICameraDeviceSession`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/camera/device/3.5/ICameraDeviceSession.hal){: .external}
version 3.5 and higher supports the
[`isReconfigurationRequired`](https://android.googlesource.com/platform/hardware/interfaces/+/22eac5f667dfca8de336ddc45ad60a08250f6b30/camera/device/3.5/ICameraDeviceSession.hal#146){: .external}
method, which provides fine-grained control over the internal session parameter
reconfiguration logic. Using this method, stream reconfiguration can occur
precisely when required.

The arguments for `isReconfigurationRequired`
provide the required information about every pending session parameter
modification, allowing for various kinds of device-specific customizations.

This feature is implemented only in the camera service and the camera HAL. There
are no public-facing APIs. If this feature is implemented, camera clients should
see performance improvements when working with session parameters.

### Implementation

To support session reconfiguration queries, you must implement the
[`isReconfigurationRequired`](https://android.googlesource.com/platform/hardware/interfaces/+/22eac5f667dfca8de336ddc45ad60a08250f6b30/camera/device/3.5/ICameraDeviceSession.hal#146){: .external}
method to check whether complete stream reconfiguration is required for new
session parameter values.

If the client changes the value of any advertised session parameter, the camera
framework calls the `isReconfigurationRequired`
method. Depending on the specific values, the HAL decides whether a complete
stream reconfiguration is required. If the HAL returns `false`, the camera
framework skips the internal reconfiguration. If the HAL returns `true`, the
framework reconfigures the streams and passes the new session parameter values
accordingly.

The `isReconfigurationRequired` method can be called by the framework some time
before a request with new parameters is submitted to the HAL, and the request
can be cancelled before it is submitted. Therefore, the HAL must not use this
method call to change its behavior in any way.

The HAL implementation must meet the following requirements:

+   The framework must be able to call the `isReconfigurationRequired` method
    at any time after active session configuration.
+   There must be no impact on the performance of pending camera requests. In
    particular, there must not be any glitches or delays during normal camera
    streaming.

The device and HAL implementation must meet the following performance
requirements:

+   Hardware and software camera settings must not be changed.
+   There must be no user-visible impact on camera performance.

The `isReconfigurationRequired`
method takes the following arguments:

+   `oldSessionParams`: Session parameters from the previous session.
    Usually the existing session parameters.
+   `newSessionParams`: New session parameters that are set by the client.

The expected return status codes are:

+   `OK`: Successful reconfiguration required query.
+   `METHOD_NOT_SUPPORTED`: The camera device doesn't support the
    reconfiguration query.
+   `INTERNAL_ERROR`: The reconfiguration query can't complete due to an
    internal error.

The return values are:

+   `true`: Stream reconfiguration is required.
+   `false`: Stream reconfiguration isn't required.

To ignore a session reconfiguration query, the HAL returns
`METHOD_NOT_SUPPORTED` or `false`. This results in the default camera service
behavior where stream reconfiguration is triggered on each session parameter
change.

### Validation

The session reconfiguration query feature can be validated using the VTS test
case in
[`CameraHidlTest#configureStreamsWithSessionParameters`](https://android.googlesource.com/platform/hardware/interfaces/+/e18057b42f1698f33f34d14e86a53934bd337bb8/camera/provider/2.4/vts/functional/VtsHalCameraProviderV2_4TargetTest.cpp#2653){: .external}.
