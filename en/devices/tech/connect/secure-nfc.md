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

# Secure NFC

Android supports off-host card emulation, which means
NFC card emulation with a secure element. For more information, see
[Host-based card emulation overview](https://developer.android.com/guide/topics/connectivity/nfc/hce){: .external}.

In certain use cases such as using
[FeliCa](https://en.wikipedia.org/wiki/FeliCa){: .external}
for transit, off-host card
emulation is permitted  when a device's screen is locked or turned off, or
when a device is turned off.

Secure NFC is a feature introduced in Android {{ androidQVersionNumber }}
that allows off-host NFC card
emulation to be enabled only when the device's screen is unlocked. Implementing
this feature gives users the option to enable Secure NFC for
improved security.

## Implementation

To implement the Secure NFC feature, the device must have an NFC controller that
supports the NCI 2.0 standard and must use the Android Open Source Project
(AOSP) NFC framework. Add the hardware (`ro.boot.hardware.sku`) that supports
the Secure NFC feature in the NFC
[resource XML file](https://android.googlesource.com/platform/packages/apps/Nfc/+/refs/heads/master/res/values/config.xml){: .external}
with the `config_skuSupportsSecureNfc` attribute.

### Framework APIs

To implement Secure NFC, implement the following framework APIs found in the
Android Open Source Project:

+   [`isSecureNfcSupported()`](https://developer.android.com/reference/android/nfc/NfcAdapter#isSecureNfcSupported()){: .external}:
    Checks if the device supports the Secure NFC feature.
+   [`isSecureNfcEnabled()`](https://developer.android.com/reference/android/nfc/NfcAdapter#isSecureNfcEnabled()){: .external}:
    Checks if the Secure NFC feature is enabled.
+   [`enableSecureNfc(boolean enable)`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/java/android/nfc/NfcAdapter.java#1722){: .external}:
    Enables the Secure NFC feature.

### Settings UI

In the Settings application, add a toggle switch to allow users to enable and
disable the Secure NFC feature. You can customize the default setting in the
Settings application to be either enabled or disabled.

Figure 1 shows an example of a toggle switch to enable and disable Secure NFC
on the Connection preferences screen in the Settings application.

![Secure NFC UI flow](/devices/tech/connect/images/secure-nfc.png){: width="300" .screenshot}

**Figure 1.** Example toggle switch to enable and disable Secure NFC

## Validation

To validate your implementation, enable the Secure NFC feature and verify that
NFC card emulation is disabled when the device's screen is off or locked, and
when the device is turned off.
