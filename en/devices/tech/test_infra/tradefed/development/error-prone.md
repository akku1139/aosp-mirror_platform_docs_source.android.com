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

# Run Error Prone Bug Checker

If you are committing code for Trade Federation, chances are that you will run
into an Error Prone-related failure in presubmit at some point.

## What is Error Prone?

Error Prone is a static analysis tool for Java that can help find
potential issues within the Android code base. See the
[Error Prone GitHub project](https://github.com/google/error-prone) for an
overview of this distinct project.

## Why do we use it in Trade Federation?

There are a lot of contributors to TF. This is meant to ease code reviews and
ensure at least minimal quality in CLs.

Error Prone is enforced against all parts of TF, so it also helps to keep the
same standard everywhere.

## What do I need to look for?

The current list of rules enforced in TF are in:
[tools/tradefederation/core/error_prone_rules.mk](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/error_prone_rules.mk).

Find related information at [errorprone.info](https://errorprone.info/).

## How do I run it locally to check before submitting?

Use the following command: `make tradefed-all javac-check -j64
RUN_ERROR_PRONE=true`

Error Prone is enforced at build time, meaning the build will fail and the error
will appear if a rule is not being respected.
