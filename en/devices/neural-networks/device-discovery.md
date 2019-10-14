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

# Device Discovery and Assignment

In Android {{ androidQVersionNumber }}, the
[Neural Networks API (NNAPI)](/devices/neural-networks/)
introduces functions that allow
machine learning framework
libraries and apps to get information about the devices available and
specify which devices to execute a model on. Providing information about the
available devices allows apps to get the exact version of the drivers
found on the device to avoid known incompatibilities. By giving apps the
ability to specify which devices are to execute different sections of a model,
apps can be optimized for the product on which they are deployed.

Support for device discovery and assignment is required for NN HAL 1.2
implementations.

## Implementation {:#implement}

To support the device discovery and assignment features in NNAPI, implement
[`getType`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#76){:.external}
and
[`getVersionString`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#56){:.external}
in `IDevice.hal` to allow the framework to get the device type and driver
version.

For each device, specify the type as one of the following categories as
specified in
[`DeviceType`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/types.hal#4737){:.external}
in
[`types.hal`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/types.hal){:.external}.

+   **`OTHER`:** A device that doesn't fall into any of the other
    categories, including a heterogeneous interface, which is a single `IDevice`
    interface that manages multiple devices, possibly of different types. A
    driver with a heterogeneous interface should also expose
    separate `IDevice` interfaces that correspond to individual devices to
    allow an application to choose from those devices.
+   **`CPU`:** A single core or multicore CPU.
+   **`GPU`:** A GPU that can run NNAPI models and accelerate graphics APIs such
    as OpenGL ES and Vulkan.
+   **`ACCELERATOR`:** A dedicated neural processing unit (NPU).

Implement
[`getVersionString`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#56){:.external}
in `IDevice.hal` for getting the version string of the device implementation.
This method must return a string that is human readable. The format of the
string is vendor specific. The version string must be different for each new
version of a driver.

The name of the `IDevice` interface must follow the `{VENDOR}-{DEVICE_NAME}`
format.
