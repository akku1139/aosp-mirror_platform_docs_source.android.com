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

# Tethering Hardware Offload

Tethering offload enables devices to save power and improve performance by
offloading the tethering traffic (over USB, Wi-Fi) to the hardware. The
tethering traffic is offloaded by providing a direct path between the modem and
the peripherals, bypassing the application processor.

## Specifications

Starting in Android 8.1, devices can use tethering offload to
offload IPv4, IPv6, or IPv4+IPv6 forwarding to the hardware.

The offload feature does not need to offload all packets. The framework is
capable of handling any packet in software. Control packets are typically
processed in software. Because IPv4 ports are shared between tethered traffic
and device traffic, IPv4 session setup/teardown packets (e.g., SYN/SYN+ACK, FIN)
must be processed in software so the kernel can construct the flow state.
The framework provides the control plane and state machines. It also provides
the hardware with information on upstream and downstream interfaces/prefixes.

For IPv4, the hardware allows IPv4 network address translation (NAT) session
setup packets to reach the CPU. The kernel creates NAT entries, and the HAL
implementation observes the entries from the framework-provided file descriptors
and handles these flows in hardware. This means the HAL implementation does not
require `CAP_NET_*` because the HAL gets opened `NF_NETLINK_CONNTRACK` sockets
from the framework. Periodically, the hardware sends NAT state updates for
currently active flows to the framework, which refreshes the corresponding
kernel connection tracking state entries.

For IPv6, the framework programs a list of IPv6 destination prefixes to which
traffic must not be offloaded. All other tethered packets can be offloaded.

For data usage accounting, `NetworkStatsService` data usage polls causes the
framework to request traffic stats from hardware. The framework also
communicates data usage limits to the hardware via the HAL.

## Hardware requirements

To implement tethering offload, your hardware must be capable of forwarding IP
packets between the modem and Wi-Fi/USB without sending the traffic through the
main processor.

## Implementation

To enable the tethering offload feature, you must implement the two following
both a config HAL (`IOffloadConfig`) and a control HAL (`IOffloadControl`).

### Config HAL: `IOffloadConfig`

The
[`IOffloadConfig`](/reference/hidl/android/hardware/tetheroffload/config/1.0/IOffloadConfig)
HAL starts the tethering offload implementation. The framework provides the HAL
implementation with pre-connected `NF_NETLINK_CONNTRACK` sockets that the
implementation can use to observe the IPv4 flows. Only forwarded flows must be
accelerated.

### Control HAL: `IOffloadControl`

The
[`IOffloadControl`](/reference/hidl/android/hardware/tetheroffload/control/1.0/IOffloadControl)
HAL controls the offload implementation. The following methods must be
implemented:

+   Start/stop offload hardware: Use `initOffload/stopOffload` and exempt local
    IP addresses or other networks from offload with `setLocalPrefixes`.
+   Set upstream interface, IPv4 address, and IPv6 gateways: Use
    `setUpstreamParameters` and configure downstream IP address ranges with
    `addDownstream/removeDownstream`.
+   Data usage accounting: Use `getForwardedStats/setDataLimit`.

Your vendor HAL must also send callbacks via the `ITetheringOffloadCallback`
interface, which informs the framework of:

+   Asynchronous events such as offload being started and stopped
    (OffloadCallbackEvent)
+   NAT timeout updates, which must be sent periodically to indicate that a
    specific IPv4 flow contains traffic and must not be closed by the kernel

## Validation

To validate your implementation of tethering offload, use manual or automated
testing to verify tethering and Wi-Fi hotspot work as expected. The
[Vendor Test Suite (VTS)](/compatibility/vts/)
contains tests for the tethering offload HALs.
