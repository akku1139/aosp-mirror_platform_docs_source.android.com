<!--
   Copyright 2011 The Android Open Source Project

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

# Miscellaneous notes about the Android build system #

The handling of user, [user]debug, eng and tests builds happens through a
parallel legacy mechanism called tags, which is another way to control
the interaction between module definitions and the core build system.

Since we're using a flat instance of make and since everything in GNU make
is global, it's possible to do lots of things from within any kind of
makefile, like setting PRODUCT_ variables within a module definition file,
calling into some private functions of the core build system directly,
declaring rules and dependencies directly... Unfortunately, those are
surprisingly (or UNsurpsisingly) fragile and should not be done.

Most devices setups rely on two kinds of legacy mechanisms that shouldn't
be used for new devices: system.prop files are an alternative way to
specify system properties, but those should be listed in product definition
files instead. AndroidBoard.mk files are Android.mk files that are
conditionally included only when building the matching device.

The Android build system aggressively attempts to compile all the modules
it's aware of, even if those modules aren't necessary for the current
target. The fundamental reason is that most engineers tend to focus on a
single configuration at any given time, and yet through their work they
could be causing build issues in modules that aren't strictly necessary for
their current configuration. Building modules aggressively makes it
possible to detect as many such build issues as possible without forcing
engineers to locally build multiple configurations. Because of that, it's
important to make as many modules visible to the core build system at all
times, even if they're not strictly necessary in all configurations.
That requires a bit of discipline to avoid naming conflicts between
device-specific modules.

Generally speaking, it's really important to try to avoid anything out of
the ordinary in the product definitions, board definitions or module
definitions. Things might look like they work at any point in time,
but might cause problems when trying to later improve the build system.
Given the size of the build system and the fact that it gets modified by
everyone, it's impossible for anyone to have a global view over everything
that happens in the build system.
