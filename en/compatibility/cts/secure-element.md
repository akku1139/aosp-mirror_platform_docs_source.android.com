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

# CTS Test for Secure Element

To provide better security, some devices have an embedded Secure Element (SE),
which is dedicated, separate tamper-resistant hardware to store cryptographic
data. Open Mobile API is a
[standard API](https://globalplatform.org/specs-library/open-mobile-api-specification-v3-2/){: .external}
used to communicate with a device's Secure Element. Android
{{ androidPVersionNumber }}
introduces support for this API and provides a backend implementation including
Secure Element Service and SE HAL.

Secure Element Service checks support for Global platform-supported Secure
Elements (essentially checks if devices have SE HAL implementation and if yes,
how many). This is used as the basis to test the API and the
underlying Secure Element implementation.

## Open Mobile API test cases

Open Mobile API (OMAPI) test cases are used to enforce API guidelines and to
confirm the
underlying implementation of Secure Elements meets the Open Mobile API
specification. These test cases require installation of a special applet, a Java
Card application on Secure Element, that
is used by the CTS application for communication. For installation, use the
sample applet found in
[`google-cardlet.cap`](https://android.googlesource.com/platform/cts/+/master/tests/tests/secure_element/sample_applet/uicc){: .external}.

To pass OMAPI test cases, the underlying Secure Element Service and the SE
should be capable of the following:

<ol>
<li>All Secure Element Reader names should start with SIM, eSE, or SD.</li>
<li>Non-SIM based readers should be capable of opening basic channels.</li>
<li><code>CtsOmapiTestCases.apk</code> should not be capable of selecting the
A000000476416E64726F6964435453FF AID:</li>
<li><code>CtsOmapiTestCases.apk</code> should be capable of selecting an
applet with the following application identifiers (AIDs):
  <ol>
  <li>0xA000000476416E64726F696443545331
    <ol>
      <li>The applet should throw a Security Exception when it receives the
        following application protocol data unit (APDUs) in
        <code>android.se.omapi.Channel.Transmit</code>
        (<em>Transmit</em>):
        <ol>
          <li>0x00700000</li>
          <li>0x00708000</li>
          <li>0x00A40404104A535231373754657374657220312E30</li>
        </ol>
      </li>
      <li>The applet should return no data when it receives the following
        APDUs in <em>Transmit</em>:
        <ol>
          <li>0x00060000</li>
          <li>0x80060000</li>
          <li>0xA0060000</li>
          <li>0x94060000</li>
          <li>0x000A000001AA</li>
          <li>0x800A000001AA</li>
          <li>0xA00A000001AA</li>
          <li>0x940A000001AA</li>
        </ol>
      </li>
      <li>The applet should return 256-byte data for the following
        <em>Transmit</em> APDUs:
        <ol>
         <li>0x0008000000</li>
         <li>0x8008000000</li>
         <li>0xA008000000</li>
         <li>0x9408000000</li>
         <li>0x000C000001AA00</li>
         <li>0x800C000001AA00</li>
         <li>0xA00C000001AA00</li>
         <li>0x940C000001AA00</li>
       </ol>
      <li>The applet should return the following status word responses for
        the respective <em>Transmit</em> APDU:
        <table>
        <thead>
        <tr>
        <th>Transmit APDU</th>
        <th>Status Word</th>
        <th>Data</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>0x00F30106</td>
        <td>0x6200</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30206</td>
        <td>0x6281</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30306</td>
        <td>0x6282</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30406</td>
        <td>0x6283</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30506</td>
        <td>0x6285</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30606</td>
        <td>0x62F1</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30706</td>
        <td>0x62F2</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30806</td>
        <td>0x63F1</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30906</td>
        <td>0x63F2</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30A06</td>
        <td>0x63C2</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30B06</td>
        <td>0x6202</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30C06</td>
        <td>0x6280</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30D06</td>
        <td>0x6284</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30E06</td>
        <td>0x6282</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30F06</td>
        <td>0x6300</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F31006</td>
        <td>0x6381</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3010A01AA</td>
        <td>0x6200</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3020A01AA</td>
        <td>0x6281</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3030A01AA</td>
        <td>0x6282</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3040A01AA</td>
        <td>0x6283</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3050A01AA</td>
        <td>0x6285</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3060A01AA</td>
        <td>0x62F1</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3070A01AA</td>
        <td>0x62F2</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3080A01AA</td>
        <td>0x63F1</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3090A01AA</td>
        <td>0x63F2</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30A0A01AA</td>
        <td>0x63C2</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30B0A01AA</td>
        <td>0x6202</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30C0A01AA</td>
        <td>0x6280</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30D0A01AA</td>
        <td>0x6284</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30E0A01AA</td>
        <td>0x6282</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F30F0A01AA</td>
        <td>0x6300</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3100A01AA</td>
        <td>0x6381</td>
        <td>No</td>
        </tr>
        <tr>
        <td>0x00F3010800</td>
        <td>0x6200</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3020800</td>
        <td>0x6281</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3030800</td>
        <td>0x6282</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3040800</td>
        <td>0x6283</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3050800</td>
        <td>0x6285</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3060800</td>
        <td>0x62F1</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3070800</td>
        <td>0x62F2</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3080800</td>
        <td>0x63F1</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3090800</td>
        <td>0x63F2</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F30A0800</td>
        <td>0x63C2</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F30B0800</td>
        <td>0x6202</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F30C0800</td>
        <td>0x6280</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F30D0800</td>
        <td>0x6284</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F30E0800</td>
        <td>0x6282</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F30F0800</td>
        <td>0x6300</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3100800</td>
        <td>0x6381</td>
        <td>Yes</td>
        </tr>
        <tr>
        <td>0x00F3010C01AA00</td>
        <td>0x6200</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3020C01AA00</td>
        <td>0x6281</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3030C01AA00</td>
        <td>0x6282</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3040C01AA00</td>
        <td>0x6283</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3050C01AA00</td>
        <td>0x6285</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3060C01AA00</td>
        <td>0x62F1</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3070C01AA00</td>
        <td>0x62F2</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3080C01AA00</td>
        <td>0x63F1</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3090C01AA00</td>
        <td>0x63F2</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F30A0C01AA00</td>
        <td>0x63C2</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F30B0C01AA00</td>
        <td>0x6202</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F30C0C01AA00</td>
        <td>0x6280</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F30D0C01AA00</td>
        <td>0x6284</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F30E0C01AA00</td>
        <td>0x6282</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F30F0C01AA00</td>
        <td>0x6300</td>
        <td>Yes*</td>
        </tr>
        <tr>
        <td>0x00F3100C01AA00</td>
        <td>0x6381</td>
        <td>Yes*</td>
        </tr>
        </tbody>
        </table>
        <small>*The response should contain data
            that is the same as input APDU,
          except the first byte is 0x01 instead of 0x00.</small>
      </li>
      <li>The applet should return segmented responses of size 2048 bytes for
        commands a,b,c,d, f and g whereas 32767 bytes for APDU(e), with last
        data byte being 0xFF and success status word <0x9000> for the following
        APDUs:
        <ol>
         <li>0x00C2080000</li>
         <li>0x00C4080002123400</li>
         <li>0x00C6080000</li>
         <li>0x00C8080002123400</li>
         <li>0x00C27FFF00</li>
         <li>0x00CF080000</li>
         <li>0x94C2080000</li>
       </ol>
      </li>
      <li>The applet should return success status word <0x9000> for the given
        APDU: 0x00F40000</li>
    </ol>
  <li>A000000476416E64726F696443545332
    <ol>
      <li>When selected, this AID should return a select response greater than
      2 bytes that are correctly formatted using Basic Encoding Rules (BER) and
        tag-length-value (TLV).</li>
    </ol>
  </li>
</ol>
</ol>

## Access Control test cases

Access Control uses configured in the Secure Element ensure that only the
application with access to an applet can communicate with it. Additionally,
Android supports configuring rules for specific APDUs that can be exchanged by
the APK.

To pass these tests, configure special Access Control Rules, either Access Rule
Application Master (ARA) or Access Rule File (ARF). You should use the applet
that is used for [OMAPI tests](#open_mobile_api_test_cases) as the same
commands need to be supported to pass the Access Control tests.

Create an instance of the applet under these AIDs:

-   0xA000000476416E64726F696443545340
-   0xA000000476416E64726F696443545341
-   0xA000000476416E64726F696443545342
-   0xA000000476416E64726F696443545343
-   0xA000000476416E64726F696443545344
-   0xA000000476416E64726F696443545345
-   0xA000000476416E64726F696443545346
-   0xA000000476416E64726F696443545347
-   0xA000000476416E64726F696443545348
-   0xA000000476416E64726F696443545349
-   0xA000000476416E64726F69644354534A
-   0xA000000476416E64726F69644354534B
-   0xA000000476416E64726F69644354534C
-   0xA000000476416E64726F69644354534D
-   0xA000000476416E64726F69644354534E
-   0xA000000476416E64726F69644354534F

### `CtsSecureElementAccessControlTestCases1`

-   **Hash of the APK:** 0x4bbe31beb2f753cfe71ec6bf112548687bb6c34e
-   **Authorized AIDs**

    -   0xA000000476416E64726F696443545340

        1.  Authorized APDUs:
            1.  0x00060000
            2.  0xA0060000

        1.  Unauthorized APDUs:

            1.  0x0008000000
            1.  0x80060000
            1.  0xA008000000
            1.  0x9406000000

    -   0xA000000476416E64726F696443545341

        1.  Authorized APDUs:

            1.  0x94060000
            1.  0x9408000000
            1.  0x940C000001AA00
            1.  0x940A000001AA

        1.  Unauthorized APDUs:

            1.  0x00060000
            1.  0x80060000
            1.  0xA0060000
            1.  0x0008000000
            1.  0x000A000001AA
            1.  0x800A000001AA
            1.  0xA00A000001AA
            1.  0x8008000000
            1.  0xA008000000
            1.  0x000C0000001AA00
            1.  0x800C000001AA00
            1.  0xA00C000001AA00

    -   0xA000000476416E64726F696443545342

    -   0xA000000476416E64726F696443545344

    -   0xA000000476416E64726F696443545345

    -   0xA000000476416E64726F696443545347

    -   0xA000000476416E64726F696443545348

    -   0xA000000476416E64726F696443545349

    -   0xA000000476416E64726F69644354534A

    -   0xA000000476416E64726F69644354534B

    -   0xA000000476416E64726F69644354534C

    -   0xA000000476416E64726F69644354534D

    -   0xA000000476416E64726F69644354534E

    -   0xA000000476416E64726F69644354534F

-   **Unauthorized AIDs**

    -   0xA000000476416E64726F696443545343
    -   0xA000000476416E64726F696443545346

### `CtsSecureElementAccessControlTestCases2`

-   **Hash of the APK:** 0x93b0ff2260babd4c2a92c68aaa0039dc514d8a33
-   **Authorized AIDs:**

    -   0xA000000476416E64726F696443545340

        1.  Authorized APDUs:

            1.  0x00060000
            1.  0xA0060000

        1.  Unauthorized APDUs:

            1.  0x0008000000
            1.  0x80060000
            1.  0xA008000000
            1.  0x9406000000

    -   0xA000000476416E64726F696443545341

        1.  Authorized APDUs:

            1.  0x94060000
            1.  0x9408000000
            1.  0x940C000001AA00
            1.  0x940A000001AA

        1.  Unauthorized APDUs:

            1.  0x0006000
            1.  0x80060000
            1.  0xA0060000
            1.  0x0008000000
            1.  0x000A000001AA
            1.  0x800A000001AA
            1.  0xA00A000001AA
            1.  0x8008000000
            1.  0xA008000000
            1.  0x000C000001AA00
            1.  0x800C000001AA00
            1.  0xA00C000001AA00

    -   0xA000000476416E64726F696443545343

    -   0xA000000476416E64726F696443545345

    -   0xA000000476416E64726F696443545346

-   **Unauthorized AIDs**

    -   0xA000000476416E64726F696443545342
    -   0xA000000476416E64726F696443545344
    -   0xA000000476416E64726F696443545347
    -   0xA000000476416E64726F696443545348
    -   0xA000000476416E64726F696443545349
    -   0xA000000476416E64726F69644354534A
    -   0xA000000476416E64726F69644354534B
    -   0xA000000476416E64726F69644354534C
    -   0xA000000476416E64726F69644354534D
    -   0xA000000476416E64726F69644354534E
    -   0xA000000476416E64726F69644354534F

### `CtsSecureElementAccessControlTestCases3`

-   **Hash of the APK:** 0x5528ca826da49d0d7329f8117481ccb27b8833aa
-   **Authorized AIDs:**

    -   0xA000000476416E64726F696443545340

        1.  Authorized APDUs:

            1.  0x00060000
            1.  0x80060000
            1.  0xA0060000
            1.  0x94060000
            1.  0x000A000001AA
            1.  0x800A000001AA
            1.  0xA00A000001AA
            1.  0x940A000001AA
            1.  0x0008000000
            1.  0x8008000000
            1.  0xA008000000
            1.  0x9408000000
            1.  0x000C000001AA00
            1.  0x800C000001AA00
            1.  A00C000001AA00
            1.  940C000001AA00

    -   0xA000000476416E64726F696443545341

        1.  Authorized APDUs:

            1.  0x94060000
            1.  0x9408000000
            1.  0x940C000001AA00
            1.  0x940A00000aAA

        1.  Unauthorized APDUs:

            1.  0x00060000
            1.  0x80060000
            1.  0xA0060000
            1.  0x0008000000
            1.  0x000A000001AA
            1.  0x800A000001AA
            1.  0xA00A000001AA
            1.  0x8008000000
            1.  0xA008000000
            1.  0x000C000001AA00
            1.  0x800C000001AA00
            1.  0xA00C000001AA00

    -   0xA000000476416E64726F696443545345

    -   0xA000000476416E64726F696443545346

-   **Unauthorized AIDs**

    -   0xA000000476416E64726F696443545342
    -   0xA000000476416E64726F696443545343
    -   0xA000000476416E64726F696443545344
    -   0xA000000476416E64726F696443545347
    -   0xA000000476416E64726F696443545348
    -   0xA000000476416E64726F696443545349
    -   0xA000000476416E64726F69644354534A
    -   0xA000000476416E64726F69644354534B
    -   0xA000000476416E64726F69644354534C
    -   0xA000000476416E64726F69644354534D
    -   0xA000000476416E64726F69644354534E
    -   0xA000000476416E64726F69644354534F

## Appendix

### Sample applet and installation steps for UMTS Integrated Circuit Card (UICC)

#### 1. Package specification

**File name:** `google-cardlet.cap`

**Package AID:** 6F 6D 61 70 69 63 61 72 64 6C 65 74  
**Version:** 1.63  
**Hash:** 5F72E0A073BA9E61A7358F2FE3F031A99F3F81E9

**Applets:**  
6F 6D 61 70 69 4A 53 52 31 37 37 = SelectResponse module  
6F 6D 61 70 69 43 61 63 68 69 6E 67 = XXLResponse module

**Imports:**  
javacard.framework v1.3 - A0000000620101  
java.lang v1.0 - A0000000620001  
uicc.hci.framework v1.0 - A0000000090005FFFFFFFF8916010000  
uicc.hci.services.cardemulation v1.0 - A0000000090005FFFFFFFF8916020100  
uicc.hci.services.connectivity v1.0 - A0000000090005FFFFFFFF8916020200

**Size on card:** 39597

#### 2. Installation steps

Load the
[`google-cardlet.cap`](https://android.googlesource.com/platform/cts/+/master/tests/tests/secure_element/sample_applet/uicc){: .external}
file to the SIM card using the appropriate
procedure (check with your SE manufacturers).

Run installation command for each applet.

##### OMAPI tests

Command to install applet

<code>80E60C00300C6F6D617069636172646C65740B<var>module_AID</var>10<var>AID</var>010002C90000</code><br>
**Module_AID**: 6F 6D 61 70 69 4A 53 52 31 37 37  
**AID:** A000000476416E64726F696443545331

<code>80E60C00310C6F6D617069636172646C65740B<var>module_AID</var>10<var>AID</var>010002C9000</code><br>
**Module_AID**: 6F 6D 61 70 69 43 61 63 68 69 6E 67  
**AID:** A000000476416E64726F696443545332

##### AccessControl tests (template using PKCS#15 structure)

<code>80E60C003C0C6F6D617069636172646C65740B<var>module_AID</var>10<var>AID</var>01000EEF0AA008810101A5038201C0C90000</code><br>
**Module_AID**: 6F 6D 61 70 69 4A 53 52 31 37 37

**AIDs:**

+   0xA000000476416E64726F696443545340
+   0xA000000476416E64726F696443545341
+   0xA000000476416E64726F696443545342
+   0xA000000476416E64726F696443545344
+   0xA000000476416E64726F696443545345
+   0xA000000476416E64726F696443545347
+   0xA000000476416E64726F696443545348
+   0xA000000476416E64726F696443545349
+   0xA000000476416E64726F69644354534A
+   0xA000000476416E64726F69644354534B
+   0xA000000476416E64726F69644354534C
+   0xA000000476416E64726F69644354534D
+   0xA000000476416E64726F69644354534E
+   0xA000000476416E64726F69644354534F

For step-by-step commands to set up the PKCS#15 structure matching the CTS
tests, see
[Commands for PKCS#15](/compatibility/cts/pkcs15-commands.txt).
