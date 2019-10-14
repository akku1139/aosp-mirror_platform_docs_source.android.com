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

# Store Secrets with Keystore

Tradefed includes the concept of [keystore](/security/keystore), where secrets
can be stored in a keystore service and requested at test run time for use
during the test.

## How to use the keystore

To use the keystore, you need to first define the source for the keystore in
your [global
configuration](/devices/tech/test_infra/tradefed/architecture/advanced/global-config).

Once done, you can then use the stored keys via: `USE_KEYSTORE@{key}`

## JSONFileKeyStore

The sample implementation in Tradefed core uses a JSON keystore,
`JSONFileKeyStoreClient`. To use this keystore, you would define a JSON key file
that has key to value mappings.

For example, you could define a `/path/to/keystore.json` file as

```json
{
  "test_account": "foo@gmail.com",
  "test_account_pwd": "helloworld",
  "wifi_lab_ssid": "Google_private_AP",
  "wifi_lab_pwd": "secret123",
}
```

Then you would add the following lines in your TF global configuration file:

```xml
<key_store class="com.android.tradefed.util.keystore.JSONFileKeyStoreFactory">
<option name="json-key-store-file" value="/path/to/keystore.json" />
</key_store>
```

When executing related tests, you can now pass in values as
`USE_KEYSTORE@test_account`, which TF will then query the keystore for and use
its value as part of the test.
