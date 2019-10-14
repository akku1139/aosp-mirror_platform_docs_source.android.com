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

# Implementing Config File Schema API

The Android platform contains many XML files for storing config
data (for example, audio config). Many of the XML files are in the `vendor`
partition, but they're read in the `system` partition. In this case, the schema
of the XML file serves as the interface across the two partitions, and therefore
the schema must be explicitly specified and must evolve in a backward-compatible
manner.

Before Android {{ androidQVersionNumber }}, the platform didn’t provide
mechanisms to require specifying and using the XML schema, or to prevent
incompatible changes in the schema. Android {{ androidQVersionNumber }} provides
this mechanism, called Config File Schema API. This mechanism consists of a tool
called `xsdc` and a build rule called `xsd_config`.

The `xsdc` tool is an XML Schema Document (XSD) compiler. It parses an XSD file
describing the schema of an XML file and generates Java and C++ code. The
generated code parses XML files that conform to the XSD schema into a tree of
objects, each of which models an XML tag. XML attributes are modeled as fields
of the objects.

The `xsd_config` build rule integrates the `xsdc` tool into the build system.
For a given XSD input file, the build rule generates Java and C++ libraries. You
can link the libraries to the modules where the XML files that conform to the
XSD are read and used. You can use the build rule for your own XML files used
across the `system` and `vendor` partitions.

## Building Config File Schema API

This section describes how to build Config File Schema API.

### Configuring the xsd_config build rule in Android.bp {:#config-build-rule}

The `xsd_config` build rule generates the parser code with the `xsdc` tool. The
`xsd_config` build rule’s `package_name` property determines the package name of
the generated Java code.

Example `xsd_config` build rule in `Android.bp`:

```
xsd_config {
    name: "hal_manifest",
    srcs: ["hal_manifest.xsd"],
    package_name: "hal.manifest",
}
```

Example directory structure:

```
├── Android.bp
├── api
│   ├── current.txt
│   ├── last_current.txt
│   ├── last_removed.txt
│   └── removed.txt
└── hal_manifest.xsd
```

The build system generates an API list using the generated Java code and checks
the API against it. This API check is added to DroidCore and executed at `m -j`.

### Creating API lists files

The API checks require API lists files in the source code.

The API lists files include:

*   `current.txt` and `removed.txt` check whether the APIs are changed by
    comparing with generated API files at build time.
*   `last_current.txt` and `last_removed.txt` check whether the APIs are
    backward compatible by comparing with API files.

To create the API lists files:

1.  Create empty lists files.
1.  Run the command `make update-api`.

## Using generated parser code

To use the generated Java code, add `:` as a prefix to the `xsd_config` module
name in the Java `srcs` property. The package of the generated Java code is the
same as the `package_name` property.

```
java_library {
    name: "vintf_test_java",
    srcs: [
        "srcs/**/*.java"
        ":hal_manifest"
    ],
}
```

To use the generated C++ code, add the `xsd_config` module name to the
`generated_sources` and `generated_headers` properties. The namespace of the
generated C++ code is the same as the `package_name` property. For example, if
the `xsd_config` module name is `hal.manifest`, the namespace is
`hal::manifest`.

```
cc_library{
    name: "vintf_test_cpp",
    srcs: ["main.cpp"],
    generated_sources: ["hal_manifest"],
    generated_headers: ["hal_manifest"],
}
```

## Using the parser

To use the Java parser code, use the `read` or
<code>read{<var>class-name</var>}</code> method to return the class of the root
element. Parsing happens at this time.

```
import hal.manifest;

…

class HalInfo {
    public String name;
    public String format;
    public String optional;
    …
}

void readHalManifestFromXml(File file) {
    …
    try (InputStream str = new BufferedInputStream(new FileInputStream(file))) {
        Manifest manifest = read(str);
        for (Hal hal : manifest.getHal()) {
            HalInfor halinfo;
            HalInfo.name = hal.getName();
            HalInfo.format = hal.getFormat();
            HalInfor.optional = hal.getOptional();
            …
        }
    }
    …
}
```

To use the C++ parser code, first include the header file. The name of the
header file is the package name with periods (.) converted to underscores (\_).
Then use the `read` or <code>read{<var>class-name</var>}</code> method to return
the class of the root element. Parsing happens at this time. The return value is
a `std::optional<>`.

```
include "hal_manifest.h"

…
using namespace hal::manifest

struct HalInfor {
    public std::string name;
    public std::string format;
    public std::string optional;
    …
};

void readHalManifestFromXml(std::string file_name) {
    …
    Manifest manifest = *read(file_name.c_str());
    for (Hal hal : manifest.getHal()) {
        struct HalInfor halinfo;
        HalInfo.name = hal.getName();
        HalInfo.format = hal.getFormat();
        HalInfor.optional = hal.getOptional();
        …
    }
    …
}
```

All the APIs provided to use the parser are in `api/current.txt`. For
uniformity, all element and attribute names are converted to camel case (for
example, `ElementName`) and used as the corresponding variable, method, and
class name. The class of the parsed root element can be obtained using the
<code>read{<var>class-name</var>}</code> function. If there is only one root
element, then the function name is `read`. The value of a parsed subelement or
attribute can be obtained using the <code>get{<var>variable-name</var>}</code>
function.

## Generating parser code

In most cases, you don’t need to run `xsdc` directly. Use the `xsd_config` build
rule instead, as described in
[Configuring the xsd_config build rule in Android.bp](#config-build-rule). This
section explains the `xsdc` command line interface, just for completeness. This
might be useful for debugging.

You must give the `xsdc` tool the path to the XSD file, and a package. The
package is a package name in Java code and a namespace in C++ code. The options
to determine whether the generated code is Java or C are `-j` or `-c`,
respectively. The `-o` option is the path of the output directory.

```
usage: xsdc path/to/xsd_file.xsd [-c] [-j] [-o <arg>] [-p]
 -c,--cpp           Generate C++ code.
 -j,--java          Generate Java code.
 -o,--outDir <arg>  Out Directory
 -p,--package       Package name of the generated java file. file name of
                    generated C++ file and header
```

Example command:

```
$ xsdc audio_policy_configuration.xsd -p audio.policy -j
```
