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

# Moving Fastboot to User Space

Android {{ androidQVersionNumber }} adds support for resizable partitions by
relocating the fastboot implementation from bootloader to user space. This
relocation enables moving the flashing code into a maintainable and testable
common location with only the vendor-specific parts of fastboot implemented by a
Hardware Abstraction Layer (HAL).

## Unified fastboot and recovery

Because userspace fastboot and recovery are similar, you can merge them
into one partition/binary. Advantages include less space use and fewer
partitions overall, as well as the ability for fastboot and recovery to share
their kernel and libraries.

To support `fastbootd`, the bootloader must implement a new boot control block
(BCB) command of `boot-fastboot`. To enter `fastbootd` mode, bootloader should
write `boot-fastboot` into the command field of the BCB message and leave the
`recovery` field of BCB unchanged (to enable restart of interrupted recovery
tasks). The `status`, `stage`, and `reserved` fields remain unchanged as well.
The bootloader is expected to load and boot into the recovery image upon seeing
`boot-fastboot` in the BCB command. Recovery then parses the BCB message and
switches to `fastbootd` mode.

### New `adb` commands

This section describes the additional `adb` command necessary to integrate
`fastbootd`. The command has differing behavior depending on whether system or
recovery executes the command.

<table class="responsive">
<thead>
<tr>
<th>Command</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>reboot fastboot</code>
</td>
<td>
<ul><li>Reboots into <code>fastbootd</code> (system).</li>
<li>Enters <code>fastbootd</code> directly without a reboot (recovery).</li>
</ul>
</td>
</tr>
</tbody>
</table>

### New fastboot commands

This section describes the additional fastboot commands necessary to integrate
`fastbootd`, including new commands for flashing and managing logical partitions.
Some commands have differing behavior depending on whether bootloader or
`fastbootd` executes the command.

<table class="responsive">
<thead>
<tr>
<th>Command</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>reboot recovery</code>
</td>
<td>
<ul><li>Reboots into recovery (bootloader).</li>
<li>Enters recovery directly without a reboot (<code>fastbootd</code>).</li>
</ul>
</td>
</tr>
<tr>
<td><code>reboot fastboot</code>
</td>
<td>Reboots into <code>fastbootd</code>.</td>
</tr>
<tr>
<td><code>getvar is-userspace</code>
</td>
<td>
<ul><li>Returns `yes` (<code>fastbootd</code>).</li>
<li>Returns `no` (bootloader).</li>
</ul>
</td>
</tr>
<tr>
<td><code>getvar is-logical:&lt;partition&gt;</code>
</td>
<td>Returns `yes` if the given partition is a logical partition,
`no` otherwise. Logical partitions support all of the commands listed below.</td>
</tr>
<tr>
<td><code>getvar super-partition-name</code>
</td>
<td>Returns the name of the super partition. The name includes the current slot
suffix if the super partition is an A/B partition (it is usually not).</td>
</tr>
<tr>
<td><code>create-logical-partition &lt;partition&gt; &lt;size&gt;</code>
</td>
<td>Creates a logical partition with the given name and size. The name must not
already exist as a logical partition.</td>
</tr>
<tr>
<td><code>delete-logical-partition &lt;partition&gt;</code>
</td>
<td>Deletes the given logical partition (effectively wiping the partition).</td>
</tr>
<tr>
<td><code>resize-logical-partition &lt;partition&gt; &lt;size&gt;</code>
</td>
<td>Resizes the logical partition to the new size without changing its contents.
Fails if not enough space is available to perform the resize.</td>
</tr>
<tr>
<td><code>update-super &lt;partition&gt;</code>
</td>
<td>Merges changes to the super partition metadata. If a merge isn't possible
(for example, the format on the device is an unsupported version), then this
command fails. An optional "wipe" parameter overwrites the device's
metadata rather than performing a merge. </td>
</tr>
</tbody>
</table>

`fastbootd` continues to support the following pre-existing fastboot commands.

<table class="responsive">
<thead>
<tr>
<th>Command</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>flash &lt;partition&gt; [&nbsp;&lt;filename&gt;&nbsp;]</code>
</td>
<td>Writes a file to a flash partition. Device must be in unlocked state.</td>
</tr>
<tr>
<td><code>erase &lt;partition&gt;</code>
</td>
<td>Erases a partition (not required to be secure erase). Device must be in
unlocked state.</td>
</tr>
<tr>
<td><code>getvar &lt;variable&gt; | all</code>
</td>
<td>Displays a bootloader variable, or all variables. If the variable doesn't
exist, returns an error.</td>
</tr>
<tr>
<td><code>set_active &lt;slot&gt;</code>
</td>
<td><p>Sets the given A/B booting slot as <strong>active</strong>. On the next
boot attempt, the system boots from the specified slot.</p>
<p>For A/B support, slots are duplicated sets of partitions that can be booted
from independently. Slots are named <strong>a</strong>, <strong>b</strong>, etc.
and differentiated by adding the suffixes <strong>_a</strong>,
<strong>_b</strong>, etc. to the partition name.</p></td>
</tr>
<tr>
<td><code>reboot</code>
</td>
<td>Reboots device normally.</td>
</tr>
<tr>
<td><code>reboot-bootloader</code> (or <code>reboot bootloader</code>)</td>
<td>Reboots device into bootloader.</td>
</tr>
</tbody>
</table>

