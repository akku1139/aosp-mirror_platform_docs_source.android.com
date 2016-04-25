## 3.12\. TV Input Framework

The [Android Television Input Framework (TIF)](http://source.android.com/devices/tv/index.html)
simplifies the delivery of live content to Android Television devices. TIF
provides a standard API to create input modules that control Android Television
devices. Android Television device implementations MUST support TV Input
Framework.

Device implementations that support TIF MUST declare the platform feature
android.software.live_tv.

### 3.12.1\. TV App

Any device implementation that declares support for Live TV MUST have an
installed TV application (TV App). The Android Open Source Project provides an
implementation of the TV App.

The TV App MUST provide facilities to install and use
[TV Channels](http://developer.android.com/reference/android/media/tv/TvContract.Channels.html)
and meet the following requirements:

*   Device implementations MUST allow third-party TIF-based inputs
    ([third-party inputs](https://source.android.com/devices/tv/index.html#third-party_input_example))
    to be installed and managed.
*   Device implementations MAY provide visual separation between pre-installed
    [TIF-based inputs](https://source.android.com/devices/tv/index.html#tv_inputs)
    (installed inputs) and third-party inputs.
*   Device implementations MUST NOT display the third-party inputs more than a
    single navigation action away from the TV App (i.e. expanding a list of
    third-party inputs from the TV App).

#### 3.12.1.1\. Electronic Program Guide

Android Television device implementations MUST show an informational and
interactive overlay, which MUST include an electronic program guide (EPG)
generated from the values in the
[TvContract.Programs](https://developer.android.com/reference/android/media/tv/TvContract.Programs.html)
fields. The EPG MUST meet the following requirements:

*   The EPG MUST display information from all installed inputs and third-party
    inputs.
*   The EPG MAY provide visual separation between the installed inputs and
    third-party inputs.
*   The EPG is STRONGLY RECOMMENDED to display installed inputs and third-party
    inputs with equal prominence. The EPG MUST NOT display the third-party
    inputs more than a single navigation action away from the installed inputs
    on the EPG.
*   On channel change, device implementations MUST display EPG data for the
    currently playing program.

#### 3.12.1.2\. Navigation

Android Television device input devices (i.e. remote control, remote control
application, or game controller) MUST allow navigation to all actionable
sections of the screen via the D-pad. D-pad up and down MUST be used to change
live TV channels when there is no actionable section on the screen.

The TV App SHOULD pass key events to HDMI inputs through CEC.

#### 3.12.1.3\. TV input app linking

Android Television device implementations MUST support
[TV input app linking](http://developer.android.com/reference/android/media/tv/TvContract.Channels.html#COLUMN_APP_LINK_INTENT_URI),
which allows all inputs to provide activity links from the current activity to
another activity (i.e. a link from live programming to related content). The TV
App MUST show TV input app linking when it is provided.
