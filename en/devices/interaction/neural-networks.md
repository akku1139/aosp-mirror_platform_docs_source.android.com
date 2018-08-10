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

This document provides an overview on how to implement a Neural Networks API
driver for Android {{ androidPVersionNumber }}. For full details, consult the
documentation found in the HAL definition files in
`hardware/interfaces/neuralnetworks. `You will find useful code, including a
sample driver, in `frameworks/ml/nn/driver.`

We suggest you familiarize yourself with the
[Neural Networks API guide](https://developer.android.com/ndk/guides/neuralnetworks/){: .external}
before reading this document.


## Changes introduced in Android {{ androidPVersionNumber }}

The 1.1 HAL is very similar to the 1.0 HAL introduced in Android 8.1. It contains
three notable changes:


*   `IDevice::prepareModel_1_1 `includes an `ExecutionPreference` parameter. A
    driver can use this to adjust its preparation, knowing that the application
    prefers to conserve battery or will be executing the model in quick
    successive calls.
*   Nine new operations have been added: `BATCH_TO_SPACE_ND`, `DIV`, `MEAN`,
    `PAD`, `SPACE_TO_BATCH_ND`, `SQUEEZE`, `STRIDED_SLICE`, `SUB`, `TRANSPOSE`.
*   An application can specify that 32 bit float computations can be run using
    16 bit float range and/or precision by setting
    `Model.relaxComputationFloat32toFloat16` to `true`. The `Capabilities`
    struct has the additional field `relaxedFloat32toFloat16Performance` so that
    the driver can report its relaxed performance to the Framework.


## Overview

The Neural Networks (NN) HAL defines an abstraction of the various accelerators.
The drivers for these accelerators must conform to this HAL. Like all drivers
implemented since the Android 8.0 release, the interface is specified in HIDL
files.

The general flow of the interface between the framework and a driver is depicted below:

![Neural Networks Interface](/devices/interaction/images/neural_networks_interface.png)

**Figure 1**: Neural Networks flow

## Initialization

At initialization, the Framework queries the driver for its capabilities. How
fast can the accelerator process floating point and quantized tensors? How much
power does the accelerator use doing so? The Framework uses this information to
determine where a model will be executed. See `IDevice::getCapabilities `in
`IDevice.hal`.


## Request compilation

For a given application request, the Framework needs to figure out which
accelerators to use.

At model compilation time, the framework sends the model to each driver by
calling `IDevice::getSupportedOperations`. Each driver returns an array of
booleans indicating which operations of the model are supported. The driver may
decide that it can't support a given operation for many reasons, for example:


*   It does not support the data type or the operation,
*   It supports only operations with specific input parameters, e.g. it can do
    convolve 3x3 and 5x5 but not 7x7, or
*   Memory constraints prevent it from handling large graphs or inputs.

The Framework chooses which parts of the model to run on the available
processors. It bases its decision on the performance characteristics of the
processor and on the preference stated by the application, e.g., whether it
prefers speed or energy efficiency. See the Performance Characteristics section
below.

The Framework instructs each selected driver to prepare to execute a subset of
the model by calling `IDevice::prepareModel.` This instructs the driver to
compile the request. A driver may for example generate code, create a re-ordered
copy of the weights, etc. There may be a substantial time between the
compilation of the model and the execution of requests, so precious resources
like large chunks of device memory should not be assigned at this time.

If any driver returns a failure code during the preparation, the Framework runs
the entire model on the CPU. On success, an `IPreparedModel `handle is returned.

A driver may want to cache to persistent storage the results of its compilation.
This avoids a perhaps lengthy compilation step each time the application is
started. The directory `frameworks/ml/nn/driver/cache` contains sample caching
code. The `nnCache `subdirectory contains persistent storage code. A driver is
free to use this implementation or any other. A driver is responsible for
freeing cached artefacts when they are no longer useful.


## Request execution

When the application asks the Framework to execute a request, the Framework
calls `IPreparedModel::execute` for each selected driver. The `Request
`parameter passed to this function lists the input and output buffers used for
the execution. Both input and output buffers use a standard format; see the
Tensors section.

The driver notifies the framework when the work has been completed via the
`IExecutionCallback`.

For user requests that span multiple processors, the Framework is responsible
for reserving the intermediate memory and for sequencing the calls to each
driver.

Multiple requests can be initiated in parallel on the same `IPreparedModel. `A
driver is free to execute them in parallel or to serialize their executions.

A driver may also be asked to keep around more than one prepared model. E.g.
prepare m1, prepare m2, run r1 on m1, run r2 on m2, run r3 on m1, run r4 on m2,
… delete m1, delete m2.

To avoid a slow first execution that could result in a poor user experience
(e.g., a first frame stutter), we recommend that the driver perform most
initializations in the compilation phase. Initialization on first execution
should be limited to actions that would negatively affect system health if done
very early, like reserving large temporary buffers or increasing the clock rate
of the accelerator. Drivers that can only prepare a very limited number of
concurrent models may also have to do their initialization at first execution.

To give good performance on quick successive executions, a driver may want to
hold on to temporary buffers or increased clock rates. We recommend that a
watchdog thread be created to release these resources if no new requests have
been created after a fixed period of time.

When an application is finished using a prepared model, the Framework releases
its reference to the `IPreparedModel` object. Shortly after, the
`IPreparedModel` object will be destroyed in the driver service that created it.
Model-specific resources can be reclaimed at this time in the implementation of
the destructor.


## Performance characteristics

To determine how to allocate the computations to the available accelerators, the
Framework must understand the efficiency of each accelerator: how fast it can
execute a query and how energy efficient it is.

While the performance could be simply measured by running a sample workload on
device, battery drain is harder to measure. For this reason, at initialization
time, the driver will provide standardized numbers on how fast and how
efficiently it can execute a few reference workloads.

This is an imperfect method. A lot of factors affect the actual runtime
performance: type of data, size of the tensors, operator types, etc.

In Android {{ androidPVersionNumber }}, we recommend that you use MobileNets
quantized and MobileNets floats as reference workloads when determining the
values that the driver must return in response to the `getCapabilities `call`.
`The MobileNets floats model should be used to measure both the full 32 bit
float performance and the relaxed 16 bit float performance.

A driver does not benefit from misrepresenting these numbers. Doing so will lead
the Framework to doing suboptimal work assignment. In future releases, these
numbers could be subject to verification by VTS.


## CPU usage

Drivers will use the CPU to set up the computations. They should not use the CPU
to perform graph computations, as this will interfere with the ability of the
Framework to allocate the work correctly. A driver should simply report to the
Framework the parts it can't handle, and let the Framework handle the rest.

There is no driver for the CPU. The Framework provides a CPU based
implementation of all operations except for OEM operations.


## Testing

Google provides a complete set of VTS tests. These tests exercise each API. They
also verify that all operators supported by a driver work correctly, and give
results of sufficient precision.

For Android {{ androidPVersionNumber }}, we've selected the following ad-hoc
precision requirements: 1e-5 for float, off-by-one for quantized. In the future,
we hope to establish more rigorous precision requirements based on tests on a
wide range of models and implementations.


## Security

Because application processes communicate directly to a driver's process, the
driver code must validate the arguments of the calls it receives. This
validation is verified by VTS. See `frameworks/ml/nn/include/ValidateHal.h` for
validation code.

Additionally, drivers should ensure that applications can't interfere with each
other even when they use the same accelerator.