## Modifications to the bootloader

Bootloader continues to support flashing the bootloader, radio, and 
boot/recovery partition, after which the device boots into fastboot (user space)
and flashes all other partitions. Bootloader is expected to support the
following commands.

<table class="responsive">
<thead>
<tr>
<th>Command</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>download</code>
</td>
<td>Downloads the image to flash.</td>
</tr>
<tr>
<td><code>flash recovery &lt;image&gt;/ flash boot &lt;image&gt;/ flash
bootloader &lt;image&gt;/</code>
</td>
<td>Flashes recovery/boot partition and bootloader.</td>
</tr>
<tr>
<td><code>reboot</code>
</td>
<td>Reboots the device.</td>
</tr>
<tr>
<td><code>reboot fastboot</code>
</td>
<td>Reboots to fastboot.</td>
</tr>
<tr>
<td><code>reboot recovery</code>
</td>
<td>Reboots to recovery.</td>
</tr>
<tr>
<td><code>getvar</code>
</td>
<td>Gets a bootloader variable that is required for flashing of recovery/boot
image (for example, <code>current-slot</code> and <code>max-download-size</code>).</td>
</tr>
<tr>
<td><code>oem <command></code>
</td>
<td>Command defined by OEM.</td>
</tr>
</tbody>
</table>

Bootloader **must not** allow the flashing of dynamic partitions and **must**
return an error that `Partition should be flashed in fastbootd`. For retrofitted
dynamic partition devices, the fastboot tool supports a force mode to directly
flash a dynamic partition while in bootloader mode. Bootloaders can
support this operation. For example, if `system` is a dynamic partition on the
retrofitted device, `fastboot --force flash system` allows the bootloader to
flash the partition instead of `fastbootd`. This force mode is intended to
provide flexibility in factory flashing and isn't recommended for developers.

## Fastboot OEM HAL

To completely replace bootloader fastboot, fastboot must handle all existing
fastboot commands. Many of these commands are from OEMs and are documented but
require a custom implementation (many commands are also OEM-specific and not
documented). To handle such commands, the fastboot HAL specifies the required
OEM commands and allows OEMs to implement their own commands.

The definition of fastboot HAL is as follows:

```
import IFastbootLogger;

/**
 * IFastboot interface implements vendor specific fastboot commands.
 */
interface IFastboot {
    /**
     * Returns a bool indicating whether the bootloader is enforcing verified
     * boot.
     *
     * @return verifiedBootState True if the bootloader is enforcing verified
     * boot and False otherwise.
     */
    isVerifiedBootEnabled() generates (bool verifiedBootState);

    /**
     * Returns a bool indicating the off-mode-charge setting. If off-mode
     * charging is enabled, the device autoboots into a special mode when
     * power is applied.
     *
     * @return offModeChargeState True if the setting is enabled and False if
     * not.
     */
    isOffModeChargeEnabled() generates (bool offModeChargeState);

    /**
     * Returns the minimum battery voltage required for flashing in mV.
     *
     * @return batteryVoltage Minimum battery voltage (in mV) required for
     * flashing to be successful.
     */
    getBatteryVoltageFlashingThreshold() generates (int32_t batteryVoltage);

    /**
     * Returns the file system type of the partition. This is only required for
     * physical partitions that need to be wiped and reformatted.
     *
     * @return type Can be ext4, f2fs or raw.
     * @return result SUCCESS if the operation is successful,
     * FAILURE_UNKNOWN if the partition is invalid or does not require
     * reformatting.
     */
    getPartitionType(string partitionName) generates (FileSystemType type, Result result);

    /**
     * Executes a fastboot OEM command.
     *
     * @param oemCmdArgs The oem command that is passed to the fastboot HAL.
     * @response result Returns the status SUCCESS if the operation is
     * successful,
     * INVALID_ARGUMENT for bad arguments,
     * FAILURE_UNKNOWN for an invalid/unsupported command.
     */
    doOemCommand(string oemCmd) generates (Result result);

};
```

## Enabling fastbootd

To enable `fastbootd` on a device:

1.  Add `fastbootd` to `PRODUCT_PACKAGES` in `device.mk`: `PRODUCT_PACKAGES +=
    fastbootd`.

1.  Ensure the fastboot HAL, boot control HAL, and health HAL are packaged as
    part of the recovery image.

1.  Add any device-specific sepolicy permissions required by `fastbootd`. For
    example, `fastbootd` requires write access to a device-specific partition to
    flash that partition. In addition, fastboot HAL implementation may also
    require device-specific permissions.

## Validating user space fastboot

The [Vendor Test Suite (VTS)](/compatibility/vts) includes tests for validating user space fastboot.
