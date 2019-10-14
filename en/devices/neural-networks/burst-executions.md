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

# Burst Executions and Fast Message Queues

Neural Networks HAL 1.2 introduces the concept of burst executions. Burst
executions are a sequence of executions of the same prepared model that occur in
rapid succession, such as those operating on frames of a camera capture or
successive audio
samples. A burst object is used to control a set of burst executions, and to
preserve resources between executions, enabling executions to have lower
overhead. Burst objects enable three optimizations:

1.  A burst object is created before a sequence of executions, and freed
    when the sequence has ended. Because of this, the lifetime of the burst
    object hints to a driver how long it should remain in a high-performance
    state.
1.  A burst object can preserve resources between executions. For example, a
    driver can map a memory object on the first execution and cache the mapping
    in the burst object for reuse in subsequent executions. Any cached resource
    can be released when the burst object is destroyed or when the NNAPI
    runtime notifies the burst object that the resource is no longer required.
1.  A burst object uses
    [fast message queues](/devices/architecture/hidl/fmq)
    (FMQs) to communicate between app and driver processes. This can
    reduce latency because the FMQ bypasses HIDL and passes data directly to
    another process through an atomic circular FIFO in shared memory. The
    consumer process knows to dequeue an item and begin processing either by
    polling the number of elements in the FIFO or by waiting on the FMQ's event
    flag, which is signaled by the producer. This event flag is a fast
    userspace mutex (futex).

An FMQ is a low-level data structure that offers no lifetime guarantees across
processes and has no built-in mechanism for determining if the process on the
other end of the FMQ is running as expected. Consequently, if the producer for
the FMQ dies, the consumer may be stuck waiting for data that never arrives. One
solution to this problem is for the driver to associate FMQs with the
higher-level burst object to detect when the burst execution has ended.

Because burst executions operate on the same arguments and return the same
results as other execution paths, the underlying FMQs must pass the same data to
and from the NNAPI service drivers. However, FMQs can only transfer
plain-old-data types. Transferring complex data is accomplished by serializing
and deserializing nested buffers (vector types) directly in the FMQs, and using
HIDL callback objects to transfer memory pool handles on demand. The producer
side of the FMQ must send the request or result messages to the consumer
atomically by using `MessageQueue::writeBlocking` if the queue is blocking, or
by using `MessageQueue::write` if the queue is nonblocking.

## Burst interfaces {:#burst-interfaces}

