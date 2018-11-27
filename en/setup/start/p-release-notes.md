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

Android {{ androidPVersionNumber }} has released! This page summarizes the
major features in this release, and provides links to additional information
when available. These feature summaries are organized according to the feature's
documentation location on this site. See the
[August 2018 Site Updates](/setup/start/site-updates#Aug-2018) for a guide to
section moves and
renaming.

## Build

### Generic System Image (GSI)

[Generic System Image (GSI)](/setup/build/gsi) describes the Generic System
Image (GSI) for Android {{ androidPVersionNumber }}, including details on
differences between GSIs for devices launching with Android
{{ androidPVersionNumber }} and devices upgrading to Android
{{ androidPVersionNumber }}.

## Architecture

### Hardware Abstraction Layer

#### HIDL Framework Backwards Compatibility

[HIDL Framework Backwards Compatibility Verification](/devices/architecture/hal/framework-testing)
is a method for verifying the backwards compatibility of the framework.

#### Dynamically Available HALs

[Dynamically Available HALs](/devices/architecture/hal/dynamic-lifecycle)
support the dynamic shutdown of Android hardware subsystems when they are not in
use or not needed.

### HIDL

#### HIDL Memory Block

[HIDL MemoryBlock](/devices/architecture/hidl/memoryblock) is an abstract layer
built on `hidl_memory`, `HIDL @1.0::IAllocator`, and `HIDL @1.0::IMapper`. It is
designed for HIDL services that have multiple memory blocks to share a single
memory heap.

### Device Tree Overlays

#### Compressed Overlays

This release adds support for using
[compressed overlays](/devices/architecture/dto/optimize#compressed-overlays) in
the Device Tree Blob Overlay (DTBO) image when using version 1 of the device
tree table header.

#### DTO Updates

This release requires that the bootloader must not modify the properties defined
in the [device tree overlays](/devices/architecture/dto/#p-update) before
passing the unified device tree blob to the kernel.

#### DTO Image Header Versioning

This release introduces a
[new version field](/devices/architecture/dto/partitions) in the DTBO image header.

#### DTBO Verification

This release requires a DTBO partition. To add nodes
or make changes to the properties in the SoC DT, the bootloader must dynamically
overlay a device specific DT over the SoC DT. For more information see
[Compiling & Verifying](/devices/architecture/dto/compile).

#### Kernel compliance

This release includes changes to requirements that affect the kernel, its
interfaces, and the use of DTBOs. For more information, see these pages:

*   [Stable Kernel Releases & Updates](/devices/architecture/kernel/releases)
*   [Android Common Kernels](/devices/architecture/kernel/android-common)
*   [Modular Kernel Requirements](/devices/architecture/kernel/modular-kernels)
*   [Interface Requirements](/devices/architecture/kernel/reqs-interfaces)
*   [Device Tree Overlays](/devices/architecture/dto/)

### Vendor NDK

#### VNDK: Design

For information about VNDK design changes in this release, see these pages:

*   [Vendor Native Development Kit (VNDK)](/devices/architecture/vndk/index)
*   [VNDK Build System Support](/devices/architecture/vndk/build-system)
*   [VNDK Definition Tool](/devices/architecture/vndk/deftool)
*   [Directories, Rules, and sepolicy](/devices/architecture/vndk/dir-rules-sepolicy)
*   [VNDK Extensions](/devices/architecture/vndk/extensions)
*   [Linker Namespace](/devices/architecture/vndk/linker-namespace)

#### VNDK: ABI Checker

[ABI Stability](/devices/architecture/vndk/abi-stability) describes the process
for ensuring changes made to libraries in the Vendor Native Development Kit
(VNDK) maintain Application Binary Interface (ABI) compliance.

#### VNDK Snapshots

[VNDK Snapshots](/devices/architecture/vndk/snapshot-design) can be used by a
system image to provide the correct VNDK libraries to vendor images even when
system and vendor images are built from different versions of Android.

### Vendor Interface Object

The following pages in the [Vendor Interface Object](/devices/architecture/vintf/)
section describe vendor interface object updates in this release:

*   [Manifests](/devices/architecture/vintf/objects)
*   [FCM Lifecycle](/devices/architecture/vintf/fcm)
*   [Device Manifest Development](/devices/architecture/vintf/dm)

#### HIDL Deprecation Schedule

The following pages describe how Android deprecates and removes HIDL HALs:

*   [FCM Lifecycle](/devices/architecture/vintf/fcm)
*   [Device Manifest Development](/devices/architecture/vintf/dm)

### Bootloader

#### Product Partitions

This release supports building
[`/product` partitions](/devices/bootloader/product-partitions) using the
Android build system. Previously, Android 8.x enforced the separation of
System-on-Chip (SoC)-specific components from the `/system` partition to the
`/vendor` partition without dedicating space for OEM-specific components built
from Android build system.

#### Canonical boot reason compliance

[Canonical Boot Reason](/devices/bootloader/boot-reason) describes changes to
the bootloader boot reason specification in this release.

#### System as Root

All devices launching with this release must use
[system-as-root](/devices/bootloader/system-as-root), which merges `ramdisk.img`
into `system.img` (this is also known as no-ramdisk), which in turn is mounted
as `rootfs`.

#### Boot Image Header Versioning

Starting in this release, the boot image header contains a
[field to indicate the header version](/devices/bootloader/boot-image-header).
The bootloader must check this header version field and parse the header
accordingly.

#### DTBO in Recovery

To prevent OTA failures due to mismatches between the recovery image and the
DTBO partition on non-A/B devices, the recovery image must contain
[information from the DTBO image](/devices/bootloader/recovery-image).

### Display

#### Display Cutouts

[Display Cutouts](/devices/tech/display/display-cutouts) allow app developers to
create immersive, edge-to-edge experiences while still allowing space for
important sensors on the front of devices.

#### Rotate Suggestions

Updates to [screen rotation behavior](/devices/tech/display/rotate-suggestions)
in this release include support for a user-facing control to pin screen rotation
in either landscape or portrait.

#### Synchronized App Transitions

[Synchronized App Transitions](/devices/tech/display/synched-app-transitions)
allow for new app transition animations.

#### Text Classification (formerly TEXTCLASSIFIER)

This release introduces a
[Text Classifier service](/devices/tech/display/textclassifier), which is now
the recommended way to implement text classification, and a default service
implementation.

#### Wide gamut color

This release introduces support for wide gamut color, including:

*   High dynamic range (HDR)
*   Processing content in the BT2020 color space, but not as an end-target
    dataspace

To use wide gamut color, a device’s full display stack (screen, hardware
composer, GPU, etc.) must support wide-gamut colors or buffer formats. Devices
are not required to claim support for wide gamut content even if the hardware
supports it. However, wide gamut color should be enabled to take full advantage
of the hardware. To avoid an inconsistent visual experience, wide gamut color
should not be turned off during runtime.

## Compatibility

### Android Compatibility Definition Document (CDD)

The [Android 9 Compatibility Definition Document](/compatibility/android-cdd)
iterates upon [previous versions](/compatibility/cdd) with updates for new
features and changes to requirements for previously released functionality.

## Settings

### Better App Widgets

The Android app widget framework now offers increased visibility into user
interactions, specifically when a user deletes or manually adds widgets. This
functionality comes by default with Launcher3.

Manufacturers need to update their Launcher apps (which are shipped with devices)
to support this feature if not based upon Launcher3. OEMs need to support the new
[widgetFeatures API](https://developer.android.com/reference/android/appwidget/AppWidgetProviderInfo#widgetFeatures){: .external}
in their default Launcher.

The API in itself does not guarantee that it will work end to end unless the
launchers implement it as expected. AOSP includes a sample implementation. See
the AOSP Change-Id Iccd6f965fa3d61992244a365efc242122292c0ca for the sample code
provided.


### Device State Change Notifications to Package Installers

A protected system broadcast can now be sent to apps that hold the
`INSTALL_PACKAGES` permission whenever a change to properties like locale or
display density happens. Receivers can be registered in the manifest, and a
process will be awakened to receive the broadcast. This is useful for package
installers that wish to install additional components of apps upon such changes,
which will happen rarely, because the configuration changes eligible to trigger
this broadcast are rare.

Device state change notification source code is located at the following
locations under `platform/frameworks/base`:

*   `api/system-current.txt`
*   `core/java/android/content/Intent.java`
*   `core/res/AndroidManifest.xml`
*   `services/core/java/com/android/server/am/ActivityManagerService.java`

### Information Architecture

Changes to the
[Settings app information architecture](/devices/tech/settings/info-architecture)
provide more Settings functionality and easier implementation.

## Tests

### Atest

[Atest](https://android.googlesource.com/platform/tools/tradefederation/+/master/atest/README.md){: .external}
is a new command line tool that allows users to build, install and run Android
tests locally.

### Compatibility Test Suite (CTS)

#### CTS Downloads

New CTS packages supporting Android 9 have been uploaded to the
[CTS Downloads](/compatibility/cts/downloads) page. The source code for the
included tests can be synced with the `android-cts-9.0_r1` tag in the
open-source tree.

#### CTS Options

For Android 9, CTS v2 gains the following
[command and argument](/compatibility/cts/run#ctsv2_reference):

*   `run retry` - Retry all tests that failed or were not executed from the
    previous sessions.
*   `‘--shard-count` - Shard a CTS run into given number of independent chunks,
    to run on multiple devices in parallel.

In addition, the previously undocumented commands ‘--retry-type’ has been added
to the same
[CTS v2 console command reference](/compatibility/cts/run#ctsv2_reference).


#### Secure Element

[Secure Element Service](/compatibility/cts/secure-element) checks for
Global platform-supported secure elements (essentially checks for
Global platform-supported secure elements, by seeing if devices have an SE
HAL implementation and if yes, how many. This is used as the
basis to test the API and the underlying secure element implementation.

#### Sensor Fusion Box

The Sensor Fusion Box is used in the CameraITS sensor_fusion test and
multi-camera sync test and provides a consistent test environment for measuring
timestamp accuracy of camera and other sensors for Android phones. See these
pages for more information:

*   [Sensor Fusion Box Quick Start Guide](/compatibility/cts/sensor-fusion-quick-start)
    provides step-by-step directions on how to set up the Sensor Fusion test and
    Sensor Fusion Box for the first time.
*   [Sensor Fusion Box Assembly](/compatibility/cts/sensor-fusion-box-assembly)
    provides step-by-step instructions for assembling a Sensor Fusion Box.

#### Wide Field of View ITS-in-a-Box

The
[Wide Field of View ITS-in-a-Box](/compatibility/cts/camera-wfov-box-assembly)
is an automated system designed to test both wide field of view (WFoV) and
regular field of view (RFoV) camera systems in the Camera Image Test Suite
(ITS).

### Vendor Test Suite

#### Host Controller Architecture

[VTS Host Controller Architecture](/compatibility/vts/host-controller) describes
the architecture of VTS test framework integrated with its cloud-based test
serving service.

#### Service Name Aware HAL Testing

[VTS Service Name Aware HAL Testing](/compatibility/vts/sna-hal-testing)
supports obtaining the service name of a given HAL instance based on the device
on which Vendor Test Suite (VTS) tests are running.

#### HAL Testability Check

[VTS HAL Testability Check](/compatibility/vts/hal-testability) includes a
runtime method for using the device configuration to identify which VTS tests
should be skipped for that device target.

#### Automated Testing Infrastructure

The [Automated Testing Infrastructure](/compatibility/vts/automated-test-infra)
page describes a new Vendor Test Suite (VTS) infrastructure for automated
testing of VTS, CTS, or other tests on partner devices running the AOSP generic
system image (GSI).

### Debugging

#### Advanced Telemetry


In Android, telemetry is the process of automatically collecting usage and
diagnostics information about the device, the Android system, and apps. In
previous versions of Android, the telemetry stack was limited and did not
capture the information needed to identify and resolve system reliability
and device or app issues. This made identifying root causes of issues difficult,
if not impossible.

Android 9 includes a new telemetry feature, `statsd`, which solves this
deficiency by collecting better data faster. `statsd` collects
app usage, battery and process statistics, and crashes. The data is analyzed and
used to improve products, hardware, and services.

For more details, see `frameworks/base/cmds/statsd/`.


## Security Features

### Application Signing

[APK Signature Scheme v3](/security/apksigning/v3) is the new APK signature
scheme, which supports APK key rotation.


### Biometric Support

Android 9 includes a
[BiometricPrompt API](https://developer.android.com/preview/features/security#fingerprint-auth){: .external}
that apps can use to integrate biometric authentication support in a device- and
modality-agnostic fashion. For more information about integrating your
biometrics stack to include `BiometricPrompt`, see
[Biometrics](/security/biometric).

### Dynamic Analysis

Android 9 includes support for more
[exploit mitigation and analysis
tools](/devices/tech/debug/fuzz-sanitize).

#### Control Flow Integrity (CFI)

[Control Flow Integrity (CFI)](/devices/tech/debug/cfi) is a security mechanism
that disallows changes to the original control flow graph of a compiled binary,
making it significantly harder to perform such attacks.

#### Kernel CFI

In addition to system CFI, which is enabled by default, this release also
includes support for [Kernel Control Flow Integrity](/devices/tech/debug/kcfi).

### Encryption

#### File-Based Encryption

[File-based encryption](/security/encryption/file-based) is updated to work with
[adoptable storage](/devices/storage/adoptable). For new devices, we recommend
using file-based encryption over full-disk encryption.

#### Metadata encryption

This release introduces support for
[metadata encryption](/security/encryption/metadata) where hardware support is
present. With metadata encryption, a single key present at boot time encrypts
whatever content is not encrypted by file-based-encryption.

### Keystore

Android 9 includes
[Keymaster 4](https://android.googlesource.com/platform/hardware/interfaces/+/master/keymaster/4.0/){: .external},
which has these features:

#### StrongBox

Android 9 includes support for Android Keystore keys that are
stored and used in a physically separate CPU purpose-built for
high-security applications, such as an embedded
[Secure Element](/compatibility/cts/secure-element) (SE).
StrongBox Keymaster is an implementation of the Keymaster HAL in discrete
secure hardware. A StrongBox has:

  *   Discrete CPU
  *   Integral secure storage
  *   High-quality True Random Number Generator
  *   Tamper-resistant packaging
  *   Side-channel resistance

#### Secure key import

To securely import a key into Keymaster 4, a key created off-device is encrypted
with a specification of the authorizations that define how the key may be used.

##### 3DES support

Keymaster 4 includes 3DES for compatibility with legacy systems that  use 3DES.

#### Version binding

To support Treble's modular structure and break the binding of `system.img`
to `boot.img`, Keymaster 4 changed the [key version binding](/security/keystore/version-binding)
model to have separate patch levels for each partition. This allows each partition to be
updated independently while still providing rollback protection.

#### Android Protected Confirmation

Supported devices that launch with Android 9 installed give developers the
ability to use the
[Android Protected Confirmation API](https://developer.android.com/preview/features/security#android-protected-confirmation){: .external}.
By using this new API, apps can use an instance of
<code>[ConfirmationPrompt](https://developer.android.com/reference/android/security/ConfirmationPrompt.html)</code>
to display a prompt to the user, asking them to approve a short statement. This
statement allows an app to reaffirm that the user would like to complete a
sensitive transaction, such as making a payment.


### SELinux

#### Per-App SELinux Sandbox

The [Application Sandbox](/security/app-sandbox) has new protections and test
cases to ensure that all non-privileged apps tageting Android 9 and higher run
individual SELinux sandboxes.

#### Treble SELinux changes

Updates to Treble SELinux in this release are documented in several pages in the
[SELinux section](/security/selinux).

#### Vendor_init

[Vendor Init](/security/selinux/vendor-init) describes updates to close the init
process access hole in the Treble system/vendor split by using a separate
SELinux domain to run `/vendor` commands with vendor-specific permissions.

#### System Properties

Android 9 restricts [system properties](/security/selinux/compatibility#system-property-and-process-labeling-ownership)
from being shared between `system` and `vendor` partitions unnecessarily and
provides a method for ensuring consistency between shared system properties.

##### SELinux attribute tests

Android 9 includes new
[build-time tests](https://android.googlesource.com/platform/system/sepolicy/+/master/tests/sepolicy_tests.py){: .external}
that ensure all files in specific locations have the
[appropriate attributes](/security/selinux/compatibility#compatibility-attributes).
For example, all files in `sysfs` have the required `sysfs_type` attribute.


## Audio

### High-Resolution Audio Effects

Updates to [High-Resolution Audio Effects](/devices/audio/highres-effects)
include converting effect processing from int16 to float format and increases in
simultaneous client output tracks, maximum client/server memory, and total mixed
tracks.

## Camera

### External USB Cameras

This release supports using
[plug-and-play USB cameras](/devices/camera/external-usb-cameras) (i.e. webcams)
using the standard Android Camera2 API and the camera HIDL interface.

### Motion Tracking

Camera devices can
[advertise motion tracking capability](/devices/camera/motion-tracking).

### Multi-Camera Support

[Multi-Camera Support](/devices/camera/multi-camera) includes API support for
multi-camera devices via a new logical camera device composed of two or more
physical camera devices pointing in the same direction.

### Session Parameters

[Implementing session parameters](/devices/camera/session-parameters) can reduce
delays by enabling camera clients to actively configure a subset of costly
request parameters as part of the capture session initialization phase.

### Single Producer, Multiple Consumer Buffer

[Single Producer Multiple Consumer Camera Buffer Transport](/devices/camera/singleprod-multiconsum)
is a new set of methods that allows camera clients to add and remove output
surfaces dynamically while the capture session is active and camera streaming is
ongoing.

## Connectivity

### Calling and Messaging

#### Implementing data plans

This release provides improved support for carriers
[implementing data plans](/devices/tech/connect/data-plans) using the
`SubcriptionPlan` APIs.

#### Third-party calling apps

This release provides APIs that allow
[third-party calling apps](/devices/tech/connect/third-party-call-apps) to
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
physical SIM card. In this release, the Android framework provides standard APIs
for accessing eSIM and managing subscription profiles on the eSIM. For more
information, see:

*   [Implementing eSIM](/devices/tech/connect/esim-overview)
*   [Modem Requirements](/devices/tech/connect/esim-modem-requirements)
*   [eUICC APIs](/devices/tech/connect/esim-euicc-api)

#### Multi-SIM support for IMS settings

This release provides improvements to the user settings for
[IMS](/devices/tech/connect/ims). Users can set up Voice over LTE (VoLTE), video
calling, and Wi-Fi calling on a per-subscription basis instead of sharing these
settings across all subscriptions.

#### SIM state broadcasts

In this release, `Intent.ACTION_SIM_STATE_CHANGED` has been deprecated, and two
separate broadcasts for card state and card application state have been added:
`TelephonyManager.ACTION_SIM_CARD_STATE_CHANGED` and
`TelephonyManager.ACTION_SIM_APPLICATION_STATE_CHANGED`.

With this change, receivers that only need to know whether a card is present are
no longer required to listen to application state changes, and receivers that
only need to know whether card applications are ready are not required to listen
to changes in card state.

The two new broadcasts are @SystemApis and are not sticky. Only receivers with
the `READ_PRIVILEGED_PHONE_STATE` permission can receive the broadcasts.

The intents are not rebroadcast when the user unlocks the device. Receivers that
depend on broadcasts sent before user unlock must either be `directBootAware`,
or they must query the state after user unlock. The states can be queried using
the corresponding APIs in TelephonyManager: `getSimCardState()`
and`getSimApplicationState()`.

### Wi-Fi

#### Carrier Wi-Fi

[Carrier Wi-Fi](/devices/tech/connect/carrier-wifi) allows devices to
automatically connect to carrier-implemented Wi-Fi networks. In areas of high
congestion or with minimal cell coverage such as a stadium or an underground
train station, Carrier Wi-Fi can be used to improve users' connectivity
experience and to offload traffic.

#### MAC randomization

[MAC Randomization](/devices/tech/connect/wifi-mac-randomization) allows devices
to use random MAC addresses when probing for new networks while not currently
associated to a network. In this release, a developer option can be enabled to
cause a device to use a randomized MAC address when connecting to a Wi-Fi
network.

#### Turn on Wi-Fi automatically

[Turn on Wi-Fi automatically](/devices/tech/connect/wifi-infrastructure#turn_on_wi-fi_automatically)
allows users to automatically re-enable Wi-Fi whenever the device is near a
Wi-Fi network that has been saved and has a sufficiently high relative received
signal strength indicator (RSSI).

#### Wi-Fi Round Trip Time (RTT)

[Wi-Fi Round Trip Time (RTT)](/devices/tech/connect/wifi-rtt) allows devices to
measure the distance to other supporting devices: whether they are Access Points
(APs) or Wi-Fi Aware peers (if Wi-Fi Aware is supported on the device). This
feature, built upon the IEEE 802.11mc protocol, enables apps to use enhanced
location accuracy and awareness.

#### Wi-Fi Scoring improvements

Improved Wi-Fi scoring models quickly and accurately determine when a device
should exit a connected Wi-Fi network or enter a new Wi-Fi network. These models
provide a reliable and seamless experience for users by avoiding gaps in
connectivity.

You should review and tune the RSSI values in the config.xml resources,
especially the following:

-   `config_wifi_framework_wifi_score_bad_rssi_threshold_5GHz`
-   `config_wifi_framework_wifi_score_entry_rssi_threshold_5GHz`
-   `config_wifi_framework_wifi_score_bad_rssi_threshold_24GHz`
-   `config_wifi_framework_wifi_score_entry_rssi_threshold_24GHz`

Note: The "entry" values were introduced in Android 8.1, and the defaults were
chosen to match the defaults for the "bad" thresholds for compatibility.
Ideally, the entry threshold should be 3 dB or more above the corresponding exit
("bad") threshold.

#### Wi-Fi STA/AP concurrency

[Wi-Fi STA/AP concurrency](/devices/tech/connect/wifi-sta-ap-concurrency) is the
ability for devices to operate in Station (STA) and Access Point (AP) modes
concurrently. For devices supporting Dual Band Simultaneous (DBS), this feature
opens up new capabilities such as not disrupting STA Wi-Fi when a user wants to
enable a hotspot (softAP).

#### WiFiStateMachine improvements

`WifiStateMachine` is the main class used to control Wi-Fi activity, coordinate
user input (operating mode: hotspot, scan, connect or off), and control Wi-Fi
network actions (e.g., scanning, connecting).

In this release, the Wi-Fi framework code and implementation of
`WifiStateMachine`has been re-architected leading to reduced code size,
easier-to-follow Wi-Fi control logic, improved control granularity, and
increased coverage and quality of unit tests.

At a high level,`WifiStateMachine` allows Wi-Fi to be in one of four states:

1.  Client mode (can connect and scan)
1.  Scan Only mode
1.  SoftAP mode (Wi-Fi hotspot)
1.  Disabled (Wi-Fi fully off)

Each Wi-Fi mode has different requirements for running services and should be
set up in a consistent manner, handling only the events relevant to its
operation. The new implementation restricts the code to events related to that
mode, reducing debugging time and the risk of introducing new bugs due to
complexity. In addition to explicit handling for mode functionality, thread
management is handled in a consistent manner and the use of asynchronous
channels is eliminated as a mechanism for synchronization.

#### Wi-Fi permission updates

From this release, the `CHANGE_WIFI_STATE` app permission is dynamically checked
and can be turned off by the user. The user can disable the permission for any
app through the special settings page in **Settings > Apps & notifications >
Special app access > Wi-Fi control**.

Apps must be able to handle cases where the `CHANGE_WIFI_STATE` permission is
not granted.

To validate this behavior, run the roboelectric and manual tests.

Run the roboelectric tests at:
[/packages/apps/Settings/tests/robotests/src/com/android/settings/wifi/AppStateChangeWifiStateBridgeTest.java](https://android.googlesource.com/platform/packages/apps/Settings/+/master/tests/robotests/src/com/android/settings/wifi/){: .external}

For manual testing:

1.  Go to Settings > Apps & notifications > Special app access > Wi-Fi control.
1.  Select and turn off the permission for your app.
1.  Verify that your app can handle the scenario where the `CHANGE_WIFI_STATE`
    permission is not granted.

#### WPS deprecation

Due to security issues, Wi-Fi Protected Setup (WPS) in `WiFiManager` has been
deprecated and disabled from this release. However, `WiFiDirect` still uses WPS
in the WPA supplicant.

## Graphics

### Implementation

#### Vulkan 1.1 API

This release supports implementing the
[Vulkan 1.1 graphics API](/devices/graphics/implement-vulkan).

#### WinScope tool for window transition tracing

This release introduces the WinScope tool for tracing window transitions.
WinScope provides infrastructure and tools to record and analyze Window Manager
state during and after transitions. It allows recording and stepping through
window transitions, while recording all pertinent window manager state to a
trace file. You can use this data to replay and step through the transition.

The WinScope tool source code is located at
`platform/development/tools/winscope`.

## Interaction

### Automotive Audio

The section [Automotive Audio](/devices/automotive/audio) describes the audio
architecture for automotive-related Android implementations.

The [Neural Networks](/devices/interaction/neural-networks) (NN) HAL defines an
abstraction of the various accelerators. The drivers for these accelerators must
conform to this HAL.

### Vehicle HAL

[Vehicle Properties](/devices/automotive/properties) describes changes to the
vehicle HAL interface.

### GNSS Satellite Selection

When working with new Global Navigation Satellite System (GNSS) HALs (v1.1+),
the Android Framework will monitor Android Settings. Partners can change the
Settings from Google Play Services or other system updatees. These settings
tell the GNSS HAL if certain GNSS satellites should not be used. This can be
useful in case of persistent GNSS satellite or constellation errors, or to
react more rapidly to GNSS HAL implementation issues that may occur when
intermixing constellations using different time systems and external events,
such as leap-second and/or Day, or Week Number rollovers.

### GNSS Hardware Model

In Android {{ androidPVersionNumber }}, the GNSS HAL version 1.1 or higher can
pass information about the hardware API to the platform. The platform needs to
implement the `IGnssCallback` interface and pass a handle to the HAL. The GNSS
HAL passes the hardware model information through the
[`LocationManager#getGnssHardwareModelName()`](https://developer.android.com/reference/android/location/LocationManager#getGnssHardwareModelName()){: .external}
API. Device manufacturers should work with their GNSS HAL providers to provide
this information where possible.

## Permissions

### Configuring Discretionary Access Control (DAC) Updates

[Configuring Discretionary Access Control (DAC)](/devices/tech/config/filesystem)
contains updates to the Android IDs (AIDs) mechanism for extending filesystem
capabilities.

### Update on the privileged apps permissions whitelisting

Starting in Android 9, if there are permissions that should be denied, edit the
XML to use a `deny-permission` tag instead of a `permission` tag as was used in
prior releases.

## Data

### Bandwidth Estimation Improvements

Android {{ androidPVersionNumber }} provides improved support for bandwidth
estimation. Android applications can make better decisions on the resolution to
use for video calls and video streaming if they are aware of the data bandwidth
available to them.

On devices running Android 6.0 and higher, a caller wanting a bandwidth estimate
for a cellular network calls
[`ConnectivityManager.requestBandwidthUpdate()`](https://developer.android.com/reference/android/net/ConnectivityManager.html#requestBandwidthUpdate\(android.net.Network\)){: .external},
and the framework *may* provide an estimated downlink bandwidth.

But on devices running {{ androidPVersionNumber }} or higher, the
[`onNetworkCapabilitiesChanged()`](https://developer.android.com/reference/android/net/ConnectivityManager.NetworkCallback.html#onCapabilitiesChanged\(android.net.Network,%20android.net.NetworkCapabilities\)){: .external}
callback automatically fires when there is a significant change in the estimated
bandwidth, and calling `requestBandwidthUpdate()` is a no-op; the associated
[`getLinkDownstreamBandwidthKbps()`](https://developer.android.com/reference/android/net/NetworkCapabilities#getlinkdownstreambandwidthkbps){: .external}
and
[`getLinkUpstreamBandwidthKbps()`](https://developer.android.com/reference/android/net/NetworkCapabilities#getlinkupstreambandwidthkbps){: .external}
is populated with updated information provided by the physical layer.

In addition, devices can check the LTE cell bandwidths via
[`ServiceState.getCellBandwidths()`](https://developer.android.com/reference/android/telephony/ServiceState#getcellbandwidths){: .external}.
This lets applications know exactly how much bandwidth (frequency) is available
on a given cell. Cell bandwidth information is available via a hidden menu so
that field testers can check the most current information.

### eBPF Traffic Monitoring

The [eBPF network traffic tool](/devices/tech/datausage/ebpf-traffic-monitor)
uses a combination of kernel and user space implementation to monitor network
usage on the device since the last device boot. It provides additional
functionality such as socket tagging, separating foreground/background traffic
and per-UID firewall to block apps from network access depending on device state.

### Restore to lower APIs

Devices can now restore from future versions of the operating system. This is
especially useful when users have upgraded their phones but then lost or broken
them.

If an OEM modifies the backup agents for any of the system packages (android,
system, settings), those agents should handle restoring backups sets that were
made on later versions of the platform without crashing and with restoring at
least some data.

Consider using a validator to check for invalid values of a given piece of
backup data and only restore valid data, as done in
`core/java/android/provider/SettingsValidators.java`.

The feature is on by default. SettingsBackupAgent support for restoring from
future versions can be turned off via
`Settings.Global.OVERRIDE_SETTINGS_PROVIDER_RESTORE_ANY_VERSION`. No additional
implementation is required unless the device manufacturer extends one of backup
agents included in the ROM (or adds a custom one).

This feature allows system restores from future versions of the platform;
however, it’s reasonable to expect that the restored data won’t be complete. The
following instructions apply to the following backup agents:

-   **PackageManagerBackupAgent**: Supports future versions of the backup data
    via format versioning; extensions here MUST be compatible with current
    restore code or follow instructions in the class, which include bumping the
    proper constants.

-   **SystemBackupAgent**: `restoreAnyVersion = false` in Android this release
    and higher. Doesn’t support restore from higher versions of the API.

-   **SettingsBackupAgent**: `restoreAnyVersion = true` starting in this release.
    Partial support exists via validators. A setting can be restored from a
    higher API version if a validator for it exists in the target OS. Adding any
    setting should be accompanied by its validator. Check class for details.

-   Any **custom backup agent** included in the ROM should increase its version
    code any time an incompatible change is made to the backup data format and
    ensure `restoreAnyVersion = false` (the default) if their agent is not
    prepared to deal with backup data from a future version of their code.

## Enterprise

### Managed Profile Improvements

[Managed Profile](/devices/tech/admin/managed-profiles) UX changes make it
easier for users to identify, access, and control the managed profile.

### Pause OTAs

A new @SystemApi lets device owners
[indefinitely pause OTA updates](/devices/tech/admin/ota-updates), including
security updates.

## Performance

### Health 2.0

This release introduces includes android.hardware.health HAL 2.0, a major
version upgrade from health@1.0 HAL. For more information see these pages:

*   [Health](/devices/tech/health/)
*   [Implementing Health](/devices/tech/health/implementation)
*   [Deprecating health@1.0](/devices/tech/health/deprecation)

### APK Caching

Android 9 includes an [APK caching](/devices/tech/perf/apk-caching) solution for
rapid installation of preloaded apps on a device that supports
A/B partitions. OEMs can place preloads and
popular apps in the APK cache stored in the mostly empty B partition on new
A/B-partitioned devices without impacting any user-facing data space.

### Profile Guided Optimization (PGO)

This release supports using
[Clang's profile-guided optimization](/devices/tech/perf/pgo) (PGO) on native
Android modules that have blueprint build rules.

### Write-Ahead Logging

[Compatibility WAL (Write-Ahead Logging) for Apps](/devices/tech/perf/compatibility-wal)
is a new special mode of SQLiteDatabase called Compatibility WAL (write-ahead
logging) that allows a database to use `journal_mode=WAL` while preserving the
behavior of keeping a maximum of one connection per database.

### Boot Times

[Optimizing Boot Times](/devices/tech/perf/boot-times) describes changes to boot
time optimization.

## Power

### Background Restrictions

Android {{ androidPVersionNumber }}
introduces [Background Restrictions](/devices/tech/power/app_mgmt),
which allow users to restrict apps that may be draining device battery power.
The system may also suggest disabling apps that it detects are negatively
affecting a device's health.

### Batteryless Devices

Android 9 more elegantly handles
[batteryless devices](/devices/tech/power/batteryless) than previous releases.
Android 9 removes some previous code for batteryless devices that by default
pretended a battery was present, was being charged at 100%, and was in good
health with a normal temperature reading on its thermistor.
