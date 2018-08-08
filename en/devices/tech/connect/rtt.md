Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
  Copyright 2018 The Android Open Source Project

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

# Implementing Real-Time Text

This page describes how to implement Real-Time Text (RTT) in Android
{{ androidPVersionNumber }}. RTT is a feature for deaf or hard of hearing users
that replaces Text Telephone (TTY) technology. With this feature, devices can
use the same phone number for voice and RTT calls, simultaneously transmit text
as it is being typed on a character-by-character basis, support 911
communications, and provide backward capability with TTY.

In an RTT call, both the caller and receiver have indications that they are in
an RTT call. When connected, both sides enter the RTT call where the text input
and keyboard is activated. When typing, the text appears and is sent as it is
typed, character by character.

## Examples and source

Framework components are available in AOSP at
[Call.RttCall](https://developer.android.com/reference/android/telecom/Call.RttCall)
and
[Connection.RttTextStream](https://developer.android.com/reference/android/telecom/Connection.RttTextStream).
IMS/modem components are proprietary and should be supplied by the IMS/modem
vendor. Dialer RTT reference implementation is also available.

AOSP Dialer code for RTT:

+   InCall:
    [/java/com/android/incallui/rtt](https://android.googlesource.com/platform/packages/apps/Dialer/+/master/java/com/android/incallui/rtt)
+   Call log:
    [/java/com/android/dialer/rtt](https://android.googlesource.com/platform/packages/apps/Dialer/+/master/java/com/android/dialer/rtt)

## Implementation

To implement RTT, you should work with a modem/SoC provider because a modem that
supports RTT is required. You can upgrade to Android
{{ androidPVersionNumber }} or backport a list of telephony framework patches
into Android 8.0. APIs added in Android 8.0 AOSP will not work.

This feature uses public APIs in AOSP in `android.telecom` and @SystemApis in
`android.telephony.ims`. All UI lies within `com.android.phone` and the AOSP
dialer.

To implement RTT, import the AOSP code and supply an IMS stack that implements
the IMS-side @SystemApis for RTT. This requires:

+   Turning RTT on/off via `ImsConfig#setProvisionedValue(RTT_SETTING_ENABLED)`
+   Indicating RTT status of a call via `ImsStreamMediaProfile#mRttMode`
+   Support for the following methods in `ImsCallSession`:

    +   `sendRttMessage`
    +   `sendRttModifyRequest`
    +   `sendRttModifyResponse`

+   Support for calling the following methods in `ImsCallSessionListener`:

    +   `callSessionRttModifyRequestReceived`
    +   `callSessionRttModifyResponseReceived`
    +   `callSessionRttMessageReceived`

## Customization

You can enable or disable this feature using the device config,
`config_support_rtt`, in the device config overlay for
`packages/services/Telephony`, and the carrier config flag,
`CarrierConfigManager.RTT_SUPPORTED_BOOL`, in the carrier config files.
Depending on the configuration, the feature is either available via the
Accessibility settings or not. Use the device config to change the default
settings. By default, the feature is set to Off.

## Validation

To validate your implementation of RTT, run CTS tests, and perform dialer RTT testing.

### CTS testing

The CTS tests (`android.cts.telecom.RttOperationsTest`) cover the AOSP portion
of the implementation. You must provide your own tests for the IMS stack portion
of the implementation.

### Dialer RTT testing

<table>
<thead>
<tr>
<th><strong>Scenario description</strong></th>
<th><strong>UI mock</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td><p>If RTT is disabled on the device, a banner about RTT
is displayed. A "Learn more" option that directs to the Google Help Center
article page with more information on RTT is displayed.</p>
<p>Banner call is displayed.</p></td>
<td><p><img src="/devices/tech/connect/images/rtt-banner.png" width="250px" alt="RTT banner"></p>

</td>
</tr>
<tr>
<td>In Dialer settings, a "Real-Time Text" screen is
available under Settings > Accessibility that provides an option to enable
"RTT mode". Descriptive text is displayed to explain the mode: "Send and
receive text messages instead of speaking and listening during a call".</td>
<td><p><img src="/devices/tech/connect/images/rtt-accessibility.png" width="250px" alt="RTT accessibility"></p>

</td>
</tr>
<tr>
<td>When RTT is enabled by default,<br>
<ul>
<li>While the call is placed, the standard in-call dialing UI is
displayed.</li>
<li>Upon call connection, the RTT mode view is displayed. If the receiving
user does not default into RTT mode, a banner indicating that RTT mode has
been requested is displayed while waiting for a response. </li>
</ul>
</td>
<td><p><img src="/devices/tech/connect/images/rtt-in-call-ui.png" width="250px" alt="RTT in-call UI"></p>

</td>
</tr>
<tr>
<td>If RTT is disabled on the device:<br>
<ul>
<li>Incoming call screen displays standard answering puck and standard
call labels.</li>
</ul>
</td>
<td><p><img src="/devices/tech/connect/images/rtt-standard-call-ui.png" width="250px" alt="RTT standard call UI"></p>

</td>
</tr>
<tr>
<td>If RTT is enabled on the device and has the default
set to answer all calls as RTT:<br>
<ul>
<li>Incoming call screen displays RTT puck and associated call labels.</li>
<li>Answering the call loads the RTT mode view with keyboard enabled.</li>
</ul>
</td>
<td><p><img src="/devices/tech/connect/images/rtt-mode-view.png" width="250px" alt="RTT mode view"></p>

</td>
</tr>
<tr>
<td>In the in-call UI for RTT, options are provided to
allow users to control the state of the voice call and get general help on
using RTT.<br>
<ul>
<li>Toggle microphone on and off.</li>
<li>Toggle speaker on and off.</li>
<li>Route audio to external audio devices if available.</li>
</ul>
</td>
<td><p><img src="/devices/tech/connect/images/rtt-in-call-ui-options.png" width="250px" alt="RTT in-call UI options"></p>

</td>
</tr>
<tr>
<td>In the "Call details" screen, a snippet of the RTT
conversation history is displayed.<br>
<ul>
<li>Snippet does not exceed one line in length. If the RTT session did
not include any conversation content, a notice is displayed indicating no
content was stored.</li>
<li>Snippet includes RTT icon to indicate an RTT call.</li>
<li>Selecting the "See all" link displays a full conversation view with the
full text of the RTT session. Timestamps are displayed. The user can return
to the Call details screen using the Back button.</li>
</ul>
</td>
<td><p><img src="/devices/tech/connect/images/rtt-call-details.png" width="250px" alt="RTT call details"></p>

</td>
</tr>
</tbody>
</table>
