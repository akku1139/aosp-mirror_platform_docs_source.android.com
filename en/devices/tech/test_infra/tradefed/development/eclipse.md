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

# Set up Eclipse

Follow these steps to set up Tradefed using Eclipse.

Create a separate workspace to develop Trade Federation, do not reuse a
workspace already employed for Android-device development.

If needed, you can download the *Eclipse IDE for Java developers* from:
[eclipse.org/downloads](https://www.eclipse.org/downloads/)

## Create projects

1.  Run make once from the command line. This will build external libraries
    depended by the projects below.
1.  Set TRADEFED_ROOT classpath variable in `Window > Preferences > Java > Build
    Path> Classpath Variables` and point it to your tradefed source root
1.  Set TRADEFED_ROOT path variable in `Window > Preferences > General >
    Workspace > Linked Resources` and point it to your tradefed source root
1.  Use the `File > Import...-> General > Existing Projects into
    workspace"`wizard to bring in these open source Java projects under the
    following paths:

    ```
    prebuilts/misc/common/ddmlib\*
    tools/loganalysis
    tools/loganalysis/tests
    tools/tradefederation/core
    tools/tradefederation/core/tests
    tools/tradefederation/contrib
    tools/tradefederation/core/remote
    platform_testing/libraries/longevity
    platform_testing/libraries/annotations
    platform_testing/libraries/composer
    ```

1.  Optionally, if you want to see `ddmlib` source code, attach the source code
    from an unbundled tools branch, such as [/platform/tools/base/tools_r22/ddmlib/src/main/java/com/android/ddmlib/IDevice.java](https://android.googlesource.com/platform/tools/base/+/tools_r22/ddmlib/src/main/java/com/android/ddmlib/IDevice.java).

1.  Optionally, if you also want the CTS harness projects loaded, import:

    ```
    test/suite_harness/common/util
    test/suite_harness/common/host-side/util
    test/suite_harness/common/host-side/tradefed
    ```

## Auto format

NOTE: Requisite files live within `development/ide/eclipse` in the full platform
source tree. So you will need to check out a platform branch such as `master`
to get these files:
[/development/master/ide/eclipse/](https://android.googlesource.com/platform/development/+/refs/heads/master/ide/eclipse/)

Use preference files in Eclipse to automatically set the formatter to the
Android style guide. To do this in Studio:

1.  Go to *Window > Preferences > Java > Code Style*.
1.  Under *Formatter*, import the file `android-formatting.xml`.
1.  Under *Organize > Imports*, import the file `android.importorder`.

### Remove trailing whitespaces

To force Eclipse to remove all trailing whitespace:

1.  Go to *Window > Preferences -> Java -> Editor -> Save Actions*.
1.  Then *Additional Actions -> Configure -> Code > Organizing tab ->
    Formatter*.
1.  Check **Remove Trailing Whitespace**.
1.   Click **Apply and Close**.

### Check code style

When submitting a changelist, an automatic preupload hook will run to check your
code format: `google-java-format`

This helps formatting your code to the common standard.

## Debug Eclipse

If you want to run TF code through a debugger in Eclipse, it is recommended you
first create a unit test for the code in question as this will be the simplest
and fastest way to exercise the functionalilty.

To debug a TF unit test, simply right-click on it and select **Debug As > JUnit
test**.

To debug a TF functional test, follow the instructions in the previous section
for running a functional test but use the *Run > Debug configurations* menu.

To debug the TF program itself, when running any configuration, follow the
instructions in the previous section for running a functional test but provide
the command line arguments for the configuration you wish to run in step 4. So
to debug the 'instrument' configuration, go to the *Run > Debug configuration*
menu and set the *Arguments* tab in the Eclipse debug configuration to
`-- package <package to run> instrument`.

### Remote debug with Eclipse

Follow these steps to remotely debug a tradefed session started from
`tradefed.sh` command line:

1.  Start tradefed.sh with the debug flag: `TF_DEBUG=1 tradefed.sh`
2.  Wait until you see this prompt from the JVM: `Listening for transport
    dt_socket at address: 10088` This means the JVM is waiting for debugger to
    attach at port `10088`.
3.  Attach with Eclipse's remote debugging from main menu: Select *Run > Debug
    Configurations...*.
4.  In the pop-up dialog, select *Remote Java Application* from the left menu.
5.  Click the *New launch configuration* icon on the action bar.
6.  Name the configuration as you desire and select **tradefederation** as the
    project.
7.  Populate the port using the address provided earlier.
8.  Switch to the *Source* tab and add the projects **tradefederation** and
    **google-tradefed** to the *Source Lookup Path*.
9.  Click **Debug** to start the debugging session.

The debugger attaches to the listening JVM process, and the terminal running
`tradefed.sh` shows the `tf>` prompt.

To step through your code in debug mode, set a break point in Eclipse and invoke
your Tradefed command (i.e. `run <test>`) in the terminal. To debug anything
during TF startup, you can set the break point first and then attach the Eclipse
debugger.

TIP: To use an alternative port, add `TF_DEBUG_PORT=nnn`to the command in step 1
above. You can even use this in production environment if you have mysterious
hang bugs to investigate: change `suspend=y` to `suspend=n` in `tradefed.sh` and
start with debug flag. The JVM won't wait for debugger to attach, but you can do
so at any time as long as the process is still running.

### Remote debug using JDB

To use the Java Debugger JDB, follow steps resembling those for Eclipse:

1.  Start `tradefed.sh` with the debug flag: `TF_DEBUG=1 tradefed.sh`
2.  Wait until you see the prompt from JVM: `Listening for transport dt_socket
    at address: 10088`.
3.  Connect `jdb`. For example, from croot run:

    ```shell
    jdb -attach 10088 \
        -sourcepath tools/tradefederation/core/src:vendor/google_tradefederation/core/src
    ```

4.  Wait for the connection and debug away! Run `man jdb` for more help.

## Examine code coverage

1.  Install the [Eclemma plugin](https://www.eclemma.org/).
2.  Go to *Help > Install New Software* and point the wizard to:
    http://update.eclemma.org/
3.  Once installed, select the *Coverage As > JUnit* test option to conduct a
    code coverage run.
