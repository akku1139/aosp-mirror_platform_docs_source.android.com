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

# Carrier Wi-Fi

Carrier Wi-Fi is a feature introduced in Android {{ androidPVersionNumber }}
that allows devices to automatically connect to carrier-implemented Wi-Fi
networks. In areas of high congestion or with minimal cell coverage such as a
stadium or an underground train station, Carrier Wi-Fi can be used to improve
users' connectivity experience and to offload traffic.

## Implementation

Device manufacturers and carriers must do the following to implement Carrier
Wi-Fi.

### Manufacturers

In the carrier config manager, configure the following parameters for each
carrier:

+  [`KEY_CARRIER_WIFI_STRING_ARRAY`](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/CarrierConfigManager.java#1606){: .external}:
    A string array where each string entry is a Base64-encoded Wi-Fi SSID and
    an EAP type separated by a comma, where the EAP type is an integer (refer to
    [https://www.iana.org/assignments/eap-numbers/eap-numbers.xhtml](https://www.iana.org/assignments/eap-numbers/eap-numbers.xhtml){: .external}).
    For example, the following configuration is for *SOME_SSID_NAME* using
    **EAP-AKA** and *Some_Other_SSID* using **EAP-SIM**:

    ```
    config {
      key: "carrier_wifi_string_array"
      text_array {
        item: "U09NRV9TU0lEX05BTUUK,23"
        item: "U29tZV9PdGhlcl9TU0lECg==,18"
      }
    }
    ```

+  [`IMSI_KEY_AVAILABILITY_INT`](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/CarrierConfigManager.java#1837){: .external}:
    Identifies whether the key used for IMSI encryption is available for WLAN
    (bit 1 is set), EPDG (bit 0 is set), or both (both bit 0 and bit 1 are
    set). For example, the following configuration indicates that IMSI
    encryption is available for WLAN but not for EPDG:

    ```
    config {
      key: "imsi_key_availability_int"
      int_value: 2
    }
    ```

+  [`IMSI_KEY_DOWNLOAD_URL_STRING`](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/CarrierConfigManager.java#1830){: .external}:
    URL from which the proto containing the public key of the carrier used for
    IMSI encryption is downloaded. For example, the following configuration
    provides a specific URL:

    ```
    config {
      key: "imsi_key_download_url_string"
      text_value: "https://www.some_company_name.com:5555/some_directory_name/"
    }
    ```

### Carriers

To implement Carrier Wi-Fi, the carrier must support encrypted IMSI and provide
a public key.

#### Support encrypted IMSI

Change the Wi-Fi network configuration to ensure that encrypted IMSI can be
handled. The format for the identity used in EAP-SIM is:

`Prefix | [IMSI || Encrypted IMSI] | @realm | {, Key Identifier AVP}`

where "|" (single bar) denotes concatenation, "||" (double bar) denotes
exclusive value, "{}" (curly brackets) denotes optional value, and realm is the
3GPP network domain name derived from the given MNC/MCC according to the 3GGP
spec (TS23.003).

`Prefix` values include:

+   "`\0`": Encrypted Identity
+   "`0`": EAP-AKA Identity
+   "`1`": EAP-SIM Identity
+   "`6`": EAP-AKA' Identity

The format for an `Encrypted IMSI` is:

`Base64{RSA_Public_Key_Encryption{eapPrefix | IMSI}}`

where "|" denotes concatenation.

`eapPrefix` values include:

+   "`0`" - EAP-AKA Identity
+   "`1`" - EAP-SIM Identity
+   "`6`" - EAP-AKA' Identity

#### Provide public key

Provide a public URL that hosts the certificate of the carrier where:

1.  The public key (and expiration) can be extracted from the certificate
1.  The information is in JSON with the following format:

```
{
"carrier-keys" : [ {
  "key-identifier" : "CertificateSerialNumber=5xxe06d4",
  "certificate" : "-----BEGIN CERTIFICATE-----\r\nTIIDRTCCAi2gAwIBAgIEVR4G1DANBgkqhkiG9w0BAQsFADBTMQswCQYDVQQGEwJVUzELMAkGA1UE\r\nCBMCTkExCzAJBgNVBAcTAk5BMQswCQYDVQQKEwJOQTELMAkGA1UECxMCTkExEDAOBgNVBAMTB1Rl\r\nc3RiT6N1/w==\r\n-----END CERTIFICATE-----",
  "key-type" : "WLAN"
} ]
}
```

## Customization

Carrier Wi-Fi is off by default unless configured in the carrier config manager
for each carrier. If the feature is on, the device attempts to connect to a
network automatically. A notification is sent on the first attempt.
