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

# Using Trade Federation with Scripting Layer for Android

Scripting Layer for Android, SL4A, is an
automation toolset for calling Android APIs in a platform-independent manner.
It supports both remote automation via `adb` and execution of scripts
from on-device via a series of lightweight translation layers.

The project is located at [platform/external/sl4a]
(https://android.googlesource.com/platform/external/sl4a/).

## Use

You can follow the [SL4A README](https://android.googlesource.com/platform/external/sl4a/+/refs/heads/master/README.md)
to build and install it manually. And when running through Tradefed, you
can take advantage of some of the harness utilities to make use easier.

### Download and install

You can start by reviewing
[BT-discovery-sl4a.xml](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/refs/heads/master/res/config/google/example/BT-discovery-sl4a.xml),
an example Tradefed configuration that uses two devices. The `SL4A.apk` is
available in most device builds within their `tests` folder.

The Tradefed example above automatically fetches the builds, flashes both
devices and installs `SL4A.apk` on both devices. You can run it like so:

```
source build/envsetup.sh
lunch
make sl4a
tradefed.sh run google/example/BT-discovery-sl4a
```

Or once built:

```
./tradefed.sh run google/example/BT-discovery-sl4a
```

### Write a test in Tradefed using SL4A

You can follow the test sample describe above:
[Sl4aBluetoothDiscovery.java](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/refs/heads/master/src/com/android/tradefed/Sl4aBluetoothDiscovery.java).
This gives a good example of the flow to use SL4A within a Tradefed test.

### SL4A API Documentation

The complete list of callbacks available through SL4A can be generated. From the
SL4A source directory, `platform/external/sl4a/`, run this command:

```shell
python Docs/generate_api_reference_md.py
```

In the Docs directory there will be an `ApiReference.md` file that contains
the RPC functions available in SL4A, as well as documentation for the RPC
functions.
