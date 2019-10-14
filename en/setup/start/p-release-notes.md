Project: /_project.yaml
Book: /_book.yaml

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

{% include "_versions.html" %}

# Android {{ androidPVersionNumber }} Release Notes

This page summarizes the major features in the
Android {{ androidPVersionNumber }} release, and provides links to additional
information. These feature summaries are organized according to the feature's
documentation location on this site. See the
[August 2018 Site Updates](/setup/start/site-updates#Aug-2018) for a guide to
section moves and renaming.

## Build

### Generic system image (GSI)

A generic system image (GSI) is a system image with adjusted configurations
for Android devices. [Generic System Image (GSI)](/setup/build/gsi)
includes details on
differences between GSIs for devices launching with Android
{{ androidPVersionNumber }} and devices upgrading to Android
{{ androidPVersionNumber }}.

## Architecture

### Hardware abstraction layer (HAL)

#### HIDL framework backwards compatibility

[HIDL framework backward compatibility verification](/devices/architecture/hal/framework-testing)
is a method for verifying the backward compatibility of the framework.

#### Dynamically available HALs

[Dynamically available HALs](/devices/architecture/hal/dynamic-lifecycle)
support the dynamic shutdown of Android hardware subsystems when they're not in
use or not needed.

### HIDL

#### HIDL MemoryBlock

[HIDL MemoryBlock](/devices/architecture/hidl/memoryblock) is an abstract layer
built on `hidl_memory`, `HIDL @1.0::IAllocator`, and `HIDL @1.0::IMapper`. It's
designed for HIDL services that have multiple memory blocks sharing a single
memory heap.

### Device tree overlays

#### Compressed overlays

Android 9 and higher includes support for
[compressed overlays](/devices/architecture/dto/optimize#compressed-overlays) in
the device tree blob overlay (DTBO) image when using version 1 of the device
tree table header.

#### DTO updates

Android 9 and higher requires that the bootloader pass the unified device
tree blob to the kernel prior to modifying the properties defined
in the [device tree overlays (DTOs)](/devices/architecture/dto/#p-update).

#### DTBO image header versioning

Android 9 and higher includes a
[version field](/devices/architecture/dto/partitions) in the DTBO image
header.

#### DTBO verification

Android 9 and higher requires a DTBO partition. To add nodes
or make changes to the properties in the SoC DT, the bootloader must dynamically
overlay a device-specific DT over the SoC DT. For more information see
[Compiling & Verifying](/devices/architecture/dto/compile).

#### Kernel compliance

Android 9 and higher includes requirements that affect the kernel, its
interfaces, and the use of DTBOs. For more information, see these pages:

*   [Stable Kernel Releases & Updates](/devices/architecture/kernel/releases)
*   [Android Common Kernels](/devices/architecture/kernel/android-common)
*   [Modular Kernel Requirements](/devices/architecture/kernel/modular-kernels)
*   [Interface Requirements](/devices/architecture/kernel/reqs-interfaces)
*   [Device Tree Overlays](/devices/architecture/dto/)

### Vendor NDK

#### Design changes

For information about VNDK design changes in Android 9 and higher, see these pages:

*   [Vendor Native Development Kit (VNDK)](/devices/architecture/vndk/index)
*   [VNDK Build System Support](/devices/architecture/vndk/build-system)
*   [VNDK Definition Tool](/devices/architecture/vndk/deftool)
*   [Directories, Rules, and sepolicy](/devices/architecture/vndk/dir-rules-sepolicy)
*   [VNDK Extensions](/devices/architecture/vndk/extensions)
*   [Linker Namespace](/devices/architecture/vndk/linker-namespace)

#### ABI checker

The [ABI Stability](/devices/architecture/vndk/abi-stability) page describes
the application binary interface (ABI) checker, which ensures that changes made
to VNDK libraries maintain ABI compliance.

#### VNDK snapshots

A system image can use [VNDK snapshots](/devices/architecture/vndk/snapshot-design)
to provide the correct VNDK libraries to vendor images even when
system and vendor images are built from different versions of Android.

### Vendor interface object (VINTF object)

The following pages in the [Vendor Interface Object](/devices/architecture/vintf/)
section describe updates in Android 9 and higher:

*   [Manifests](/devices/architecture/vintf/objects)
*   [FCM Lifecycle](/devices/architecture/vintf/fcm)
*   [Device Manifest Development](/devices/architecture/vintf/dm)

#### HIDL deprecation schedule

The following pages describe how Android deprecates and removes HIDL HALs:

*   [FCM Lifecycle](/devices/architecture/vintf/fcm)
*   [Device Manifest Development](/devices/architecture/vintf/dm)

### Bootloader

#### Product partitions

Android 9 and higher supports building
[`/product` partitions](/devices/bootloader/product-partitions) using the
Android build system. Previously, Android 8.x enforced the separation of
system-on-chip (SoC)-specific components from the `/system` partition to the
`/vendor` partition without dedicating space for OEM-specific components built
from the Android build system.

#### Canonical boot reason compliance

The [Canonical Boot Reason](/devices/bootloader/boot-reason) page describes
changes to the bootloader boot reason specification in Android 9 and higher.

#### System as Root

All devices launching with Android 9 and higher must use
[system-as-root](/devices/bootloader/system-as-root), which merges `ramdisk.img`
into `system.img` (also known as no-ramdisk), which in turn is mounted
as rootfs.

#### Boot image header versioning

In Android 9 and higher, the boot image header contains a
[field to indicate the header version](/devices/bootloader/boot-image-header).
The bootloader must check this version field and parse the header
accordingly.

#### DTBO in recovery

To prevent OTA failures due to mismatches between the recovery image and the
DTBO partition on non-A/B devices, the recovery image must contain
[information from the DTBO image](/devices/bootloader/recovery-image).

### Display

#### Display cutouts

[Display cutouts](/devices/tech/display/display-cutouts) allow app developers to
create immersive, edge-to-edge experiences while still allowing space for
important sensors on the front of devices.

#### Rotate suggestions

Updates to [screen rotation behavior](/devices/tech/display/rotate-suggestions)
Android 9 and higher include support for a user-facing control to pin screen rotation
to either landscape or portrait even if the device position changes.

#### Synchronized app transitions

[Synchronized app transitions](/devices/tech/display/synched-app-transitions)
allow for new app transition animations.

#### Text classification (formerly TEXTCLASSIFIER)

Android 9 and higher includes a
[Text Classifier service](/devices/tech/display/textclassifier), which is
the recommended way to implement text classification, and a default service
implementation.

#### Wide-gamut color

Android 9 and higher includes support for wide-gamut color, including:

*   High dynamic range (HDR)
*   Processing content in the BT2020 color space, but not as an end-target
    dataspace

To use wide-gamut color, a device’s full display stack (such as screen, hardware
composer, GPU) must support wide-gamut colors or buffer formats. Devices
aren't required to claim support for wide-gamut content even if the hardware
supports it. However, wide-gamut color should be enabled to take full advantage
of the hardware. To avoid an inconsistent visual experience, wide-gamut color
shouldn't be turned off during runtime.

## Compatibility

### Android Compatibility Definition Document (CDD)

The [Android 9 Compatibility Definition Document](/compatibility/android-cdd)
iterates upon [previous versions](/compatibility/cdd) with updates for new
features and changes to requirements for previously released functionality.

## Settings

### Better app widgets

The Android app widget framework offers increased visibility into user
interactions, specifically when a user deletes or manually adds widgets. This
functionality comes by default with Launcher3.

Manufacturers need to update their launcher apps (which are shipped with devices)
to support this feature if not based upon Launcher3. OEMs need to support the new
[widgetFeatures field](https://developer.android.com/reference/android/appwidget/AppWidgetProviderInfo#widgetFeatures){: .external}
in their default launcher.

Note that the feature only works end to end when the
launchers implement it as expected. AOSP includes a sample implementation. See
the AOSP Change-Id Iccd6f965fa3d61992244a365efc242122292c0ca for the sample code
provided.

### Device state change notifications to package installers

A protected system broadcast can be sent to apps that hold the
`INSTALL_PACKAGES` permission whenever there's a change to properties like
locale or display density. Receivers can be registered in the manifest, and a
process awakens to receive the broadcast. This is useful for package
installers that wish to install additional components of apps upon such changes,
which is uncommon, because the configuration changes eligible to trigger
this broadcast are rare.

Device state change notification source code is located at the following
locations under `platform/frameworks/base`:

*   `api/system-current.txt`
*   `core/java/android/content/Intent.java`
*   `core/res/AndroidManifest.xml`
*   `services/core/java/com/android/server/am/ActivityManagerService.java`

### Information architecture

Changes to the
[information architecture for the Settings app](/devices/tech/settings/info-architecture)
provide more functionality and easier implementation.

## Tests

### Atest

The [Atest](/compatibility/tests/development/atest) command line tool
allows you to build, install, and run Android tests locally, greatly speeding
test re-runs without requiring knowledge of Trade Federation
test harness command line options.

### Compatibility Test Suite (CTS)

#### CTS downloads

CTS packages supporting Android 9 are available on the
[CTS Downloads](/compatibility/cts/downloads) page. The source code for the
included tests can be synced with the `android-cts-9.0_r1` tag in the
open-source tree.

#### CTS options

For Android 9, CTS v2 gains the following
[command and argument](/compatibility/cts/run#ctsv2_reference):

*   `run retry` retries all tests that failed or weren't executed from the
    previous sessions.
*   `‘--shard-count` shards a CTS run into given number of independent chunks,
    to run on multiple devices in parallel.

In addition, the previously undocumented command `--retry-type` has been added
to the same CTS v2 console command reference.

#### Secure Element (SE) service

The [Secure Element service](/compatibility/cts/secure-element) checks for
global platform-supported secure elements by identifying whether devices
have an SE HAL implementation and if so, how many. This is used as the
basis to test the API and the underlying secure element implementation.

#### Sensor fusion box

The sensor fusion box is used in the Camera Image Test Suite (Camera ITS)
sensor fusion test and multi-camera sync test and provides a consistent test
environment for measuring the timestamp accuracy of the camera and other sensors
for Android phones. See these pages for more information:

*   [Sensor Fusion Box Quick Start Guide](/compatibility/cts/sensor-fusion-quick-start)
    provides steps for setting up the sensor fusion test and
    sensor fusion box for the first time.
*   [Sensor Fusion Box Assembly](/compatibility/cts/sensor-fusion-box-assembly)
    provides steps for assembling a sensor fusion box.

#### Wide field of view ITS-in-a-box

The
[wide field of view ITS-in-a-box](/compatibility/cts/camera-wfov-box-assembly)
is an automated system designed to test both wide field of view (WFoV) and
regular field of view (RFoV) camera systems in the Camera ITS.

### Vendor Test Suite (VTS)

#### Host controller architecture

The [VTS host controller architecture](/compatibility/vts/host-controller) is
the architecture of VTS test framework integrated with its cloud-based
test-serving service.

#### Service name-aware HAL testing

[VTS service name-aware HAL testing](/compatibility/vts/sna-hal-testing)
supports getting the service name of a given HAL instance based on the device
on which VTS tests are running.

#### HAL testability check

[VTS HAL testability check](/compatibility/vts/hal-testability) includes a
runtime method for using the device configuration to identify which VTS tests
should be skipped for that device target.

#### Automated testing infrastructure

The [automated testing infrastructure](/compatibility/vts/automated-test-infra)
is a VTS infrastructure for automated testing of VTS, CTS, or other tests on
partner devices running the AOSP generic system image (GSI).

### Debugging

#### Advanced telemetry

In Android, <em>telemetry</em> is the process of automatically collecting use
and diagnostics information about the device, the Android system, and apps. In
previous versions of Android, the telemetry stack was limited and didn't
capture the information needed to identify and resolve system reliability
and device or app issues. This made identifying root causes of issues difficult,
if not impossible.

Android 9 includes the `statsd` telemetry feature, which solves this
deficiency by collecting better data faster. `statsd` collects
app usage, battery and process statistics, and crashes. The data is analyzed and
used to improve products, hardware, and services.

For more details, see `frameworks/base/cmds/statsd/`.

## Security features

### Application signing

The [v3 APK signature scheme](/security/apksigning/v3) supports APK key rotation.

### Biometric support

Android 9 includes the public class
[`BiometricPrompt`](https://developer.android.com/reference/android/hardware/biometrics/BiometricPrompt){: .external},
which apps can use to integrate biometric authentication support in a
device- and modality-agnostic fashion. For more information about integrating
your biometrics stack to include `BiometricPrompt`, see
[Biometrics](/security/biometric).

### Dynamic analysis

Android 9 includes support for more [exploit mitigation and analysis
tools](/devices/tech/debug/fuzz-sanitize).

#### Control flow integrity (CFI)

[Control flow integrity (CFI)](/devices/tech/debug/cfi) is a security mechanism
that prohibits changes to the original control flow graph of a compiled binary,
making it significantly harder to perform such attacks.

#### Kernel CFI

In addition to system CFI, which is enabled by default, Android 9 and higher
includes support for
[kernel control flow integrity (CFI)](/devices/tech/debug/kcfi).

### Encryption

#### File-based encryption (FBE)

[File-based encryption (FBE)](/security/encryption/file-based) is updated to work
with [adoptable storage](/devices/storage/adoptable). New devices
should use file-based encryption instead of full-disk encryption.

#### Metadata encryption

Android 9 and higher includes support for
[metadata encryption](/security/encryption/metadata) where hardware support is
present. With metadata encryption, a single key present at boot time uses
file-based-encryption to encrypt any unenctypted content.

### Keystore

Android 9 and higher includes
[Keymaster 4](https://android.googlesource.com/platform/hardware/interfaces/+/master/keymaster/4.0/){: .external},
which has these features.

#### StrongBox

Android 9 and higher includes support for Android Keystore keys that are
stored and used in a physically separate CPU purpose-built for
high-security applications, such as an embedded
[secure element (SE)](/compatibility/cts/secure-element).
StrongBox Keymaster is an implementation of the Keymaster HAL in discrete
secure hardware. A StrongBox has:

  *   Discrete CPU
  *   Integral secure storage
  *   High-quality true random number generator
  *   Tamper-resistant packaging
  *   Side-channel resistance

#### Secure key import

To securely import a key into Keymaster 4, a key created off-device is encrypted
with a specification of the authorizations that define how the key may be used.

##### 3DES support

Keymaster 4 includes 3DES for compatibility with legacy systems that use 3DES.

#### Version binding

To support Treble's modular structure and break the binding of `system.img`
to `boot.img`, Keymaster 4 changed the [key version binding](/security/keystore/version-binding)
model to have separate patch levels for each partition. This allows each partition to be
updated independently while still providing rollback protection.

#### Android Protected Confirmation API

Supported devices that launch with Android 9 installed give developers the
ability to use the
[Android Protected Confirmation API](https://developer.android.com/training/articles/security-android-protected-confirmation){: .external}.
With this API, apps can use an instance of
[`ConfirmationPrompt`](https://developer.android.com/reference/android/security/ConfirmationPrompt.html)
to display a prompt to the user, asking them to approve a short statement. This
statement allows an app to reaffirm that the user wants to complete a
sensitive transaction, such as making a payment.

### SELinux

#### Per-app SELinux sandbox

The [application sandbox](/security/app-sandbox) has new protections and test
cases to ensure that all non-privileged apps tageting Android 9 and higher run
individual SELinux sandboxes.

#### Treble SELinux changes

Updates to Treble SELinux in Android 9 and higher are documented in several pages
in the [SELinux section](/security/selinux).

#### Vendor init

[Vendor init](/security/selinux/vendor-init) closes the hole
in the Treble system/vendor split by using a separate
SELinux domain to run `/vendor` commands with vendor-specific permissions.

#### System properties

Android 9 restricts [system properties](/security/selinux/compatibility#system-property-and-ownership)
from being shared between `system` and `vendor` partitions unnecessarily and
provides a method for ensuring consistency between shared system properties.

##### SELinux attribute tests

Android 9 includes new
[build-time tests](https://android.googlesource.com/platform/system/sepolicy/+/master/tests/sepolicy_tests.py){: .external}
that ensure all files in specific locations have the
[appropriate attributes](/security/selinux/compatibility#compatibility-attributes).
For example, all files in `sysfs` have the required `sysfs_type` attribute.


## Audio

### High-resolution audio effects

Updates to [high-resolution audio effects](/devices/audio/highres-effects)
include converting effect processing from int16 to float format and increases in
simultaneous client output tracks, maximum client/server memory, and total mixed
tracks.

## Camera

### External USB cameras

Android 9 and higher supports using
[plug-and-play USB cameras](/devices/camera/external-usb-cameras) (that is,
webcams) using the standard [Android Camera2 API](https://developer.android.com/reference/android/hardware/camera2/package-summary.html)
and the camera HIDL interface.

### Motion tracking

Camera devices can
[advertise motion tracking capability](/devices/camera/motion-tracking).

### Multi-camera support

[Multi-camera cupport](/devices/camera/multi-camera) includes API support for
multi-camera devices via a new logical camera device composed of two or more
physical camera devices pointing in the same direction.

### Session parameters

[Implementing session parameters](/devices/camera/session-parameters) can reduce
delays by enabling camera clients to actively configure a subset of costly
request parameters as part of the capture session initialization phase.

### Single producer, multiple consumer buffer

[Single producer, multiple consumer camera buffer transport](/devices/camera/singleprod-multiconsum)
is a set of methods that allows camera clients to add and remove output
surfaces dynamically while the capture session is active and camera streaming is
ongoing.

## Connectivity

### Calling and messaging

#### Implementing data plans

Android 9 and higher provides improved support for carriers
[implementing data plans](/devices/tech/connect/data-plans) using the
SubcriptionPlan APIs.

#### Third-party calling apps

Android 9 and higher provides APIs that allow
[third-party (3P) calling apps](/devices/tech/connect/third-party-call-apps) to
handle concurrent incoming carrier calls and to have calls logged in the system
call log.

### Carrier

#### Carrier identification

In Android {{ androidPVersionNumber }}, AOSP adds a carrier ID database to help
with [carrier identification](/devices/tech/config/carrierid). The database
minimizes duplicate logic and fragmented app experiences by providing a common
way to identify carriers.

#### eSIM

Embedded SIM (eSIM or eUICC) is the latest technology to allow mobile users to
download a carrier profile and activate a carrier's service without having a
physical SIM card. In Android 9 and higher, the Android framework provides
standard APIs for accessing eSIM and managing subscription profiles on eSIM.
For more information, see:

*   [Implementing eSIM](/devices/tech/connect/esim-overview)
*   [Modem Requirements](/devices/tech/connect/esim-modem-requirements)
*   [eUICC APIs](/devices/tech/connect/esim-euicc-api)

#### Multi-SIM support for IMS settings

Android 9 and higher provides improvements to the user settings for
[IP multimedia subsystem (IMS)](/devices/tech/connect/ims). You can set up
voiceover LTE (VoLTE), video calling, and Wi-Fi calling on a per-subscription
basis instead of sharing these settings across all subscriptions.

#### SIM state broadcasts

In Android 9 and higher, `Intent.ACTION_SIM_STATE_CHANGED` is deprecated, and two
separate broadcasts for card state and card application state are added,
`TelephonyManager.ACTION_SIM_CARD_STATE_CHANGED` and
`TelephonyManager.ACTION_SIM_APPLICATION_STATE_CHANGED`.

With these changes, receivers that only need to know whether a card is present
don't have to listen to application state changes, and receivers that
only need to know whether card applications are ready don't have to listen
to changes in card state.

The two new broadcasts are @SystemApis and aren't sticky. Only receivers with
the `READ_PRIVILEGED_PHONE_STATE` permission can receive the broadcasts.

The intents aren't rebroadcast when you unlock the device. Receivers that
depend on broadcasts sent before you unlock must either use `directBootAware`,
or they must query the state after user unlock. The states can be queried using
the corresponding APIs in TelephonyManager, `getSimCardState()`
and`getSimApplicationState()`.

### Wi-Fi

#### Carrier Wi-Fi

The [carrier Wi-Fi](/devices/tech/connect/carrier-wifi) feature allows devices
to automatically connect to carrier-implemented Wi-Fi networks. In areas of high
congestion or with minimal cell coverage such as a stadium or an underground
train station, carrier Wi-Fi helps improve connectivity
and offloads traffic.

#### MAC randomization

[MAC randomization](/devices/tech/connect/wifi-mac-randomization) lets devices
use random MAC addresses when probing for new networks while not currently
associated with a network. In Android 9 and higher, a developer option can be enabled to
cause a device to use a randomized MAC address when connecting to a Wi-Fi
network.

#### Turn on Wi-Fi automatically

When the [Turn on Wi-Fi automatically](/devices/tech/connect/wifi-infrastructure#turn_on_wi-fi_automatically)
feature is enabled, Wi-Fi is automatically re-enabled whenever the device is
near a saved Wi-Fi network with a sufficiently high relative received
signal strength indicator (RSSI).

#### Wi-Fi round trip time (RTT)

[Wi-Fi round trip time (RTT)](/devices/tech/connect/wifi-rtt) allows devices to
measure the distance to other supporting devices, whether they are access points
(APs) or [Wi-Fi Aware](https://source.android.com/devices/tech/connect/wifi-aware)
peers (if Wi-Fi Aware is supported on the device). This
feature is built on the IEEE 802.11mc protocol, and enables apps to use enhanced
location accuracy and awareness.

#### Wi-Fi scoring improvements

Improved Wi-Fi scoring models quickly and accurately determine when a device
should exit a connected Wi-Fi network or enter a new Wi-Fi network. These models
provide a reliable and seamless experience for users by avoiding gaps in
connectivity.

Review and tune the RSSI values in the `config.xml` resources,
especially the following:

-   `config_wifi_framework_wifi_score_bad_rssi_threshold_5GHz`
-   `config_wifi_framework_wifi_score_entry_rssi_threshold_5GHz`
-   `config_wifi_framework_wifi_score_bad_rssi_threshold_24GHz`
-   `config_wifi_framework_wifi_score_entry_rssi_threshold_24GHz`

Note: The `entry` values were introduced in Android 8.1, and the defaults were
chosen to match the defaults for the `bad` thresholds for compatibility.
Ideally, the entry threshold should be 3&nbsp;dB or more above the corresponding
exit (`bad`) threshold.

#### Wi-Fi STA/AP concurrency

[Wi-Fi STA/AP concurrency](/devices/tech/connect/wifi-sta-ap-concurrency) is the
ability for devices to operate in station (STA) and access point (AP) modes
concurrently. For devices supporting dual band simultaneous (DBS) Wi-Fi, this
opens up capabilities such as not disrupting STA Wi-Fi when a user wants to
enable a hotspot (SoftAP).

#### WiFiStateMachine improvements

`WifiStateMachine` is the main class used to control Wi-Fi activity, coordinate
user input (operating modes: hotspot, scan, connect, or off), and control Wi-Fi
network actions (such as scanning or connecting).

In Android 9 and higher, the Wi-Fi framework code and implementation of
`WifiStateMachine` is re-architected, leading to reduced code size,
easier-to-follow Wi-Fi control logic, improved control granularity, and
increased coverage and quality of unit tests.

At a high level,`WifiStateMachine` allows Wi-Fi to be in one of four states:

*  Client mode (can connect and scan)
*  Scan only mode
*  SoftAP mode (Wi-Fi hotspot)
*  Disabled (Wi-Fi fully off)

Each Wi-Fi mode has different requirements for running services and should be
set up in a consistent manner, handling only the events relevant to its
operation. The new implementation restricts the code to events related to that
mode, reducing debugging time and the risk of introducing new bugs due to
complexity. In addition to explicit handling for mode functionality, thread
management is handled in a consistent manner and the use of asynchronous
channels is eliminated as a mechanism for synchronization.

#### Wi-Fi permission updates

In Android 9 and higher, the `CHANGE_WIFI_STATE` app permission is enabled
by default. You can disable the permission for any
app on the settings page in **Settings > Apps & notifications >
Special app access > Wi-Fi control**.

Apps must be able to handle cases where the `CHANGE_WIFI_STATE` permission isn't
granted.

To validate this behavior, run the [roboelectric](https://android.googlesource.com/platform/packages/apps/Settings/+/master/tests/robotests/src/com/android/settings/wifi/){: .external}
and manual tests.

For manual testing:

1.  Go to **Settings > Apps & notifications > Special app access > Wi-Fi control**.
1.  Select and turn off the permission for your app.
1.  Verify that your app can handle the scenario where the `CHANGE_WIFI_STATE`
    permission isn't granted.

#### WPS deprecation

Due to security issues, Wi-Fi protected setup (WPS) in `WiFiManager` is
deprecated and disabled in Android 9 and higher. However, `WiFiDirect` still uses
WPS in the WPA supplicant.

## Graphics

### Implementation

#### Vulkan 1.1 API

Android 9 and higher supports implementing the
[Vulkan 1.1 graphics API](/devices/graphics/implement-vulkan).

#### WinScope tool for window transition tracing

Android 9 and higher includes the WinScope tool for tracing window transitions.
WinScope provides infrastructure and tools to record and analyze the window
manager state during and after transitions. It allows recording and stepping
through window transitions, while recording all pertinent window manager state
to a trace file. You can use this data to replay and step through the transition.

The WinScope tool source code is located at
`platform/development/tools/winscope`.

## Interaction

### Automotive audio

[Automotive Audio](/devices/automotive/audio) describes the audio
architecture for automotive-related Android implementations.

The [Neural Networks (NN)](/devices/interaction/neural-networks) HAL defines an
abstraction of the various accelerators. The drivers for these accelerators must
conform to this HAL.

### Vehicle HAL

[Vehicle Properties](/devices/automotive/properties) describes changes to the
vehicle HAL interface.

### GNSS satellite selection

When working with new global navigation satellite system (GNSS) HALs (v1.1+),
the Android Framework monitors Android settings. Partners can change the
settings from Google Play services or other system updates. These settings
tell the GNSS HAL if certain GNSS satellites shouldn't be used. This can be
useful in case of persistent GNSS satellite or constellation errors, or to
react more rapidly to GNSS HAL implementation issues that may occur when
mixing constellations using different time systems and external events,
such as leap-second, day, or week number rollovers.

### GNSS hardware model

In Android {{ androidPVersionNumber }}, the GNSS HAL version 1.1 or higher can
pass information about the hardware API to the platform. The platform needs to
implement the `IGnssCallback` interface and pass a handle to the HAL. The GNSS
HAL passes the hardware model information through the
[`LocationManager#getGnssHardwareModelName()`](https://developer.android.com/reference/android/location/LocationManager#getGnssHardwareModelName()){: .external}
method. Device manufacturers should work with their GNSS HAL providers to provide
this information where possible.

## Permissions

### Configuring discretionary access control (DAC) updates

[Configuring Discretionary Access Control (DAC)](/devices/tech/config/filesystem)
contains updates to the Android IDs (AIDs) mechanism for extending file system
capabilities.

### Whitelisting privileged apps permissions

In Android 9 and higher, if there are permissions that
should be denied, edit the XML to use the `deny-permission` tag instead of
the `permission` tag used in prior releases.

## Data

### Bandwidth estimation improvements

Android {{ androidPVersionNumber }} provides improved support for bandwidth
estimation. Android apps can make more appropriate resolution settings
for video calls and video streaming if they can access the data bandwidth
available.

On devices running Android 6.0 or higher, a caller wanting a bandwidth estimate
for a cellular network calls
[`ConnectivityManager.requestBandwidthUpdate()`](https://developer.android.com/reference/android/net/ConnectivityManager.html#requestBandwidthUpdate\(android.net.Network\)){: .external},
and the framework *may* provide an estimated downlink bandwidth.

But on devices running {{ androidPVersionNumber }} or higher, the
[`onCapabilitiesChanged()`](https://developer.android.com/reference/android/net/ConnectivityManager.NetworkCallback.html#onCapabilitiesChanged\(android.net.Network,%20android.net.NetworkCapabilities\)){: .external}
callback automatically fires when there's a significant change in the estimated
bandwidth, and calling `requestBandwidthUpdate()` is a no-op; the associated
[`getLinkDownstreamBandwidthKbps()`](https://developer.android.com/reference/android/net/NetworkCapabilities#getLinkDownstreamBandwidthKbps()){: .external}
and
[`getLinkUpstreamBandwidthKbps()`](https://developer.android.com/reference/android/net/NetworkCapabilities.html#getLinkUpstreamBandwidthKbps()){: .external}
are populated with updated information provided by the physical layer.

In addition, devices can check the LTE cell bandwidths via
[`ServiceState.getCellBandwidths()`](https://developer.android.com/reference/android/telephony/ServiceState#getCellBandwidths()){: .external}.
This lets applications determine how much bandwidth (frequency) is available
on a given cell. Cell bandwidth information is available via a hidden menu so
that field testers can check the most current information.

### eBPF traffic monitoring

The [eBPF network traffic tool](/devices/tech/datausage/ebpf-traffic-monitor)
uses a combination of kernel and user space implementation to monitor network
use on a device since the last device boot. This tool provides additional
functionality such as socket tagging, separating foreground/background traffic,
and per-UID firewall to block apps from network access depending on device state.

### Restore to lower APIs

Devices can now restore from future versions of the operating system. This is
especially useful when users have upgraded their phones but then lost or broken
them.

If an OEM modifies the backup agents for any of the system packages (android,
system, settings), those agents should handle restoring backups sets that were
made on higher versions of the platform without crashing and with restoring at
least some data.

Consider using a validator to check for invalid values of a given piece of
backup data and only restore valid data, as in
`core/java/android/provider/SettingsValidators.java`.

The feature is on by default. SettingsBackupAgent support for restoring from
future versions can be turned off via
`Settings.Global.OVERRIDE_SETTINGS_PROVIDER_RESTORE_ANY_VERSION`. No additional
implementation is required unless the device manufacturer extends one of the
backup agents included in the ROM (or adds a custom agent).

This feature allows system restores from future versions of the platform;
however, it’s reasonable to expect that the restored data won’t be complete. The
following instructions apply to the following backup agents:

-   **PackageManagerBackupAgent** supports future versions of the backup data
    via format versioning; extensions here **must** be compatible with the
    current restore code or follow instructions in the class, which include
    bumping the proper constants.

-   **SystemBackupAgent** specifies `restoreAnyVersion = false` in Android 9 and
    higher. It doesn’t support a restore from higher versions of the API.

-   **SettingsBackupAgent** specifies `restoreAnyVersion = true` in Android 9 and
    higher. Partial support exists via validators. A setting can be restored from a
    higher API version if a validator for it exists in the target OS. Adding any
    setting should be accompanied by its validator. Check the class for details.

-   Any **custom backup agent** included in the ROM should increase its version
    code any time an incompatible change is made to the backup data format and
    ensure `restoreAnyVersion = false` (the default) if their agent is not
    prepared to deal with backup data from a future version of their code.

## Enterprise

### Managed profile improvements

UX changes for [managed profiles](/devices/tech/admin/managed-profiles) make it
easier for users to identify, access, and control the managed profile.

### Pausing OTAs

A new @SystemApi lets device owners
[indefinitely pause OTA updates](/devices/tech/admin/ota-updates), including
security updates.

## Performance

### Health 2.0

Android 9 and higher includes `android.hardware.health` HAL 2.0, a major
version upgrade from health@1.0 HAL. For more information see these pages:

*   [Performance and Health](/devices/tech/health/)
*   [Implementing Health](/devices/tech/health/implementation)
*   [Deprecating health@1.0](/devices/tech/health/deprecation)

### APK caching

Android 9 and higher includes an [APK caching](/devices/tech/perf/apk-caching)
solution for rapid installation of preloaded apps on a device that supports
A/B partitions. OEMs can place preloads and
popular apps in the APK cache stored mostly in the empty B partition on new
A/B-partitioned devices without impacting any user-facing data space.

### Profile-guided optimization (PGO)

Android 9 and higher supports using
[Clang's profile-guided optimization (PGO)](/devices/tech/perf/pgo) on native
Android modules that have blueprint build rules.

### Write-ahead logging (WAL)

A special mode of SQLiteDatabase called [compatibility write-ahead
logging (WAL)](/devices/tech/perf/compatibility-wal) allows a database to use
`journal_mode=WAL` while keeping a maximum of one connection per database.

### Boot times

Android {{ androidPVersionNumber }} changes boot time optimization as described
in [Optimizing Boot Times](/devices/tech/perf/boot-times).

## Power

### Background restrictions

Android 9 and higher includes [background restrictions](/devices/tech/power/app_mgmt)
that allow users to restrict apps that may be draining battery power.
The system may also suggest disabling apps that are negatively
affecting a device's health.

### Batteryless devices

Android {{ androidPVersionNumber }} handles
[batteryless devices](/devices/tech/power/batteryless) more elegantly than
in previous releases. Android {{ androidPVersionNumber }} removes code for
batteryless devices that assumed by default
that a battery was present, charged at 100%, and in good
health with a normal temperature reading on its thermistor.
