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

# Dumping User and Kernel Stacks on Kernel Events

Dumping the native kernel and userspace stack when a certain code path in the
kernel is executed can help with understanding the code flow when you are debugging
a certain behavior, such as an error you found in the logs. One such case is when
you notice SELinux denial messages in logs but want to know which path triggered
it to better understand why it happened.

In this article we will show you how to use kernel instrumentation and BPF Compiler Collection (BCC) to
dump both the user and kernel stack when a kernel event occurs in an Android
system. BCC is a toolkit for creating efficient kernel tracing.

## Installing adeb

The [adeb](https://android.googlesource.com/platform/external/adeb)
project installs a chroot environment on your Android device. We will use adeb in later
steps in the articles.

Install adeb using the instructions in the [adeb README](https://android.googlesource.com/platform/external/adeb/+/master/README.md).

Run the following command to install adeb on your target Android device:
<pre class="devsite-terminal devsite-click-to-copy">
adeb prepare --full
</pre>
adeb comes prepackaged with BCC, so the previous step also installs BCC's `trace` utility
we need for later steps.

## Example: Understanding which path triggered an SELinux denial

### Adding a tracepoint to the kernel
The diff below adds a tracepoint at the point where an SELinux denial is logged
in the kernel, we will need it in later parts of this article to use with BCC.
You can apply the diff to your kernel sources to add an SELinux denial tracepoint.
If the diff does not apply cleanly, patch it in manually using the diff as a reference.

<pre class="prettyprint">
diff --git a/include/trace/events/selinux.h b/include/trace/events/selinux.h
new file mode 100644
index 000000000000..dac185062634
--- /dev/null
+++ b/include/trace/events/selinux.h
@@ -0,0 +1,34 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM selinux
+
+#if !defined(_TRACE_SELINUX_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_SELINUX_H
+
+#include &lt;linux/ktime.h&gt;
+#include &lt;linux/tracepoint.h&gt;
+
+TRACE_EVENT(selinux_denied,
+
+	TP_PROTO(int cls, int av),
+
+	TP_ARGS(cls, av),
+
+	TP_STRUCT__entry(
+		__field(	int,		cls	)
+		__field(	int,		av	)
+	),
+
+	TP_fast_assign(
+		__entry->cls = cls;
+		__entry->av = av;
+	),
+
+	TP_printk("denied %d %d",
+		__entry->cls,
+		__entry->av)
+);
+
+#endif /* _TRACE_SELINUX_H */
+
+/* This part ust be outside protection */
+#include &lt;trace/define_trace.&gt;
diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index 84d9a2e2bbaf..ab04b7c2dd01 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -34,6 +34,9 @@
 #include "avc_ss.h"
 #include "classmap.h"
 
+#define CREATE_TRACE_POINTS
+#include &lt;trace/events/selinux.h&gt;
+
 #define AVC_CACHE_SLOTS			512
 #define AVC_DEF_CACHE_THRESHOLD		512
 #define AVC_CACHE_RECLAIM		16
@@ -713,6 +716,12 @@ static void avc_audit_pre_callback(struct audit_buffer *ab, void *a)
 	struct common_audit_data *ad = a;
 	audit_log_format(ab, "avc:  %s ",
 			 ad->selinux_audit_data->denied ? "denied" : "granted");
+
+	if (ad->selinux_audit_data->denied) {
+		trace_selinux_denied(ad->selinux_audit_data->tclass,
+				     ad->selinux_audit_data->audited);
+	}
+
 	avc_dump_av(ab, ad->selinux_audit_data->tclass,
 			ad->selinux_audit_data->audited);
 	audit_log_format(ab, " for ");
</pre>

### Tracing the user and kernel stacks
To trace stacks when the SELinux denial tracepoint is hit, run the following command:
<pre class="prettyprint">
<code class="devsite-terminal">adeb shell</code>
<code class="devsite-terminal">trace -K -U 't:selinux:selinux_denial'</code>
</pre>

You should see something like this when denials are triggered:
<pre class="prettyprint">
2286    2434    Binder:2286_4   selinux_denied
        avc_audit_pre_callback+0xd8 [kernel]
        avc_audit_pre_callback+0xd8 [kernel]
        common_lsm_audit+0x64 [kernel]
        slow_avc_audit+0x74 [kernel]
        avc_has_perm+0xb8 [kernel]
        selinux_binder_transfer_file+0x158 [kernel]
        security_binder_transfer_file+0x50 [kernel]
        binder_translate_fd+0xcc [kernel]
        binder_transaction+0x1b64 [kernel]
        binder_ioctl+0xadc [kernel]
        do_vfs_ioctl+0x5c8 [kernel]
        sys_ioctl+0x88 [kernel]
        __sys_trace_return+0x0 [kernel]
        __ioctl+0x8 [libc.so]
        android::IPCThreadState::talkWithDriver(bool)+0x104 [libbinder.so]
        android::IPCThreadState::waitForResponse(android::Parcel*, int*)+0x40
                                                            [libbinder.so]
        android::IPCThreadState::executeCommand(int)+0x460 [libbinder.so]
        android::IPCThreadState::getAndExecuteCommand()+0xa0 [libbinder.so]
        android::IPCThreadState::joinThreadPool(bool)+0x40 [libbinder.so]
        [unknown] [libbinder.so]
        android::Thread::_threadLoop(void*)+0x12c [libutils.so]
        android::AndroidRuntime::javaThreadShell(void*)+0x90 [libandroid_runtime.so]
        __pthread_start(void*)+0x28 [libc.so]
        __start_thread+0x48 [libc.so]
</pre>

The call chain above is a unified kernel and user native call chain giving you
a better view of the code flow starting from userspace all the way down to the kernel where
the denial happens. In the example call chain above, a binder transaction
initiated from userspace involved passing a file descriptor. Since the file
descriptor did not have the needed SELinux policy settings, SELinux denied it and
the binder transaction failed.

The same tracing technique can be used for dumping the stack on system calls, kernel
function entry, and more by changing the arguments passed to the `trace` command
in most cases.

## Additional references

For more information on `trace`, see the [BCC trace tool documentation](https://android.googlesource.com/platform/external/bcc/+/master/tools/trace_example.txt).
For more information about running BCC on Android devices, see the
[adeb project's BCC howto](https://android.googlesource.com/platform/external/adeb/+/master/BCC.md).
