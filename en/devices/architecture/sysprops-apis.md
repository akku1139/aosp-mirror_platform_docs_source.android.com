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

# Implementing System Properties as APIs

System properties provide a convenient way to share information, usually
configurations, system-wide. Each partition can use its own system properties
internally. A problem can happen when properties are accessed across partitions,
such as `/vendor` accessing `/system`-defined properties. Since Android 8.0,
some partitions, such as `/system`, can be upgraded, while `/vendor` is left
unchanged. Because system properties are just a global dictionary of string
key/value pairs with no schema, it's difficult to stabilize properties. The
`/system` partition could change or remove properties that the `/vendor`
partition depends on without any notice.

Starting with the Android {{ androidQVersionNumber }} release, system properties
accessed across partitions are schematized into Sysprop Description files, and
APIs to access properties are generated as concrete functions for C++ and
classes for Java. These APIs are more convenient to use because no magic strings
(such as `ro.build.date`) are needed for access, and because they can be
statically typed. ABI stability is also checked at build time, and the build
breaks if incompatible changes happen. This check acts as explicitly defined
interfaces between partitions. These APIs can also provide consistency between
Java and C++.

## Defining system properties as APIs

Define system properties as APIs with Sysprop Description files (`.sysprop`),
which use a TextFormat of protobuf, with the following schema:

```
// File: sysprop.proto

syntax = "proto3";

package sysprop;

enum Access {
  Readonly = 0;
  Writeonce = 1;
  ReadWrite = 2;
}

enum Owner {
  Platform = 0;
  Vendor = 1;
  Odm = 2;
}

enum Scope {
  Public = 0;
  System = 1;
  Internal = 2;
}

enum Type {
  Boolean = 0;
  Integer = 1;
  Long = 2;
  Double = 3;
  String = 4;
  Enum = 5;

  BooleanList = 20;
  IntegerList = 21;
  LongList = 22;
  DoubleList = 23;
  StringList = 24;
  EnumList = 25;
}

message Property {
  string api_name = 1;
  Type type = 2;
  Access access = 3;
  Scope scope = 4;
  string prop_name = 5;
  string enum_values = 6;
  bool integer_as_bool = 7;
}

message Properties {
  Owner owner = 1;
  string module = 2;
  repeated Property prop = 3;
}
```

One Sysprop Description file contains one properties message, which describes a
set of properties. The meaning of its fields are as follows.

<table>
  <tr>
   <th>Field</th>
   <th>Meaning</th>
  </tr>
  <tr>
  <td><code>owner</code>
   </td>
   <td>Set to the  partition that owns the properties: <code>Platform</code>,
   <code>Vendor</code>, or <code>Odm</code>.
   </td>
  </tr>
  <tr>
  <td><code>module</code>
   </td>
   <td>Used to create a namespace (C++) or static final class (Java) in which
   generated APIs are placed. For example, <code>com.android.sysprop.BuildProperties</code>
   will be namespace <code>com::android::sysprop::BuildProperties</code> in C++,
   and the <code>BuildProperties</code> class in the package in
   <code>com.android.sysprop</code> in Java.
   </td>
  </tr>
  <tr>
  <td><code>prop</code>
   </td>
   <td>List of properties.
   </td>
  </tr>
</table>

The meanings of the `Property` message fields are as follows.

<table>
  <tr>
   <th>Field</th>
   <th>Meaning</th>
  </tr>
  <tr>
  <td><code>api_name</code>
   </td>
   <td>The name of the generated API.
   </td>
  </tr>
  <tr>
  <td><code>type</code>
   </td>
   <td>The type of this property.
   </td>
  </tr>
  <tr>
   <td><code>access<code>
   </td>
   <td><code>Readonly</code>: Generates getter API only
<p>
<code>Writeonce</code>, <code>ReadWrite</code>: Generates setter API with internal scope
<p>
Note: Properties with the prefix <code>ro.</code> may not use <code>ReadWrite</code> access.
   </td>
  </tr>
  <tr>
  <td><code>scope</code>
   </td>
   <td><code>Internal</code>: Only the owner can access.
<p>
<code>System</code>: Only bundled modules (not built against SDK or NDK) can access.
<p>
<code>Public</code>: Everyone can access, except for NDK modules.
   </td>
  </tr>
  <tr>
  <td><code>prop_name</code>
   </td>
   <td>The name of the underlying system property, for example <code>ro.build.date</code>.
   </td>
  </tr>
  <tr>
   <td><code>enum_values</code>
   </td>
   <td>(<code>Enum</code>, <code>EnumList</code> only) A bar(|)-separated string
   that consists of possible enum values. For example, <code>value1|value2</code>.
   </td>
  </tr>
  <tr>
   <td><code>integer_as_bool</code>
   </td>
   <td>(<code>Boolean</code>, <code>BooleanList</code> only) Make setters use
   <code>0</code> and <code>1</code> instead of <code>false</code> and </code>true</code>.
   </td>
  </tr>
