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

# Testing Multiple Users

This page describes important aspects of testing multiple users on the
Android platform. For information about implementing multi-user support, see
[Supporting Multiple Users](/devices/tech/admin/multi-user).

## Device paths {: #device-paths }

The following table lists several of the device paths and how they are resolved.
All values in the **Path** column are a user-specific sandboxed storage.
Android's storage story has changed over time; read the
[Storage](/devices/storage) documentation for more information.

Note: All values in the **System path** column are translated to the
corresponding **Path** (at zygote fork time) based on what user is running the
app.

<table>
  <tr>
   <th>Path
   </th>
   <th>System path (optional)
   </th>
   <th>Purpose
   </th>
  </tr>
  <tr>
   <td><code>/data/user/{userId}/{app.path}</code>
   </td>
   <td><code>/data/data</code>
   </td>
   <td>App storage
   </td>
  </tr>
  <tr>
   <td><code>/storage/emulated/{userId}</code>
   </td>
   <td><code>/sdcard</code>
   </td>
   <td>Shared internal storage
   </td>
  </tr>
  <tr>
   <td><code>/data/media/{userId}</code>
   </td>
   <td><em>none</em>
   </td>
   <td>User media data (for example, music, videos)
   </td>
  </tr>
  <tr>
   <td><code>/data/system/users/{userId}</code>
   </td>
   <td><em>none</em>
   </td>
   <td>System configuration/state per user
   <p>Accessible only by system apps</p>
   </td>
  </tr>
</table>

Here's an example of using a user-specific path:

```
# to access user 10's private application data for app com.bar.foo:
$ adb shell ls /data/user/10/com.bar.foo/
```

## adb interactions across users {: #adb-interactions-across-users }

Several `adb` commands are useful when dealing with multiple users. Some of
these commands are supported only in Android {{ androidPVersionNumber }} and
higher:

*   `adb shell instrument --user <userId>` runs an instrumentation test against
    a specific user. By default this uses the current user.
*   `adb install --user <userId>` installs a package for a specific user. To
    guarantee that a package is installed for all users, you must call this for every
    user.
*   `adb uninstall --user <userId>` uninstalls a package for a specific user.
    Call without the `--user` flag to uninstall for all users.
*   `adb shell am get-current-user` gets the current (foreground) user ID.
*   `adb shell pm list users` gets a list of all existing users.
*   `adb shell pm create-user` creates a new user, returning the ID.
*   `adb shell pm remove-user` removes a specific user by ID.
*   `adb shell pm disable --user <userId>` disables a package for a specific
    user.
*   `adb shell pm enable --user <userId>` enables a package for a specific user.
*   `adb shell pm list packages --user <userId>` lists packages (`-e` for
    enabled, `-d` for disabled) for a specific user. By default this always lists for
    the system user.

The following information helps explain how `adb` behaves with multiple users:

*   `adb` (or more accurately the `adbd` daemon) always runs as the **system
    user** (user ID = 0) _regardless of which user is current_. Therefore device
    paths that are user dependent (such as `/sdcard/`) always resolve as
    the system user. See [Device paths](#device-paths) for more details.

*   If a default user isn't specified, each `adb` subcommand has a different user. The
    best practice is to retrieve the user ID with `am get-current-user` and then
    explicitly use `--user <userId>` for any command that supports it. Explicit
    user flags weren't supported for all commands until Android {{
    androidPVersionNumber }}.

