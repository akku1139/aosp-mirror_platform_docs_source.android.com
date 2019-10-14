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

# Contribute Non-Core Code

To enable teams that contribute non-core src to the tradefederation projects
full ownership of the review process, the following projects have been created
with open +2 rights for all teams. This relieves the core tradefederation team
from the burden of all code reviews un-related to the core framework while also
allowing the other teams to iterate faster in their review cycle.

**Non-core src** is defined as code that is not required by the tradefederation
framework to be functional (e.g. custom tests, configs, specific test
utilities).

> ***IMPORTANT*** Non-core src should not extend core tradefederation classes.
> Doing so impacts future refactoring/clean up. If you are unsure if your code
> belongs in core or contrib, reach out to android-tradefed@ for clarification.
> The core tradefederation team is happy to advise and receive feature requests.
>
> An example core tradefederation class would be any class in the
> ```com.google.android.tradefed.build``` package like:
> ```com.google.android.tradefed.build.LaunchControlProvider```
>
> Again, please reach out if you are unclear what would be considered a core
> class to android-tradefed@.

[TOC]

## Contrib projects' paths

*   [platform/tools/tradefederation/contrib](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/refs/heads/master)

## Who are these contrib projects for?

If you currently work in the tradefederation projects writing tests/test
utilities/configs, these projects were created for you.

## Code reviews in contrib projects

The goal of the contrib projects is to allow you to do development in Tradefed
without needing the review of the core team (android-tradefed@). So we expect
your team or anybody familiar with your context to perform the code reviews on
your CLs.

Always feel free to reach out to android-tradefed@ if stuck or need guidance on
a particular case, but do not rely on it by default to do your code review in
contrib. **Tradefed team has no SLO when it comes to code reviews in contrib.**

## Where can I start working on these projects?

They have been added to the following branch manifests and are already part of
master platform checkout so if you don't see the projects in your environment,
you're a repo sync away from contributing.

*   master
*   tradefed
*   oc-dev
*   oc-dev-plus-aosp
*   nyc-mr2-dev-plus-aosp
*   master-daydream-dev
*   master-without-vendor
*   wear-master


## Development and Testing

Development in contrib is expected to have the same quality bar as anywhere else
in the Android repositories:

*   Respect the Android formatting guidelines
*   Code is tested and submitted with tests
*   Design is thoughtful and makes sense

### How to test locally in contrib?

#### AOSP

In aosp, unit tests of contrib are located in
[platform/tools/tradefederation/contrib/tests/src/](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/refs/heads/master/tests/src/com/android)
and unit tests should be added to
[com.android.tradefed.prodtests.UnitTests](https://android.googlesource.com/platform/tools/tradefederation/contrib/+/refs/heads/master/tests/src/com/android/tradefed/prodtests/UnitTests.java)
to be picked up in presubmit and local testing scripts.

Aosp local scripts after running lunch:

```
tools/tradefederation/core/tests/run_tradefed_aosp_presubmit.sh
```

## Build rules update to contrib projects

The build rules (makefiles) are under their own `build/` folder and locked by an
`OWNERS` file that will prevent your from modifying them without an extra review
from the core team. This is the only limitation to the contrib project.

We need this review to ensure no unexpected dependencies are added to the
overall Tradefed projects without the knowledge or agreement from the core team.
If you really need some new dependencies to be added, please contact
`android-tradefed@` to look into your use cases and advise you.
