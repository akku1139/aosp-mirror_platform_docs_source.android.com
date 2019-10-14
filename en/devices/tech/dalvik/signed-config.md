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

# Implementing Signed Config

The Signed Config feature allows embedding configuration of non-SDK interface restrictions
in APKs. This allows removing specific non-SDK interfaces from the blacklist, to
allow AndroidX to safely use them. This allows the AndroidX team to add support
for new features on Android versions that have already been released. It is
supported in Android {{ androidQVersionNumber }} and later.

Properly supporting Signed Config ensures that the AndroidX libraries will
function correctly on devices in the future.

No customization of this feature is possible. It is fully supported in AOSP and
requires no OEM effort to support it.

## Examples and source

The feature implementation is in the system server at
`frameworks/base/services/core/java/com/android/server/signedconfig`. The CTS
test `CtsSignedConfigHostTestCases` includes example usage, and an example
configuration in
`cts/hostsidetests/signedconfig/app/version1_AndroidManifest.xml`.

## Implementation

No effort is required to support the feature, and there are no specific hardware
requirements.

The feature uses two application metadata keys to embed configuration and a
signature inside APKs. Those keys are `android.settings.global` and
`android.settings.global.signature`. If or when the AndroidX libraries require
non-SDK interfaces to be removed from the blacklist in the future, values for
these keys will be published by the Android team and/or as part of AndroidX.

The APK metadata keys `android.settings.global` and
`android.settings.global.signature` both contain base-64 encoded data. The value
for key `android.settings.global` is JSON-encoded config values to be applied to
the global settings in `SettingsProvider`. The value for
`android.settings.global.signature` is an ECDSA-p256 signature of the JSON data.
The signature is used to verify the origin of the configuration data.

The feature isn't user visible.

## Customization

The feature isn't intended for customization. OEMs are discouraged from
modifying the feature, including replacing the keys. Any changes to it are
likely to cause AndroidX to not function properly on affected devices in the
future.

## Validation

The CTS test `CtsSignedConfigHostTestCases` verifies the feature implementation.

You can also test the feature manually by installing an appropriate APK and
inspecting the `adb logcat` output:

```
$ adb install CtsSignedConfigTestAppV1.apk
...
$ adb logcat
...
I SignedConfig: Verified config using production key
...
```
