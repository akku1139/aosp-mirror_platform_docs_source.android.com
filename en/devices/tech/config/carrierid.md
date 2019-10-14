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

# Carrier Identification

Devices running Android {{ androidPVersionNumber }} can recognize subscription
carrier information to
provide an ID and a carrier name. Android maintains a carrier ID database, with
matching rules for each carrier and its unique carrier ID. AOSP includes the
content of the carrier ID database, in the file
[`carrier_list.textpb`](https://android.googlesource.com/platform/packages/providers/TelephonyProvider/+/master/assets/carrier_list.textpb){: .external}.
The unified database minimizes duplicate logic in apps that need to identify
carriers and limits the exposure of carrier-identifying attributes.

To improve the coverage and accuracy of carrier identification, Android supports
out-of-band and carrier ID table updates. Each update comes with a version
number and is published to AOSP.

## Implementation

Users who want to implement out-of-band updates can download the
[`carrier_list.pb`](https://android.googlesource.com/platform/packages/providers/TelephonyProvider/+/master/assets/carrier_list.pb){: .external}
binary from AOSP. To view the readable format of the table, see
[`carrier_list.textpb`](https://android.googlesource.com/platform/packages/providers/TelephonyProvider/+/master/assets/carrier_list.textpb){: .external}.

Place the carrier ID table in the `/data/misc/carrierid/` data partition of the
device. If the carrier ID table is newer than the existing version, the device
persists the table to the
[carrier ID database class](https://developer.android.com/reference/android/provider/Telephony.CarrierId).
The most recent information from the carrier ID database is picked up by the
public methods
[`getSimCarrierId()`](https://developer.android.com/reference/android/telephony/TelephonyManager#getSimCarrierId()){: .external}
and
[`getSimCarrierIdName()`](https://developer.android.com/reference/android/telephony/TelephonyManager#getSimCarrierIdName()){: .external}.

## Adding carrier ID information to the database

To add or update a carrier ID to the database, submit a request using the
[Carrier identification information form](https://docs.google.com/forms/d/1KjwTaExKRjkE9tbR9yavBrGzwvuz1dNku2Ae_7GrdUQ/viewform?edit_requested=true){: .external}.

Your request is reviewed and if approved, the change is pushed to the AOSP code
base at
[`carrier_list.pb`](https://android.googlesource.com/platform/packages/providers/TelephonyProvider/+/master/assets/carrier_list.pb){: .external}.
You can then copy the updated list and incorporate it into your customized
build.

## Integrating carrier IDs with CarrierConfig

Starting from Android {{ androidQVersionNumber }},
[carrier configuration](/devices/tech/config/carrier) supports
using carrier IDs as keys to fetch carrier-specific configurations from
[`CarrierService`](https://developer.android.com/reference/android/service/carrier/CarrierService){: .external}.

Integrating carrier IDs with `CarrierConfig` has the following advantages:

-   Consolidates all MCC/MNC pairs for each carrier into a single location
    removing duplicate or inconsistent data.
-   Creates a canonical identifier for each carrier and removes ambiguity.
-   Allows mobile virtual network operators (MVNOs) to be identified with
    individual IDs instead of having configurations as part of a mobile network
    operator (MNO).

### Migrating configuration data to carrier IDs

To migrate configuration data from MCC/MNC pairs to carrier IDs, follow
these steps:

1.  Group the `carrier_config_mccmnc.xml` files from a single carrier together.
    Use
    [`carrier_list.textpb`](https://android.googlesource.com/platform/packages/providers/TelephonyProvider/+/master/assets/carrier_list.textpb){: .external}
    as a reference to map the MCC, MNC, and MVNO information to a particular
    carrier.

1.  Merge the configurations into a single file.

1.  (Optional) Inherit data from MNOs. MVNOs inherit configurations from
    MNOs in the legacy `carrier_config_mccmnc.xml` file. Because carrier IDs
    allow all carriers including MVNOs to have a dedicated config file, it's
    recommended to include MNO data during migration.

1.  If the configuration for an MVNO carrier ID doesn't exist, fetch the
    configuration from its MNO carrier ID using
    [`getCarrierIdFromSimMccMnc`](https://developer.android.com/reference/android/telephony/TelephonyManager#getCarrierIdFromSimMccMnc()){: .external}.

1.  Rename the new file as
    <code>carrier\_config\_carrierid\_<var>carrierid</var>\_<var>carriername</var>.xml</code>
    where <var>carrierid</var> must correspond to a `canonical_id` and
    <var>carriername</var> should correspond to a `carrier_name` in
    [`carrier_list.textpb`](https://android.googlesource.com/platform/packages/providers/TelephonyProvider/+/master/assets/carrier_list.textpb){: .external}

Note: If a `carrier_config_mccmnc` file doesn't have a matching
    carrier ID, submit a request to add a carrier ID by following the steps in
    [Adding carrier ID information to the database](#adding_carrier_id_information_to_the_database).

