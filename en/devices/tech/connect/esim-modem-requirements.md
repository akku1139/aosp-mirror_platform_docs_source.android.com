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

# Modem Requirements for eSIM Support

This page summarizes the required modem features for supporting an eSIM chip or
removable eSIM 4FF card.

## General requirements

These are the modem requirements for general eSIM support. The LPA needs the
modem to support all of these requirements to function properly.

### Handle the default boot profile correctly

When there is no operational or test profile enabled on eSIM, the default boot
profile is enabled. The modem shall recognize the eSIM with the default boot
profile enabled as a valid SIM. The modem shall report card as valid to upper
layers and shall not turn off the SIM power.

### Send terminal capabilities correctly

When opening a logical channel to ISD-R, the modem shall send correct terminal
capabilities to the eSIM. The terminal capability must encode support for eUICC
capabilities: "Local Profile Management" and "Profile Download" per ETSI TS 102
221.

### Implement setSimPower API in Radio HAL v1.1

The modem shall support the
[setSimPower](/reference/hidl/android/hardware/radio/1.1/IRadio#setsimcardpower_1_1)
API.

### Implement getSimSlotsStatus API in IRadioConfig HAL v1.0

The modem shall support the
[getSimSlotsStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/config/1.0/IRadioConfig.hal#51){: .external}
API, which indicates whether a slot contains an eSIM.

### Implement getIccCardStatus API in IRadio HAL v1.2

The modem shall provide the ATR and slot ID of the card status as specified in
the
[getIccCardStatus](/reference/hidl/android/hardware/radio/1.0/IRadio#getIccCardStatus)
API. This API was first introduced in v1.0 and, in v1.2,
[CardStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.2/types.hal#341){: .external}
was changed to include
[ATR](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.2/types.hal#351){: .external}.

### (Optional) Support eSIM OS OTA

As the eSIM OS OTA is not standardized, this depends on the vendor providing
eSIM OS. The modem shall support all requirements for eSIM OS OTA, for example
switching to passthrough mode and keeping the eSIM powered on during the OTA
procedure.

## Logging requirements

These are general modem logging requirements to properly debug eSIM issues.

### Provide PC based tools to capture detailed modem logs

Logging shall capture all the OTA packets for Cellular RATs (4G, 3G, 2G) and IMS
(SIP, RTP, RTCP, XCAP). ESP protected SIP packets shall be logged without ESP.
OTA parser shall be compliant to 3GPP specs.

Logging shall support capture IP packets on all network interfaces.

Logging shall support capturing debug logs and protocol layer information
including protocol layer states, radio power measurements, network cell
information, packet TX/RX statistics, inter-layer messaging, inter-processor
communication, SIM functionality & APDU logging, and RIL logging.

### On-device logging

Device software shall support an on-device modem log capturing mechanism.

### Log config support

Device software shall support different modem logging configurations (level,
modules). These configurations shall be supported for both on-device logging and
PC-tool-based logging.

### Android bug report

Bug reports shall contain modem logs, vendor RIL logs, panic signature logs, and
Android logs.
