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

# Emergency Numbers and Emergency Calling

Emergency calling is fundamental and critical for devices because they must work
for Android users while satisfying various carrier and regulatory requirements
all over the world. The Android framework provides users with a fast and safe
emergency calling experience.

Android {{ androidQVersionNumber }} provides improved support for emergency call
functions, maintenance, and updates in the local Android platform by using a
detailed emergency number list from the SIM, network, modem, and database.
Android {{ androidQVersionNumber }}
also supports emergency calling based on the type of emergency services such as
police, fire, or ambulance. Android {{ androidQVersionNumber }} provides
improved support for multi-SIM
devices by sharing emergency numbers from multiple subscriptions in
the TelephonyManager API.

In Android {{ androidQVersionNumber }} with Radio HAL 1.4, emergency calling is
improved by separating emergency calls from normal calls in the HAL interface
to optimize the emergency calling path and allowing devices to dial the
appropriate emergency number configured in the Android database.

## Implementation

To implement the emergency calling and emergency number functions, implement
the following
[`TelephonyManager`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/telephony/java/android/telephony/TelephonyManager.java){: .external}
and hardware interface APIs.

### TelephonyManager APIs

Implement the following APIs:

+   Implement
    [`getEmergencyNumberList`](https://developer.android.com/reference/android/telephony/TelephonyManager.html#getEmergencyNumberList()){: .external}
    to get valid emergency numbers for emergency calling based on the emergency
    number source including the locale, SIM cards, default, modem, Android
    database, and network. For each emergency
    number, specify the corresponding emergency service category such as
    police, ambulance, and fire.
+   Implement
    [`isEmergencyNumber`](https://developer.android.com/reference/android/telephony/TelephonyManager.html#isEmergencyNumber(java.lang.String)){: .external}
    to identify whether a phone number is an emergency number.
+   Implement
    [`isPotentialEmergencyNumber`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/telephony/java/android/telephony/TelephonyManager.java#10554){: .external}
    to identify a number as an emergency number if it has the same
    starting digits as any of the emergency numbers.

The values for emergency number sources are:

+   `EMERGENCY_NUMBER_SOURCE_NETWORK_SIGNALING`: Number is from the network
    signal
+   `EMERGENCY_NUMBER_SOURCE_SIM`: Number is from the SIM card
+   `EMERGENCY_NUMBER_SOURCE_DATABASE`: Number is from the platform-maintained
    database
+   `EMERGENCY_NUMBER_SOURCE_MODEM_CONFIG`: Number is from the modem configuration
+   `EMERGENCY_NUMBER_SOURCE_DEFAULT`: Number is available by default. The
    numbers 112 and 911 must always be available. 000, 08, 110, 999, 118,
    and 119 must be available when no SIM is present. For more details, see
    _Section 10: Emergency Calls_ in
    [3GPP TS 22.101](https://www.etsi.org/deliver/etsi_ts/122100_122199/122101/09.01.00_60/ts_122101v090100p.pdf){: .external}.

The values for emergency service categories are:

+   `UNSPECIFIED`: General emergency call, all categories
+   `POLICE`: Police
+   `AMBULANCE`: Ambulance
+   `FIRE_BRIGADE`: Fire brigade
+   `MARINE_GUARD`: Marine Guard
+   `MOUNTAIN_RESCUE`: Mountain Rescue
+   `MIEC`:  Manually Initiated eCall (MIeC)
+   `AIEC`: Automatically Initiated eCall (AIeC)

For more details, see _Section 10: Emergency Calls_ in
[3GPP TS 22.101](https://www.etsi.org/deliver/etsi_ts/122100_122199/122101/09.01.00_60/ts_122101v090100p.pdf){: .external}.

### Hardware interface APIs

Implement
[`emergencyDial`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/IRadio.hal#159){: .external}
in `IRadio.hal`. Implement
[`emergencyDialResponse`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/IRadioResponse.hal#55){: .external}
in `IRadioResponse.hal` to send a response with response type, serial number,
and error information.

To report the current list of emergency numbers, implement
[`currentEmergencyNumberList`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/IRadioIndication.hal#52){: .external}
in `IRadioIndication.hal`. Implement
[`EmergencyNumber`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/types.hal#99){: .external}
in `types.hal`, which contains information about the emergency number including
the number address, the mobile country code (MCC), mobile network code (MNC),
[emergency service category](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/types.hal#145){: .external},
emergency uniform resource name (URN), and
[emergency number source](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/types.hal#170){: .external}.

To indicate how an emergency call is handled, use
[`EmergencyCallRouting`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/types.hal#194){: .external}.
An emergency call can be requested using emergency routing or normal call
routing as required. If this is `UNKNOWN`, routing is decided based on the
implementation.

## Validation

To validate your implementation, run the following CTS and VTS tests.

### CTS tests

+   [`testGetEmergencyNumberList`](https://android.googlesource.com/platform/cts/+/refs/heads/master/tests/tests/telephony/current/src/android/telephony/cts/TelephonyManagerTest.java#1235){: .external}
+   [`testIsEmergencyNumber`](https://android.googlesource.com/platform/cts/+/refs/heads/master/tests/tests/telephony/current/src/android/telephony/cts/TelephonyManagerTest.java#1277){: .external}
+   [`testIsPotentialEmergencyNumber`](https://android.googlesource.com/platform/cts/+/refs/heads/master/tests/tests/telephony/current/src/android/telephony/cts/TelephonyManagerTest.java#1304){: .external}

### VTS tests

+   [`emergencyDial`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/vts/functional/radio_hidl_hal_api.cpp#24){: .external}
+   [`emergencyDial_withServices`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/vts/functional/radio_hidl_hal_api.cpp#49){: .external}
+   [`emergencyDial_withEmergencyRouting`](https://android.googlesource.com/platform/hardware/interfaces/+/refs/heads/master/radio/1.4/vts/functional/radio_hidl_hal_api.cpp#75){: .external}

## References

For additional information on related technical specifications and standards,
see:

+   [3GPP TS 22.101](https://www.etsi.org/deliver/etsi_ts/122100_122199/122101/09.01.00_60/ts_122101v090100p.pdf){: .external},
    _Section 10: Emergency Calls_
+   [3GPP TS 24.008](https://www.etsi.org/deliver/etsi_ts/124000_124099/124008/07.15.00_60/ts_124008v071500p.pdf){: .external},
    _Section 9.2.13.4: Emergency Number List_
+   [3GPP TS 23.167](https://www.etsi.org/deliver/etsi_ts/123100_123199/123167/15.04.00_60/ts_123167v150400p.pdf){: .external},
    _Section 6: Functional description_
+   [3GPP TS 24.503](https://www.etsi.org/deliver/etsi_ts/124500_124599/124503/08.22.00_60/ts_124503v082200p.pdf){: .external},
    _Section 5.1.6.8.1: General_
+   [RFC 5031](https://tools.ietf.org/html/rfc5031){: .external}: _A Uniform
    Resource Name (URN) for Emergency and Other Well-Known Services_
