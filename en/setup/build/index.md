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

# Soong Build System

Before the Android 7.0 release, Android used
[GNU Make](https://www.gnu.org/software/make/){: .external}
exclusively to describe and execute its build rules. The Make build system is
widely supported and used, but at Android's scale became slow, error-prone,
unscalable, and difficult to test. The
[Soong build system](https://android.googlesource.com/platform/build/soong/+/refs/heads/master/README.md){: .external}
provides the flexibility required for Android builds.

## What is Soong?

The
[Soong build system](https://android.googlesource.com/platform/build/soong/+/refs/heads/master/README.md){: .external}
was introduced in Android 7.0 (Nougat) to replace Make. This is still a work in
progress.

See the
[Android Make Build System](https://android.googlesource.com/platform/build/+/master/README.md){: .external}
description in the Android Open Source Project (AOSP) for general
[instructions](https://android.googlesource.com/platform/build/+/master/Usage.txt){: .external}
and
[build system changes for Android.mk writers](https://android.googlesource.com/platform/build/+/master/Changes.md){: .external}
to learn of modifications needed to adapt from Make to Soong.

See
[Simple Build Configuration](/compatibility/tests/development/blueprints)
for example Soong configuration (Blueprint or `.bp`) files and the
[Soong reference files](https://ci.android.com/builds/latest/branches/aosp-build-tools/targets/linux/view/soong_build.html){: .external} for complete details.

Caution: Until Android fully converts from Make to Soong, the Make product
configuration must specify `PRODUCT_SOONG_NAMESPACES` value. See the
[Namespace modules](#namespace_modules) section for instructions.

## Android.bp file format

By design, `Android.bp` files are simple. They contain no conditionals nor
control flow statements - all complexity is handled by build logic written in
Go. The syntax and semantics of `Android.bp` files are similar to
[Bazel BUILD files](https://www.bazel.io/versions/master/docs/be/overview.html){: .external}
when possible.

### Modules

A module in an `Android.bp` file starts with a
[module type](https://ci.android.com/builds/latest/branches/aosp-build-tools/targets/linux/view/soong_build.html){: .external}
followed by a set of properties in `name: value,` format:

```
cc_binary {
    name: "gzip",
    srcs: ["src/test/minigzip.c"],
    shared_libs: ["libz"],
    stl: "none",
}
```

Every module must have a `name` property, and the value must be unique across
all `Android.bp` files, with the only two exceptions being the ones in
namespaces and prebuilt modules.

For a list of valid module types and their properties, see the
[Soong Modules Reference](https://ci.android.com/builds/latest/branches/aosp-build-tools/targets/linux/view/soong_build.html){: .external}.

### Types

Variables and properties are strongly typed, with variables dynamically based on
the first assignment, and properties set statically by the module type. The
supported types are:

*   Bool (`true` or `false`)
*   Integers (`int`)
*   Strings (`"string"`)
*   Lists of strings (`["string1", "string2"]`)
*   Maps (`{key1: "value1", key2: ["value2"]}`)

Maps may contain values of any type, including nested maps. Lists and maps may
have trailing commas after the last value.

### Globs

Properties that take a list of files, such as `srcs`, can also take glob
patterns. Glob patterns can contain the normal UNIX wildcard `*`, for example
`*.java`. glob patterns can also contain a single `**` wildcard as a path
element, which matches zero or more path elements. For example,
`java/**/*.java` matches both:
`java/Main.java`
`java/com/android/Main.java`

### Variables

An `Android.bp` file may contain top-level variable assignments:

```
gzip_srcs = ["src/test/minigzip.c"],
cc_binary {
    name: "gzip",
    srcs: gzip_srcs,
    shared_libs: ["libz"],
    stl: "none",
}
```

Variables are scoped to the remainder of the file they are declared in, as well
as any child Blueprint files. Variables are immutable with one exception - they
can be appended to with a += assignment, but only before they have been
referenced.

### Comments

`Android.bp` files can contain C-style multiline`/* */` and C++ style
single-line `//` comments.

### Operators

Strings, lists of strings, and maps can be appended using the + operator.
Integers can be summed up using the + operator. Appending a map produces the
union of keys in both maps, appending the values of any keys that are present in
both maps.

### Conditionals

Soong doesn't support conditionals in `Android.bp` files. Instead,
complexity in build rules that would require conditionals are handled in Go,
where high-level language features can be used, and implicit dependencies
introduced by conditionals can be tracked. Most conditionals are converted to a
map property, where one of the values in the map is selected and appended
to the top-level properties.

For example, to support architecture-specific files:

```
cc_library {
    ...
    srcs: ["generic.cpp"],
    arch: {
        arm: {
            srcs: ["arm.cpp"],
        },
        x86: {
            srcs: ["x86.cpp"],
        },
    },
}
```

### Formatter

Soong includes a canonical formatter for Blueprint files, similar to
[gofmt](https://golang.org/cmd/gofmt/){: .external}. To recursively reformat all
`Android.bp` files in the current directory, run:

```
bpfmt -w .
```

The canonical format includes four-space indents, newlines after every element
of a multi-element list, and a trailing comma in lists and maps.

## Special Modules

Some special module groups have unique characteristics.

### Defaults modules

A defaults module can be used to repeat the same properties in multiple modules.
For example:

```
cc_defaults {
    name: "gzip_defaults",
    shared_libs: ["libz"],
    stl: "none",
}

cc_binary {
    name: "gzip",
    defaults: ["gzip_defaults"],
    srcs: ["src/test/minigzip.c"],
}
```

### Prebuilt modules

Some prebuilt module types allow a module to have the same name as its
source-based counterparts. For example, there can be a `cc_prebuilt_binary`
named 'foo' when there is already a `cc_binary` with the same name. This gives
developers the flexibility to choose which version to include in their final
product. If a build configuration contains both versions, the `prefer` flag
value in the prebuilt module definition dictates which version has priority.
Note that some prebuilt modules have names that don't start with `prebuilt`,
such as `android_app_import`.

### Namespace modules

Until Android fully converts from Make to Soong, the Make product configuration
must specify a `PRODUCT_SOONG_NAMESPACES` value. Its
value should be a space-separated list of namespaces that Soong exports to Make
to be built by the `m` command. After Android's conversion to Soong is complete,
the details of enabling namespaces could change.

Soong provides the ability for modules in different directories to specify the
same name, as long as each module is declared within a separate namespace. A
namespace can be declared like this:

```
soong_namespace {
    imports: ["path/to/otherNamespace1", "path/to/otherNamespace2"],
}
```

Note that a namespace does not have a name property; its path is automatically
assigned as its name.

Each Soong module is assigned a namespace based on its location in the tree.
Each Soong module is considered to be in the namespace defined by the
`soong_namespace` found in an `Android.bp` file in the current directory or
closest ancestor directory. If no such `soong_namespace` module is found, the
module is considered to be in the implicit root namespace.

Here is an example: Soong attempts to resolve dependency D declared by module M
in namespace N that imports namespaces I1, I2, I3…

1.  Then if D is a fully-qualified name of the form `//namespace:module`, only
    the specified namespace will be searched for the specified module name.
1.  Otherwise, Soong will first look for a module named D declared in namespace
    N.
1.  If that module does not exist, Soong will look for a module named D in
    namespaces I1, I2, I3…
1.  Lastly, Soong will look in the root namespace.
