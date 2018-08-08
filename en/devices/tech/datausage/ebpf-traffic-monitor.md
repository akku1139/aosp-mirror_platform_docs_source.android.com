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

# eBPF Traffic Monitoring

## Introduction {:#introduction}

The eBPF network traffic tool uses a combination of kernel and user space
implementation to monitor network usage on the device since the last device
boot. It provides additional functionality such as socket tagging, separating
foreground/background traffic and per-UID firewall to block apps from network
access depending on phone state. The statistics gathered from the tool are
stored in a kernel data structure called `eBPF maps` and the result is used by
services like `NetworkStatsService` to provide persistent traffic statistics
since the last boot.

## Examples and source {:#examples-and-source}

The userspace changes are mainly in the `system/netd` and `framework/base`
projects. Development is being done in AOSP, so AOSP code will always be up to
date. The source is mainly located at
[`system/netd/server/TrafficController*`](https://android.googlesource.com/platform/system/netd/+/master/server/TrafficController.cpp){: .external},
[`system/netd/bpfloader`](https://android.googlesource.com/platform/system/netd/+/master/bpfloader/){: .external}
and
[`system/netd/libbpf/`](https://android.googlesource.com/platform/system/netd/+/master/libbpf/){: .external}.
Some necessary framework changes are in `framework/base/` and `system/core` as
well.

## Implementation {:#implementation}

Starting with Android {{ androidPVersionNumber }}, Android devices running on
kernel 4.9 or above and originally shipped with the P release MUST use
eBPF-based network traffic monitoring accounting instead of `xt_qtaguid`. The
new infrastructure is more flexible and more maintainable and does not require
any out-of-tree kernel code.

The major design differences between legacy and eBPF traffic monitoring are
illustrated in Figure 1.

![Legacy and eBPF traffic monitoring design differences](/devices/images/ebpf-net-monitor.png)

**Figure 1.** Legacy (left) and eBPF (right) traffic monitoring design
differences

The new `trafficController` design is based on per-`cgroup` eBPF filter as well
as `xt_bpf` netfilter module inside the kernel. These eBPF filters are applied
on the packet tx/rx when they pass through the filter. The `cgroup` eBPF filter
is located at the transport layer and is responsible for counting the traffic
against the right UID depending on the socket UID as well as userspace setting.
The `xt_bpf` netfilter is hooked at the`bw_raw_PREROUTING` and
`bw_mangle_POSTROUTING` chain and is responsible for counting traffic against
the correct interface.

At boot time, the userspace process `trafficController` creates the eBPF maps
used for data collection and pins all maps as a virtual file at `sys/fs/bpf`.
Then the privileged process `bpfloader` loads the precompiled eBPF program into
the kernel and attaches it to the correct `cgroup`. There is a single root
`cgroup` for all traffic so all the process should be included in that `cgroup`
by default.

At run time, the `trafficController` can tag/untag a socket by writing to the
`traffic_cookie_tag_map` and `traffic_uid_counterSet_map`. The
`NetworkStatsService` can read the traffic stats data from
`traffic_tag_stats_map`, `traffic_uid_stats_map` and `traffic_iface_stats_map`.
Besides the traffic stats collection function, the `trafficController` and
`cgroup` eBPF filter are also responsible for blocking traffic from certain UIDs
depending on the phone settings. The UID-based networking traffic blocking
feature is a replacement of the `xt_owner` module inside the kernel and the
detail mode can be configured by writing to`traffic_powersave_uid_map`,
`traffic_standby_uid_map` and `traffic_dozable_uid_map`.

The new implementation follows the legacy `xt_qtaguid` module implementation so
`TrafficController` and `NetworkStatsService` will run with either the legacy or
new implementation. If the app uses public APIs, it should not experience any
difference whether `xt_qtaguid` or eBPF tools are used in the background.

If the device kernel is based on the Android common kernel 4.9 (SHA
39c856663dcc81739e52b02b77d6af259eb838f6 or above), then no modifications to
HALs, drivers, or kernel code are required to implement the new eBPF tool.

## Requirements {:#requirements}

1.  The kernel config MUST have these following configs turned on:

    1.  `CONFIG_CGROUP_BPF=y`
    1.  `CONFIG_BPF=y`
    1.  `CONFIG_BPF_SYSCALL=y`
    1.  `CONFIG_NETFILTER_XT_MATCH_BPF=y`

    The
    [VTS kernel config test](https://android.googlesource.com/platform/test/vts-testcase/kernel/+/master/config/VtsKernelConfigTest.py){: .external}
    is helpful when verifying the correct config is turned on.

1.  The device `MEM_LOCK` rlimit MUST be set to 8 MB or more.

## Legacy xt_qtaguid deprecation process {:#legacy-xt_qtaguid-deprecation-process}

The new eBPF tool is replacing the`xt_qtaguid` module and the `xt_owner` module
it is based on. We will start to remove the `xt_qtaguid` module from the Android
kernel and disable its unnecessary configs.

In the Android {{ androidPVersionNumber }} release, the `xt_qtaguid` module is
turned on in all devices, but all the public APIs that directly read the
`xt_qtaguid` module proc file are moved into the `NetworkManagement` Service.
Depending on the device kernel version and first API level, the
`NetworkManagement` Service knows whether eBPF tools is turned on and chooses
the right module to get for each app network usage stat. Apps with SDK level 28
and higher are blocked from accessing `xt_qtaguid` proc files by sepolicy.

In the next Android release after {{ androidPVersionNumber }}, app access to
those `xt_qtaguid` proc files will be completely blocked we will start to remove
the `xt_qtaguid` module from the new Android common kernels. After it is
removed, we will update the Android base config for that kernel version to
explicitly turn the `xt_qtaguid` module off. The `xt_qtaguid` module will be
completely deprecated when the minimum kernel version requirement for an Android
release is 4.9 or above.

In the Android {{ androidPVersionNumber }} release, only devices that launch
with the Android {{ androidPVersionNumber }} release are required to have the
new eBPF feature. For devices that shipped with a kernel that can support eBPF
tools, we recommend updating it to the new eBPF feature when upgrading to the
Android {{ androidPVersionNumber }} release. There is no CTS test to enforce
that update.

## Validation {:#validation}

You should regularly take patches from Android common kernels and Android AOSP
master. Ensure your implementation passes the applicable VTS and CTS tests, the
`netd_unit_test`, and the `libbpf_test`.

### Testing {:#testing}

There are
[kernel net_tests](https://android.googlesource.com/kernel/tests/+/master/net/test/bpf_test.py){: .external}
to ensure you have the required features turned on and required kernel patches
backported. The tests are integrated as part of Android {{ androidPVersionNumber }}
release VTS tests. There are some unit tests in `system/netd/`
([`netd_unit_test`](https://android.googlesource.com/platform/system/netd/+/master/server/TrafficControllerTest.cpp){: .external}
and
[`libbpf_test`](https://android.googlesource.com/platform/system/netd/+/master/libbpf/BpfNetworkStatsTest.cpp){: .external}).
There are some tests in `netd_integration_test` to validate the overall behavior
of the new tool.

#### CTS and CTS verifier {:#cts-and-cts-verifier}

Because both traffic monitoring modules are supported in the Android
{{ androidPVersionNumber }} release, there is no CTS test to force implementing the
new module on all devices. But for devices with kernel version higher then 4.9
that originally ship with the Android {{ androidPVersionNumber }} release (i.e.
the first API level >= 28), there are CTS tests on GSI to validate the new
module is correctly configured. Old CTS tests such as `TrafficStatsTest`,
`NetworkUsageStatsTest` and `CtsNativeNetTestCases` can be used to verify the
behavior to be consistent with old UID module.

#### Manual testing {:#manual-testing}

There are some unit tests in `system/netd/`
([`netd_unit_test`](https://android.googlesource.com/platform/system/netd/+/master/server/TrafficControllerTest.cpp){: .external},
[`netd_integration_test`](https://android.googlesource.com/platform/system/netd/+/master/tests/bpf_base_test.cpp){: .external}
and
[`libbpf_test`](https://android.googlesource.com/platform/system/netd/+/master/libbpf/BpfNetworkStatsTest.cpp){: .external}).
There is dumpsys support for manually checking the status. The command
**`dumpsys netd`** shows the basic status of the `trafficController` module and
whether eBPF is correctly turned on. If eBPF is turned on, the command
**`dumpsys netd trafficcontroller`** shows the detailed content of each eBPF
map, including tagged socket information, stats per tag, UID and iface, and
owner UID match.

### Test locations {:#test-locations}

CTS tests are located at:

*   [https://android.googlesource.com/platform/cts/+/master/tests/tests/net/src/android/net/cts/TrafficStatsTest.java](https://android.googlesource.com/platform/cts/+/master/tests/tests/net/src/android/net/cts/TrafficStatsTest.java)
    {: .external}
*   [https://android.googlesource.com/platform/cts/+/master/tests/tests/app.usage/src/android/app/usage/cts/NetworkUsageStatsTest.java](https://android.googlesource.com/platform/cts/+/master/tests/tests/app.usage/src/android/app/usage/cts/NetworkUsageStatsTest.java)
    {: .external}
*   [https://android.googlesource.com/platform/system/netd/+/master/tests/bpf_base_test.cpp](https://android.googlesource.com/platform/system/netd/+/master/tests/bpf_base_test.cpp)
    {: .external}

VTS tests are located at
[https://android.googlesource.com/kernel/tests/+/master/net/test/bpf_test.py](https://android.googlesource.com/kernel/tests/+/master/net/test/bpf_test.py){: .external}.

Unit tests are located at:

*   [https://android.googlesource.com/platform/system/netd/+/master/libbpf/BpfNetworkStatsTest.cpp](https://android.googlesource.com/platform/system/netd/+/master/libbpf/BpfNetworkStatsTest.cpp)
    {: .external}
*   [https://android.googlesource.com/platform/system/netd/+/master/server/TrafficControllerTest.cpp](https://android.googlesource.com/platform/system/netd/+/master/server/TrafficControllerTest.cpp)
    {: .external}
