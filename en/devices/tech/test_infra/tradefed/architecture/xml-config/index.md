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

# High-level structure of Tradefed XML configuration

Tradefed's configurations follow an XML structure to describe the test to be run
and the preparation/setup steps to be done.

In theory, everything can be defined in the XML for a single command. But in
practice, it is more practical to have base template XML files and customize
them with extra command line parameters.

## Structure

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

    <!-- [OPTIONAL] -->
    <logger class="com.android.tradefed.log.FileLogger">
        <option name="log-level" value="VERBOSE" />
        <option name="log-level-display" value="VERBOSE" />
    </logger>

    <!-- [OPTIONAL] -->
    <log_saver class="com.android.tradefed.result.FileSystemLogSaver" />

    <!-- As many reporters as we want -->
    <result_reporter class="com.android.tradefed.result.ConsoleResultReporter" />
    <result_reporter class="com.android.tradefed.result.suite.SuiteResultReporter" />
    <result_reporter class="com.android.tradefed.result.MetricsXMLResultReporter"/>
</configuration>
```

The overall Tradefed XML is delimited by `<configuration>` tags. `Tradefed
objects` are defined in their own tags, for example: `build_provider`,
`target_preparer`, `test`, etc. Their individual purposes are described in more
detail in the [Architecture](/devices/tech/test_infra/tradefed/architecture/)
section.

Each object has the Java class associated with the object defined in `class=`
that is resolved at runtime; so as long as the JAR file containing the class is
on the Tradefed Java classpath when running, it will be found and resolved.

## Orders of Tradefed objects

The order of the different tags does not matter. For example, it makes no
difference if `build_provider` is specified after `target_preparer`. The flow of
the test invocation is enforced by the harness itself, so it will always call
them in the right order.

The order of objects with the **same tag does matter**. For example, two
`target_preparer` objects defined will be called in their order of definition in
the XML. It is important to understand this as it can change the end state of
the device setup. For example, *flashing then installing an apk* would not be the
same as *installing an apk and flashing* since flashing would wipe the device.
