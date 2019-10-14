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

# Templates and Includes in Tradefed XML Configuration

Creating one monolithic XML configuration to define a test is not always
practical. If you want to re-use part of the setup to run similar tests, you
would be forced to copy and maintain two giant XML files.

This is where `template` and `include` tags in Tradefed XML Configuration
definition come in handy. They allow you to set placeholders in some XML
configuration to add part of another XML configuration.

## Example Definition For Templates

```xml
<configuration description="Common base configuration for local runs with minimum overhead">
    <build_provider class="com.android.tradefed.build.BootstrapBuildProvider" />

    <template-include name="preparers" default="empty" />

    <template-include name="test" default="empty" />

    <template-include name="reporters" default="empty" />
</configuration>
```

Templates are placeholders with a `name` to reference them, and an optional
`default` field. The default field defines the default replacement XML that
should be used.

In order to replace a template for a given configuration, the following command
parameter needs to be added to the command line:

```
--template:map <name of template>=<replacement XML config path>

--template:map preparers=empty
```

For example:

```
<template-include name="preparers" default="empty" />
```

The `empty` reference in this case refers to the `empty.xml` configuration that
contains nothing; we use it as our reference to *replace with nothing*.

The path of XML configs can be absolute or relative to the `res/config` folder
inside Tradefed's JAR resources. Here are a few of their locations:

*   tools/tradefederation/core/res/config
*   tools/tradefederation/core/tests/res/config
*   tools/tradedeferation/contrib/res/config

## Example Definition of Includes

```xml
<configuration description="Common base configuration for local runs with minimum overhead">
    <build_provider class="com.android.tradefed.build.BootstrapBuildProvider" />

    <include name="empty"/>
</configuration>
```

Includes are simpler than Templates as they require no command line arguments;
they directly expand the referenced XML in the `name` tag. Similar to templates,
the path to the config can be absolute or relative. Still, for `includes` we
recommend using only relative paths as they are more portable in Tradefed.
Absolute paths would not be valid if Tradefed is moved to another machine.

## Misconfiguration

In case of misconfiguration, such as when the replacement XML cannot be found,
Tradefed will throw a `ConfigurationException` with description of what seems to
be missing or misconfigured.
