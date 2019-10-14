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

# Compilation Caching

From Android {{ androidQVersionNumber }}, the Neural Networks API (NNAPI)
provides functions to support
caching of compilation artifacts, which reduces the time used for compilation
when an app starts. Using this caching functionality, the driver doesn't
need to manage or clean up the cached files. This is an optional feature that
can be implemented with NN HAL 1.2. For more information about this function,
see
[`ANeuralNetworksCompilation_setCaching`](https://developer.android.com/ndk/reference/group/neural-networks.html#aneuralnetworkscompilation_setcaching){:.external}.

The driver can also implement compilation caching independent of the NNAPI. This
can be implemented whether the NNAPI NDK and HAL caching features are used or
not. AOSP provides a low-level utility library (a caching engine). For more
information, see [Implementing a caching engine](#caching-engine).

## Workflow overview {:#workflow}

This section describes general workflows with the compilation caching feature
implemented.

### Caching information provided and cache hit {:#info-and-hit}

1.  The app passes a caching directory and a checksum unique to the model.
1.  The NNAPI runtime looks for the cache files based on the checksum, the
    execution preference, and the partitioning outcome and finds the files.
1.  The NNAPI opens the cache files and passes the handles to the driver
    with
    [`prepareModelFromCache`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#346){:.external}.
1.  The driver prepares the model directly from the cache files and returns
    the prepared model.

### Caching information provided and cache miss {:#info-and-miss}

1.  The app passes a checksum unique to the model and a caching
    directory.
1.  The NNAPI runtime looks for the caching files based on the checksum, the
    execution preference, and the partitioning outcome and doesn't find the
    cache files.
1.  The NNAPI creates empty cache files based on the checksum, the execution
    preference, and the partitioning, opens the cache files, and passes the
    handles and the model to the driver with
    [`prepareModel_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#266){:.external}.
1.  The driver compiles the model, writes caching information to the cache
    files, and returns the prepared model.

### Caching information not provided {:#no-info}

1.  The app invokes compilation without providing any caching information.
1.  The app passes nothing related to caching.
1.  The NNAPI runtime passes the model to the driver with
    [`prepareModel_1_2`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#266){:.external}.
1.  The driver compiles the model and returns the prepared model.

## Caching information {:#cache-info}

The caching information that is provided to a driver consists of a token and
cache file handles.

### Token {:#token}

The
[token](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#246){:.external}
is a caching token of length
[`Constant::BYTE_SIZE_OF_CACHE_TOKEN`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/types.hal#32){:.external}
that identifies the prepared model. The same token is provided when saving the
cache files with `prepareModel_1_2` and retrieving the prepared model with
`prepareModelFromCache`. The client of the driver should choose a token with a
low rate of collision. The driver can't detect a token collision. A collision
results in a failed execution or in a successful execution that produces
incorrect output values.

### Cache file handles (two types of cache files) {:#cache-file-handles}

The two types of cache files are _data cache_ and _model cache_.

+   **Data cache:** Use for caching constant data including preprocessed and
    transformed tensor buffers. A modification to the data cache shouldn't
    result in any effect worse than generating bad output values at execution
    time.
+   **Model cache:** Use for caching security-sensitive data such as compiled
    executable machine code in the device's native binary format. A
    modification to the model cache might affect the driver's execution
    behavior, and a malicious client could make use of this to execute beyond
    the granted permission. Thus, the driver must check whether the model cache
    is corrupted before preparing the model from cache. For more information,
    see [Security](#security).

The driver must decide how cache information is distributed between the two
types of cache files, and report how many cache files it needs for each type
with
[`getNumberOfCacheFilesNeeded`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/neuralnetworks/1.2/IDevice.hal#164){:.external}.

The NNAPI runtime always opens cache file handles with both read and write
permission.

Note: Multiple threads may prepare the same model concurrently. To prevent a
write occurring concurrently with a read or another write, the driver must
implement file locking logic.

## Security {:#security}

In compilation caching, the model cache may contain security-sensitive data such
as compiled executable machine code in the device's native binary format. If not
properly protected, a modification to the model cache may affect the driver's
execution behavior. Because the cache contents are stored in the app
directory, the cache files are modifiable by the client. A buggy client may
accidentally corrupt the cache, and a malicious client could intentionally make
use of this to execute unverified code on the device. Depending on the
characteristics of the device, this may be a security issue. Thus, the
driver must be able to detect
potential model cache corruption before preparing the model from cache.

One way to do this is for the driver to maintain a map from the token to a
cryptographic hash of the model cache. The driver can store the token and the
hash of its model cache when saving the compilation to cache. The driver checks
the new hash of the model cache with the recorded token and hash pair when
retrieving the compilation from cache. This mapping should be persistent across
system reboots. The driver can use the
[Android keystore service](/security/keystore), the utility library in
[`framework/ml/nn/driver/cache`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/driver/cache/){:.external},
or any other suitable mechanism to implement a mapping manager. Upon driver
update, this mapping manager should be reinitialized to prevent preparing cache
files from an earlier version.

To prevent
[time-of-check to time-of-use](https://en.wikipedia.org/wiki/Time-of-check_to_time-of-use){:.external}
(TOCTOU) attacks, the driver must compute the recorded hash before saving to
file and compute the new hash after copying the file content to an internal
buffer.

This sample code demonstrates how to implement this logic.

```
bool saveToCache(const sp<V1_2::IPreparedModel> preparedModel,
                 const hidl_vec<hidl_handle>& modelFds, const hidl_vec<hidl_handle>& dataFds,
                 const HidlToken& token) {
    // Serialize the prepared model to internal buffers.
    auto buffers = serialize(preparedModel);

    // This implementation detail is important: the cache hash must be computed from internal
    // buffers instead of cache files to prevent time-of-check to time-of-use (TOCTOU) attacks.
    auto hash = computeHash(buffers);

    // Store the {token, hash} pair to a mapping manager that is persistent across reboots.
    CacheManager::get()->store(token, hash);

    // Write the cache contents from internal buffers to cache files.
    return writeToFds(buffers, modelFds, dataFds);
}

sp<V1_2::IPreparedModel> prepareFromCache(const hidl_vec<hidl_handle>& modelFds,
                                          const hidl_vec<hidl_handle>& dataFds,
                                          const HidlToken& token) {
    // Copy the cache contents from cache files to internal buffers.
    auto buffers = readFromFds(modelFds, dataFds);

    // This implementation detail is important: the cache hash must be computed from internal
    // buffers instead of cache files to prevent time-of-check to time-of-use (TOCTOU) attacks.
    auto hash = computeHash(buffers);

    // Validate the {token, hash} pair by a mapping manager that is persistent across reboots.
    if (CacheManager::get()->validate(token, hash)) {
        // Retrieve the prepared model from internal buffers.
        return deserialize<V1_2::IPreparedModel>(buffers);
    } else {
        return nullptr;
    }
}
```

## Advanced use cases {:#advanced-use-cases}

In certain advanced use cases, a driver requires access to the cache content
(read or write) after the compilation call. Example use cases include:

+   **Just-in-time compilation:** The compilation is delayed until the
    first execution.
+   **Multi-stage compilation:** A fast compilation is performed initially
    and an optional optimized compilation is performed at a later time
    depending on the frequency of use.

To access the cache content (read or write) after the compilation call, ensure
that the driver:

+   Duplicates the file handles during the invocation of
    `prepareModel_1_2` or `prepareModelFromCache` and reads/updates the cache
    content at a later time.
+   Implements file locking logic outside of the ordinary compilation call
    to prevent a write occurring concurrently with a read or another write.

## Implementing a caching engine {:#caching-engine}

In addition to the NN HAL 1.2 compilation caching interface, you can also find a
caching utility library in the
[`frameworks/ml/nn/driver/cache`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/driver/cache/){:.external}
directory. The
[`nnCache`](https://android.googlesource.com/platform/frameworks/ml/+/refs/heads/master/nn/driver/cache/nnCache/){:.external}
subdirectory contains persistent storage code for the driver to implement
compilation caching without using the NNAPI caching features. This form of
compilation caching can be implemented with any version of the NN HAL. If the
driver chooses to implement caching disconnected from the HAL interface,
the driver is
responsible for freeing cached artifacts when they are no longer needed.
