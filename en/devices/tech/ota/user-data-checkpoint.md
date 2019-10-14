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

# User Data Checkpoint (UDC)

Android {{ androidQVersionNumber }} introduces User Data Checkpoint (UDC), which
allows Android to roll back to its previous state when an Android over-the-air
(OTA) update fails. With UDC, if an Android OTA update fails, the device can
safely roll back to its previous state. Although
[A/B updates](/devices/tech/ota/ab) solve this problem for early boot, rollback
isn't supported when the user data partition (mounted on `/data`) is modified.

UDC enables the device to revert the user data partition even after being
modified. The UDC feature accomplishes this with checkpoint capabilities to the
file system, an alternative implementation when the file system doesn't support
checkpoints, integration with the bootloader A/B mechanism while also supporting
non-A/B updates, and support for key version binding and key rollback
prevention.

## User impact

The UDC feature improves the OTA update experience for users as fewer users lose
their data when an OTA update fails. This can reduce the number of support calls
from users who run into issues during the update process. However, when an OTA
update fails, users may notice the device rebooting multiple times.

## How it works

### Checkpoint functionality in different file systems {:#f2fscheckpoint}

For the F2FS file system, UDC adds the checkpoint functionality to the upstream
4.20 Linux kernel and backports it to all common kernels supported by devices
running Android {{ androidQVersionNumber }}.

For other file systems, UDC uses a device mapper virtual device called `dm_bow`
for checkpoint functionality. `dm_bow` sits between the device and the file
system. When a partition is mounted, a trim is issued causing the file system to
issue trim commands on all free blocks. `dm_bow` intercepts these trims and uses
them to set up a free block list. Reads and writes are then sent to the device
unmodified, but before a write is allowed, data needed for a restore is backed
up to a free block.

### Checkpointing process

When a partition with the `checkpoint=fs/block` flag is mounted, Android calls
`restoreCheckpoint` on the drive to allow the device to restore any current
checkpoint. `init` then calls the `needsCheckpoint` function to determine if
the device either is in a bootloader A/B state or has set the update retry
count. If either is true, Android calls `createCheckpoint` to either add mount
flags or build a `dm_bow` device.

After the partition is mounted, the checkpoint code is called to issue trims.
The boot process then continues as normal. At `LOCKED_BOOT_COMPLETE`, Android
calls `commitCheckpoint` to commit the current checkpoint and the update
continues as normal.

### Managing keymaster keys

Keymaster keys are used for device encryption or other purposes. To manage these
keys, Android delays key delete calls until the checkpoint is committed.

Note: UDC doesn't create any additional security or privacy issues. With UDC,
Android writes data to a different place on the `userdata` partition.

### Monitoring health

