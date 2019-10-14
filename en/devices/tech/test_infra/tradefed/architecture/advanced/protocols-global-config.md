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

# Load Protocols via Global Config

In order to understand this section, first study the Tradefed
[@Option](/devices/tech/test_infra/tradefed/fundamentals/options).

Typical options in Tradefed allow for test classes to receive additional
information from the XML configuration or command line. This feature allows
you to go one extra step and resolve some of this additional information if
necessary.

## File option example

Example File @option:

```java
@Option(name = 'config-file')
private File mConfigFile;
```

The above can be set via XML configuration:

```XML
<option name="config-file" value="/tmp/file" />
```

or via command:

```shell
--config-file /tmp/file
```

## Description

The feature allows you to resolve File-typed @Options that are remote into a
local file to be available seamlessly from a user standpoint.

For this to work, the file needs to be specified with a *remote style path*.
For example:

```shell
--config-file gs://bucket/tmp/file
```

This path points to a file within a Google Cloud Storage (GCS) bucket where
it's stored. Tradefed upon seeing that remote path, will attempt to download the
file locally and assign it to the @Option. This results in the `mConfigFile`
variable to now point to the local version of the file, which can be used by
the test.

If the remote file cannot be downloaded for any reason, Tradefed will throw
a `ConfigurationException` that will prevent the test from running. We consider
missing those files a critical failure since some test artifacts will also be
missing.

## Supported protocols

The officially supported protocol to download and its format are:

Google Cloud Storage, protocol: `gs`, format: `gs://<bucket name>/path`
## Limitations

The dynamic resolution of @Option currently supports only a limited number of
protocols and locations to download from. The resolution of @Option is currently
enabled only for the main XML Tradefed configuration. If running as a suite, current
modules (`AndroidTest.xml`) will not resolve the files. *This is meant to prevent
modules from creating some unknown dependencies*.

## Implementing a new protocol

The protocols that are supported have an implementation in Tradefed of the
[IRemoteFileResolver interface](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/config/remote/IRemoteFileResolver.java),
which defines the short tag of the protocol that will be matched in the
file path. For example, `gs` is used for the Google Cloud Storage protocol.

The protocols implemented can be added to
[DynamicRemoteFileResolver](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/config/DynamicRemoteFileResolver.java)
maps to officially turn on the support.
