## 3.3\. Native API Compatibility

### 3.3.1\. Application Binary Interfaces

Managed Dalvik bytecode can call into native code provided in the application
.apk file as an ELF .so file compiled for the appropriate device hardware
architecture. As native code is highly dependent on the underlying processor
technology, Android defines a number of Application Binary Interfaces (ABIs) in
the Android NDK. Device implementations MUST be compatible with one or more
defined ABIs, and MUST implement compatibility with the Android NDK, as below.

If a device implementation includes support for an Android ABI, it:

*   MUST include support for code running in the managed environment to call
    into native code, using the standard Java Native Interface (JNI) semantics.
*   MUST be source-compatible (i.e. header compatible) and binary-compatible
    (for the ABI) with each required library in the list below.
*   MUST support the equivalent 32-bit ABI if any 64-bit ABI is supported.
*   MUST accurately report the native Application Binary Interface (ABI)
    supported by the device, via the android.os.Build.SUPPORTED_ABIS,
    android.os.Build.SUPPORTED_32_BIT_ABIS, and
    android.os.Build.SUPPORTED_64_BIT_ABIS parameters, each a comma separated
    list of ABIs ordered from the most to the least preferred one.
*   MUST report, via the above parameters, only those ABIs documented and
    described in the latest version of the [Android NDK ABI Management documentation](https://developer.android.com/ndk/guides/abis.html), and MUST
    include support for the [Advanced SIMD](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0388f/Beijfcja.html)
    (a.k.a. NEON) extension.
*   SHOULD be built using the source code and header files available in the
    upstream Android Open Source Project

The following native code APIs MUST be available to apps that include native code:

*   libc (C library)
*   libm (math library)
*   Minimal support for C++
*   JNI interface
*   liblog (Android logging)
*   libz (Zlib compression)
*   libdl (dynamic linker)
*   libGLESv1_CM.so (OpenGL ES 1.x)
*   libGLESv2.so (OpenGL ES 2.0)
*   libGLESv3.so (OpenGL ES 3.x)
*   libEGL.so (native OpenGL surface management)
*   libjnigraphics.so
*   libOpenSLES.so (OpenSL ES 1.0.1 audio support)
*   libOpenMAXAL.so (OpenMAX AL 1.0.1 support)
*   libandroid.so (native Android activity support)
*   libmediandk.so (native media APIs support)
*   Support for OpenGL, as described below

Note that future releases of the Android NDK may introduce support for
additional ABIs. If a device implementation is not compatible with an existing
predefined ABI, it MUST NOT report support for any ABIs at all.

Note that device implementations MUST include libGLESv3.so and it MUST symlink
(symbolic link) to libGLESv2.so. in turn, MUST export all the OpenGL ES 3.1 and
[Android Extension Pack](http://developer.android.com/guide/topics/graphics/opengl.html#aep)
function symbols as defined in the NDK release android-21. Although all the
symbols must be present, only the corresponding functions for OpenGL ES versions
and extensions actually supported by the device must be fully implemented.

Device implementations, if including a native library with the name
libvulkan.so, MUST export function symbols and provide an implementation of the
Vulkan 1.0 API and the VK_KHR_surface, VK_KHR_swapchain, and
VK_KHR_android_surface extensions as defined by the Khronos Group and passing
the Khronos conformance tests.

Native code compatibility is challenging. For this reason, device implementers
are **STRONGLY RECOMMENDED** to use the implementations of the libraries listed
above from the upstream Android Open Source Project.

### 3.3.2. 32-bit ARM Native Code Compatibility

The ARMv8 architecture deprecates several CPU operations, including some
operations used in existing native code. On 64-bit ARM devices, the following
deprecated operations MUST remain available to 32-bit native ARM code, either
through native CPU support or through software emulation:

*   SWP and SWPB instructions
*   SETEND instruction
*   CP15ISB, CP15DSB, and CP15DMB barrier operations

Legacy versions of the Android NDK used /proc/cpuinfo to discover CPU features
from 32-bit ARM native code. For compatibility with applications built using
this NDK, devices MUST include the following lines in /proc/cpuinfo when it is
read by 32-bit ARM applications:

*   "Features: ", followed by a list of any optional ARMv7 CPU features supported by the device.
*   "CPU architecture: ", followed by an integer describing the device's highest
    supported ARM architecture (e.g., "8" for ARMv8 devices).

These requirements only apply when /proc/cpuinfo is read by 32-bit ARM
applications. Devices SHOULD not alter /proc/cpuinfo when read by 64-bit ARM or
non-ARM applications.

