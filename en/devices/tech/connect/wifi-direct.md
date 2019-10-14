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

# Wi-Fi Direct

The
[Wi-Fi Direct](https://developer.android.com/guide/topics/connectivity/wifip2p.html){: .external}
feature, also known as Wi-Fi P2P, allows supporting devices to discover and connect
to one another directly
using the Wi-Fi Direct protocol without internet or cellular network access. This
feature, built upon the [Wi-Fi Alliance](https://www.wi-fi.org/){: .external}
(WFA)
[Wi-Fi Direct specification](https://www.wi-fi.org/wi-fi-direct){: .external}
allows sharing of high-throughput data among
trusted devices and apps that are otherwise off-network.

## Examples and source

To use this feature, device manufacturers must implement the Wi-Fi
[Hardware Interface Design Language (HIDL)](/devices/architecture/hidl) provided
in the Android Open Source Project (AOSP). HIDL replaces the previous
[Hardware Abstraction Layer (HAL)](/devices/architecture/hal) structure used to
streamline implementations by specifying types and method calls collected into
interfaces and packages.

The following Wi-Fi HAL surfaces are required to employ the Wi-Fi Direct feature:
+ `hardware/interfaces/wifi/1.3` or higher
+ `hardware/interfaces/wifi/supplicant/1.2` or higher

## Implementation

Device manufacturers need to provide both framework and HAL/firmware support:

+   Framework:
    +   AOSP code
    +   Enable Wi-Fi Direct: Requires a feature flag
+   Wi-Fi Direct (P2P) HAL support (which implies firmware support)

To implement this feature, device manufacturers implement the Wi-Fi HIDL and
enable the feature flag for Wi-Fi Direct. In `device.mk` located in
`device/<oem>/<device>`, modify the `PRODUCT_COPY_FILES` environment variable
to include support for the Wi-Fi Direct feature:

    ```
    PRODUCT_COPY_FILES +=
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml
    ```

All other requirements for supporting Wi-FI Direct are included in AOSP.

## MAC randomization

Android requires that the Wi-Fi Direct *device address* and *interface
address* are randomized. They must be different from the true MAC address of
the device and must meet the following requirements:

+ The Wi-Fi Direct device address must be randomized on interface creation if there
  is no persistent group saved; otherwise the device address must keep using the last
  generated MAC address.
+ The Wi-Fi Direct interface address, also known as group address, must be randomized every time a connection is established.

Wi-Fi Direct MAC randomization is implementation in the 'wpa_supplicant' and controlled
by two configurations, `p2p_device_random_mac_addr` and
`p2p_interface_random_mac_addr`.

To enable this feature, device manufacturers must:
+ Implement the Wi-Hi Supplicant
HIDL API `ISupplicantP2pIface::setMacRandomization` in
`hardware/interface/wifi/supplicant/1.2`.

+ Set
`config_wifi_p2p_mac_randomization_supported` to 'true' in a device custom
overlay.

## Validation

Android provides a set of unit tests, integration tests (Android Connectivity
Test Suite, or ACTS),
[Compatibility Test Suite (CTS)](/compatibility/cts) tests, and
[CTS Verifier](/compatibility/cts/verifier) tests to validate the Wi-Fi Direct
feature. Wi-Fi Direct can also be tested using the
[Vendor Test Suite (VTS)](/compatibility/vts).

### Unit tests

Verify the Wi-Fi Direct package using the following tests.

Service tests:

```
% ./frameworks/opt/net/wifi/tests/wifitests/runtests.sh -e package
com.android.server.wifi.p2p
```

Manager tests:

```
% ./frameworks/base/wifi/tests/runtests.sh -e package android.net.wifi.p2p
```

### Integration tests (ACTS)

The ACTS Wi-FI Direct test suite, located in
`tools/test/connectivity/acts/tests/google/wifi/p2p`, implements
functional tests of Wi-Fi Direct.

### Compatibility Test Suite (CTS) tests

Use CTS tests to validate the Wi-Fi Direct feature. CTS detects when the feature
is enabled and automatically includes the associated tests.

To trigger the CTS tests, run:

```
% atest android.net.wifi.p2p.cts
```

### CTS Verifier tests

CTS Verifier tests validate Wi-Fi Direct behavior using two devices: a test
device and a *known good* device. To run the tests, open CTS Verifier and
navigate to the section titled Wi-Fi Direct Tests.
