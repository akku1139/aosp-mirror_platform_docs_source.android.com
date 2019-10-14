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

# Neural Networks API Drivers

This page provides an overview of how to implement a Neural Networks API (NNAPI)
driver. For further details, see the documentation found in the HAL definition
files in
[`hardware/interfaces/neuralnetworks`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/){:.external}.
A sample driver implementation is in
[`frameworks/ml/nn/driver/sample`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/driver/sample){:.external}.

For more information on the Neural Networks API, see
[Neural Networks API](https://developer.android.com/ndk/guides/neuralnetworks/){:.external}.

## Neural Networks HAL {:#nnhal}

The Neural Networks (NN) HAL defines an abstraction of the various _devices_,
such as graphics processing units (GPUs) and digital signal processors (DSPs),
that are in a product (for example, a phone or tablet). The drivers for these
devices must conform to the NN HAL. The interface is specified in the HAL
definition files in
[`hardware/interfaces/neuralnetworks`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/){:.external}.

The general flow of the interface between the framework and a driver is depicted
in figure 1.

![Neural Networks flow](/devices/neural-networks/images/neural-networks-interface.png)

**Figure 1.** Neural Networks flow

## Initialization {:#initialization}

At initialization, the framework queries the driver for its capabilities using
[`IDevice::getCapabilities_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#87){:.external}
in `IDevice.hal` (or
[`getCapabilities_1_1`](/reference/hidl/android/hardware/neuralnetworks/1.1/IDevice#getcapabilities_1_1)
for HAL 1.1 and
[`getCapabilities`](/reference/hidl/android/hardware/neuralnetworks/1.0/IDevice#getcapabilities)
for HAL 1.0). The `@1.2::Capabilities` structure includes all data types and
represents nonrelaxed performance using a vector.

To determine how to allocate computations to the available devices, the
framework uses the capabilities to understand how quickly and how energy
efficiently each driver can perform an execution. To provide this information,
the driver must provide standardized performance numbers based on the execution
of reference workloads.

To determine the values that the driver returns in response to
`IDevice::getCapabilities_1_2`, use the NNAPI benchmark app to measure the
performance for corresponding data types. The MobileNet v1 and v2, `asr_float`,
and `tts_float` models are recommended for measuring performance for 32-bit
floating point values and the MobileNet v1 and v2 quantized models are
recommended for 8-bit quantized values. For more information, see
[Android Machine Learning Test Suite](#mlts).

In Android 9 and lower, the `Capabilities` structure includes driver performance
information only for floating point and quantized tensors and doesn't include
scalar data types.

As part of the initialization process, the framework may query more information,
using
[`IDevice::getType`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#76){:.external},
[`IDevice::getVersionString`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#56){:.external},
[`IDevice:getSupportedExtensions`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#101){:.external},
and
[`IDevice::getNumberOfCacheFilesNeeded`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#164){:.external}.

Between product reboots, the framework expects all queries described in this
section to always report the same values for a given driver. Otherwise, an app
using that driver may exhibit reduced performance or incorrect behavior.

## Compilation {:#compilation}

The framework determines which devices to use when it receives a request from an
app. In Android {{ androidQVersionNumber }}, apps can discover
and specify the devices
that the framework picks from. For more information, see
[Device Discovery and Assignment](/devices/neural-networks/device-discovery).

At model compilation time, the framework sends the model to each candidate
driver by calling
[`IDevice::getSupportedOperations_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#123){:.external}
(or
[`getSupportedOperations_1_1`](/reference/hidl/android/hardware/neuralnetworks/1.1/IDevice#getsupportedoperations_1_1)
for HAL 1.1 and
[`getSupportedOperations`](/reference/hidl/android/hardware/neuralnetworks/1.0/IDevice#getsupportedoperations)
for HAL 1.0). Each driver returns an array of booleans indicating which
operations of the model are supported. A driver can determine that it can't
support a given operation for a number of reasons. For example:

+   The driver doesn't support the data type.
+   The driver only supports operations with specific input parameters. For
    example, a driver might support 3x3 and 5x5, but not 7x7 convolution
    operations.
+   The driver has memory constraints preventing it from handling large
    graphs or inputs.

During compilation, the input, output, and internal operands of the model, as
described in
[`OperandLifeTime`](/reference/hidl/android/hardware/neuralnetworks/1.0/types#operandlifetime),
can have unknown dimensions or rank. For more information, see
[Output shape](#output-shape).

The framework instructs each selected driver to prepare to execute a subset of
the model by calling
[`IDevice::prepareModel_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#266){:.external}
or
[`prepareModelFromCache`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#346){:.external}
(or
[`prepareModel_1_1`](/reference/hidl/android/hardware/neuralnetworks/1.1/IDevice#preparemodel_1_1)
for HAL 1.1 and
[`prepareModel`](/reference/hidl/android/hardware/neuralnetworks/1.0/IDevice#preparemodel)
for HAL 1.0). Each driver then compiles its subset. For example, a driver might
generate code or create a reordered copy of the weights. Because there can be a
significant amount of time between the compilation of the model and the
execution of requests, resources such as large chunks of device memory shouldn't
be assigned during compilation.

On success, the driver returns an
[`@1.2::IPreparedModel`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IPreparedModel.hal){:.external}
(or
[`@1.0::IPreparedModel`](/reference/hidl/android/hardware/neuralnetworks/1.0/IPreparedModel))
handle. If the driver returns a failure code when preparing its subset of the
model, the framework runs the entire model on the CPU.

To reduce the time used for compilation when an app starts, a driver can
cache compilation artifacts. For more information, see [Compilation
Caching](/devices/neural-networks/compilation-caching).

## Execution {:#execution}

When an app asks the framework to execute a request, the framework calls
the
[`IPreparedModel::executeSynchronously`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IPreparedModel.hal#141){:.external}
HAL method by default to perform a synchronous execution on a prepared model.
A request can also be executed asynchronously using the
[`execute_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IPreparedModel.hal#79){:.external}
method
([`execute`](/reference/hidl/android/hardware/neuralnetworks/1.0/IPreparedModel#execute)
for drivers with NN HAL 1.1 or lower)
or executed using a
[burst execution](/devices/neural-networks/burst-executions).

Synchronous execution calls improve performance and reduce threading
overhead as compared to asynchronous calls because control is returned to the
app process only after the execution is completed. This means that the
driver doesn't need a separate mechanism to notify the app process that
an execution is completed.

With the asynchronous `execute_1_2` or `execute` method, control returns to the
app process after the execution has started, and the driver must notify
the framework when the execution is completed, using the
[`@1.2::IExecutionCallback`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IExecutionCallback.hal){:.external}
or
[`@1.0::IExecutionCallback`](/reference/hidl/android/hardware/neuralnetworks/1.0/IExecutionCallback)
interface.

For debugging, you may want to set the `debug.nn.syncexec-hal` property to `0`,
which tells the framework to call the asynchronous
[`execute_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IPreparedModel.hal#79){:.external}
method instead of `executeSynchronously` because otherwise there might be no way
of running `execute_1_2` from the framework.

The `Request` parameter passed to the execute method lists the input and output
operands used for the execution. The memory that stores the operand data must
use row-major order with the first dimension iterating the slowest and have no
padding at the end of any row. For more information about the types of operands,
see
[Operands](https://developer.android.com/ndk/guides/neuralnetworks#operands){:.external}.

For NN HAL 1.2 drivers, when a request is
completed, the error status, [output shape](#output-shape), and
[timing information](#timing) are returned
to the framework. During execution, output or internal operands of the model can
have one or more unknown dimensions or unknown rank. When at least one output
operand has an unknown dimension or rank, the driver must return
dynamically sized output information.

For drivers with NN HAL 1.1 or lower, only the error status is returned when a
request is completed. The dimensions for input and output operands must be fully
specified for the execution to complete successfully. Internal operands can
have one or more unknown dimensions, but they must have specified rank.

For user requests that span multiple drivers, the framework is responsible for
reserving intermediate memory and for sequencing the calls to each driver.

Multiple requests can be initiated in parallel on the same
[`@1.2::IPreparedModel`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IPreparedModel.hal){:.external}
(or
[`@1.0::IPreparedModel`](/reference/hidl/android/hardware/neuralnetworks/1.0/IPreparedModel)).
The driver can execute requests in parallel or serialize the executions.

The framework can ask a driver to keep more than one prepared model. For
example, prepare model `m1`, prepare `m2`, execute request `r1` on `m1`, execute
`r2` on `m2`, execute `r3` on `m1`, execute `r4` on `m2`, release (described in
[Cleanup](#cleanup)) `m1`, and release `m2`.

To avoid a slow first execution that could result in a poor user experience (for
example, a first frame stutter), the driver should perform most initializations
in the compilation phase. Initialization on first execution should be limited to
actions that negatively affect system health when performed early, such as
reserving large temporary buffers or increasing the clock rate of a device.
Drivers that can prepare only a limited number of concurrent models might have
to do their initialization at first execution.

In Android {{ androidQVersionNumber }}, in cases where multiple executions with
the same prepared model
are executed in quick succession, the client may choose to use an execution
burst object to communicate between app and driver processes. For more
information, see
[Burst Executions and Fast Message Queues](/devices/neural-networks/burst-executions).

To improve performance for multiple executions in quick succession, the driver
can hold on to temporary buffers or increase clock rates. Creating a watchdog
thread is recommended to release resources if no new requests are created after
a fixed period of time.

Note: Support for synchronous execution calls across the HAL layer isn't
dependent on synchronous execution calls across the NDK layer.

### Output shape {:#output-shape}

For requests where one or more output operands don't have all dimensions
specified, the driver must provide a list of output shapes containing the
dimension information for each output operand after execution. For more
information on dimensions, see
[`types.hal`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/types.hal#4872){:.external}.

If an execution fails because of an undersized output buffer, the driver must
indicate which output operands have insufficient buffer size in the list of
output shapes, and should report as much dimensional information as possible,
using zero for dimensions that are unknown.

### Timing {:#timing}

In Android {{ androidQVersionNumber }}, an app can ask for the execution
time if the app
has specified a single device to use during the compilation process. For
details, see
[`MeasureTiming`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/types.hal#5081){:.external}
and [Device Discovery and Assignment](/devices/neural-networks/device-discovery).
In this case, an
NN HAL 1.2 driver must measure execution duration or report `UINT64_MAX` (to
indicate that duration is unavailable) when executing a request. The driver
should minimize any performance penalty resulting from measuring execution
duration.

The driver reports the following durations in microseconds in the
[`Timing`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/types.hal#5096){:.external}
structure:

+   **Execution time on device:** Doesn't include execution time in the
    driver, which runs on the host processor.
+   **Execution time in the driver:** Includes execution time on device.

These durations must include the time when the execution is suspended, for
example, when the execution has been preempted by other tasks or when it is
waiting for a resource to become available.

Note: While the driver reports durations in microseconds, the framework reports
durations in nanoseconds (by scaling the durations reported by the driver).

When the driver hasn't been asked to measure the execution duration, or when
there's an execution error, the driver must report durations as
`UINT64_MAX`. Even when the driver has been asked to measure the execution
duration, it can instead report `UINT64_MAX` for time on the device, time in the
driver, or both. When the driver reports both durations as a value other than
`UINT64_MAX`, the execution time in the driver must equal or exceed the time on
the device.

## Cleanup {:#cleanup}

When an app is finished using a prepared model, the framework releases
its reference to the
[`@1.2::IPreparedModel`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IPreparedModel.hal){:.external}
(or
[`@1.0::IPreparedModel`](/reference/hidl/android/hardware/neuralnetworks/1.0/IPreparedModel))
object. When the `IPreparedModel` object is no longer referenced, it's
automatically destroyed in the driver service that created it. Model-specific
resources can be reclaimed at this time in the driver's implementation of the
destructor. If the driver service wants the `IPreparedModel` object to be
automatically destroyed when no longer needed by the client, it must not hold
any references to the `IPreparedModel` object after the `IPreparedeModel` object
has been returned through
[`IPreparedModelCallback::notify_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IPreparedModelCallback.hal#54){:.external}
or
[`IPreparedModelCallback::notify`](/reference/hidl/android/hardware/neuralnetworks/1.0/IPreparedModelCallback#notify).

## CPU usage {:#cpu-usage}

Drivers are expected to use the CPU to set up computations. Drivers shouldn't
use the CPU to perform graph computations because that interferes with the
ability of the framework to correctly allocate work. The driver should report
the parts that it can't handle to the framework and let the framework handle the
rest.

The framework provides a CPU implementation for all NNAPI operations except for
vendor-defined operations. For more information, see
[Vendor Extensions](/devices/neural-networks/vendor-extensions).

The
[operations introduced in Android {{ androidQVersionNumber }}](#android-q)
(API level 29)
only have a reference CPU implementation to verify that the CTS and VTS tests
are correct. The optimized implementations included in mobile machine learning
frameworks are preferred over the NNAPI CPU implementation.

## Utility functions

The NNAPI codebase includes utility functions that can be used by driver
services.

The
[`frameworks/ml/nn/common/include/Utils.h`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/common/include/Utils.h){:.external}
file contains assorted utility functions, such as those used for logging and
for converting between different NN HAL versions.

+   VLogging: `VLOG` is a wrapper macro around Android's `LOG` that only
    logs the message if the appropriate tag is set in the `debug.nn.vlog`
    property.
    [`initVLogMask()`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/common/Utils.cpp#50){:.external}
    must be called before any calls to `VLOG`. The `VLOG_IS_ON` macro can be
    used to check if `VLOG` is currently enabled, enabling complicated logging
    code to be skipped if it's not needed. The value of the property must be
    one of the following:

    +   An empty string, indicating that no logging is to be done.
    +   The token `1` or `all`, indicating that all logging is to be done.
    +   A list of tags, delimited by spaces, commas, or colons,
        indicating which logging is to be done. The tags are `compilation`,
        `cpuexe`, `driver`, `execution`, `manager`, and `model`.

+   `compliantWithV1_*`: Returns `true` if an NN HAL object can be converted
    to the same type of a different HAL version without losing information. For
    example, calling `compliantWithV1_0` on a `V1_2::Model` returns `false` if
    the model includes operation types introduced in NN HAL 1.1 or NN HAL 1.2.
+   `convertToV1_*`: Converts an NN HAL object from one version to another.
    A warning is logged if the conversion results in a loss of information (that
    is, if the new version of the type cannot fully represent the value).
+   Capabilities: The `nonExtensionOperandPerformance` and `update`
    functions can be used to help build the
    [`Capabilities::operandPerformance`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/types.hal#4782){:.external}
    field.
+   Querying properties of types: `isExtensionOperandType`,
    `isExtensionOperationType`, `nonExtensionSizeOfData`,
    `nonExtensionOperandSizeOfData`, `nonExtensionOperandTypeIsScalar`,
    `tensorHasUnspecifiedDimensions`.

The
[`frameworks/ml/nn/common/include/ValidateHal.h`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/common/include/ValidateHal.h){:.external}
file contains utility functions for validating that an NN HAL object is valid
according to its HAL version's specification.

+   `validate*`: Returns `true` if the NN HAL object is valid
    according to its HAL version's specification. OEM types and extension types
    aren't validated. For example, `validateModel` returns `false` if the
    model contains an operation that references an operand index that doesn't
    exist, or an operation that isn't supported at that HAL version.

The
[`frameworks/ml/nn/common/include/Tracing.h`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/common/include/Tracing.h){:.external}
file contains macros to simplify adding
[systracing](/devices/tech/debug/systrace) information to Neural Networks code.
For an example, see the `NNTRACE_*` macro invocations in the
[sample driver](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/driver/sample){:.external}.

The
[`frameworks/ml/nn/common/include/GraphDump.h`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/common/include/GraphDump.h){:.external}
file contains a utility function to dump the content of a `Model` in graphical
form for debugging purposes.

+   `graphDump`: Writes a representation of the model in Graphviz
    (`.dot`) format to the specified stream (if provided) or to the logcat (if
    no stream is provided).

## Validation {:#validation}

To test your implementation of the NNAPI, use the VTS and CTS tests included in
the Android framework. VTS exercises your drivers directly (without using the
framework), whereas CTS exercises them indirectly through the framework. These
test each API method and verify that all operations supported by the
drivers work correctly and provide results that meet the precision requirements.

The precision requirements in CTS and VTS for the NNAPI are as follows:

+   **Floating-point:**
    abs(expected&nbsp;-&nbsp;actual)&nbsp;<=&nbsp;atol&nbsp;+&nbsp;rtol&nbsp;
    *&nbsp;abs(expected); where:

    +   For fp32, atol&nbsp;=&nbsp;rtol&nbsp;=&nbsp;1e-5f
    +   For fp16, atol&nbsp;=&nbsp;rtol&nbsp;=&nbsp;5.0f&nbsp;*&nbsp;0.0009765625f

+   **Quantized:** off-by-one (except for `mobilenet_quantized`,
    which is off-by-two)
+   **Boolean:** exact match

One way CTS tests NNAPI is by generating fixed pseudorandom graphs
used to test and compare the
execution results from each driver with the NNAPI reference implementation. For
drivers with NN HAL 1.2 or higher, if the results don't meet the precision
criteria, CTS reports an error and dumps a specification file for the failed
model under `/data/local/tmp` for debugging. For more details about the
precision criteria, see
[`TestRandomGraph.cpp`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/runtime/test/fuzzing/TestRandomGraph.cpp#573){:.external}
and
[`RandomGraphGenerator.h`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/runtime/test/fuzzing/RandomGraphGenerator.h){:.external}.

### Security {:#security}

Because app processes communicate directly with a driver's process,
drivers must validate the arguments of the calls they receive. This validation
is verified by VTS. The validation code is in
[`frameworks/ml/nn/common/include/ValidateHal.h`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/common/include/ValidateHal.h){:.external}.

Drivers should also ensure that apps can't interfere with other
apps when using the same device.

### Android Machine Learning Test Suite {:#mlts}

The Android Machine Learning Test Suite (MLTS) is an NNAPI benchmark included in
CTS and VTS for validating the accuracy of real models on vendor devices. The
benchmark evaluates latency and accuracy, and compares the drivers' results with
the results using
[TF Lite](https://www.tensorflow.org/lite){:.external} running on the CPU,
for the same model and datasets. This ensures that a driver's accuracy isn't
worse than the CPU reference implementation.

Android platform developers also use MLTS to evaluate the latency and accuracy
of drivers.

The NNAPI benchmark can be found in two projects in AOSP:

+   [`platform/test/mlts/benchmark`](https://android.googlesource.com/platform/test/mlts/benchmark/+/master){:.external}
    (benchmark app)
+   [`platform/test/mlts/models`](https://android.googlesource.com/platform/test/mlts/models/+/master){:.external}
    (models and datasets)

#### Models and datasets {:#models}

The NNAPI benchmark uses the following models and datasets.

+   MobileNetV1 float and u8 quantized in different sizes, run against a
    small subset (1500 images) of Open Images Dataset v4.
+   MobileNetV2 float and u8 quantized in different sizes, run against a
    small subset (1500 images) of Open Images Dataset v4.
+   Long short-term memory (LSTM) based acoustic model for text-to-speech,
    run against a small subset of the CMU Arctic set.
+   LSTM based acoustic model for automatic speech recognition, run against
    a small subset of the LibriSpeech dataset.

For more information, see
[`platform/test/mlts/models`](https://android.googlesource.com/platform/test/mlts/models/+/master){:.external}.

#### Using MLTS {:#use-mlts}

To use the MLTS:

1.  Connect a target device to your workstation and make sure it's
    reachable through
    [adb](https://developer.android.com/studio/command-line/adb){:.external}.
    Export the target device `ANDROID_SERIAL`
    environment variable if more than one device is connected.
1.  `cd` into the Android top-level source directory.

    ```
    source build/envsetup.sh
    lunch aosp_arm-userdebug # Or aosp_arm64-userdebug if available.
    ./test/mlts/benchmark/build_and_run_benchmark.sh
    ```

    At the end of a benchmark run, the results are presented as an HTML page
    and passed to `xdg-open`.

For more information, see
[`platform/test/mlts/benchmark/README.txt`](https://android.googlesource.com/platform/test/mlts/benchmark/+/refs/heads/master/README.txt){:.external}.

## Neural Networks HAL versions {:#hal-versions}

This section describes the changes introduced in Android and Neural
Networks HAL versions.

### Android {{ androidQVersionNumber }} {:#android-q}

Android {{ androidQVersionNumber }} introduces NN HAL 1.2, which includes the
following notable changes.

+   The `Capabilities` struct includes all data types including scalar
    data types, and represents nonrelaxed performance using a vector rather
    than named fields.
+   The `getVersionString` and `getType` methods allow the framework to
    retrieve device type (`DeviceType`) and version information. See
    [Device Discovery and Assignment](/devices/neural-networks/device-discovery).
+   The `executeSynchronously` method is called by default to perform an
    execution synchronously. The `execute_1_2` method tells the framework to
    perform an execution asynchronously. See [Execution](#execution).
+   The `MeasureTiming` parameter to `executeSynchronously`, `execute_1_2`,
    and burst execution specifies whether the driver is to measure execution
    duration. The results are reported in the `Timing` structure. See
    [Timing](#timing).
+   Support for executions where one or more output operands have an unknown
    dimension or rank. See [Output shape](#output-shape).
+   Support for vendor extensions, which are collections of vendor-defined
    operations and data types. The driver reports supported extensions through
    the `IDevice::getSupportedExtensions` method. See
    [Vendor Extensions](/devices/neural-networks/vendor-extensions).
+   Ability for a burst object to control a set of burst executions using
    fast message queues (FMQs) to communicate between app and driver
    processes, reducing latency. See
    [Burst Executions and Fast Message Queues](/devices/neural-networks/burst-executions).
+   Support for AHardwareBuffer to allow the driver to perform executions
    without copying data. See
    [AHardwareBuffer](/devices/neural-networks/ahardwarebuffer).
+   Improved support for caching of compilation artifacts to reduce the time
    used for compilation when an app starts. See
    [Compilation Caching](/devices/neural-networks/compilation-caching).

Android {{ androidQVersionNumber }} introduces the following operand types and
operations.

+   [Operand types](https://developer.android.com/ndk/reference/group/neural-networks.html#operandcode){:.external}

    +   `ANEURALNETWORKS_BOOL`
    +   `ANEURALNETWORKS_FLOAT16`
    +   `ANEURALNETWORKS_TENSOR_BOOL8`
    +   `ANEURALNETWORKS_TENSOR_FLOAT16`
    +   `ANEURALNETWORKS_TENSOR_QUANT16_ASYMM`
    +   `ANEURALNETWORKS_TENSOR_QUANT16_SYMM`
    +   `ANEURALNETWORKS_TENSOR_QUANT8_SYMM`
    +   `ANEURALNETWORKS_TENSOR_QUANT8_SYMM_PER_CHANNEL`

+   [Operations](https://developer.android.com/ndk/reference/group/neural-networks.html#operationcode){:.external}

    +   `ANEURALNETWORKS_ABS`
    +   `ANEURALNETWORKS_ARGMAX`
    +   `ANEURALNETWORKS_ARGMIN`
    +   `ANEURALNETWORKS_AXIS_ALIGNED_BBOX_TRANSFORM`
    +   `ANEURALNETWORKS_BIDIRECTIONAL_SEQUENCE_LSTM`
    +   `ANEURALNETWORKS_BIDIRECTIONAL_SEQUENCE_RNN`
    +   `ANEURALNETWORKS_BOX_WITH_NMS_LIMIT`
    +   `ANEURALNETWORKS_CAST`
    +   `ANEURALNETWORKS_CHANNEL_SHUFFLE`
    +   `ANEURALNETWORKS_DETECTION_POSTPROCESSING`
    +   `ANEURALNETWORKS_EQUAL`
    +   `ANEURALNETWORKS_EXP`
    +   `ANEURALNETWORKS_EXPAND_DIMS`
    +   `ANEURALNETWORKS_GATHER`
    +   `ANEURALNETWORKS_GENERATE_PROPOSALS`
    +   `ANEURALNETWORKS_GREATER`
    +   `ANEURALNETWORKS_GREATER_EQUAL`
    +   `ANEURALNETWORKS_GROUPED_CONV_2D`
    +   `ANEURALNETWORKS_HEATMAP_MAX_KEYPOINT`
    +   `ANEURALNETWORKS_INSTANCE_NORMALIZATION`
    +   `ANEURALNETWORKS_LESS`
    +   `ANEURALNETWORKS_LESS_EQUAL`
    +   `ANEURALNETWORKS_LOG`
    +   `ANEURALNETWORKS_LOGICAL_AND`
    +   `ANEURALNETWORKS_LOGICAL_NOT`
    +   `ANEURALNETWORKS_LOGICAL_OR`
    +   `ANEURALNETWORKS_LOG_SOFTMAX`
    +   `ANEURALNETWORKS_MAXIMUM`
    +   `ANEURALNETWORKS_MINIMUM`
    +   `ANEURALNETWORKS_NEG`
    +   `ANEURALNETWORKS_NOT_EQUAL`
    +   `ANEURALNETWORKS_PAD_V2`
    +   `ANEURALNETWORKS_POW`
    +   `ANEURALNETWORKS_PRELU`
    +   `ANEURALNETWORKS_QUANTIZE`
    +   `ANEURALNETWORKS_QUANTIZED_16BIT_LSTM`
    +   `ANEURALNETWORKS_RANDOM_MULTINOMIAL`
    +   `ANEURALNETWORKS_REDUCE_ALL`
    +   `ANEURALNETWORKS_REDUCE_ANY`
    +   `ANEURALNETWORKS_REDUCE_MAX`
    +   `ANEURALNETWORKS_REDUCE_MIN`
    +   `ANEURALNETWORKS_REDUCE_PROD`
    +   `ANEURALNETWORKS_REDUCE_SUM`
    +   `ANEURALNETWORKS_RESIZE_NEAREST_NEIGHBOR`
    +   `ANEURALNETWORKS_ROI_ALIGN`
    +   `ANEURALNETWORKS_ROI_POOLING`
    +   `ANEURALNETWORKS_RSQRT`
    +   `ANEURALNETWORKS_SELECT`
    +   `ANEURALNETWORKS_SIN`
    +   `ANEURALNETWORKS_SLICE`
    +   `ANEURALNETWORKS_SPLIT`
    +   `ANEURALNETWORKS_SQRT`
    +   `ANEURALNETWORKS_TILE`
    +   `ANEURALNETWORKS_TOPK_V2`
    +   `ANEURALNETWORKS_TRANSPOSE_CONV_2D`
    +   `ANEURALNETWORKS_UNIDIRECTIONAL_SEQUENCE_LSTM`
    +   `ANEURALNETWORKS_UNIDIRECTIONAL_SEQUENCE_RNN`

Android {{ androidQVersionNumber }} introduces updates to many of the existing
operations. The updates are
mainly related to the following:

+   Support for the NCHW memory layout
+   Support for tensors with rank different than 4 in softmax and
    normalization operations
+   Support for dilated convolutions
+   Support for inputs with mixed quantization in
    `ANEURALNETWORKS_CONCATENATION`

The list below shows the operations that are modified in
Android {{ androidQVersionNumber }}. For full
details of the changes, see
[OperationCode](https://developer.android.com/ndk/reference/group/neural-networks#operationcode){:.external}
in the NNAPI reference documentation.

+   `ANEURALNETWORKS_ADD`
+   `ANEURALNETWORKS_AVERAGE_POOL_2D`
+   `ANEURALNETWORKS_BATCH_TO_SPACE_ND`
+   `ANEURALNETWORKS_CONCATENATION`
+   `ANEURALNETWORKS_CONV_2D`
+   `ANEURALNETWORKS_DEPTHWISE_CONV_2D`
+   `ANEURALNETWORKS_DEPTH_TO_SPACE`
+   `ANEURALNETWORKS_DEQUANTIZE`
+   `ANEURALNETWORKS_DIV`
+   `ANEURALNETWORKS_FLOOR`
+   `ANEURALNETWORKS_FULLY_CONNECTED`
+   `ANEURALNETWORKS_L2_NORMALIZATION`
+   `ANEURALNETWORKS_L2_POOL_2D`
+   `ANEURALNETWORKS_LOCAL_RESPONSE_NORMALIZATION`
+   `ANEURALNETWORKS_LOGISTIC`
+   `ANEURALNETWORKS_LSH_PROJECTION`
+   `ANEURALNETWORKS_LSTM`
+   `ANEURALNETWORKS_MAX_POOL_2D`
+   `ANEURALNETWORKS_MEAN`
+   `ANEURALNETWORKS_MUL`
+   `ANEURALNETWORKS_PAD`
+   `ANEURALNETWORKS_RELU`
+   `ANEURALNETWORKS_RELU1`
+   `ANEURALNETWORKS_RELU6`
+   `ANEURALNETWORKS_RESHAPE`
+   `ANEURALNETWORKS_RESIZE_BILINEAR`
+   `ANEURALNETWORKS_RNN`
+   `ANEURALNETWORKS_ROI_ALIGN`
+   `ANEURALNETWORKS_SOFTMAX`
+   `ANEURALNETWORKS_SPACE_TO_BATCH_ND`
+   `ANEURALNETWORKS_SPACE_TO_DEPTH`
+   `ANEURALNETWORKS_SQUEEZE`
+   `ANEURALNETWORKS_STRIDED_SLICE`
+   `ANEURALNETWORKS_SUB`
+   `ANEURALNETWORKS_SVDF`
+   `ANEURALNETWORKS_TANH`
+   `ANEURALNETWORKS_TRANSPOSE`

### Android 9 {:#android-9}

NN HAL 1.1 is introduced in Android 9 and includes the following notable
changes.

+   `IDevice::prepareModel_1_1` includes an `ExecutionPreference`
    parameter. A driver can use this to adjust its preparation, knowing that
    the app prefers to conserve battery or will be executing the model
    in quick successive calls.
+   Nine new operations have been added: `BATCH_TO_SPACE_ND`, `DIV`, `MEAN`,
    `PAD`, `SPACE_TO_BATCH_ND`, `SQUEEZE`, `STRIDED_SLICE`, `SUB`, `TRANSPOSE`.
+   An app can specify that 32-bit float computations can be run
    using 16-bit float range and/or precision by setting
    `Model.relaxComputationFloat32toFloat16` to `true`. The `Capabilities`
    struct has the additional field `relaxedFloat32toFloat16Performance` so
    that the driver can report its relaxed performance to the framework.

### Android 8.1 {:#android-81}

The initial Neural Networks HAL (1.0) was released in Android 8.1. For more
information, see
[`/neuralnetworks/1.0/`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.0/){:.external}.

