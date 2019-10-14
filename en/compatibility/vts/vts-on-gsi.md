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

# VTS Testing with Debug Ramdisk

In Android {{ androidQVersionNumber }}, the
[generic system image](https://source.android.com/setup/build/gsi) (GSI) used to
run [CTS-on-GSI/VTS](https://source.android.com/compatibility/vts/codelab-video)
compliance testing changes from userdebug to user build type, because GSI is
release signed. However, the
<code>[adb root](https://developer.android.com/studio/command-line/adb)</code>
command that gives a host root permissions to the Android device under test
isn't available in a user build. This is a problem because VTS requires
`adb root` to run.

The debug ramdisk is introduced in Android {{ androidQVersionNumber }} to make
`adb root` possible, if the device is unlocked. This simplifies the testing flow
by reusing the same user build GSI `system.img`. For STS setup, using another
userdebug OEM `system.img` is still required. The following table shows images
and build types for the compliance tests in Android {{ androidQVersionNumber }}.

<table>
  <tr>
   <th>Test suite</th>
   <th>Test with</td>
   <th>Build</td>
   <th>Debug ramdisk</td>
   <th>adb root?</td>
   <th>Android {{ androidPVersionNumber }} -> {{ androidQVersionNumber }} build variant change</td>
  </tr>
  <tr>
   <td><strong>CTS</strong></td>
   <td>OEM’s system</td>
   <td>user</td>
   <td>N</td>
   <td>N</td>
   <td>No change</td>
  </tr>
  <tr>
   <td><strong>CTS-on-GSI</strong></td>
   <td>GSI</td>
   <td>user</td>
   <td>N</td>
   <td>N</td>
   <td><p>userdebug -> user GSI</p><p>release signed</p></td>
  </tr>
  <tr>
   <td><strong>STS</strong></td>
   <td>OEM’s system</td>
   <td>userdebug</td>
   <td>N</td>
   <td>Y</td>
   <td>New in Q</td>
  </tr>
  <tr>
   <td><strong>VTS</strong></td>
   <td>GSI</td>
   <td>user</td>
   <td>Y</td>
   <td>Y</td>
   <td><p>userdebug -> user GSI</p><p>release signed</p>
   </td>
  </tr>
</table>

## Prerequisites for using a debug ramdisk

The debug ramdisk is provided by the OEM running the compliance tests. It
shouldn't be release signed, and it can only be used if the device is
[unlocked](https://source.android.com/security/verifiedboot/device-state).

The debug ramdisk won't be generated or used for upgrading devices with:

*   `BOARD_BUILD_SYSTEM_ROOT_IMAGE` true
*   `skip_initramfs` in kernel command line

Note: All new devices launched in Android
{{ androidQVersionNumber }} and higher must have ramdisk to support
[Dynamic Partitions](https://source.android.com/devices/tech/ota/dynamic_partitions).

## AOSP changes

The debug ramdisk changes in
[AOSP](https://android-review.googlesource.com/dashboard/self) are identified by
the
[`debug_ramdisk`](https://android-review.googlesource.com/q/hashtag:debug_ramdisk)
hashtag.

These additional image files are generated under the build folder
`out/target/product/$(TARGET_DEVICE)`:

*   `ramdisk-debug.img`
*   `boot-debug.img`

When `boot-debug.img` is flashed onto the `/boot` partition of the device, the
userdebug version of the system sepolicy file and an additional property file,
`adb_debug.prop`, are loaded. This allows `adb root` with the user build
`system.img` (either GSI’s or the OEM’s).
