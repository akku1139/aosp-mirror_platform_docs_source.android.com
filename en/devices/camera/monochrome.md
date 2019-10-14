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

# Monochrome Cameras

Devices running Android {{ androidPVersionNumber }} or higher can support
monochrome cameras. Android {{ androidQVersionNumber }}
provides additional support for the Y8 stream format, monochrome and
near-infrared (NIR) color filter array
static metadata, and `DngCreator` functions for monochrome cameras.

With this capability, device manufacturers can implement a monochrome or
NIR camera device and reduce memory use by using
the Y8 stream format. A monochrome camera can serve as the underlying physical
camera of a
[logical multi-camera device](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#REQUEST_AVAILABLE_CAPABILITIES_LOGICAL_MULTI_CAMERA){: .external}
to achieve better low-light noise characteristics.

## Implementation

### Hardware requirements

To implement this feature, your device must have a monochrome camera sensor and
an image signal processor (ISP) to process the sensor output.

### Implementing a monochrome camera

To advertise a camera device as a monochrome camera, the
[Camera HAL](/devices/camera/camera3) must meet
the following requirements:

+   `android.sensor.info.colorFilterArray` is set to `MONO` or `NIR`.
+   `BACKWARD_COMPATIBLE` required keys are supported and
    `MANUAL_POST_PROCESSING` isn't supported.
+   `android.control.awbAvailableModes` only contains `AUTO` and
    `android.control.awbState` is either `CONVERTED` or `LOCKED` depending on
    `android.control.awbLock`.
+   `android.colorCorrection.mode`, `android.colorCorrection.transform`, and
    `android.colorCorrection.gains` aren't in available request and result
    keys. As a result, the camera device is
    [`LIMITED`](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata.html#INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED){: .external}.
+   The following color-related static metadata keys aren't present:

    +   `android.sensor.referenceIlluminant*`
    +   `android.sensor.calibrationTransform*`
    +   `android.sensor.colorTransform*`
    +   `android.sensor.forwardMatrix*`
    +   `android.sensor.neutralColorPoint`
    +   `android.sensor.greenSplit`

+   All color channels have the same values for the following metadata keys:

    +   `android.sensor.blackLevelPattern`
    +   `android.sensor.dynamicBlackLevel`
    +   `android.statistics.lensShadingMap`
    +   `android.tonemap.curve`

+   `android.sensor.noiseProfile` has only one color channel.

For monochrome devices supporting Y8 stream formats, the Camera HAL must support
swapping `YUV_420_888` formats in mandatory stream combinations (including
reprocessing) with Y8 formats.

The following public APIs are used in this feature:

+   [Y8 image format](https://developer.android.com/reference/android/graphics/ImageFormat#Y8){: .external}
+   [SENSOR_INFO_COLOR_FILTER_ARRANGEMENT_MONO](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#SENSOR_INFO_COLOR_FILTER_ARRANGEMENT_MONO){: .external}
+   [SENSOR_INFO_COLOR_FILTER_ARRANGEMENT_NIR](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#SENSOR_INFO_COLOR_FILTER_ARRANGEMENT_NIR){: .external}
+   [MONOCHROME camera capability](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#REQUEST_AVAILABLE_CAPABILITIES_MONOCHROME){: .external}
    (introduced in Android {{ androidPVersionNumber }})

For more details on the Camera HAL, see
[docs.html](https://android.googlesource.com/platform/system/media/+/master/camera/docs/docs.html){: .external}.
For more information on related public APIs, see
[ImageFormat](https://developer.android.com/reference/android/graphics/ImageFormat){: .external},
[CameraCharacteristics](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics){: .external},
[CaptureRequest](https://developer.android.com/reference/android/hardware/camera2/CaptureRequest){: .external},
and
[CaptureResult](https://developer.android.com/reference/android/hardware/camera2/CaptureResult){: .external}.

## Validation

To validate your implementation of a monochrome camera, run the following CTS
and VTS tests.

### CTS tests

+   `testMonochromeCharacteristics`
+   `CaptureRequestTest`
+   `CaptureResultTest`
+   `StillCaptureTest`
+   `DngCreatorTest`

### VTS tests

+   `getCameraCharacteristics`
+   `processMultiCaptureRequestPreview`
