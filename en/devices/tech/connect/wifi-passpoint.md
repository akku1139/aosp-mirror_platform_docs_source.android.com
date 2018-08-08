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

# Passpoint R1

Android has supported Passpoint R1 since Android 6.0 allowing the provisioning
of Passpoint R1 (release 1) credentials through web-based downloading of a
special file that contains profile and credential information. The client
automatically launches a special installer for the Wi-Fi information and allows
the user to view parts of the information before accepting or declining the
content.

The profile information contained in the file is used for matching against data
retrieved from Passpoint R1 enabled access points, and the credentials are
automatically applied for any matched network.

The Android reference implementation supports EAP-TTLS, EAP-TLS, EAP-SIM,
EAP-AKA, and EAP-AKA'.

## Download mechanism

The wifi-config file must be hosted on a web-server and should be protected with
TLS (HTTPS) since it may contain clear text password or private key data. The
content is made up of wrapped multi-part MIME text represented in UTF-8 and
encoded in base64 encoding per RFC-2045 section 6.8.

The following HTTP header fields are used by the client to automatically launch
a Wi-Fi installer on the device:

+   `Content-Type` must be set to `application/x-wifi-config`
+   `Content-Transfer-Encoding` must be set to `base64`
+   `Content-Disposition` must not be set

The HTTP method used to retrieve the file must be GET. Any time an HTTP GET from
the browser receives a response with these MIME headers, the installation app is
started. The download must be triggered by tapping on an HTML element such as a
button (automatic redirects to a download URL are not supported). This behavior
is specific to Google Chrome; other web browsers may or may not provide similar
functionality.

## File composition

The base64-encoded content must consist of MIME multipart content with a
`Content-Type` of `multipart/mixed`. The following parts make up the individual
parts of the multi-part content:

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
<td>Optional for EAP-TLS and EAP-TTLS</td>
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
text that specifies parts of the `HomeSP` and `Credential` sub-trees in the
Passpoint R2 Technical Specification Version 1.0.0, section 9.1.

Note: The profile XML format used in Android for Passpoint R1 borrows the
Passpoint R2 format but isn't necessarily R2 compliant. That is a design choice
and not a requirement of Passpoint R1.

The top-level node must be `MgmtTree` and the immediate sub-node must be
`PerProviderSubscription`. An example XML file appears in the Appendix below.

The following sub-tree nodes are used under `HomeSP`:

+   `FriendlyName`: Must be set; used as display text
+   `FQDN`: Required
+   `RoamingConsortiumOI`

The following sub-tree nodes are used under `Credential`:

+   `Realm`: Must be a non-empty string
+   `UsernamePassword`: Required for EAP-TTLS with the following nodes set:

    +   `Username`
    +   `Password`
    +   `EAPMethod/EAPType`: Must be set to `21`
    +   `EAPMethod/InnerMethod`: Must be set to one of `PAP`, `CHAP`, `MS-CHAP`,
        or `MS-CHAP-V2`

+   `DigitalCertificate`: Required for EAP-TLS. The following nodes must be set:

    +   `CertificateType` set to `x509v3`
    +   `CertSHA256Fingerprint` set to the correct SHA-256 digest of the client
        certificate in the EAP-TLS key MIME section.

+   `SIM`: Required for EAP-SIM, EAP-AKA and EAP-AKA'. The `EAPType` field must
    be set to the appropriate EAP type and `IMSI` must match an IMSI of one of
    the SIM cards installed in the device at the time of provisioning. The IMSI
    string can either consist entirely of decimal digits to force full equality
    match, or of zero or more decimal digits followed by an asterisk (\*) to
    relax the IMSI matching to prefix only. For example, the IMSI string 123\*
    matches any SIM card with an IMSI starting with 123.

# Example Profile OMA-DM XML

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
          <Value>Century House</Value>
        </Node>
        <Node>
          <NodeName>FQDN</NodeName>
          <Value>mi6.co.uk</Value>
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
          <Value>shaken.stirred.com</Value>
        </Node>
        <Node>
          <NodeName>UsernamePassword</NodeName>
          <Node>
            <NodeName>Username</NodeName>
            <Value>james</Value>
          </Node>
          <Node>
            <NodeName>Password</NodeName>
            <Value>Ym9uZDAwNw==</Value>
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
