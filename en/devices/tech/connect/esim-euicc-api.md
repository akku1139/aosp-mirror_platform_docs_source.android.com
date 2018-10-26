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

# eUICC APIs

In Android {{ androidPVersionNumber }}, profile management APIs (public and
@SystemApi) are available through the class `EuiccManager`. eUICC communication
APIs (@SystemApi only) are available through the class `EuiccCardManager`.

## About eUICC

Carriers can make carrier apps using EuiccManager to manage profiles, as shown
in Figure 1. Carrier apps don't need to be system apps but need to have carrier
privileges granted by eUICC profiles. An
[LPA app](/devices/tech/connect/esim-overview#making_an_lpa_app) (LUI and LPA
backend) needs to be a system app (i.e., included in the system image) to call
the @SystemApi.

![Android phone with Carrier App and OEM LPA](/devices/tech/connect/images/carrier-oem-lpa.png)

**Figure 1.** Android phones with carrier app and OEM LPA

Besides the logic of calling `EuiccCardManager` and talking to eUICC, LPA apps
must implement the following:

+   SM-DP+ client talking to SM-DP+ server to authenticate and
    download profiles
+   [Optional] SM-DS to get more potential downloadable profiles
+   Notification handling to send notifications to the server to
    update the profile state
+   [Optional] Slots management including switching between eSIM and pSIM logic.
    This is optional if the phone only has an eSIM chip.
+   eSIM OTA

Although more than one LPA app can be present in an Android phone, only one LPA
can be selected to be the actual working LPA based on the priority defined in
the `AndroidManifest.xml` file of each app.

## Using EuiccManager

The LPA APIs are public through `EuiccManager` (under package
`android.telephony.euicc`). A carrier app can get the instance of `EuiccManager`,
and call the methods in `EuiccManager` to get the eUICC information and manage
subscriptions (referred to as profiles in GSMA RSP documents) as
SubscriptionInfo instances.

To call public APIs including download, switch, and delete subscription
operations, the carrier app must have the required privileges. Carrier
privileges are added by the mobile carrier in the profile metadata. The eUICC
API enforces the carrier privilege rules accordingly.

The Android platform does not handle the profile policy rules. If a policy rule
is declared in the profile metadata, the LPA can choose how to handle the
profile download and installation procedure. For example, it is possible for a
third-party OEM LPA to handle policy rules using a special error code (the error
code is passed from the OEM LPA to the platform, then the platform passes the
code to the OEM LUI).

### APIs

