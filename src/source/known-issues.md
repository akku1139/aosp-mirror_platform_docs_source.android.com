<!--
   Copyright 2010 The Android Open Source Project 

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

# Known Issues #

Even with our best care, small problems sometimes slip in. This page keeps
track of the known issues around using the Android source code.

## OpenGL libraries on Ubuntu ##

**Symptom**: The build fails with the following error:

    error: GL/glx.h: No such file or directory

**Cause**: Recent changes to the emulator code now require OpenGL
development headers and libraries.

**Fix**: Install the necessary OpenGL development package:

    $ sudo apt-get install libgl1-mesa-dev

## Script error when building for crespo ##

**Symptom**: A bash script error at the end of crespo builds:

    /bin/bash: 536870912 / 4096 -s 128 * (4096 -s 128+64): syntax error in expression (error token is "128 * (4096 -s 128+64)")

**Cause**: Overly creative stuffing of multiple parameters into a variable
that was only meant to contain a single one. That variable is used in multiple
locations and not all of them can deal with the complex value.

**Fix**: None at present. The warning is harmless as that part of the build
is only a sanity-check for the size of the system partition, and the system
partition on crespo is only about 20% filled by an AOSP build.
