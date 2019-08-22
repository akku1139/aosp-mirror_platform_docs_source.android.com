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

# Trade Federation Console

The Trade Federation Console is an optional component that allows you to inspect
the state of Trade Federation and what it sees, from the device states to the
current tests in progress.

It is a great tool for monitoring a large number of tests running in parallel
and understanding the progress of each test.

## Reaching the console

Once Tradefed is built, the `tradefed.sh` launcher script is accessible from
your path and by default will take you to the console.

The console presents itself with the `tf >` prompt.

## What can the console do?

The `help` of the console will always list the most up-to-date information.
A few interesting features of it are:

*   List the devices and how Tradefed sees their state: `list devices`
*   List the currently running invocations and their metadata: `list invocations`
*   Get the logs of all running invocations and Tradefed: `dump logs`

The console allows you to debug what is happening in Tradefed and the devices by
querying some states that are not shown together anywhere else.

## How to avoid the console?

In several cases the console is not needed, or example When running a one-time
command.

In such cases, `commandAndExit` can be added to the `tradefed.sh`
launcher script command in order to prevent the console from starting. This
extra argument is needed when attempting to run Tradefed as part of a script
or piping its output directly. Letting the console enabled while running
Tradefed from a script will triggered an inconsistent behavior and might
cause several issues.

```shell
tradefed.sh run commandAndExit <usual command>
```

## Console autocompletion

The console provides basic autocompletion of configuration names.

```shell
tf > run <hit TAB>
result in:
Display all 167 possibilities? (y or n)
```

By hitting TAB after the `run` you can get the full list of configurations
available. And if you have a partial name already typed in, the console will
print all the possibilities.

```shell
tf >run tf/<HIT TAB>

tf/acceptance            tf/fake                  tf/func
tf/stress                tf/uiautomator           tf/unit-runner
tf >run tf/
```

This is a useful when you don't remember an exact configuration name.
