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

# Motion Tracking

In Android {{ androidPVersionNumber }}, camera devices can advertise
[motion tracking capability](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#REQUEST_AVAILABLE_CAPABILITIES_MOTION_TRACKING){: .external}.
Cameras that support this feature do not produce motion tracking data itself,
but instead are used by ARCore or an image-stabilization algorithm along with
other sensors for scene analysis. To support this feature, devices must support
[`CONTROL_CAPTURE_INTENT_MOTION_TRACKING`](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#CONTROL_CAPTURE_INTENT_MOTION_TRACKING){: .external}.
If this intent is part of the capture request, the camera must limit the
exposure time to a maximum of 20 milliseconds to reduce motion blur.

## Examples and source

A reference motion tracking implementation on the HAL side is available as part
of the
[Camera HAL](https://android.googlesource.com/platform/hardware/qcom/camera/+/master/msm8998/QCamera2/HAL3/QCamera3HWI.cpp){: .external}.

## Implementation

To enable motion tracking on a camera device, make sure:

+   The
    [`ANDROID_REQUEST_AVAILABLE_CAPABILITIES_MOTION_TRACKING`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#231){: .external}
    capability is enabled.
+   The
    [`ANDROID_CONTROL_CAPTURE_INTENT_MOTION_TRACKING`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#207){: .external}
    intent is supported and when included in a capture request limits the camera
    exposure time to a maximum of 20 milliseconds.
+   Lens calibration data from the following list is accurately reported in the
    static information and dynamic metadata fields:

    +   [`ANDROID_LENS_POSE_ROTATION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#747){: .external}  
    +   [`ANDROID_LENS_POSE_TRANSLATION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#753){: .external}  
    +   [`ANDROID_LENS_INTRINSIC_CALIBRATION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#773){: .external}  
    +   [`ANDROID_LENS_RADIAL_DISTORTION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#780){: .external}  
    +   [`ANDROID_LENS_POSE_REFERENCE`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#79){: .external}  

## Validation

Camera devices supporting the motion tracking feature must pass the
[camera CTS tests](/compatibility/cts/camera-hal#cts_tests).