The following APIs can be found in the
[`EuiccManager` reference documentation](https://developer.android.com/reference/android/telephony/euicc/EuiccManager){: .external}
and
[`EuiccManager.java`](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/euicc/EuiccManager.java){: .external}.

#### Get instance (public)

Gets the instance of `EuiccManager` through `Context#getSystemService`.

```
EuiccManager mgr = (EuiccManager) context.getSystemService(Context.EUICC_SERVICE);
```

#### Check enabled (public)

Checks whether the embedded subscription is enabled. This should be checked
before accessing LPA APIs.

```
boolean isEnabled = mgr.isEnabled();
if (!isEnabled) {
    return;
}
```

#### Get EID (public)

Gets the EID identifying the eUICC hardware. This may be null if the eUICC is
not ready. The caller must have carrier privilege or the
`READ_PRIVILEGED_PHONE_STATE` permission.

```
String eid = mgr.getEid();
if (eid == null) {
  // Handle null case.
}
```

#### Get EuiccInfo (public)

Gets information about the eUICC. This contains the OS version.

```
EuiccInfo info = mgr.getEuiccInfo();
String osVer = info.getOsVersion();
```

#### Download subscription (public)

Downloads the given subscription (referred to as "profile" in GSMA RSP
documents). The subscription can be created from an activation code. For
example, an activation code can be parsed from a QR code. Downloading a
subscription is an asynchronous operation.

The caller must either have the `WRITE_EMBEDDED_SUBSCRIPTIONS` permission or
have carrier privileges for the target subscription.

```
// Register receiver.
String action = "download_subscription";
BroadcastReceiver receiver =
        new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (!action.equals(intent.getAction())) {
                    return;
                }
                resultCode = getResultCode();
                detailedCode = intent.getIntExtra(
                    EuiccManager.EXTRA_EMBEDDED_SUBSCRIPTION_DETAILED_CODE,
                    0 /* defaultValue*/);
                resultIntent = intent;
            }
        };
context.registerReceiver(
        receiver,
        new IntentFilter(action),
        "example.broadcast.permission" /* broadcastPermission*/, null /* handler */);

// Download subscription asynchronously.
DownloadableSubscription sub =
        DownloadableSubscription.forActivationCode(code /* encodedActivationCode*/);
Intent intent = new Intent(action);
PendingIntent callbackIntent = PendingIntent.getBroadcast(
        getContext(), 0 /* requestCode */, intent, PendingIntent.FLAG_UPDATE_CURRENT);
mgr.downloadSubscription(sub, true /* switchAfterDownload */, callbackIntent);
```

#### Switch subscription (public)

Switches to (enables) the given subscription. The caller must either have
`WRITE_EMBEDDED_SUBSCRIPTIONS` or have carrier privileges for the current
enabled subscription and the target subscription.

```
// Register receiver.
String action = "switch_to_subscription";
BroadcastReceiver receiver =
        new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (!action.equals(intent.getAction())) {
                    return;
                }
                resultCode = getResultCode();
                detailedCode = intent.getIntExtra(
                    EuiccManager.EXTRA_EMBEDDED_SUBSCRIPTION_DETAILED_CODE, 0 /* defaultValue*/);
                resultIntent = intent;
            }
        };
context.registerReceiver(receiver, new IntentFilter(action),
        "example.broadcast.permission" /* broadcastPermission*/, null /* handler */);

// Switch to a subscription asynchronously.
Intent intent = new Intent(action);
PendingIntent callbackIntent = PendingIntent.getBroadcast(
        getContext(), 0 /* requestCode */, intent, PendingIntent.FLAG_UPDATE_CURRENT);
mgr.switchToSubscription(1 /* subscriptionId */, callbackIntent);
```

#### Delete subscription (public)

Deletes a subscription with a subscription ID. If the subscription is currently
active, it is first disabled. The caller must have either
`WRITE_EMBEDDED_SUBSCRIPTIONS` or carrier privileges for the target
subscription.

```
// Register receiver.
String action = "delete_subscription";
BroadcastReceiver receiver =
        new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (!action.equals(intent.getAction())) {
                    return;
                }
                resultCode = getResultCode();
                detailedCode = intent.getIntExtra(
                    EuiccManager.EXTRA_EMBEDDED_SUBSCRIPTION_DETAILED_CODE,
                    0 /* defaultValue*/);
                resultIntent = intent;
            }
        };
context.registerReceiver(receiver, new IntentFilter(action),
        "example.broadcast.permission" /* broadcastPermission*/,
        null /* handler */);

// Delete a subscription asynchronously.
Intent intent = new Intent(action);
PendingIntent callbackIntent = PendingIntent.getBroadcast(
        getContext(), 0 /* requestCode */, intent, PendingIntent.FLAG_UPDATE_CURRENT);
mgr.deleteSubscription(1 /* subscriptionId */, callbackIntent);
```

#### Start resolution activity (public)

Starts an activity to resolve a user-resolvable error. If an operation returns
`EuiccManager#EMBEDDED_SUBSCRIPTION_RESULT_RESOLVABLE_ERROR`, this method can be
called to prompt the user to resolve the issue. This method can only be called
once for a particular error.

```
...
mgr.startResolutionActivity(getActivity(), 0 /* requestCode */, resultIntent, callbackIntent);
```

### Constants

To see a list of the `public` constants in `EuiccManager`, see
[Constants](https://developer.android.com/reference/android/telephony/euicc/EuiccManager#constants){: .external}.
