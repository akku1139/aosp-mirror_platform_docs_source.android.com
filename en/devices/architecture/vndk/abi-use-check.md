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

# Prebuilt ABI Usages Checker

Android shared libraries evolve from time to time. Keeping prebuilt binaries
up-to-date requires considerable effort. In Android {{ androidPVersionNumber }}
or earlier, the prebuilt binaries that depend on removed libraries or ABIs only
fail to link at run-time. Developers have to trace the logs to find the outdated
prebuilt binaries. In Android {{ androidQVersionNumber }}, a symbol-based ABI
usages checker is introduced. The checker can detect outdated prebuilt binaries
at build-time, so that shared library developers can know which prebuilt
binaries might be broken by their change and which prebuilt binaries must be
re-built.

## Symbol-based ABI usages checker

The symbol-based ABI usages checker emulates the Android dynamic linker on host.
The checker links the prebuilt binary with the dependencies of the prebuilt
binary and checks whether all undefined symbols are resolved.

First, the checker checks the target architecture of the prebuilt binary. If
the prebuilt binary does not target ARM, AArch64, x86, or x86-64 architecture,
the checker skips the prebuilt binary.

Second, the dependencies of the prebuilt binary must be listed in
`LOCAL_SHARED_LIBRARIES` or `shared_libs`. The build system resolves the module
names to the matching variant (i.e. `core` vs. `vendor`) of the shared
libraries.

Third, the checker compares the `DT_NEEDED` entries to `LOCAL_SHARED_LIBRARIES`
or `shared_libs`. In particular, the checker extracts the `DT_SONAME` entry from
each shared libraries and compares these `DT_SONAME` with the `DT_NEEDED`
entries recorded in the prebuilt binary. If there is a mismatch, an error
message is emitted.

Fourth, the checker resolves the undefined symbols in the prebuilt binary. Those
undefined symbols must be defined in one of the dependencies and the symbol
binding must be either `GLOBAL` or `WEAK`. If an undefined symbol cannot be
resolved, an error message is emitted.

## Prebuilts module properties

Dependencies of the prebuilt binary must be specified in one of the following:

*   Android.bp: `shared_libs: ["libc", "libdl", "libm"],`
*   Android.mk: `LOCAL_SHARED_LIBRARIES := libc libdl libm`

If the prebuilt binary is designed to have some **unresolvable undefined
symbols**, specify one of the following:

*   Android.bp: `allow_undefined_symbols: true,`
*   Android.mk: `LOCAL_ALLOW_UNDEFINED_SYMBOLS := true`

To have the prebuilt binary skip the ELF file check, specify one of the
following:

*   Android.bp: `check_elf_files: false,`
*   Android.mk: `LOCAL_CHECK_ELF_FILES := false`

## Run the checker

To run the checker, set the environment variable `CHECK_ELF_FILES` to `true` and
run `make check-elf-files`:

```
CHECK_ELF_FILES=true make check-elf-files
```

To enable the checker by default, add `PRODUCT_CHECK_ELF_FILES` to
`BoardConfig.mk`:

```
PRODUCT_CHECK_ELF_FILES := true
```

Prebuilts are automatically checked during the build process of Android:

```
make
```
