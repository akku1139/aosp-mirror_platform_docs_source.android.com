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

# Build Info in Tradefed

[Build Info](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/build/BuildInfo.java)
in TF is a widely used object to carry resources for test setup and runs.
Everything from device images to test APKs are stored or linked in the Build
Info to be found. This allows a unified way to access test resources from a test
and decouple the test from getting test resources.

## Build Info properties

The two main properties of build info objects are attributes and files:

*   *Attributes* - They can be added via `#addBuildAttribute()`; they represent
    labels and string information to the builds. Attributes can be used to store
    information related to the build.
*   *Files*: They can be added via `setFile()`; the file will be tracked and
    managed by Build Info during the invocation lifecyle (for example,
    properly handled during sharding). This avoids the need for the
    test to know anything about the file system and instead can simply rely on
    the abstracted Build Info object to get their resources.

NOTE: Files should always be stored in `Files` and not in `Attributes` as an
absolute path. Attributes are treated as pure java strings, and the reference
could be invalidated during part of the invocation lifecycle.

## Build Info in multi-devices

When a test configuration is set up with multiple devices, one Build Info object
will exist per device. This allows requesting and targeting files from one
device to another.

## Build Info in multi-builds

It is possible to require builds from several targets. In these cases, one
Build Info object will exist per target. This allows requesting and targeting
files from any target.

## Proto format

Build Info is serializable in a protobuf format to make its usage easier across
systems if needed.