A health daemon verifies that there's enough disk space to create a
checkpoint. The health daemon is located in
[`cp_healthDaemon`](https://android.googlesource.com/platform/system/vold/+/refs/heads/master/Checkpoint.cpp#284){: .external}
in `Checkpoint.cpp`.

The health daemon has the following behaviors that can be configured:

- [`ro.sys.cp_msleeptime`](https://android.googlesource.com/platform/system/vold/+/refs/heads/master/Checkpoint.cpp#274){: .external}:
  Controls how often the device checks disk usage.
- [`ro.sys.cp_min_free_bytes`](https://android.googlesource.com/platform/system/vold/+/refs/heads/master/Checkpoint.cpp#278){: .external}:
  Controls the minimum value the health daemon looks for.
- [`ro.sys.cp_commit_on_full`](https://android.googlesource.com/platform/system/vold/+/refs/heads/master/Checkpoint.cpp#281){: .external}:
  Controls whether the health daemon reboots the device or commits the
  checkpoint and continues when the disk is full.

### Checkpoint APIs

Checkpoint APIs are used by the UDC feature. For other APIs used by UDC, see
[`IVoid.aidl`](https://android.googlesource.com/platform/system/vold/+/master/binder/android/os/IVold.aidl){: .external}.

#### void startCheckpoint(int retry)

Creates a checkpoint.

The framework calls this method when it's ready to start an update. The
checkpoint is created before checkpointed file systems such as userdata are
mounted R/W after reboot. If the retry count is positive, the API handles
tracking retries, and the updater calls `needsRollback` to check if a rollback
of the update is required. If the retry count is `-1`, the API defers to the A/B
bootloader's judgement.

This method isn't called when doing a normal A/B update.

#### void commitChanges()

Commits the changes.

The framework calls this method after reboot when the changes are ready to be
committed. This is called before data (such as pictures, video, SMS, server
receipt of receival) is written to userdata and before `BootComplete`.

If no active checkpointed update exists, this method has no effect.

#### abortChanges()

Forces reboot and reverts to the checkpoint. Abandons all userdata modifications
since the first reboot.

The framework calls this method after reboot but before `commitChanges`.
`retry_counter` is decreased when this method is called. Log entries are
generated.

#### bool needsRollback()

Determines whether a rollback is required.

On noncheckpoint devices, returns `false`. On checkpoint devices, returns `true`
during a noncheckpoint boot.

## Implementing UDC

### Reference implementation

For an example of how UDC can be implemented, see
[dm-bow.c](https://android.googlesource.com/kernel/common/+/refs/heads/android-4.19/drivers/md/dm-bow.c){: .external}.
For additional documentation on the feature, see
[dm-bow.txt](https://android.googlesource.com/kernel/common/+/refs/heads/android-4.19/Documentation/device-mapper/dm-bow.txt){: .external}.

### Setup

In `on fs` in your `init.hardware.rc` file, make sure you have:

<pre class="prettyprint">
mount_all /vendor/etc/fstab.${ro.boot.hardware.platform} <strong>--early</strong>
</pre>

In `on late-fs` in your `init.hardware.rc` file, make sure you have:

<pre class="prettyprint">
mount_all /vendor/etc/fstab.${ro.boot.hardware.platform} <strong>--late</strong>
</pre>

In your `fstab.hardware` file, make sure `/data` is tagged as `latemount`.

<pre class="prettyprint">
/dev/block/bootdevice/by-name/userdata              /data              f2fs
noatime,nosuid,nodev,discard,reserve_root=32768,resgid=1065,fsync_mode=nobarrier
latemount,wait,check,fileencryption=ice,keydirectory=/metadata/vold/metadata_encryption,quota,formattable,sysfs_path=/sys/devices/platform/soc/1d84000.ufshc,reservedsize=128M,checkpoint=fs
</pre>

### Adding metadata partition

UDC requires a metadata partition to store the nonbootloader retry count and
keys. Set up a metadata partition and early mount it at `/metadata`.

In your `fstab.hardware` file, make sure `/metadata` is tagged as `earlymount`
or `first_stage_mount`.

<pre class="prettyprint">
/dev/block/by-name/metadata           /metadata           ext4
noatime,nosuid,nodev,discard,sync
wait,formattable,first_stage_mount
</pre>

Initialize the partition to all zeroes.

Add the following lines to `BoardConfig.mk`:

<pre class="prettyprint">
BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS := <var>existing_folders</var> metadata
</pre>

### Updating systems

#### F2FS systems
For systems that use F2FS to format data, make sure that your version of F2FS
supports checkpoints. For more information, see [Checkpoint functionality in
different file systems](#f2fscheckpoint).

Add the `checkpoint=fs` flag to the `<fs_mgr_flags>` section of fstab for the
device mounted at `/data`.

#### Non-F2FS systems

For non-F2FS systems, `dm-bow` must be enabled in the kernel config.

Add the `checkpoint=block` flag to the `<fs_mgr_flags>` section of fstab for the
device mounted at `/data`.

### Checking logs

Log entries are generated when Checkpoint APIs are called.

## Validation

To test your UDC implementation, run the `VtsKernelCheckpointTest` set of VTS
tests.
