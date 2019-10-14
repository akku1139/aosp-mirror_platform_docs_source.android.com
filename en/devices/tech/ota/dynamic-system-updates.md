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

# Dynamic System Updates

Dynamic System Updates (DSU) allows you to make an Android system image that
users can download from the internet and try out without the risk of corrupting
the current system image. This document describes how to support DSU.

## Kernel requirements

See
[Implementing Dynamic Partitions](/devices/tech/ota/dynamic_partitions)
for kernel requirements.

In addition, DSU relies on the device-mapper-verity (dm-verity) kernel feature
to verify the Android system image. So you must enable the following kernel
configs:

*   `CONFIG_DM_VERITY=y`
*   `CONFIG_DM_VERITY_FEC=y`

## Partition requirements

The `metadata` partition (16 MB or larger) is required for storing data related to
the installed images. It must be mounted during first stage mount.

The `userdata` partition must use f2fs or ext4 file system. When using f2fs,
include all f2fs related patches available in the
[Android common kernel](/devices/architecture/kernel/android-common).

DSU was developed and tested with kernel/common 4.9. It's recommended
to use kernel 4.9 and higher for this feature.

## Vendor HAL behavior

### Weaver HAL

The weaver HAL provides a fixed number of slots for storing user keys. The DSU
consumes two extra key slots. If an OEM has a weaver HAL, it needs to have
enough slots for a generic system image (GSI) and a host image.

### Gatekeeper HAL

The [gatekeeper HAL](/security/authentication/gatekeeper) needs to support
large USER_ID values, because the GSI offsets UIDs to the HAL by +1000000.

## Verify boot

Three GSI keys must be included into ramdisk: Q-GSI, R-GSI, and S-GSI. So devices
can either use DSU or modify the fstab setting to verify the GSI image with
those keys.

To include GSI keys, add the following line to the file
`device/<device_name>/device.mk`:

```
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
```

### Rollback protection

When using DSU, the downloaded Android system image must be newer than the
current system image on the device. This is done by comparing the security patch
levels in the
[Android Verified Boot](https://android.googlesource.com/platform/external/avb/)
(AVB)
[AVB property descriptor](https://android-review.googlesource.com/c/platform/build/+/909173)
of both system images: `Prop: com.android.build.system.security_patch ->
'2019-04-05'`.

For devices not using AVB, put the security patch level of the current system
image into the bootloader kernel cmdline:
`androidboot.system.security_patch=2019-04-05`.

## Hardware requirements

When you launch a DSU instance, two temporary files are allocated:

*   A logical partition to store `GSI.img` (1~1.5&nbsp;G)
*   An 8&nbsp;GB empty `/data` partition as the sandbox for running the GSI

We recommend reserving at least 10&nbsp;GB of free space before launching a DSU
instance. DSU also supports allocation from an SD card. When
an SD card is present, it has the highest priority for the allocation. SD card
support is critical for lower-powered devices that might not have enough
internal storage. When an SD card is present, make sure it's not adopted. DSU
doesn't support [adopted](/devices/storage/adoptable) SD cards.

## Available frontends

You can launch DSU using `adb` or using an app.

### Launching DSU using adb

To launch DSU using adb, enter these commands:

```
$>simg2img out/target/product/.../system.img system.raw
$>gzip -c system.raw > system.raw.gz
$>adb push system.raw.gz /storage/emulated/0/Download
$>adb shell am start-activity \
-n com.android.dynsystem/com.android.dynsystem.VerificationActivity  \
-a android.os.image.action.START_INSTALL    \
-d file:///storage/emulated/0/Download/system.raw.gz  \
--el KEY_SYSTEM_SIZE $(du -b system.raw|cut -f1)  \
--el KEY_USERDATA_SIZE 8589934592
```

### Launching DSU using an app

The main entry point to DSU is the
`android.os.image.DynamicSystemClient.java` API:

```
public class DynamicSystemClient {


...
...

     /**
     * Start installing DynamicSystem from URL with default userdata size.
     *
     * @param systemUrl A network URL or a file URL to system image.
     * @param systemSize size of system image.
     */
    public void start(String systemUrl, long systemSize) {
        start(systemUrl, systemSize, DEFAULT_USERDATA_SIZE);
    }
```

You must bundle/pre-install this app on the device. Because
`DynamicSystemClient` is a System API, you can't build the app with the regular
SDK API and you can't publish it on the Play Store. The purpose of this app is:

1.  Fetch an image list and the corresponding URL with a vendor-defined scheme.
1.  Match the images in the list against the device and show compatible images
    for the user to select.
1.  Invoke `DynamicSystemClient.start` like this:

    ```
    DynamicSystemClient aot = new DynamicSystemClient(...)
       aot.start(
            ...URL of the selected image...,
            ...uncompressed size of the selected image...);

    ```

The URL points to a gzipped, non-sparse, system image file, which you can make
with the following commands:

```
$> simg2img ${OUT}/system.img ${OUT}/system.raw
$> gzip ${OUT}/system.raw
$> ls ${OUT}/system.raw.gz
```

The filename should follow this format:

```
<android version>.<lunch name>.<user defined title>.raw.gz
```

Examples:

*   `o.aosp_taimen-userdebug.2018dev.raw.gz`
*   `p.aosp_taimen-userdebug.2018dev.raw.gz`

## Feature flag

The DSU feature is under the `settings_dynamic_android` feature flag.
Before using DSU, make sure the corresponding feature flag is enabled.

![Enabling the feature flag.](/devices/tech/images/aot-settings.png)

**Figure 1.** Enabling the feature flag

The feature flag UI might be unavailable on a device running a user build.
In this case, use the `adb` command instead:

```
adb shell setprop persist.sys.fflag.override.settings_dynamic_system 1
```

## Vendor host system images on GCE (optional)

One of the possible storage locations for the system images is the Google
Compute Engine (GCE) bucket. The release administrator uses the
[GCP storage console](https://console.cloud.google.com/storage)
to add/delete/change the released system image.

The images must be public access, as shown here:

![Public access in GCE](/devices/tech/images/aot-image-access.png)

**Figure 2.** Public access in GCE

The procedure to make an item public is available
[here](https://cloud.google.com/storage/docs/access-control/making-data-public).
