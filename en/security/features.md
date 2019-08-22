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

# Android Security Features

Use the features described in this section to make the Android devices you
develop as secure as possible.

## Application sandbox

The Android platform takes advantage of the Linux user-based protection to
identify and isolate app resources. To do this, Android assigns a unique user ID
(UID) to each Android application and runs it in its own process. Android uses
this UID to set up a kernel-level Application Sandbox.

## Application signing

Application signing allows developers to identify the author of the application
and to update their application without creating complicated interfaces and
permissions. Every application that is run on the Android platform must be
signed by the developer.

## Authentication

Android uses the concept of user-authentication-gated cryptographic keys that
requires cryptographic key storage and service provider and user authenticators.

On devices with a fingerprint sensor, users can enroll one or more fingerprints
and use those fingerprints to unlock the device and perform other tasks. And the
Gatekeeper subsystem performs device pattern/password authentication in a
Trusted Execution Environment (TEE).

## Biometrics

Android 9 and higher includes a BiometricPrompt API that app developers can use
to integrate biometric authentication into their applications in a device- and
modality-agnostic fashion. Only strong biometrics can integrate with
`BiometricPrompt`.

## Encryption

Once a device is encrypted, all user-created data is automatically encrypted
before committing it to disk and all reads automatically decrypt data before
returning it to the calling process. Encryption ensures that even if an
unauthorized party tries to access the data, they won’t be able to read it.

## Keystore

Android offers a hardware-backed Keystore that provides key generation, import
and export of asymmetric keys, import of raw symmetric keys, asymmetric
encryption and decryption with appropriate padding modes, and more.

## Security-Enhanced Linux

As part of the Android security model, Android uses Security-Enhanced Linux
(SELinux) to enforce mandatory access control (MAC) over all processes, even
processes running with root/superuser privileges (Linux capabilities).

## Trusty Trusted Execution Environment (TEE)

Trusty is a secure Operating System (OS) that provides a Trusted Execution
Environment (TEE) for Android. The Trusty OS runs on the same processor as the
Android OS, but Trusty is isolated from the rest of the system by both hardware
and software.

## Verified Boot

Verified Boot strives to ensure all executed code comes from a trusted source
(usually device OEMs), rather than from an attacker or corruption. It
establishes a full chain of trust, starting from a hardware-protected root of
trust to the bootloader, to the boot partition and other verified partitions.
