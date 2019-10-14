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

# Employ Module Controllers

Each suite module (defined by `AndroidTest.xml`) can contain a special
`module_controller` object that can alter some behavior of the module:

## Whether to run the module or not based on some conditions

By implementing [BaseModuleController](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/testtype/suite/module/BaseModuleController.java)
and adding it to the `AndroidTest.xml` like this:

```xml
<object type="module_controller" class="com.android.tradefed.testtype.suite.module.<NAME>" />
```

The module controller will be used to determine whether the module should run
or not, based on the
`public abstract RunStrategy shouldRun(IInvocationContext context);`
implementation.

## Whether to collect some logs or not on failures

When running a full suite, it's possible to request at the suite level the
collection of some logs on failures (screenshot, bugreport, logcat). But for
some modules, a particular log requested might not have any value and will
simply waste time to be collected. In that situation, a module can explicitly
specify which logs they are interested in:

```xml
<object type="module_controller"
        class="com.android.tradefed.testtype.suite.module.TestFailureModuleController">
    <option name="screenshot-on-failure" value="<true OR false>" />
    <option name="bugreportz-on-failure" value="<true OR false>" />
    <option name="logcat-on-failure" value="<true OR false>" />
</object>
```

NOTE: Implementation of controllers should be generic if possible in order to
maximize re-usability. And skipping a module based on its condition should
be reviewed by the module owner to get the approval that skipping a module is
the proper behavior for them.
