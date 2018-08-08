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

# HIDL Memory Block

The HIDL MemoryBlock is an abstract layer built on `hidl_memory`, `HIDL
@1.0::IAllocator`, and `HIDL @1.0::IMapper`. It is designed for HIDL services
that have multiple memory blocks to share a single memory heap.


## Performance improvements

Using MemoryBlock in applications can significantly reduce the number of
`mmap`/`munmap` and user space segmentation faults, thus improving performance.
For example:

*   Using per `hidl_memory` for each buffer allocation averages 238 us/1 allocation.
*   Using `MemoryBlock` and sharing a single `hidl_memory` averages 2.82 us/1 allocation.


## Architecture

The HIDL MemoryBlock architecture includes HIDL services with multiple memory
blocks sharing a single memory heap:

![HIDL MemoryBlock](/devices/architecture/images/hidl_memoryblock_arch.png)

**Figure 1.** HIDL MemoryBlock architecture


## Normal usage

This section provides an example of using MemoryBlock by first declaring the HAL
then implementing the HAL.


### Declaring the HAL

For the following example IFoo HAL:

```
import android.hidl.memory.block@1.0::MemoryBlock;

interface IFoo {
    getSome() generates(MemoryBlock block);
    giveBack(MemoryBlock block);
};
```

The `Android.bp` is as follows:

```
hidl_interface {
    ...
    srcs: [
        "IFoo.hal",
    ],
    interfaces: [
        "android.hidl.memory.block@1.0",
        ...
};
```

### Implementing the HAL

To implement the example HAL:

1.  Get the `hidl_memory` (for details, refer to [HIDL C++](/devices/architecture/hidl-cpp/)).


    ```
    #include <android/hidl/allocator/1.0/IAllocator.h>

    using ::android::hidl::allocator::V1_0::IAllocator;
    using ::android::hardware::hidl_memory;
    ...
      sp<IAllocator> allocator = IAllocator::getService("ashmem");
      allocator->allocate(2048, [&](bool success, const hidl_memory& mem)
      {
            if (!success) { /* error */ }
            // you can now use the hidl_memory object 'mem' or pass it
      }));
    ```

1.  Make a `HidlMemoryDealer` with the acquired `hidl_memory`:

    ```
    #include <hidlmemory/HidlMemoryDealer.h>

    using ::android::hardware::HidlMemoryDealer
    /* The mem argument is acquired in the Step1, returned by the ashmemAllocator->allocate */
    sp<HidlMemoryDealer> memory_dealer = HidlMemoryDealer::getInstance(mem);
    ```

1.  Allocate `MemoryBlock`, which is a struct defined with HIDL.

    Example `MemoryBlock`:

    ```
    struct MemoryBlock {
    IMemoryToken token;
    uint64_t size;
    uint64_t offset;
    };
    ```

    Example using the `MemoryDealer` to allocate a `MemoryBlock`:


    ```
    #include <android/hidl/memory/block/1.0/types.h>

    using ::android::hidl::memory::block::V1_0::MemoryBlock;

    Return<void> Foo::getSome(getSome_cb _hidl_cb) {
        MemoryBlock block = memory_dealer->allocate(1024);
        if(HidlMemoryDealer::isOk(block)){
            _hidl_cb(block);
        ...
    ```

1.  Deallocate `MemoryBlock`:

    ```
    Return<void> Foo::giveBack(const MemoryBlock& block) {
        memory_dealer->deallocate(block.offset);
    ...
    ```

1.  Manipulate the data:

    ```
    #include <hidlmemory/mapping.h>
    #include <android/hidl/memory/1.0/IMemory.h>

    using ::android::hidl::memory::V1_0::IMemory;

    sp<IMemory> memory = mapMemory(block);
    uint8_t* data =

    static_cast<uint8_t*>(static_cast<void*>(memory->getPointer()));
    ```