The burst interfaces for the Neural Networks HAL are found in
[`hardware/interfaces/neuralnetworks/1.2/`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/){:.external}
and are described below. For more information on burst interfaces in the NDK
layer, see
[`frameworks/ml/nn/runtime/include/NeuralNetworks.h`](https://android.googlesource.com/platform/frameworks/ml/+/master/nn/runtime/include/NeuralNetworks.h){:.external}.

### types.hal {:#types}

[`types.hal`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/types.hal){:.external}
defines the type of data that is sent across the FMQ.

+   [`FmqRequestDatum`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/types.hal#5128){:.external}:
    A single element of a serialized representation of an execution `Request`
    object and a `MeasureTiming` value, which is sent across the fast message
    queue.
+   [`FmqResultDatum`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/types.hal#5251){:.external}:
    A single element of a serialized representation of the values returned from
    an execution (`ErrorStatus`, `OutputShapes`, and `Timing`), which is
    returned through the fast message queue.

### IBurstContext.hal {:#burstcontext}

[`IBurstContext.hal`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/IBurstContext.hal){:.external}
defines the HIDL interface object that lives in the Neural Networks service.

+   [`IBurstContext`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/IBurstContext.hal#22){:.external}:
    Context object to manage the resources of a burst.

### IBurstCallback.hal {:#burstcallback}

[`IBurstCallback.hal`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/IBurstCallback.hal){:.external}
defines the HIDL interface object for a callback created by the Neural Networks
runtime and is used by the Neural Networks service to retrieve `hidl_memory`
objects corresponding to slot identifiers.

+   [IBurstCallback](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/IBurstCallback.hal#25){:.external}:
    Callback object used by a service to retrieve memory objects.

### IPreparedModel.hal {:#preparedmodel}

[`IPreparedModel.hal`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/IPreparedModel.hal){:.external}
is extended in HAL 1.2 with a method to create an `IBurstContext` object from a
prepared model.

+   [`configureExecutionBurst`](https://android.googlesource.com/platform/hardware/interfaces/+/master/neuralnetworks/1.2/IPreparedModel.hal#156){:.external}:
    Configures a burst object used to execute multiple inferences on a prepared
    model in rapid succession.

## Supporting burst executions in a driver {:#support-driver}

The simplest way to support burst objects in a HIDL NNAPI service is to use the
burst utility function `::android::nn::ExecutionBurstServer::create`, which is
found in
[`ExecutionBurstServer.h`](https://android.googlesource.com/platform/frameworks/ml/+/master/nn/common/include/ExecutionBurstServer.h#274){:.external}
and packaged in the `libneuralnetworks_common` and `libneuralnetworks_util`
static libraries. This factory function has two overloads:

+   One overload accepts a pointer to an `IPreparedModel` object. This
    utility function uses the `executeSynchronously` method in an
    `IPreparedModel` object to execute the model.
+   One overload accepts a customizable `IBurstExecutorWithCache` object,
    which can be used to cache resources (such as `hidl_memory` mappings) that
    persist across multiple executions.

Each overload returns an `IBurstContext` object (which represents the burst
object) that contains and manages its own dedicated listener thread. This thread
receives requests from the `requestChannel` FMQ, performs the inference, then
returns the results through the `resultChannel` FMQ. This thread and all other
resources contained in the `IBurstContext` object are automatically released
when the burst's client loses its reference to `IBurstContext`.

Alternatively, you can create your own implementation of `IBurstContext` that
understands how to send and receive messages over the `requestChannel` and
`resultChannel` FMQs passed to `IPreparedModel::configureExecutionBurst`.

The burst utility functions are found in
[`ExecutionBurstServer.h`](https://android.googlesource.com/platform/frameworks/ml/+/master/nn/common/include/ExecutionBurstServer.h#274){:.external}.

```
/**
 * Create automated context to manage FMQ-based executions.
 *
 * This function is intended to be used by a service to automatically:
 * 1) Receive data from a provided FMQ
 * 2) Execute a model with the given information
 * 3) Send the result to the created FMQ
 *
 * @param callback Callback used to retrieve memories corresponding to
 *     unrecognized slots.
 * @param requestChannel Input FMQ channel through which the client passes the
 *     request to the service.
 * @param resultChannel Output FMQ channel from which the client can retrieve
 *     the result of the execution.
 * @param executorWithCache Object which maintains a local cache of the
 *     memory pools and executes using the cached memory pools.
 * @result IBurstContext Handle to the burst context.
 */
static sp<ExecutionBurstServer> create(
        const sp<IBurstCallback>& callback, const FmqRequestDescriptor& requestChannel,
        const FmqResultDescriptor& resultChannel,
        std::shared_ptr<IBurstExecutorWithCache> executorWithCache);

/**
 * Create automated context to manage FMQ-based executions.
 *
 * This function is intended to be used by a service to automatically:
 * 1) Receive data from a provided FMQ
 * 2) Execute a model with the given information
 * 3) Send the result to the created FMQ
 *
 * @param callback Callback used to retrieve memories corresponding to
 *     unrecognized slots.
 * @param requestChannel Input FMQ channel through which the client passes the
 *     request to the service.
 * @param resultChannel Output FMQ channel from which the client can retrieve
 *     the result of the execution.
 * @param preparedModel PreparedModel that the burst object was created from.
 *     IPreparedModel::executeSynchronously will be used to perform the
 *     execution.
 * @result IBurstContext Handle to the burst context.
 */
  static sp<ExecutionBurstServer> create(const sp<IBurstCallback>& callback,
                                         const FmqRequestDescriptor& requestChannel,
                                         const FmqResultDescriptor& resultChannel,
                                         IPreparedModel* preparedModel);
```

The following is a reference implementation of a burst interface found in the
Neural Networks sample driver at
[`frameworks/ml/nn/driver/sample/SampleDriver.cpp`](https://android.googlesource.com/platform/frameworks/ml/+/master/nn/driver/sample/SampleDriver.cpp){:.external}.

```
Return<void> SamplePreparedModel::configureExecutionBurst(
        const sp<V1_2::IBurstCallback>& callback,
        const MQDescriptorSync<V1_2::FmqRequestDatum>& requestChannel,
        const MQDescriptorSync<V1_2::FmqResultDatum>& resultChannel,
        configureExecutionBurst_cb cb) {
    NNTRACE_FULL(NNTRACE_LAYER_DRIVER, NNTRACE_PHASE_EXECUTION,
                 "SampleDriver::configureExecutionBurst");
    // Alternatively, the burst could be configured via:
    // const sp<V1_2::IBurstContext> burst =
    //         ExecutionBurstServer::create(callback, requestChannel,
    //                                      resultChannel, this);
    //
    // However, this alternative representation does not include a memory map
    // caching optimization, and adds overhead.
    const std::shared_ptr<BurstExecutorWithCache> executorWithCache =
            std::make_shared<BurstExecutorWithCache>(mModel, mDriver, mPoolInfos);
    const sp<V1_2::IBurstContext> burst = ExecutionBurstServer::create(
            callback, requestChannel, resultChannel, executorWithCache);
    if (burst == nullptr) {
        cb(ErrorStatus::GENERAL_FAILURE, {});
    } else {
        cb(ErrorStatus::NONE, burst);
    }
    return Void();
}
```
