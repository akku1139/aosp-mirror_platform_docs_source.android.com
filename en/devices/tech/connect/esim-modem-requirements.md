Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

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

### Handling the default boot profile correctly

When there is no operational or test profile enabled on eSIM, the default boot
profile is enabled. The modem recognizes the eSIM with the default boot
profile enabled as a valid SIM, reports the card as valid to upper layers,
and doesn't turn off the SIM power.

### Sending terminal capabilities correctly

On power-up, the modem sends correct terminal capabilities to the eSIM. The
terminal capability encodes support for eUICC capabilities *Local Profile
Management* and *Profile Download*.

See
[ETSI TS 102 221 Section 11.1.19.2.4](https://www.etsi.org/deliver/etsi_ts/102200_102299/102221/15.00.00_60/ts_102221v150000p.pdf){:.external}:
“Additional Terminal capability indications related to eUICC". Bytes [1-3] shall
be: ‘83 (Tag) ‘01’ (Length) ‘07’ (eUICC capabilities).

### (Optional) Supporting eSIM OS OTA updates

Note: As eSIM OS over-the-air (OTA) updates aren't standardized, this depends
on the vendor providing the eSIM OS.

The modem supports all requirements for eSIM OS OTA updates, for example,
switching to passthrough mode and keeping the eSIM powered on during the OTA
update procedure.

## HAL requirements

These are API implementations that are required for general eSIM support.

### Implementing setSimPower in Radio HAL v1.1

The modem supports the
[setSimPower](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.1/IRadio.hal#72){:.external}
method.

### Implementing getSimSlotsStatus in IRadioConfig HAL v1.2

Note: Support for IRadioConfig HAL v1.2 is required for devices launching
with Android {{ androidQVersionNumber }} and is recommended for all other
Android versions.

The modem supports the
[getSimSlotsStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/config/1.0/IRadioConfig.hal#51){: .external}
method, which indicates whether a slot contains an eSIM.

This method was introduced in v1.0. In v1.2,
[SimSlotStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/config/1.2/types.hal#22){: .external}
includes
[EID](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/config/1.2/types.hal#31){: .external}.

### Implementing getIccCardStatus in IRadio HAL v1.4

Note: Support for IRadio HAL v1.4 is required for devices launching with Android
{{ androidQVersionNumber }} and is recommended for all other Android
versions.

The modem provides the answer to reset (ATR) and slot ID of the card status
in the
[getIccCardStatusResponse](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.0/IRadioResponse.hal#38){:.external}
method. This method was introduced in v1.0 and, in v1.2,
[CardStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.2/types.hal#343){: .external}
was changed to include
[ATR](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.2/types.hal#353){: .external}.
In v1.4,
[CardStatus](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.4/types.hal#1669){: .external}
includes
[EID](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.4/types.hal?#1678){: .external}.

### Setting CardState:RESTRICTED on SIM lock (subsidy lock)

If the eSIM is SIM locked (subsidy locked), the modem sets the card state as
[`CardState:RESTRICTED`](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.0/types.hal#168){:.external}
in the
[getIccCardStatusResponse](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/1.0/IRadioResponse.hal#38){:.external}
method.

### (Optional) Implementing setSimSlotsMapping in IRadioConfig HAL v1.0

Note: Only required in device configurations that require slot switching, for
example, where the device has one eSIM slot and one physical/removable SIM
(pSIM) slot, and only one can be active at the same time.

The modem supports the
[setSimSlotsMapping](https://android.googlesource.com/platform/hardware/interfaces/+/master/radio/config/1.0/IRadioConfig.hal#81){: .external}
method,
which sets the mapping from physical slots to logical slots. The LPA uses this
method to select the active SIM slot.

## Logging requirements

These are general modem logging requirements for debugging eSIM issues.

### Log capture

Logging captures interprocessor communication, SIM functionality, radio
interface layer (RIL) logging, and application protocol data unit (APDU)
logging.

### On-device logging

Device software supports an on-device modem log capturing mechanism.

### Log config support

Device software supports different modem logging configurations (level,
modules). These configurations must be supported for both on-device logging and
PC-tool-based logging.

### Android bug report

Bug reports contains modem logs, vendor RIL logs, panic signature logs, and
Android logs.