*   Access to `/sdcard` paths of secondary users is denied starting in
    Android {{ androidPVersionNumber }}. See
    [Content provider for multi-user data](#content-provider) for details on how
    to retrieve files during testing.

## Content provider for multi-user data {: #content-provider }

Because `adb` runs as the system user and data is sandboxed in Android {{
androidPVersionNumber }} and higher, you must use content providers to push or
pull any test data from a nonsystem user. This is **not** necessary if:

*   `adbd` is running as root (through `adb root`), which is only possible using
    `userdebug` or `usereng` builds.

*   You're using Trade Federation's (Tradefed's)
    [`ITestDevice`](/reference/tradefed/com/android/tradefed/device/ITestDevice)
    to push/pull the files, in which case use `/sdcard/` paths in your test
    config (for example, see the source code for `pushFile` in
    [`NativeDevice.java`](https://android.googlesource.com/platform/tools/tradefederation/+/master/src/com/android/tradefed/device/NativeDevice.java)).

When a content provider is running in the secondary user, you can access it by
using the `adb shell content` command with the appropriate `user`, `uri`, and
other parameters specified.

### Workaround for app developers {: #workaround-for-app-developers }

Interact with test files using `adb content` and an instance of
[`ContentProvider`](https://developer.android.com/guide/topics/providers/content-provider-basics),
instead of the `push` or `pull` command.

1.  Create an instance of `ContentProvider` hosted by the app that can serve/store files
    where needed. Use the app’s internal storage.
1.  Use `adb shell content` `read` or `write` commands to push/pull the files.

### Workaround for media files {: #workaround-for-media-files }

To push media files to the media partition of the SD card, use [`MediaStore`](https://developer.android.com/reference/android/provider/MediaStore) public
APIs. For example:

```
# push MVIMG_20190129_142956.jpg to /storage/emulated/10/Pictures
# step 1
$ adb shell content insert --user 10 --uri content://media/external/images/media/ --bind _display_name:s:foo.jpg

# step 2
$ adb shell content query --user 10 --projection _id --uri content://media/external/images/media/ --where "_display_name=\'foo.jpg\'"

# step 3
$ adb shell content write --user 10 --uri content://media/external/images/media/8022 < MVIMG_20190129_142956.jpg
```

### Installing a generic content provider {: #install-a-generic-content-provider }

Install and use an existing content provider that reads and writes files to the
user-specific `/sdcard` path.

Get `TradefedContentProvider.apk` in one of these ways:

*   Download the
    [`TradefedContentProvider.apk` file](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/res/apks/contentprovider/TradefedContentProvider.apk) from the Android Git Repository

*   Or build it from the source using `make TradefedContentProvider`.

    ```
    # install content provider apk
    $ adb install --user 10 -g TradefedContentProvider.apk

    # pull some_file.txt
    $ adb shell content read --user 10 --uri content://android.tradefed.contentprovider/sdcard/some_file.txt > local_file.txt

    # push local_file.txt
    $ adb shell content write --user 10 --uri content://android.tradefed.contentprovider/sdcard/some_file.txt < local_file.txt
    ```

## Trade Federation multi-user support {: #tradefed }

[Tradefed](/devices/tech/test_infra/tradefed) is the official
Android test harness. This section summarizes some of Tradefed's builtin support
for multi-user test scenarios.

### Status checkers {: #tradefed-statuscheckers }

[System status checkers (SSCs)](/devices/tech/test_infra/tradefed/testing/through-suite/system-status-checker)
are run **before** the target preparers, and their cleanup is run **after**
those preparers.

[`UserChecker`](https://android.googlesource.com/platform/tools/tradefederation/+/refs/heads/master/src/com/android/tradefed/suite/checker/UserChecker.java)
is defined explicitly to aid developers when testing multiple users. It tracks
whether a test has changed the state of the users on the device (for example,
created users without removing them in teardown). In addition, if `user-cleanup`
is set, it automatically attempts to clean up after the test, while still
providing helpful errors so that the test can be fixed.

```
<system_checker class="com.android.tradefed.suite.checker.UserChecker" >
    <option name="user-cleanup" value="true" />
</system_checker>
```

### Target preparer {: #tradefed-targetpreparer }

Target preparers are typically used to set up a device with a particular
configuration. In the case of multi-user testing preparers can be used to create users of a
specific type as well as switch to other users.

For device types that don't have a secondary user, you can use
`CreateUserPreparer` to create _and switch_ to a secondary user in
`AndroidTest.xml`. At the end of the test, the preparer switches back and
deletes the secondary user.

```
<target_preparer
  class="com.google.android.tradefed.targetprep.CreateUserPreparer" >
</target_preparer>
```

If the user type you want already exists on the device, use
`SwitchUserTargetPreparer` to switch to the existing user. Common values for
`user-type` include `system` or `secondary`.

```
<target_preparer
  class="com.android.tradefed.targetprep.SwitchUserTargetPreparer">
    <option name="user-type" value="secondary" />
</target_preparer>
```

### Host-driven tests {: #tradefed-hostdriven }

In some instances, a test needs to switch users _within the test_. Don't
make the switch from within a device-side test framework, such as
[UI Automator](https://developer.android.com/training/testing/ui-automator),
because the test process may be killed at any time. Instead, use a host-side test framework like Tradefed's
[Host-Driven Test Framework](/preview/devices/tech/test_infra/tradefed/testing/through-tf/host-driven-test),
which gives access to
[`ITestDevice`](/reference/tradefed/com/android/tradefed/device/ITestDevice),
allowing for any user manipulation that is needed.

Use `UserChecker` (described in
[Status checkers](#tradefed-statuscheckers)) for host-driven tests that change
the user state because it ensures that the test properly cleans up after itself.
