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

# Cgroup Abstraction Layer

Android {{ androidQVersionNumber }} includes a cgroup abstraction layer and
task profiles, which developers can use to describe a set of restrictions to
apply to a thread or a process. The system uses the profiles to choose how to
apply the restrictions using available cgroups and can change the underlying
cgroup feature set without affecting higher software layers.


## About control groups (cgroups)

Control groups provide a mechanism for aggregating/partitioning sets of tasks
(processes, threads, and all their future children) into hierarchical groups
with specialized behavior. Android uses cgroups to control and account for
system resources such as CPU and memory.

In Android 9 and lower, the set of available cgroups and their mounting points
and versions were described in the `init.rc` initialization script and
(hypothetically) could be changed. Because the Android framework expected a
specific set of cgroups to exist at specific locations and have a specific
version and subgroup hierarchy, the freedom to choose the next cgroup version or
change cgroup hierarchy to use new features was (in reality) limited.

In Android {{ androidQVersionNumber }}:

*   Cgroup setup (previously done via the `init.rc` initialization script) is
    described using `cgroups.json` file, and all cgroups are mounted before
    early-init stage of the initialization process.
*   Task profiles provide an abstraction that decouples required functionality
    from how that functionality is implemented. Profiles are described using the
    `task_profiles.json` file and the Android framework can apply those profiles
    to a process or a thread using the new `SetTaskProfiles` and
    `SetProcessProfiles` APIs.

For backward compatibility, legacy `set_cpuset_policy`, `set_sched_policy`, and
`get_sched_policy` functions provide the same API, but their implementation is
modified to use task profiles. OEM, SoCs, and carrier partners can use the
legacy APIs or can use task profiles directly. Additional cgroups
can still be mounted via `init.rc` initialization script and vendor code can use
them as before; however, if the Android framework is required to recognize these
new cgroups and use them, the groups should be described in the `cgroups.json`
file and new task profiles should be defined in the `task_profiles.json` file.


## Cgroups description file

Cgroups are described in the `cgroups.json` file located under
`<ANDROID_BUILD_TOP>/system/core/libprocessgroup/profiles/`. Each controller is
described in a subsection and should have at least a name and mounting path
(Mode, UID, and GID attributes are optional).

Example `cgroups.json` file:

```
{
  "Cgroups": [
    {
      "Controller": "cpu",
      "Path": "/dev/cpuctl",
      "Mode": "0755",
      "UID": "system",
      "GID": "system"
    },
    {
      "Controller": "cpuacct",
      "Path": "/acct",
      "Mode": "0555"
    }
}
```


This file is parsed by the `init` process before early-init stage and cgroups
are mounted at the specified locations. The cgroup mounting location can be
obtained later using the `CgroupGetControllerPath` API function.


## Task profiles file

Task profiles and attributes are described in the `task_profiles.json` file
located under `<ANDROID_BUILD_TOP>/system/core/libprocessgroup/profiles/`.
Profiles describe a specific set of actions to be applied to a process or a
thread. A set of actions is associated with a profile name, which is used in
`SetTaskProfiles` and `SetProcessProfiles` calls to invoke profile actions.
Supported profile actions are `SetTimerSlack`,  `SetAttribute`, and
`JoinCgroup`.

Example `task_profiles.json` file:

```
{
  "Attributes": [
    {
      "Name": "MemSoftLimit",
      "Controller": "memory",
      "File": "memory.soft_limit_in_bytes"
    },
    {
      "Name": "MemSwappiness",
      "Controller": "memory",
      "File": "memory.swappiness"
    }
  ],
  "Profiles": [
    {
      "Name": "MaxPerformance",
      "Actions" : [
        {
          "Name" : "JoinCgroup",
          "Params" :
          {
            "Controller": "schedtune",
            "Path": "top-app"
          }
        }
      ]
    },
    {
      "Name": "TimerSlackHigh",
      "Actions" : [
        {
          "Name" : "SetTimerSlack",
          "Params" :
          {
            "Slack": "40000000"
          }
        }
      ]
    },
    {
      "Name": "LowMemoryUsage",
      "Actions" : [
        {
          "Name" : "SetAttribute",
          "Params" :
          {
            "Name" : "MemSoftLimit",
            "Value" : "16MB"
          }
        },
        {
          "Name" : "SetAttribute",
          "Params" :
          {
            "Name" : "MemSwappiness",
            "Value" : "150"

          }
        }
      ]
    }
  ]
}
```


**Attributes** name specific cgroup files and should be used *only* when the
framework requires direct access to those files and access can't be abstracted
using task profiles. In all other cases, task profiles should be used as they
provide better decoupling between required behavior and its implementation
details.

## Changes to existing API

Android {{ androidQVersionNumber }} keeps the functions `set_cpuset_policy`,
`set_sched_policy`, and `get_sched_policy` and makes no changes to the API;
however, Android {{ androidQVersionNumber }} moves these functions into
`libprocessgroup`, which now contains all cgroup-related functionality.

The `cutils/sched_policy.h` header still exists and can be included, but it
simply includes a new `processgroup/sched_policy.h` header so all new code
should directly include `processgroup/sched_policy.h`.

Modules that use any of these functions should add dependency on the
`libprocessgroup` library into their makefile. If no other functionality from
`libcutils` is being used by a module, then dependency on the `libcutils`
library should be dropped from the makefile.


## Task profiles API

The following private APIs are introduced and defined in
`processgroup/processgroup.h`:

*   `bool SetTaskProfiles(int tid, const std::vector<std::string>& profiles)`

    Applies the task profiles specified in `profiles` to the thread specified by
    its thread ID using `tid` parameter.
*   `bool SetProcessProfiles(uid_t uid, pid_t pid, const std::vector<std::string>& profiles)`

    Applies the task profiles specified in `profiles` to the process specified
    by its user and process IDs using `uid` and `pid` parameters.
*   `bool CgroupGetControllerPath(const std::string& cgroup_name, std::string* path)`

    Returns whether a cgroup controller specified by `cgroup_name` exists and
    sets the `path` variable to the root of that cgroup.
*   `bool CgroupGetAttributePath(const std::string& attr_name, std::string* path)`

    Returns whether a profile attribute specified by `attr_name` exists and sets
    the `path` variable to the path of the file associated with that profile
    attribute.
*   `bool CgroupGetAttributePathForTask(const std::string& attr_name, int tid, std::string* path)`

    Returns whether a profile attribute specified by `attr_name` exists and sets
    the `path` variable to the path of the file associated with that profile
    attribute and the thread specified by its thread ID using the `tid`
    parameter.
*   `bool UsePerAppMemcg()`

    Returns whether system is configured to use per-application memory cgroups.