</table>

Each type of property maps to the following types in C++ and Java.

<table>
  <tr>
   <th>Type</th>
   <th>C++</th>
   <th>Java</th>
  </tr>
  <tr>
   <td>Boolean
   </td>
   <td><code>std::optional&lt;bool&gt;</code>
   </td>
   <td><code>Optional&lt;Boolean&gt;</code>
   </td>
  </tr>
  <tr>
   <td>Integer
   </td>
   <td><code>std::optional&lt;std::int32_t&gt;</code>
   </td>
   <td><code>Optional&lt;Integer&gt;</code>
   </td>
  </tr>
  <tr>
   <td>Long
   </td>
   <td><code>std::optional&lt;std::int64_t&gt;</code>
   </td>
   <td><code>Optional&lt;Long&gt;</code>
   </td>
  </tr>
  <tr>
   <td>Double
   </td>
   <td><code>std::optional&lt;double&gt;</code>
   </td>
   <td><code>Optional&lt;Double&gt;</code>
   </td>
  </tr>
  <tr>
   <td>String
   </td>
   <td><code>std::optional&lt;std::string&gt;</code>
   </td>
   <td><code>Optional&lt;String&gt;</code>
   </td>
  </tr>
  <tr>
   <td>Enum
   </td>
   <td><code>std::optional&lt;{api_name}_values&gt;</code>
   </td>
   <td><code>Optional&lt;{api_name}_values&gt;</code>
   </td>
  </tr>
  <tr>
   <td>T List
   </td>
   <td><code>std::vector&lt;std::optional&lt;T&gt;</code>
   </td>
   <td><code>List&lt;T&gt;</code>
   </td>
  </tr>
</table>

Here's an example of a Sysprop Description file defining three properties:

```
# File: android/sysprop/PlatformProperties.sysprop

owner: Platform
module: "android.sysprop.PlatformProperties"
prop {
    api_name: "build_date"
    type: String
    prop_name: "ro.build.date"
    scope: System
    access: Readonly
}
prop {
    api_name: "date_utc"
    type: Integer
    prop_name: "ro.build.date_utc"
    scope: Internal
    access: Readonly
}
prop {
    api_name: "device_status"
    type: Enum
    enum_values: "on|off|unknown"
    prop_name: "device.status"
    scope: Public
    access: ReadWrite
}
```

## Defining system properties libraries

You can now define `sysprop_library` modules with Sysprop Description files.
`sysprop_library` serves as an API for both C++ and Java. The build system
internally generates one `java_sdk_library` and one `cc_library` for each
instance of `sysprop_library`.

```
// File: Android.bp
sysprop_library {
    name: "PlatformProperties",
    srcs: ["android/sysprop/PlatformProperties.sysprop"],
    property_owner: "Platform",
    api_packages: ["android.sysprop"],
    vendor_available: true,
}
```

You must include API lists files in the source for API checks. To do this,
create API files and an `api` directory. Put the `api` directory in the same
directory as `Android.bp`. The API filenames are `current.txt`, `removed.txt`,
`system-current.txt`, `system-removed.txt`, `test-current.txt`, and
`test-removed.txt`. You can update the API files by running the `make
update-api` command. The build system checks whether the APIs are changed by
comparing these API files with generated API files at build time. Here's an
example directory and file organization:

```
├── api
│   ├── current.txt
│   ├── removed.txt
│   ├── system-current.txt
│   ├── system-removed.txt
│   ├── test-current.txt
│   └── test-removed.txt
└── Android.bp
```

Both Java and C++ client modules can link against `sysprop_library` to use
generated APIs. The build system creates links from clients to generated C++ and
Java libraries, thus giving clients access to generated APIs.

```
java_library {
    name: "JavaClient",
    srcs: ["foo/bar.java"],
    libs: ["PlatformProperties"],
}

cc_binary {
    name: "cc_client",
    srcs: ["baz.cpp"],
    shared_libs: ["PlatformProperties"],
}
```

In the above example, you could access defined properties as follows.

Java example:

```
import android.sysprop.PlatformProperties;

…

static void foo() {
    …
    Integer dateUtc = PlatformProperties.date_utc().orElse(-1);
    …
}
…
```

C++ example:

```
#include <android/sysprop/PlatformProperties.sysprop.h>
using namespace android::sysprop;

…

void bar() {
    …
    std::string build_date = PlatformProperties::build_date().value_or("(unknown)");
    …
}
…
```
