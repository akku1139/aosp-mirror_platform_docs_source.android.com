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

# Stream Configurations

Android {{ androidQVersionNumber }} introduces features allowing camera clients
to choose optimal camera
streams for specific use cases and to ensure that certain stream combinations
are supported by the camera device. A _stream configuration_ refers to a single
camera stream configured in the camera device and a _stream combination_ refers
to one or more sets of streams configured in the camera device. For more on
these features, see
[recommended stream configurations](#recommended_stream_configurations) and
[API to query stream combinations](#api_to_query_stream_combinations).

## Reference implementation

There is a vendor-side reference implementation of the recommended configuration
streams and the API to query stream combination features. You can find this
implementation at
[QCamera3HWI.cpp](https://android.googlesource.com/platform/hardware/qcom/camera/+/master/msm8998/QCamera2/HAL3/QCamera3HWI.cpp){: .external}

## Recommended stream configurations

Camera vendors can advertise recommended stream configurations for specific use
cases to camera clients. These recommended stream configurations, which are
subsets of
[StreamConfigurationMap](https://developer.android.com/reference/android/hardware/camera2/params/StreamConfigurationMap){: .external},
can help camera clients choose optimal configurations.

Although
[StreamConfigurationMap](https://developer.android.com/reference/android/hardware/camera2/params/StreamConfigurationMap){: .external}
provides exhaustive stream configuration information to camera clients, it
doesn't provide any information about the efficiency, power, or performance
impacts of choosing one stream over another. Camera clients can freely choose
from all the possible stream configurations but in many cases, this leads to
clients using sub-optimal camera configurations and applications making
time-consuming exhaustive searches.

For example, although some processed YUV formats are required and must be
supported, the camera device might not have native support for the formats. This
results in an additional processing pass for the format conversion and reduces
efficiency. The size and corresponding aspect ratio can also have a similar
impact making particular dimensions preferable in terms of power and
performance.

Your recommended stream configuration maps aren't required to be exhaustive
compared to the
[StreamConfigurationMap](https://developer.android.com/reference/android/hardware/camera2/params/StreamConfigurationMap){: .external}.
The suggested configuration maps must follow the requirements in the
[implementation](#implementation) section and can include any of the
available formats, sizes, or other values found in
[StreamConfigurationMap](https://developer.android.com/reference/android/hardware/camera2/params/StreamConfigurationMap){: .external}.
Hidden formats, sizes, or other values not found in StreamConfigurationMap
can't be included in recommended stream configuration maps.

All tests remain unchanged and aren't relaxed depending on the recommended
stream configurations.

The recommended stream configurations provided by the camera implementation are
optional and the camera client can ignore them.

### Implementation

Follow these steps to implement this feature.

#### Metadata entries

To enable this feature the Camera HAL must populate the following static
metadata entries:

+   `android.scaler.availableRecommendedStreamConfigurations`: The
    recommended subset of stream configurations for specific use cases. The
    declaration uses simple bitmaps indicating the suggested use cases in
    the form of `[1 << PREVIEW | 1 << RECORD..]`. The use cases extend the
    regular (format, width, height, input) tuple with one additional entry.
    Non-existing public use cases or any other bits set within the range
    `[PUBLIC_END, VENDOR_START]` are prohibited.

    This information is stored in the
    [`availableRecommendedStreamConfigurations`](https://android.googlesource.com/platform/system/media/+/9c7b5d3b4eea93dba8438e01b256898cdf451f47/camera/docs/metadata_definitions.xml#6493){: .external}
    metadata tag.

    The following example shows an array for a recommended stream
    configuration for a camera device that only supports 4K and 1080p, where
    both resolutions are preferred for video recording but only 1080p is
    suggested for preview.

    ```
    [3840, 2160, HAL_PIXEL_FORMAT_IMPLEMENTATION_DEFINED,
    ANDROID_SCALER_AVAILABLE_STREAM_CONFIGURATIONS_OUTPUT,
    (1 << ANDROID_SCALER_AVAILABLE_RECOMMENDED_STREAM_CONFIGURATIONS_RECORD |
    1 << ANDROID_SCALER_AVAILABLE_RECOMMENDED_STREAM_CONFIGURATIONS_SNAPSHOT |
    1 << ANDROID_SCALER_AVAILABLE_RECOMMENDED_STREAM_CONFIGURATIONS_VIDEO_SNAPSHOT),
    1920, 1080, HAL_PIXEL_FORMAT_IMPLEMENTATION_DEFINED,
    ANDROID_SCALER_AVAILABLE_STREAM_CONFIGURATIONS_OUTPUT,
    (1 << ANDROID_SCALER_AVAILABLE_RECOMMENDED_STREAM_CONFIGURATIONS_PREVIEW |
    1 << ANDROID_SCALER_AVAILABLE_RECOMMENDED_STREAM_CONFIGURATIONS_RECORD |
    1 << ANDROID_SCALER_AVAILABLE_RECOMMENDED_STREAM_CONFIGURATIONS_SNAPSHOT |
    1 << ANDROID_SCALER_AVAILABLE_RECOMMENDED_STREAM_CONFIGURATIONS_VIDEO_SNAPSHOT)]
    ```

    Note: The above array example only illustrates one particular scenario
    and isn't complete. The complete final array must include the recommended
    stream configurations for all required use cases mentioned below.

+   `android.depth.availableRecommendedDepthStreamConfigurations`
    (available only if supported by device): The recommended depth dataspace
    stream configurations suggested for this camera device. Similar to the
    above metadata entry, an additional use case bitmap indicates the suggested
    use cases.

    This information is stored in the
    [`availableRecommendedInputOutputFormatsMap`](https://android.googlesource.com/platform/system/media/+/9c7b5d3b4eea93dba8438e01b256898cdf451f47/camera/docs/metadata_definitions.xml#6627){: .external}
    metadata tag.

+   `android.scaler.availableRecommendedInputOutputFormatsMap` (available
    only if supported by device): The mapping of recommended image formats that
    are suggested for this camera device for input streams, to their
    corresponding output formats.

    This information is stored in the
    [`availableRecommendedDepthStreamConfigurations`](https://android.googlesource.com/platform/system/media/+/9c7b5d3b4eea93dba8438e01b256898cdf451f47/camera/docs/metadata_definitions.xml#10043){: .external}
    metadata tag.

This information is available to camera clients through the
[RecommendedStreamConfigurationMap](https://developer.android.com/reference/android/hardware/camera2/params/RecommendedStreamConfigurationMap){: .external}
API.

#### Required use cases

Recommended stream configurations must be provided for the following use cases
and meet the corresponding requirements:

<table>
<thead>
<tr>
<th><strong>Use case</strong></th>
<th><strong>Requirement</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td><code><strong>PREVIEW</strong></code></td>
<td>A preview must only include non-stalling processed stream configurations
  with output formats such as <code>YUV_420_888</code> and
  <code>IMPLEMENTATION_DEFINED</code>.</td>
</tr>
<tr>
<td><code><strong>RECORD</strong></code></td>
<td>A video record must include stream configurations that match the advertised
supported media <a
href="https://developer.android.com/reference/android/media/CamcorderProfile" class="external">profiles</a>
  with the <code>IMPLEMENTATION_DEFINED</code> format.</td>
</tr>
<tr>
  <td><code><strong>VIDEO_SNAPSHOT</strong></code></td>
<td>A video snapshot must include stream configurations that are at least as
large as the maximum RECORD resolutions and only with the BLOB +
DATASPACE_JFIF format/dataspace combination (JPEG). The configurations
should not cause preview glitches and should be able to run at 30 fps.</td>
</tr>
<tr>
<td><code><strong>SNAPSHOT</strong></code></td>
<td>Snapshot stream configurations must include at least one with a size close
to <code>android.sensor.info.activeArraySize</code> with the BLOB +
DATASPACE_JFIF format/dataspace combination (JPEG). Taking into account
restrictions on aspect ratio, alignment, and other vendor-specific restrictions,
the area of the maximum suggested size should not be less than 97% of the sensor
array size area.</td>
</tr>
<tr>
<td><strong><code>ZSL</code> (if supported)</strong></td>
<td>If supported by the camera device, recommended input stream configurations
must only be advertised together with other processed or stalling output
formats.</td>
</tr>
<tr>
<td><strong><code>RAW</code> (if supported)</strong></td>
<td>If supported by the camera device, recommended raw stream configurations
must only include RAW based output formats.</td>
</tr>
</tbody>
</table>

#### Other use cases

You can provide additional recommended configuration streams for use cases
specific to your implementation.

### Validation

To test your implementation of the recommended configuration streams, run the
following CTS and VTS tests:

+   CTS:
    [`ExtendedCameraCharacteristicsTest.java`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/ExtendedCameraCharacteristicsTest.java){: .external}

+   VTS:
    [`VtsHalCameraProviderV2_4TargetTest.cpp`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/provider/2.4/vts/functional/VtsHalCameraProviderV2_4TargetTest.cpp){: .external}

## API to query stream combinations

The Android platform supports an API to query stream combinations. Implementing
this API allows camera clients to safely query stream combinations at any point
after receiving a valid
[CameraDevice](https://developer.android.com/reference/android/hardware/camera2/CameraDevice){: .external}
instance, removing the overhead of initializing a camera capture session and
the potential of having subsequent camera exceptions including camera breakage,
and allowing for faster queries.

This feature also allows camera clients to receive a list of stream combinations
compiled according to the
[guidelines](https://developer.android.com/reference/android/hardware/camera2/CameraDevice#createCaptureSession(java.util.List%3Candroid.view.Surface%3E,%20android.hardware.camera2.CameraCaptureSession.StateCallback,%20android.os.Handler)){: .external}
for CameraDevice and the supported HW level. CTS tests are available to enforce
the correctness of query results as much as possible covering a minor subset of
the most common stream combinations.

You can choose to support this feature by implementing one additional HIDL API
call in the Camera HAL.

### Implementation

To support an API to query stream combinations, the Camera HAL must provide an
implementation for the
[`isStreamCombinationSupported`](https://android.googlesource.com/platform/hardware/interfaces/+/40a8c6ed51abdf0ebebd566879ef232573696ab0/camera/device/3.5/ICameraDevice.hal#114){: .external}
HIDL API interface. This interface checks whether the camera device supports a
specified camera stream combination.

When called, the API must return one of the following status codes:

+   `OK`: The stream combination query was successful.
+   `METHOD_NOT_SUPPORTED`: The camera device does not support the stream
    combination query.
+   `INTERNAL_ERROR`: The stream combination query cannot complete due to
    an internal error.

The API returns true if the stream combination is supported. Otherwise, it
returns false.

The framework uses the public API
[`isSessionConfigurationSupported`](https://developer.android.com/reference/android/hardware/camera2/CameraDevice#isSessionConfigurationSupported(android.hardware.camera2.params.SessionConfiguration)){: .external}
to check whether the particular session configuration is supported by the camera
device.

Calls to the API must not have any side effects on normal camera operation. API
calls must not alter any internal states or slow down the camera performance.
Make sure that after the Camera HAL successfully validates a stream combination,
camera clients can successfully configure the stream combination.
To avoid issues, make sure the implementation does not store any information
during stream combination queries, change its internal state, or engage in
time-consuming operations.

### Validation

To validate this feature, run the following Camera CTS and VTS test cases:

Camera CTS modules:

+   [`MultiViewTest.java`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/MultiViewTest.java){: .external}
+   [`RecordingTest.java`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/RecordingTest.java){: .external}
+   [`RobustnessTest.java`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/RobustnessTest.java){: .external}
+   [`SurfaceViewPreviewTest.java`](https://android.googlesource.com/platform/cts/+/master/tests/camera/src/android/hardware/camera2/cts/SurfaceViewPreviewTest.java){: .external}

Camera VTS:

[`VtsHalCameraProviderV2_4TargetTest.cpp`](https://android.googlesource.com/platform/hardware/interfaces/+/master/camera/provider/2.4/vts/functional/VtsHalCameraProviderV2_4TargetTest.cpp){: .external}
