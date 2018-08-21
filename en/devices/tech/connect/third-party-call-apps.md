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

# Supporting Third-Party Calling Apps

Android {{ androidPVersionNumber }} provides APIs to better support third-party
(3P) calling apps. 3P calling apps typically rely on Telephony APIs such as the
`PHONE_STATE` broadcast to co-exist alongside carrier phone calls. As a
consequence, 3P calling apps must give carrier calls priority and often resort
to silently rejecting incoming calls in the app, or terminating an ongoing call
to make way for a carrier call.

The APIs in Android {{ androidPVersionNumber }} support concurrent calling
scenarios between 3P apps and carrier calls. This makes it possible, for
example, to receive an incoming 3P call while engaged in a carrier call. The
framework assumes responsibility for ensuring the carrier call is held when the
user engages in the 3P call.

In Android {{ androidPVersionNumber }}, 3P calling apps are encouraged to
implement the self-managed `ConnectionService` API. For more information on how
to build a calling app using this API, see
[Build a calling app](https://developer.android.com/guide/topics/connectivity/telecom/selfManaged){: .external}.

The self-managed `ConnectionService` API also gives developers the opportunity
to opt-in to having calls in their app logged in the system call log (see
[`EXTRA_LOG_SELF_MANAGED_CALLS`](https://developer.android.com/reference/android/telecom/PhoneAccount#EXTRA_LOG_SELF_MANAGED_CALLS){: .external}).
Per the requirements in the
[Android Compatibility Definition Document (CDD)](/compatibility/android-cdd#7_4_data_connectivity)
(section 7.4.1.2), you should ensure your dialer/phone app displays these
call log entries and shows the name of the 3P calling app where the call
originated (for an example of how the AOSP dialer app meets this requirement,
see
[Call log entries from 3P calling apps](#call_log_entries_from_3p_calling_apps)).

Apps are responsible for setting
[`CAPABILITY_SUPPORT_HOLD`](https://developer.android.com/reference/android/telecom/Connection.html#CAPABILITY_SUPPORT_HOLD){: .external}
and
[`CAPABILITY_HOLD`](https://developer.android.com/reference/android/telecom/Connection.html#CAPABILITY_HOLD){: .external}
on their apps' connections. However, it is possible that an app cannot hold a
call in some circumstances. The framework includes provisions for resolving
these types of cases.

## Scenarios

You should modify your dialer app to handle the following scenarios.

### Handling incoming calls which disconnect an ongoing call

In a scenario where there is an ongoing 3P call (e.g. in a SuperCaller call)
that does not support hold, and the user receives a mobile call (e.g. via their
carrier FooCom), your Dialer/Phone app should indicate to the user that
answering the mobile network call will end the ongoing 3P call.

This user experience is important as a 3P calling app may have an ongoing call
that cannot be held by the framework. Answering a new mobile call causes the
ongoing 3P call to be disconnected.

See the user interface below for an example:

<figure id="incoming-call-3p-call-app">
  <img src="/devices/tech/connect/images/incoming-call-3p-call-app.png"
    width="250" class="screenshot"
    alt="Incoming call disconnecting an ongoing 3P call">
  <figcaption><strong>Figure 1.</strong> Incoming call which disconnects an
  ongoing 3P call</figcaption>
</figure>

Your dialer app can check if an incoming call causes another call to be
disconnected by checking the
[call extras](https://developer.android.com/reference/android/telecom/Call.Details.html#getExtras\(\)){: .external}.
Make sure that
[`EXTRA_ANSWERING_DROPS_FG_CALL`](https://developer.android.com/reference/android/telecom/Connection.html#EXTRA_ANSWERING_DROPS_FG_CALL){: .external}
is set to `TRUE`, and
[`EXTRA_ANSWERING_DROPS_FG_CALL_APP_NAME`](https://developer.android.com/reference/android/telecom/Connection.html#EXTRA_ANSWERING_DROPS_FG_CALL_APP_NAME){: .external}
is set to the name of the app whose call is disconnected upon answering the
incoming mobile call.

### Call log entries from 3P calling apps

Developers of 3P calling apps can opt-in to having calls in their app logged in
the system call log (see
[`EXTRA_LOG_SELF_MANAGED_CALLS`](https://developer.android.com/reference/android/telecom/PhoneAccount#EXTRA_LOG_SELF_MANAGED_CALLS){: .external}).
This means that it is possible to have entries in the call log that are not for
mobile network calls.

When the AOSP dialer app displays call log entries related to a 3P calling app,
the name of the app where the call took place is displayed in the call log, as
illustrated below:

<figure id="call-log-entry-3p">
  <img src="/devices/tech/connect/images/call-log-entry-3p.png"
    width="400" class="screenshot"
    alt="Call log entry with 3P calling app">
  <figcaption><strong>Figure 2.</strong> Call log entry with name of 3P calling
  app on dialer app</figcaption>
</figure>

To determine the name of an app associated with a call log entry, use the
[`PHONE_ACCOUNT_COMPONENT_NAME`](https://developer.android.com/reference/android/provider/CallLog.Calls.html#PHONE_ACCOUNT_COMPONENT_NAME){: .external}
and
[`PHONE_ACCOUNT_ID`](https://developer.android.com/reference/android/provider/CallLog.Calls.html#PHONE_ACCOUNT_ID){: .external}
columns in the call log provider to create an instance of
[`PhoneAccountHandle`](https://developer.android.com/reference/android/telecom/PhoneAccountHandle.html#PhoneAccountHandle\(android.content.ComponentName,%20java.lang.String\)){: .external},
which identifies the source of a call log entry. Query
[`TelecomManager`](https://developer.android.com/reference/android/telecom/TelecomManager.html#getPhoneAccount\(android.telecom.PhoneAccountHandle\)){: .external}
to get the details for the PhoneAccount. \
To determine if a call log entry is from a 3P calling app, check
[`PhoneAccount` capabilities ](https://developer.android.com/reference/android/telecom/PhoneAccount.html#getCapabilities\(\)){: .external}
to see if
[`CAPABILITY_SELF_MANAGED`](https://developer.android.com/reference/android/telecom/PhoneAccount.html#CAPABILITY_SELF_MANAGED){: .external}
is set.

The
[`getLabel`](https://developer.android.com/reference/android/telecom/PhoneAccount.html#getLabel\(\)){: .external}
method of the returned `PhoneAccount` returns the name of the app associated
with a call log entry from the 3P calling app.

## Validation

To test that your device supports 3P calling apps, use the Telecomm test
application, which implements the self-managed ConnectionService API. The
application is located in
[`/packages/services/Telecomm/testapps/`](https://android.googlesource.com/platform/packages/services/Telecomm/+/master/testapps/){: .external}.

1.  Build the test app from the root of your Android source repository using:

    `mmma packages/services/Telecomm/testapps/`

1.  Install the build apk using `adb install -g -r <apk path>`. A Self-Managed
    Sample icon is then added to your launcher.

1.  Tap the icon to open the test application.

### Handling incoming calls which disconnect an ongoing call

Follow these steps to verify that an incoming call disconnects an ongoing 3P
call.

<figure id="test-app-3p-call">
  <img src="/devices/tech/connect/images/test-app-3p-call.png"
    width="250" class="screenshot"
    alt="Test application for 3P calling apps">
  <figcaption><strong>Figure 3.</strong> Test application with sample
  implementations of the self-managed ConnectionService API</figcaption>
</figure>

1.  Uncheck the **Holdable** option.
1.  Tap **OUTGOING** to start a new sample outgoing call.
1.  Tap the **ACTIVE** button to make the call go active.
1.  Call the phone number of the device under test with another phone. This
    invokes the scenario where your dialer is provided with the name of an app,
    which will have its call disconnected.
1.  When you are finished, tap the **DISCONNECT** button in the test app.

### Call log entries from 3P calling apps

After completing the steps above, the test app should have logged a call to the
system call log. To confirm the device logs calls from 3P calling apps,
open your dialer app and confirm the call appears in the system call log.
