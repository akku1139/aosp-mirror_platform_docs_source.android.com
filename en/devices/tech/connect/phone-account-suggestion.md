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

# Phone Account Suggestion

In Android {{ androidQVersionNumber }}, the phone account suggestion service
allows suggestions for phone
accounts to be shown to users when making a call. For example, for users with a
device with multiple SIMs and lower rates for for intra-network calls, this
service first identifies the callee's carrier and then suggests using the SIM on
the same network as the callee.

The phone account suggestion service is optional and can be implemented on
devices running Android {{ androidQVersionNumber }} or higher.

## Implementation

To implement phone account suggestions, implement _one_
[`PhoneAccountSuggestionService`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestionService.java){: .external}
service in an app that is located in `/system/priv-app/`. The service isn't
queried if more than one `PhoneAccountSuggestionService `is implemented. The
service must declare the
`android.Manifest.permission.BIND_PHONE_ACCOUNT_SUGGESTION_SERVICE` permission.

When a user makes an outgoing call where neither the
[default outgoing phone account](https://developer.android.com/reference/android/telecom/TelecomManager.html#getDefaultOutgoingPhoneAccount(java.lang.String)){: .external}
nor the
[preferred phone account](https://developer.android.com/reference/android/provider/ContactsContract.DataColumns.html#PREFERRED_PHONE_ACCOUNT_COMPONENT_NAME){: .external}
is set for the callee, the telecom service binds to
`PhoneAccountSuggestionService` to gather information about the accounts,
[`onAccountSuggestionRequest(String number)`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestionService.java#98){: .external}
is called, and the outgoing call process is suspended.

`PhoneAccountSuggestionService` must call
[`suggestPhoneAccounts(String number, List<PhoneAccountSuggestion> suggestions)`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestionService.java#110){: .external}
with the number returned by
[`onAccountSuggestionRequest(String number)`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestionService.java#98){: .external}.

When
[`suggestPhoneAccounts(String number, List<PhoneAccountSuggestion> suggestions)`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestionService.java#110){: .external}
is called, the telecom service returns a list of suggested phone accounts. The
dialer must then display the list of suggested phone accounts for the user to
choose from to make the call.

### PhoneAccountSuggestion

To make suggestions, use the
[PhoneAccountSuggestion](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestion.java){: .external}
class.
For example, if the service determines the callee is on the same carrier as one
of the SIMs in the device, the service should mark the phone account with
[`REASON_INTRA_CARRIER`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestion.java#46){: .external}.
This information can then be conveyed to the user in the dialer.

For example, in a situation where the user has configured the device to use
a work SIM for all contacts
in a work Google account, the service should mark the phone account with
[`REASON_USER_SET`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestion.java#58){: .external}
and set
[`shouldAutoSelect`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestion.java#121){: .external}
to true to allow the dialer to bypass the selection dialog and automatically
place the call using the phone account.

For information on other suggestions, see
[`PhoneAccountSuggestion`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestion.java){: .external}.

### Dialer

When the call enters the
[`STATE_SELECT_PHONE_ACCOUNT`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/Call.java#84){: .external}
state, the dialer must use the information from
[`PhoneAccountSuggestion`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/PhoneAccountSuggestion.java){: .external}
to handle
[`EXTRA_SUGGESTED_PHONE_ACCOUNTS`](https://android.googlesource.com/platform/frameworks/base/+/master/telecomm/java/android/telecom/Call.java#136){: .external}.

### Disabling the service

To customize your implementation for specific carriers, you can enable or
disable the service using
[`setComponentEnabledSetting`](https://developer.android.com/reference/android/content/pm/PackageManager.html#setComponentEnabledSetting(android.content.ComponentName,%20int,%20int)`){: .external}.
The service is not queried if disabled.

### System UI implementation

Depending on your implementation, changes to the system UI may be required. For
example, to allow users to specify that all calls to a specific contact are
made from a specific phone account, you must implement a customized set up flow
and settings UI for the device.

## Validation

To validate your implementation, run the following CTS tests:

+   [`/cts/tests/tests/telecom/src/android/telecom/cts/PhoneAccountSuggestionServiceTest.java`](https://android.googlesource.com/platform/cts/+/master/tests/tests/telecom/src/android/telecom/cts/PhoneAccountSuggestionServiceTest.java)
+   [`/cts/tests/tests/telecom/src/android/telecom/cts/PhoneAccountSuggestionTest.java`](https://android.googlesource.com/platform/cts/+/master/tests/tests/telecom/src/android/telecom/cts/PhoneAccountSuggestionTest.java)
