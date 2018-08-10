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

# Multi-Camera Support

Android {{ androidPVersionNumber }} introduces API support for multi-camera
devices via a new logical camera device composed of two or more physical camera
devices pointing in the same direction. The logical camera device is exposed as
a single CameraDevice/CaptureSession to an application allowing for interaction
with HAL-integrated multi-camera features. Applications can optionally access
and control underlying physical camera streams, metadata, and controls.

![Multi-camera support](/devices/camera/images/multi-camera.png)

**Figure 1**. Multi-camera support

In this diagram, different camera IDs are color coded. The application can
stream raw buffers from each physical camera at the same time. It is also
possible to set separate controls and receive separate metadata from different
physical cameras.

## Examples and sources

Multi-camera devices must be advertised via the
[logical multi-camera capability](https://developer.android.com/reference/android/hardware/camera2/CameraMetadata#REQUEST_AVAILABLE_CAPABILITIES_LOGICAL_MULTI_CAMERA).

Camera clients can query the camera ID of the physical devices a particular
logical camera is made of by calling
[`getPhysicalCameraIds()`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics.html#getPhysicalCameraIds\(\)).
The IDs returned as part of the result are then used to control physical devices
individually via
[`setPhysicalCameraId()`](https://developer.android.com/reference/android/hardware/camera2/params/OutputConfiguration.html#setPhysicalCameraId\(java.lang.String\)).
The results from such individual requests can be queried from the complete
result by invoking
[`getPhysicalCameraResults()`](https://developer.android.com/reference/android/hardware/camera2/TotalCaptureResult.html#getPhysicalCameraResults\(\)).

Individual physical camera requests may support only a limited subset of
parameters. To receive a list of the supported parameters, developers can call
[`getAvailablePhysicalCameraRequestKeys()`](https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics.html#getAvailablePhysicalCameraRequestKeys\(\)).

Physical camera streams are supported only for non-reprocessing requests and
only for monochrome and bayer sensors.

## Implementation

### Support checklist

To add logical multi-camera devices on the HAL side:

+   Add a
    [`ANDROID_REQUEST_AVAILABLE_CAPABILITIES_LOGICAL_MULTI_CAMERA`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#232)
    capability for any logical camera device backed by two or more physical
    cameras that are also exposed to an application.
+   Populate the static
    [`ANDROID_LOGICAL_MULTI_CAMERA_PHYSICAL_IDS`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#161)
    metadata field with a list of physical camera IDs.
+   Populate the depth-related static metadata required to correlate between
    physical camera streams' pixels:
    [`ANDROID_LENS_POSE_ROTATION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#747),
    [`ANDROID_LENS_POSE_TRANSLATION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#753),
    [`ANDROID_LENS_INTRINSIC_CALIBRATION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#773),
    [`ANDROID_LENS_RADIAL_DISTORTION`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.2/types.hal#780),
    [`ANDROID_LENS_POSE_REFERENCE`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#79)`
+   Set the static
    [`ANDROID_LOGICAL_MULTI_CAMERA_SENSOR_SYNC_TYPE`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#167)
    metadata field to:

    +   [`ANDROID_LOGICAL_MULTI_CAMERA_SENSOR_SYNC_TYPE_APPROXIMATE`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#256):
        For sensors in master-master mode, no hardware shutter/exposure sync.
    +   [`ANDROID_LOGICAL_MULTI_CAMERA_SENSOR_SYNC_TYPE_CALIBRATED`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#257):
        For sensors in master-slave mode, hardware shutter/exposure sync.

+   Populate
    [`ANDROID_REQUEST_AVAILABLE_PHYSICAL_CAMERA_REQUEST_KEYS`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/metadata/3.3/types.hal#106)
    with a list of supported parameters for individual physical cameras. The
    list can be empty if the logical device doesn't support individual requests.

+   If individual requests are supported, process and apply the individual
    [`physicalCameraSettings`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/device/3.4/types.hal#226)
    that can arrive as part of capture requests and append the individual
    [`physicalCameraMetadata`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/device/3.4/types.hal#289)
    accordingly.

The camera device must support replacing one logical YUV/RAW stream with
physical streams of the same size (RAW size is an exception) and format from two
physical cameras.

### Stream configuration map

For a logical camera, the mandatory stream combinations for the camera device of
a certain hardware level is the same as what's required in
[`CameraDevice.createCaptureSession`](https://developer.android.com/reference/android/hardware/camera2/CameraDevice.html#createCaptureSession\(java.util.List<android.view.Surface>, android.hardware.camera2.CameraCaptureSession.StateCallback, android.os.Handler\)).
All the streams in the stream configuration map should be fused/logical frames.

If certain stream combinations cannot be fused, they should not be included in
the logical camera's stream configuration map. Instead the application can look
up the stream configuration map of the individual physical camera and configure
the stream using the physical camera ID.

This means that the logical camera's hardware level may be lower than that of
individual cameras. One such example is when the two physical cameras have
different raw sizes. The logical camera does not have RAW capability, so it
cannot be a LEVEL_3 device, but the individual physical cameras can be LEVEL_3
devices.

For both the logical camera and the underlying physical cameras, the directly
configured processed streams, RAW streams, and stall streams should not exceed
the predefined `android.request.maxNumOutputStreams`.

### Guaranteed stream combination

Both the logical camera and its underlying physical cameras must guarantee the
[mandatory stream combinations](https://developer.android.com/reference/android/hardware/camera2/CameraDevice#createcapturesession_4)
required for their device levels.

A logical camera device should operate in the same way as a physical camera
device based on its hardware level and capabilities. It's recommended that its
feature set is a superset of that of individual physical cameras.

Additionally, for each guaranteed stream combination, the logical camera must
support:

+   Replacing one logical YUV_420_888 or raw stream with two physical streams of
    the same size and format, each from a separate physical camera, given that
    the size and format are supported by the physical cameras.

+   Adding two raw streams, one from each physical camera, if the logical camera
    doesn't advertise RAW capability, but the underlying physical cameras do.
    This usually occurs when the physical cameras have different sensor sizes.

Using physical streams in place of a logical stream of the same size and format
must not slow down the frame rate of the capture, as long as the minimum frame
duration of the physical and logical streams are the same.

### Performance and power considerations

+   Performance:

    +   Without attaching physical camera settings, physical streams should not
        slow down capture rate.
    +   Applying physical camera settings may slow down the capture rate if the
        underlying cameras are put into different frame rates.

+   Power:

    +   HAL's power optimization continues to work in the default case.
    +   Configuring or requesting physical streams may override HAL's internal
        power optimization and incur more power use.

## Customization

You can customize your device implementation in the following ways.

+   The fused output of the logical camera device depends entirely on the HAL
    implementation. The decision on how fused logical streams are derived from
    the physical cameras is transparent to the application and Android camera
    framework.
+   Individual physical requests and results can be optionally supported. The
    set of available parameters in such requests is also entirely dependent on
    the specific HAL implementation.

## Validation

Logical multi-camera devices must pass Camera CTS like any other regular camera.
The test cases that target this type of device can be found in the
[`LogicalCameraDeviceTest`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/)
module.

These three ITS tests target multi-camera systems to facilitate the proper
fusing of images:

+   [`scene1/test_multi_camera_match.py`](https://android.googlesource.com/platform/cts/+/master/apps/CameraITS/tests/scene1/)
+   [`scene4/test_multi_camera_alignment.py`](https://android.googlesource.com/platform/cts/+/master/apps/CameraITS/tests/scene4/)
+   [`sensor_fusion/test_multi_camera_frame_sync.py`](https://android.googlesource.com/platform/cts/+/master/apps/CameraITS/tests/sensor_fusion/)

The scene1 and scene4 tests run with the
[ITS-in-a-box](/compatibility/cts/camera-its-box) test
rig. The `test_multi_camera_match` test asserts that the brightness of the
center of the images match when the two cameras are both enabled. The
`test_multi_camera_alignment` test asserts that camera spacings, orientations,
and distortion parameters are properly loaded. If the multi-camera system
includes a Wide FoV camera (>90o), the rev2 version of the ITS box is required.

`Sensor_fusion` is a second test rig that enables repeated, prescribed phone
motion and asserts that the gyroscope and image sensor timestamps match and that
the multi-camera frames are in sync.

All boxes are available through AcuSpec, Inc.
([www.acuspecinc.com](http://www.acuspecinc.com), fred@acuspecinc.com) and MYWAY
Manufacturing ([www.myway.tw](http://www.myway.tw), sales@myway.tw).
Additionally, the rev1 ITS box can be purchased through West-Mark
([www.west-mark.com](http://www.west-mark.com), dgoodman@west-mark.com).
