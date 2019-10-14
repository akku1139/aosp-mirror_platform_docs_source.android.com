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

Carrier Wi-Fi is an auto-connection feature (using encrypted IMSI) available in Android {{ androidPVersionNumber }}
and higher
that allows devices to automatically connect to carrier-implemented Wi-Fi
networks. In areas of high congestion or with minimal cell coverage such as a
stadium or an underground train station, carrier Wi-Fi can be used to improve
users' connectivity experience and to offload traffic.

Devices with the carrier Wi-Fi feature automatically connect to
configured carrier Wi-Fi networks (networks with a public key certificate). When
a user manually disconnects from a carrier Wi-Fi network, the network is
blacklisted for 24 hours (no auto-connection). Users can manually connect to
blacklisted networks at any time.

On devices running Android 9 with carrier Wi-Fi implemented,
automatic connection through carrier Wi-Fi is off by default. A notification
is sent to the user when the device attempts to connect to a carrier Wi-Fi
network for the first time.

## Implementation

Device manufacturers and carriers must do the following to implement carrier
Wi-Fi.

### Manufacturers

In the carrier config manager, configure the following parameters for each
carrier:

+  `carrier_wifi_string_array`:
    A string array where each string entry is a Base64-encoded Wi-Fi SSID and
    an EAP type separated by a comma, where the EAP type is an integer (refer to
    [Extensible Authentication Protocol (EAP) Registry](https://www.iana.org/assignments/eap-numbers/eap-numbers.xhtml){: .external}).
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

+  `imsi_key_availability_int`:
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

+  `imsi_key_download_url_string`:
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

To implement carrier Wi-Fi, the carrier must support encrypted IMSI and provide
a public key.

#### Support IMSI privacy protection

Implement support for IMSI privacy protection as specified in section
*4.1: Encrypting the Identity* of the *Privacy Protection for EAP-AKA* 3GPP
specification draft (S3-170116). For more information, download
[*Privacy Protection for EAP-AKA*](http://www.3gpp.org/ftp/TSG_SA/WG3_Security/TSGS3_86_Sophia/Docs/S3-170116.zip){: .external}.

#### Providing the public key

Provide a public URL to a server, preferably using HTTP over TLS, that hosts the
certificate of the carrier where:

1.  The public key (and expiration) can be extracted from the certificate.
1.  The information from the server is in JSON format as specified in
    *Server Response* in section *4.3: Mechanism to Configure the Public Key* of
    the *Privacy Protection or EAP-AKA* 3GPP specification draft (S3-170116).

    Additionally, the server response may include the following JSON string
    property: <code>"key-type" : "<var>type</var>"</code>. The value for
    <var>type</var> must be either `WLAN` or `EPDG`. If the `key-type` property
    isn't included, then its value defaults to `WLAN`.

    ```
    {
    "carrier-keys" : [ {
      "key-identifier" : "CertificateSerialNumber=5xxe06d4",
      "public-key" : "-----BEGIN CERTIFICATE-----\r\nTIIDRTCCAi2gAwIBAgIEVR4G1DANBgkqhkiG9w0BAQsFADBTMQswCQYDVQQGEwJVUzELMAkGA1UE\r\nCBMCTkExCzAJBgNVBAcTAk5BMQswCQYDVQQKEwJOQTELMAkGA1UECxMCTkExEDAOBgNVBAMTB1Rl\r\nc3RiT6N1/w==\r\n-----END CERTIFICATE-----"
    } ]
    }
    ```
