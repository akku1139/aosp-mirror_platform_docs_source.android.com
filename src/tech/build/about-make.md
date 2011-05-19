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

# About GNU make as used for Android #

As a quick introduction, before we talk about the Android build system
itself, here are a few notes about GNU make itself that will help
understand how Android gets built.

## General GNU make architecture ##

GNU make is 2-pass tool:

 - a parser (front end)

 - a rules engine (back end)

At the front end, the parser reads the makefiles and generates build
rules for targets. A build rule essentially contains 3 things: the target
being built (the "current" target), the targets that need to be built
before the current target ("dependencies"), and the commands to execute
to build the current target.

At the back end, the rules engine recursively finds the rules and executes
the commands to build the goal's dependencies, followed finally by the
commands to build the goal itself. GNU make has shortcuts to not build targets
that match the names of existing files that are considered up-to-date, which
is how it usually knows how to only rebuild what needs to be rebuilt.

## Strengths and weaknesses ##

GNU make is both a powerful and a limited tool. For a project as large
as Android, we need all the power that it offers, and we also push it to
its limits.

In the front-end, the language is somewhat restrictive. The biggest difficulty
for Android is that GNU make doesn't have true functions, and therefore also
doesn't have local variables. We have 125k lines of makefiles in Android,
as counted in Google's internal master tree in mid-2011. In those conditions,
it's critically important to follow conventions very closely. We're really
talking about 125k lines of code written using only global variables.

In the back-end, there are also a few quirks. GNU make can't fully directly
handle rules that output multiple files. It doesn't deal well with situations
where a same files is accessed through multiple paths. It's confused when
commands handle an entire directory (or most similar structures) as an
input.

What we're seeing, really, is that GNU make is a great tool to handle
makefiles of 1k lines, scales well to 10k lines, and is uncomfortable
but workable at 100k lines. It probably wouldn't be practical for 1M lines.

## Moving to another tool ##

Given the large size of the overall Android build system, we can't
underestimate the very large effort that it would take to move to any other
tool. Even making changes in the current build system can end up being very
time-consuming.
