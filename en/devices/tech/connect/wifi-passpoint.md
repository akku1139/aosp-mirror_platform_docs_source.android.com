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

# Passpoint (Hotspot 2.0)

[Passpoint](https://www.wi-fi.org/discover-wi-fi/passpoint){: .external} is a
[Wi-Fi Alliance (WFA)](https://www.wi-fi.org/){: .external}
protocol that helps users discover and authenticate to Wi-Fi hotspots to
access the internet. Passpoint is based on *Hotspot 2.0* technology.

## Device support {:#device_support}

To support Passpoint, device manufacturers need to implement
`hardware/interfaces/wifi/supplicant/1.0` or higher. The Wi-Fi
[HAL interface design language (HIDL)](/devices/architecture/hidl) provided
in the Android Open Source Project (AOSP) defines a HAL to the supplicant.
The supplicant provides support for
the 802.11u standard, specifically
network discovery and selection features such as Generic Advertisement Service
(GAS) and access network query protocol (ANQP).

### Implementation {:#implementation}

Device manufacturers need to provide both framework and HAL/firmware support:

+   Framework: Enable Passpoint (requires a feature flag)
+   Firmware: Support for 802.11u

To support Passpoint, implement the Wi-Fi HAL and enable the feature flag for
Passpoint. In `device.mk` located in `device/<oem>/<device>`, modify the
`PRODUCT_COPY_FILES` environment variable to include support for the
Passpoint feature:

```
PRODUCT_COPY_FILES +=
frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml
```

All other requirements for supporting Passpoint are included in AOSP.

### Validation {:#validation}

To validate your implementation of the Passpoint feature, use the set of unit
tests and integration tests provided in the Android Comms Test Suite
(ACTS).


#### Unit tests {:#unit_tests}

Run the following Passpoint package unit tests.

Service tests:

```
% ./frameworks/opt/net/wifi/tests/wifitests/runtests.sh -e package
com.android.server.wifi.hotspot2
```

Manager tests:

```
% ./frameworks/base/wifi/tests/runtests.sh -e package android.net.wifi.hotspot2
```

#### Integration tests (ACTS) {:#integration_tests_acts}

The ACTS Passpoint test suite, located in
`tools/test/connectivity/acts/tests/google/wifi/WifiPasspointTest.py`,
implements a set of functional tests.

Note: Some tests are hard-coded to support specific Passpoint service
provider environments. To set up the test environment for these tests, work with
the specific service provider.

## Passpoint R1 {:#passpoint_r1}

Android has supported Passpoint R1 since Android 6.0, allowing the provisioning
of Passpoint R1 (release 1) credentials through web-based downloading of a
special file that contains profile and credential information. The client
automatically launches a special installer for the Wi-Fi information and allows
the user to view parts of the information before accepting or declining the
content.

The profile information contained in the file is used for matching to data
retrieved from Passpoint-enabled access points, and the credentials are
automatically applied for any matched network.

The Android reference implementation supports EAP-TTLS, EAP-TLS, EAP-SIM,
EAP-AKA, and EAP-AKA'.

### Download mechanism {:#download_mechanism}

The Passpoint configuration file must be hosted on a web server and should be
protected with TLS (HTTPS) because it may contain clear text password or
private key data. The content is made up of wrapped multipart MIME text
represented in UTF-8 and encoded in base64 encoding per RFC-2045 section 6.8.

The following HTTP header fields are used by the client to automatically launch
a Wi-Fi installer on the device:

+   `Content-Type` must be set to `application/x-wifi-config`.
+   `Content-Transfer-Encoding` must be set to `base64`.
+   `Content-Disposition` must not be set.

The HTTP method used to retrieve the file must be GET. Any time an HTTP GET from
the browser receives a response with these MIME headers, the installation app is
started. The download must be triggered by tapping on an HTML element such as a
button (automatic redirects to a download URL aren't supported). This behavior
is specific to Google Chrome; other web browsers may or may not provide similar
functionality.

### File composition {:#file_composition}

The base64-encoded content must consist of MIME multipart content with a
`Content-Type` of `multipart/mixed`. The following parts make up the individual
parts of the multipart content.

<table>
<thead>
<tr>
<th><strong>Part</strong></th>
<th><strong>Content-Type (less quotes)</strong></th>
<th><strong>Required</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td>Profile</td>
<td><code>
application/x-passpoint-profile
</code>

</td>
<td>Always</td>
<td>OMA-DM SyncML formatted payload containing the Passpoint R1
<code>PerProviderSubscription</code> formatted MO for <code>HomeSP</code>
and <code>Credential</code>.</td>
</tr>
<tr>
<td>Trust certificate</td>
<td><code>
application/x-x509-ca-cert
</code>

</td>
<td>Required for EAP-TLS and EAP-TTLS</td>
<td>A single X.509v3 base64-encoded certificate payload.</td>
</tr>
<tr>
<td>EAP-TLS key</td>
<td><code>
application/x-pkcs12
</code>

</td>
<td>Required for EAP-TLS</td>
<td>A base64-encoded PKCS #12 ASN.1 structure containing a client certificate
chain with at least the client certificate and the associated private key.
The PKCS 12 container as well as the private key and the certificates must
all be in clear text with no password.</td>
</tr>
</tbody>
</table>

The Profile section must be transferred as base64-encoded, UTF-8-encoded XML
text that specifies parts of the `HomeSP` and `Credential` subtrees in the
Passpoint R2 Technical Specification Version 1.0.0, section 9.1.

Note: The profile XML format used in Android for Passpoint R1 borrows the
Passpoint R2 format but isn't necessarily R2 compliant. That is a design choice
and not a requirement of Passpoint R1.

The top-level node must be `MgmtTree` and the immediate subnode must be
`PerProviderSubscription`. An example XML file appears in
[Example profile OMA-DM XML](#example_profile_oma-dm_xml).

The following subtree nodes are used under `HomeSP`:

+   `FriendlyName`: Must be set; used as display text
+   `FQDN`: Required
+   `RoamingConsortiumOI`

The following subtree nodes are used under `Credential`:

+   `Realm`: Must be a nonempty string
+   `UsernamePassword`: Required for EAP-TTLS with the following nodes set:

    +   `Username`: String that contains the username
    +   `Password`: Base64-encoded string (set to `cGFzc3dvcmQ=`, the
        base64-encoded string for "password", in the example below)
    +   `EAPMethod/EAPType`: Must be set to `21`
    +   `EAPMethod/InnerMethod`: Must be set to one of `PAP`, `CHAP`, `MS-CHAP`,
        or `MS-CHAP-V2`

+   `DigitalCertificate`: Required for EAP-TLS. The following nodes must be set:

    +   `CertificateType` set to `x509v3`
    +   `CertSHA256Fingerprint` set to the correct SHA-256 digest of the client
        certificate in the EAP-TLS key MIME section

+   `SIM`: Required for EAP-SIM, EAP-AKA, and EAP-AKA'. The `EAPType` field must
    be set to the appropriate EAP type and `IMSI` must match an IMSI of one of
    the SIM cards installed in the device at the time of provisioning. The IMSI
    string can either consist entirely of decimal digits to force full equality
    match, or of zero or more decimal digits followed by an asterisk (\*) to
    relax the IMSI matching to prefix only. For example, the IMSI string 123\*
    matches any SIM card with an IMSI starting with 123.

### Example profile OMA-DM XML {:#example_profile_oma-dm_xml}

```xml
<MgmtTree xmlns="syncml:dmddf1.2">
  <VerDTD>1.2</VerDTD>
  <Node>
    <NodeName>PerProviderSubscription</NodeName>
    <RTProperties>
      <Type>
        <DDFName>urn:wfa:mo:hotspot2dot0-perprovidersubscription:1.0</DDFName>
      </Type>
    </RTProperties>
    <Node>
      <NodeName>i001</NodeName>
      <Node>
        <NodeName>HomeSP</NodeName>
        <Node>
          <NodeName>FriendlyName</NodeName>
          <Value>Example Network</Value>
        </Node>
        <Node>
          <NodeName>FQDN</NodeName>
          <Value>hotspot.example.net</Value>
        </Node>
        <Node>
          <NodeName>RoamingConsortiumOI</NodeName>
          <Value>112233,445566</Value>
        </Node>
      </Node>
      <Node>
        <NodeName>Credential</NodeName>
        <Node>
          <NodeName>Realm</NodeName>
          <Value>example.com</Value>
        </Node>
        <Node>
          <NodeName>UsernamePassword</NodeName>
          <Node>
            <NodeName>Username</NodeName>
            <Value>user</Value>
          </Node>
          <Node>
            <NodeName>Password</NodeName>
            <Value>cGFzc3dvcmQ=</Value>
          </Node>
          <Node>
            <NodeName>EAPMethod</NodeName>
            <Node>
              <NodeName>EAPType</NodeName>
              <Value>21</Value>
            </Node>
            <Node>
              <NodeName>InnerMethod</NodeName>
              <Value>MS-CHAP-V2</Value>
            </Node>
          </Node>
        </Node>
      </Node>
    </Node>
  </Node>
</MgmtTree>
```

### Auth advisory {:#auth_advisory}

Note: This advisory doesn't apply to devices running
Android {{ androidQVersionNumber }} or higher.

Devices running Android 8.x or Android 9 with a Passpoint R1 EAP-SIM, EAP-AKA,
or EAP-AKA' profile won't autoconnect to the Passpoint network. This
issue affects users, carriers, and services by reducing the Wi-Fi offload.


<table>
  <tr>
   <th><strong>Segment</strong>
   </th>
   <th><strong>Impact</strong>
   </th>
   <th><strong>Size of impact</strong>
   </th>
  </tr>
  <tr>
   <td>Carriers and Passpoint service providers
   </td>
   <td>Increased load on cellular network.
   </td>
   <td>Any carrier using Passpoint R1.
   </td>
  </tr>
  <tr>
   <td>Users
   </td>
   <td>Missed opportunity to autoconnect to Carrier Wi-Fi access points
    (APs), resulting in higher data costs.
   </td>
   <td>Any user with a device that runs on a carrier network supporting
    Passpoint R1.
   </td>
  </tr>
</table>

#### Cause of failure {:#cause_of_failure}

Passpoint specifies a mechanism to match an advertised (ANQP) service provider
to a profile installed on the device. The following matching rules for
EAP-SIM, EAP-AKA, and EAP-AKA' are a partial set of rules focusing on the
EAP-SIM/AKA/AKA' failures:


```
If the FQDN (Fully Qualified Domain Name) matches
    then the service is a Home Service Provider.
Else: If the PLMN ID (3GPP Network) matches
    then the service is a Roaming Service Provider.
```

The second criterion was modified in Android 8.0:

```
Else: If the PLMN ID (3GPP Network) matches AND the NAI Realm matches
    then the service is a Roaming Service Provider.
```

With this modification, the system observed no match for previously
working service providers, so Passpoint devices didn't autoconnect.


#### Workarounds {:#workarounds}

To work around the issue of the modified matching criteria, carriers and
service providers need to add the network access identifier (NAI) realm to
the information published by the Passpoint AP.

The recommended solution is for network service providers to implement a
network-side workaround for the fastest time to deployment. A device-side
workaround depends on OEMs picking up a changelist (CL) from AOSP and then
updating devices in the field.


##### Network fix for carriers and Passpoint service providers {:#network_fix_for_carriers_and_passpoint_service_providers}

The network-side workaround requires reconfiguring the network to add the NAI
realm ANQP element as specified below. The Passpoint specifications don't
require the NAI realm ANQP element, but the addition of this property
complies with the Passpoint specifications, so spec-compliant client
implementations should not break.

1.  Add the NAI realm ANQP element.
1.  Set the NAI realm subfield to match the `Realm` of the profile
    installed on the device.

#####  Device/AOSP fix for OEMs {:#deviceaosp_fix_for_oems}

To implement a device-side workaround, OEMs need to pick the patch CL
[aosp/718508](https://android-review.googlesource.com/c/platform/frameworks/opt/net/wifi/+/718508){:.external}.
This patch can be applied on top of the following releases (doesn't apply to
Android {{ androidQVersionNumber }} or higher):

+   Android 9
+   Android 8.x

When the patch is picked up, OEMs need to update devices in the field.

## Passpoint R2 {:#passpoint_r2}

Android {{ androidQVersionNumber }} introduces support for Passpoint R2
features. Passpoint R2 implements online sign up (OSU), a standard method to
provision new Passpoint profiles. Android {{ androidQVersionNumber }} supports
the provisioning of EAP-TTLS profiles using SOAP-XML.

The Passpoint R2 features supported in Android {{ androidQVersionNumber }} only
require AOSP code (no additional driver or firmware support is required). The
AOSP code also includes a
default implementation of the Passpoint R2 UI in the Settings application.

When Android detects a Passpoint R2 access point, the Android framework:

1. Displays a list of the service providers in the Wi-Fi picker (in
  addition to displaying the SSIDs).
2. Prompts the user to tap one of the service providers to set up a Passpoint
   profile.
3. Walks the user through the Passpoint profile setup flow.
4. Installs the resulting Passpoint profile on successful completion.
5. Associates to the Passpoint network using the newly provisioned Passpoint
  profile.

Note: CA certificates (trusted root certificates) for authentication,
authorization, and accounting (AAA) servers and remediation servers must be
DER-encoded X.509 certificates, and the `Content-Type` header field must be set
to `application/x-x509-ca-cert`. It's recommended to set the
`Content-Transfer-Encoding` header field to `base64`.


