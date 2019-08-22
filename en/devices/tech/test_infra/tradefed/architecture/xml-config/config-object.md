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

# Tradefed Configuration Object

[Tradefed XML configuration](/devices/tech/test_infra/tradefed/architecture/xml-config)
is parsed, and a `Configuration` object is created from it that describes the
complete configuration.

The object is described by the
[IConfiguration interface.](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/config/IConfiguration.java)
it will contain an instance of all the objects defined in the XML.

This example:

```xml
<configuration description="<description of the configuration>">
    <!-- A build provider that takes local device information -->
    <build_provider class="com.android.tradefed.build.BootstrapBuildProvider" />

    <!-- Some target preparation, disabled by default -->
    <target_preparer class="com.android.tradefed.targetprep.PreloadedClassesPreparer">
        <option name="disable" value="true" />
    </target_preparer>

    <!-- One test running some unit tests -->
    <test class="com.android.tradefed.testtype.HostTest">
        <option name="class" value="com.android.tradefed.build.BuildInfoTest" />
    </test>
</configuration>
```

Will result in:

*   `IConfiguration#getBuildProvider()` to return a `BootstrapBuildProvider`
    instance.
*   `IConfiguration#getTargetPreparers()` to return a list of `ITargetPreparer`
    containing an instance of `PreloadedClassesPreparer`.
*   `IConfiguration#getTests()` to return a list of `IRemoteTest` containing an
    instance of `HostTest`.

Every single object in the configuration object can be mapped to the XML
definition, so understanding the XML definition usually helps to understand
what to expect from the configuration object.
