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

These are the modem requirements for general eSIM support. The Local Profile
Assistant (LPA) needs the modem to support all of these requirements to function
properly.

### Handle the default boot profile correctly

When there is no operational or test profile enabled on eSIM, the default boot
profile is enabled. The modem shall recognize the eSIM with the default boot
profile enabled as a valid SIM, shall report the card as valid to upper layers,
and shall not turn off the SIM power.

### Send terminal capabilities correctly

On power-up, the modem shall send correct terminal capabilities to the eSIM. The
terminal capability shall encode support for eUICC capabilities: "Local Profile
Management" and "Profile Download".

See
[ETSI TS 102 221 Section 11.1.19.2.4](https://www.etsi.org/deliver/etsi_ts/102200_102299/102221/15.00.00_60/ts_102221v150000p.pdf):
“Additional Terminal capability indications related to eUICC". Bytes [1-3] shall
be: ‘83 (Tag) ‘01’ (Length) ‘07’ (eUICC capabilities).

### (Optional) Support eSIM OS OTA updates

Note: As eSIM OS over-the-air (OTA) updates are not standardized, this depends
on the vendor providing the eSIM OS.

The modem shall support all requirements for eSIM OS OTA updates, for example
switching to passthrough mode and keeping the eSIM powered on during the OTA
update procedure.

## HAL requirements

These are API implementations that are required for general eSIM support.

### Implement setSimPower API in Radio HAL v1.1

The modem shall support the
[setSimPower](/reference/hidl/android/hardware/radio/1.1/IRadio#setsimcardpower_1_1)
API.

### Implement getSimSlotsStatus API in IRadioConfig HAL v1.0

The modem shall support the
[getSimSlotsStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/config/1.0/IRadioConfig.hal#51){: .external}
API, which indicates whether a slot contains an eSIM.

### Implement getIccCardStatus API in IRadio HAL v1.2

The modem shall provide the Answer To Reset (ATR) and slot ID of the card status
in the
[getIccCardStatusResponse](https://source.android.com/reference/hidl/android/hardware/radio/1.0/IRadioResponse#geticccardstatusresponse)
API. This API was introduced in v1.0 and, in v1.2,
[CardStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.2/types.hal#341){: .external}
was changed to include
[ATR](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.2/types.hal#351){: .external}.

### Set CardState:RESTRICTED on SIM lock (subsidy lock)

If the eSIM is SIM locked (subsidy locked), the modem shall set card state as
[`CardState:RESTRICTED`](https://source.android.com/reference/hidl/android/hardware/radio/1.0/types#cardstate)
in the
[getIccCardStatusResponse](https://source.android.com/reference/hidl/android/hardware/radio/1.0/IRadioResponse#geticccardstatusresponse)
API.

### (Optional) Implement setSimSlotsMapping API in IRadioConfig HAL v1.0

Note: Only required in device configurations that require slot switching, for
example, where the device has one eSIM slot and one physical/removable SIM
(pSIM) slot, and only one can be active at the same time.

The modem shall support the
[setSimSlotsMapping API](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/config/1.0/IRadioConfig.hal#81){: .external},
which sets the mapping from physical slots to logical slots. The LPA uses this
API to select the active SIM slot.

## Logging requirements

These are general modem logging requirements for debugging eSIM issues.

### Log capture

Logging shall capture inter-processor communication, SIM functionality, Radio
Interface Layer (RIL) logging, and application protocol data unit (APDU)
logging.

### On-device logging

Device software shall support an on-device modem log capturing mechanism.

### Log config support

Device software shall support different modem logging configurations (level,
modules). These configurations shall be supported for both on-device logging and
PC-tool-based logging.

### Android bug report

Bug reports shall contain modem logs, vendor RIL logs, panic signature logs, and
Android logs.