1.  Config `Android.bp`:

    ```
    shared_libs: [
            "android.hidl.memory@1.0",

            "android.hidl.memory.block@1.0"

            "android.hidl.memory.token@1.0",
            "libhidlbase",
            "libhidlmemory",
    ```

1.  Review the flow to determine if you need to `lockMemory`. 

    Normally, the MemoryBlock uses reference count to maintain the shared
    `hidl_memory` which is `mmap()`-ed the first time one of its `MemoryBlock`s gets
    mapped and is `munmap()`-ed when nothing refers to it. To keep the `hidl_memory`
    always mapped, you can use `lockMemory`, a RAII style object that keeps the
    corresponding `hidl_memory` mapped throughout the lock life cycle. Example:

    ```
    #include <hidlmemory/mapping.h>

    sp<RefBase> lockMemory(const sp<IMemoryToken> key);
    ```

## Extended usage

This section provides details about the extended usage of `MemoryBlock`.


### Using reference count to manage Memoryblock

In most situations, the most efficient way to use MemoryBlock is to explicitly
allocate/deallocate. However, in complicated applications using reference count
for garbage collection might be a better idea. To have reference count on
MemoryBlock, you can bind MemoryBlock with a binder object, which helps to count
the references and deallocate the MemoryBlock when the count decreases to zero.


### Declaring the HAL

When declaring the HAL, describe a HIDL struct that contains a MemoryBlock and a
IBase:


```
import android.hidl.memory.block@1.0::MemoryBlock;

struct MemoryBlockAllocation {
    MemoryBlock block;
    IBase refcnt;
};
```

Use the `MemoryBlockAllocation` to replace `MemoryBlock` and remove the method
to give back the `MemoryBlock`. It will be deallocated by reference counting
with the `MemoryBlockAllocation`. Example:


```
interface IFoo {
    allocateSome() generates(MemoryBlockAllocation allocation);
};
```

### Implementing the HAL

Example of the service side implementation of the HAL:


```
class MemoryBlockRefCnt: public virtual IBase {
   MemoryBlockRefCnt(uint64_t offset, sp<MemoryDealer> dealer)
     : mOffset(offset), mDealer(dealer) {}
   ~MemoryBlockRefCnt() {
       mDealer->deallocate(mOffset);
   }
 private:
   uint64_t mOffset;
   sp<MemoryDealer> mDealer;
};

Return<void> Foo::allocateSome(allocateSome_cb _hidl_cb) {
    MemoryBlockAllocation allocation;
    allocation.block = memory_dealer->allocate(1024);
    if(HidlMemoryDealer::isOk(block)){
        allocation.refcnt= new MemoryBlockRefCnt(...);
        _hidl_cb(allocation);
```


Example of the client side implementation of the HAL:


```
ifoo->allocateSome([&](const MemoryBlockAllocation& allocation){
    ...
);
```

### Attaching/retrieving metadata

Some applications need additional data to bind with the allocated `MemoryBlock`.
You can append/retrieve metadata using two methods:


*   If the application accesses the metadata as often as the block itself,
    append the metadata and pass them all in a struct. Example:

    ```
    import android.hidl.memory.block@1.0::MemoryBlock;

    struct MemoryBlockWithMetaData{
        MemoryBlock block;
        MetaDataStruct metaData;
    };
    ```

*   If the application accesses the metadata much less frequently than the
    block, it is more efficient to pass the metadata passively with an
    interface. Example:

    ```
    import android.hidl.memory.block@1.0::MemoryBlock;

    struct MemoryBlockWithMetaData{
        MemoryBlock block;
        IMetaData metaData;
    };
    ```

    Next, bind the metadata with the MemoryBlock using the Memory Dealer. Example:

    ```
    MemoryBlockWithMetaData memory_block;
    memory_block.block = dealer->allocate(size);
    if(HidlMemoryDealer::isOk(block)){
        memory_block.metaData = new MetaData(...);
    ```
