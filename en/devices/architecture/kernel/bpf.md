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

# Extending the kernel with eBPF

Android includes an eBPF loader and library that loads eBPF
programs at boot time to extend kernel functionality. This can be used for
collecting statistics from the kernel, monitoring, or debugging.

## About eBPF

Extended Berkeley Packet Filter (eBPF) is an in-kernel virtual machine that
runs user-supplied eBPF programs that can be hooked to probes or events in
the kernel, collect useful statistics, and store the results in rich
data structures. A program is loaded into the kernel using the `bpf(2)` syscall
and is provided by the user as a binary blob of eBPF machine instructions.
The Android build system has support for compiling C programs to eBPF using
simple build file syntax described later.

More information about eBPF internals and architecture can be found at [Brendan
Gregg's eBPF page](http://www.brendangregg.com/ebpf.html){: .external}.

## Android BPF loader

During Android boot, all eBPF programs located at `/system/etc/bpf/` are
loaded.  These programs are binary objects built by the Android build system
from C programs accompanied with Android.bp files in the Android source tree.
The build system stores the generated objects at `/system/etc/bpf`, and
they become part of the system image.

### Format of an Android eBPF C program

An eBPF C program loaded on an Android device must have the following format:

<pre class="prettyprint">
#include &lt;bpf_helpers.h&gt;

&lt;... define one or more maps in the maps section, ex:
/* Define a map of type array, with 10 entries */
struct bpf_map_def SEC("maps") MY_MAPNAME = {
        .type = BPF_MAP_TYPE_ARRAY,
        .key_size = sizeof(int),
        .value_size = sizeof(uint32_t),
        .max_entries = 10,
};
... &gt;

SEC("PROGTYPE/PROGNAME")
int PROGFUNC(..args..) {
   &lt;body-of-code
    ... read or write to MY_MAPNAME
    ... do other things
   &gt;
}

char _license[] SEC("license") = "GPL"; // or other license
</pre>

Here, `MY_MAPNAME` is the name of your map variable. It's of type `struct
bpf_map_def` and tells the BPF loader what kind of map to create with what
parameters. This struct definition is provided by the `bpf_helpers.h` header
that the C program includes. The above code results in a creation of an array
map of 10 entries.

Next, the program defines a function `PROGFUNC`. When compiled, this function is
placed in a section. The section must have a name of the format
`PROGTYPE/PROGNAME`. `PROGTYPE` can be any one of the following. More types can
be found in the [Loader
source code](https://android.googlesource.com/platform/system/bpf/+/4845288a6e42e13b1bb8063923b24371c9e93397/libbpf_android/Loader.cpp){:
.external}.

<table class="responsive">
<tbody>
<tr>
<th>kprobe</th>
<td>Hooks <code>PROGFUNC</code> onto at a kernel instruction using the
kprobe infrastructure. <code>PROGNAME</code> must be the name of the kernel
function being kprobed. Refer to the <a
href="https://www.kernel.org/doc/Documentation/kprobes.txt"
class="external">kprobe kernel documentation</a> for more information about
kprobes.
</td>
</tr>

<tr>
<th>tracepoint</th>
<td>Hooks <code>PROGFUNC</code> onto a tracepoint. <code>PROGNAME</code> must be of
   the format <code>SUBSYSTEM/EVENT</code>.  For example, a tracepoint section for attaching
functions to scheduler context switch events would be 
  <code>SEC("tracepoint/sched/sched_switch")</code>, where <code>sched</code> is
  the name of the trace subsystem, and <code>sched_switch</code> is the name
  of the trace event. Check the <a
href="https://www.kernel.org/doc/Documentation/trace/events.txt" class="external">trace events kernel
documentation</a> for more information about tracepoints.
</td>
</tr>

<tr>
<th>skfilter</th>
<td>Program will function as a networking socket filter.</td>
</tr>

<tr>
<th>schedcls</th>
<td>Program functions as a networking traffic classifier.</td>
</tr>

<tr>
<th>cgroupskb, cgroupsock</th>
<td>Program runs whenever processes in a CGroup create an AF_INET or AF_INET6 socket.
</td>
</tr>

</tbody>
</table>

As an example of a complete C program, the following program creates a map and
defines a function `tp_sched_switch`, which can be attached to the
`sched:sched_switch trace` event ([see this
section](/devices/architecture/kernel/bpf#attaching_programs_to_tracepoints_and_kprobes)
for how to attach).
The program adds information about the latest task PID that ran on a particular CPU.
Name this `myschedtp.c`. We'll refer to this file later in this document.
  
<pre class="prettyprint">
#include &lt;linux/bpf.h&gt;
#include &lt;stdbool.h&gt;
#include &lt;stdint.h&gt;
#include &lt;bpf_helpers.h&gt;

struct bpf_map_def SEC("maps") cpu_pid = {
        .type = BPF_MAP_TYPE_ARRAY,
        .key_size = sizeof(int),
        .value_size = sizeof(uint32_t),
        /* Assume max of 1024 CPUs */
        .max_entries = 1024,
};

struct switch_args {
    unsigned long long ignore;
    char prev_comm[16];
    int prev_pid;
    int prev_prio;
    long long prev_state;
    char next_comm[16];
    int next_pid;
    int next_prio;
};

SEC("tracepoint/sched/sched_switch")
int tp_sched_switch(struct switch_args* args) {
    int key;
    uint32_t val;

    key = bpf_get_smp_processor_id();
    val = args-&gt;next_pid;

    bpf_map_update_elem(&cpu_pid, &key, &val, BPF_ANY);
    return 0;
}

char _license[] SEC("license") = "GPL";
</pre>

The license section is used by the kernel to verify if the program is compatible with the
kernel's license when the program makes use of BPF helper functions provided by the kernel. Set `_license` to your
project's license.

### Format of the Android.bp file
In order for the Android build system to build an eBPF .c program, an entry has
to be made in the Android.bp file of the project.

For example, to build an eBPF C program of name `bpf_test.c`, make the following
entry in your project's Android.bp file:
<pre class="prettyprint">
bpf {
    name: "bpf_test.o",
    srcs: ["bpf_test.c"],
    cflags: [
        "-Wall",
        "-Werror",
    ],
}
</pre>

This compiles the C program resulting in the object
`/system/etc/bpf/bpf_test.o`. On boot, the Android system automatically loads
the `bpf_test.o` program into the kernel.

### Files available in sysfs
During boot up, the Android system automatically loads all the eBPF objects from `/system/etc/bpf/`,
creates the maps that the program needs, and pins the loaded program with its maps to the bpf file system.
These files can then be used for further interaction with the eBPF program or reading maps. This section
describes the conventions used for naming these files and their locations in sysfs.

The following files are created and pinned:

*  For any programs loaded, assuming `PROGNAME` is the name of the program and `FILENAME` is the name of the eBPF C file, the Android loader creates and pins each program at `/sys/fs/bpf/prog_FILENAME_PROGTYPE_PROGNAME`.

   For example, for the above `sched_switch` tracepoint example in `myschedtp.c`, a program file will be created and pinned to
`/sys/fs/bpf/prog_myschedtp_tracepoint_sched_sched_switch`.

*  For any maps created, assuming `MAPNAME` is the name of the map and `PROGNAME` is the name of the eBPF C file, the Android loader creates and pins each map to `/sys/fs/bpf/map_FILENAME_MAPNAME`.

   For example, for the above `sched_switch` tracepoint example in `myschedtp.c`, a map file is created and pinned to
`/sys/fs/bpf/map_myschedtp_cpu_pid`.

*  The `bpf_obj_get()` in the Android BPF library can be used to obtained a file descriptor from these pinned /sys/fs/bpf file. This function returns a file descriptor, which can be used for further operations, such as reading maps or attaching a program to a tracepoint.

## Android BPF library
The Android BPF library is named `libbpf_android.so` and is part of the system
image. This library provides the user with low-level eBPF functionality needed
for creating and reading maps, creating probes, tracepoints, perf buffers etc.

### Attaching programs to tracepoints and kprobes
Once tracepoint and kprobe programs have been loaded (which is done automatically
at boot up as previously described), they need to be activated. To activate them,
first, use the `bpf_obj_get()` API to obtain the program fd from the pinned file's
location (see the [Files available in sysfs](/devices/architecture/kernel/bpf#files_available_in_sysfs)
section). Next, call the `bpf_attach_tracepoint()`
API in the BPF library, passing it the program fd and the tracepoint name.

For example, to attach the `sched_switch` tracepoint defined in the `myschedtp.c`
source file in the example above, do the following (error checking is not shown):

<pre class="prettyprint">
  char *tp_prog_path = "/sys/fs/bpf/prog_myschedtp_tracepoint_sched_sched_switch";
  char *tp_map_path = "/sys/fs/bpf/map_myschedtp_cpu_pid";

  // Attach tracepoint and wait for 4 seconds
  int mProgFd = bpf_obj_get(tp_prog_path);
  int mMapFd = bpf_obj_get(tp_map_path);
  int ret = bpf_attach_tracepoint(mProgFd, "sched", "sched_switch");
  sleep(4);

  // Read the map to find the last PID that ran on CPU 0
  android::bpf::BpfMap<int, int> myMap(mMapFd);
  printf("last PID running on CPU %d is %d\n", 0, myMap.readValue(0));
</pre>

### Reading from the maps

BPF maps support arbitrary complex key and value structures or types. The
Android BPF library includes an `android::BpfMap` class that makes use of C++
templates to instantiate `BpfMap` based on the key and value's type for the
map in question. The above code shows an example of using a `BpfMap` with key and
value as integers. The integers can also be arbitrary structures.

Thus the templatized `BpfMap` class makes it easy to define a custom `BpfMap`
object suitable for the particular map. The map can then be accessed using the
custom-generated functions which are type aware, resulting in cleaner code.

For more information about `BpfMap`, refer to the
[Android sources].(https://android.googlesource.com/platform/system/bpf/+/75b410bdf186263fa4e05e079bfba44578622c33/libbpf/include/bpf/BpfMap.h){: .external}

## Debugging issues

During boot time, several messages related to BPF loading are logged. If the
loading process fails for any reason, a detailed log message is provided
in logcat. Filtering the logcat logs by "bpf" prints all the messages and
any detailed errors during load time, such as eBPF verifier errors.

## Users of eBPF in Android

Currently there are two eBPF C programs in Android that you can refer to for examples.

The `netd` [eBPF C
program](https://android.googlesource.com/platform/system/bpf/+/4845288a6e42e13b1bb8063923b24371c9e93397/progs/netd.c){: .external}
is used by the networking daemon (netd) in Android for various purposes such as
socket filtering and statistics gathering. To see how this programs is used, check the [eBPF traffic
monitor](https://www.google.com/url?sa=D&q=https%3A%2F%2Fsource.android.com%2Fdevices%2Ftech%2Fdatausage%2Febpf-traffic-monitor){: .external}
sources.

The `time_in_state` [eBPF C
program](https://android.googlesource.com/platform/system/bpfprogs/+/482dfa1ca63eb209866ff3a7b3aeb3daada7b4e1/time_in_state.c){: .external}
calculates the amount of time an Android app spends at different
CPU frequencies which is used to calculate power. This program is currently under development.

## Licensing considerations

If you want to contribute an eBPF C program, it should be contributed to the right
project depending on its license. A GPL licensed eBPF C program should be
contributed to the `system/bpfprogs` AOSP project. On the other hand, if the program
is Apache licensed, it should be contributed to `system/bpf` AOSP project.
