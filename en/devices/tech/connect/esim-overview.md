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

# Implementing eSIM

Embedded SIM (eSIM, or eUICC) is the latest technology to allow mobile users to
download a carrier profile and activate a carrier's service without having a
physical SIM card. It is a global specification driven by the GSMA that enables
remote SIM provisioning of any mobile device. Starting with Android
{{ androidPVersionNumber }}, the Android framework provides standard APIs for
accessing eSIM and managing subscription profiles on the eSIM. These _eUICC
APIs_ enable third parties to develop their own carrier apps and Local Profile
Assistants (LPAs) on eSIM-enabled Android devices.

The LPA is a standalone, system application that should be included in the
Android build image. Management of the profiles on the eSIM is generally done by
the LPA, as it serves as a bridge between the SM-DP+ (remote service that
prepares, stores, and delivers profile packages to devices) and the eUICC chip.
The LPA APK can optionally include a UI component, called the LPA UI or LUI, to
provide a central place for the end user to manage all embedded subscription
profiles. The Android framework automatically discovers and connects to the best
available LPA, and routes all the eUICC operations through an LPA instance.

![Simplified Remote SIM Provisioning (RSP) architecture](/devices/tech/connect/images/rsp-architecture.png)

**Figure 1.** Simplified Remote SIM Provisioning (RSP) architecture

Mobile network operators interested in creating a _carrier app_ should look at
the APIs in
[EuiccManager](https://developer.android.com/reference/android/telephony/euicc/EuiccManager){: .external},
which provides high-level profile management operations such as
`downloadSubscription()`, `switchToSubscription()`, and
`deleteSubscription()`.

If you are a device OEM interested in creating your own LPA system app, you must
extend
[EuiccService](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/service/euicc/EuiccService.java){: .external}
for the Android framework to connect to your LPA services. In addition, you
should use the APIs in
[EuiccCardManager](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/euicc/EuiccCardManager.java){: .external},
which provides ES10x functions based on GSMA Remote SIM Provisioning (RSP) v2.0.
These functions are used to issue commands to the eUICC chip, such as
`prepareDownload()`, `loadBoundProfilePackage()`, `retrieveNotificationList()`,
and `resetMemory()`.

The APIs in
[EuiccManager](https://developer.android.com/reference/android/telephony/euicc/EuiccManager){: .external}
require a properly implemented LPA app to function and the caller of
[EuiccCardManager](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/euicc/EuiccCardManager.java){: .external}
APIs must be an LPA. This is enforced by the Android framework.

Devices running Android {{ androidQVersionNumber }} or higher can support
devices with multiple eSIMs. For more information, see
[Supporting multiple eSIMs](#supporting_multiple_esims).

## Making a carrier app

The eUICC APIs in Android {{ androidPVersionNumber }} make it possible for
mobile network operators to create carrier-branded applications to manage their
profiles directly. This includes downloading and deleting subscription profiles
owned by the carrier, as well as switching to a profile owned by a carrier.

### EuiccManager

`EuiccManager` is the main entry point for applications to interact with the
LPA. This includes carrier apps that download, delete, and switch to
subscriptions owned by the carrier. This also includes the LUI system app, which
provides a central location/UI for managing _all_ embedded subscriptions, and
can be a separate app from the one that provides the `EuiccService`.

To use the public APIs, a carrier app must first obtain the instance of
`EuiccManager` through `Context#getSystemService`:

```
EuiccManager mgr = (EuiccManager) context.getSystemService(Context.EUICC_SERVICE);
```

You should check whether eSIM is supported on the device before performing any
eSIM operations. `EuiccManager#isEnabled()` generally returns true if the
android.hardware.telephony.euicc feature is defined and an LPA package is
present.

```
boolean isEnabled = mgr.isEnabled();
if (!isEnabled) {
    return;
}
```

To get information about the eUICC hardware and the eSIM OS version:

```
EuiccInfo info = mgr.getEuiccInfo();
String osVer = info.getOsVersion();
```

Many APIs, such as `downloadSubscription()` and `switchToSubscription()`, use
`PendingIntent` callbacks as they may take seconds or even minutes to complete.
The `PendingIntent` is sent with a result code in the
`EuiccManager#EMBEDDED_SUBSCRIPTION_RESULT_` space, which provides
framework-defined error codes, as well as an arbitrary detailed result code
propagated from the LPA as `EXTRA_EMBEDDED_SUBSCRIPTION_DETAILED_CODE`, allowing
the carrier app to track for logging/debugging purposes. The `PendingIntent`
must be a `BroadcastReceiver`.

To download a given `DownloadableSubscription` (created from an
_activation code_ or a QR code):

```
// Register receiver.
static final String ACTION_DOWNLOAD_SUBSCRIPTION = "download_subscription";
static final String LPA_DECLARED_PERMISSION
    = "com.your.company.lpa.permission.BROADCAST";
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
context.registerReceiver(receiver,
        new IntentFilter(ACTION_DOWNLOAD_SUBSCRIPTION),
        LPA_DECLARED_PERMISSION /* broadcastPermission*/,
        null /* handler */);

// Download subscription asynchronously.
DownloadableSubscription sub = DownloadableSubscription
        .forActivationCode(code /* encodedActivationCode*/);
Intent intent = new Intent(action);
PendingIntent callbackIntent = PendingIntent.getBroadcast(
        getContext(), 0 /* requestCode */, intent,
        PendingIntent.FLAG_UPDATE_CURRENT);
mgr.downloadSubscription(sub, true /* switchAfterDownload */,
        callbackIntent);
```

To switch to a subscription given the subscription ID:

```
// Register receiver.
static final String ACTION_SWITCH_TO_SUBSCRIPTION = "switch_to_subscription";
static final String LPA_DECLARED_PERMISSION
    = "com.your.company.lpa.permission.BROADCAST";
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
context.registerReceiver(receiver,
        new IntentFilter(ACTION_SWITCH_TO_SUBSCRIPTION),
        LPA_DECLARED_PERMISSION /* broadcastPermission*/,
        null /* handler */);

// Switch to a subscription asynchronously.
Intent intent = new Intent(action);
PendingIntent callbackIntent = PendingIntent.getBroadcast(
        getContext(), 0 /* requestCode */, intent,
        PendingIntent.FLAG_UPDATE_CURRENT);
mgr.switchToSubscription(1 /* subscriptionId */, callbackIntent);
```

For a complete list of `EuiccManager` APIs and code examples, see
[eUICC APIs](/devices/tech/connect/esim-euicc-api).

### Resolvable errors

There are some cases where the system is unable to complete the eSIM operation
but the error can be resolved by the user. For example, `downloadSubscription`
may fail if the profile metadata indicates that a *carrier confirmation code*
is required. Or `switchToSubscription` may fail if the carrier app has carrier
privileges over the destination profile (i.e. carrier owns the profile) but
doesn't have carrier privileges over the currently enabled profile, and hence
user consent is required.

For these cases, the caller's callback is called with
`EuiccManager#EMBEDDED_SUBSCRIPTION_RESULT_RESOLVABLE_ERROR`. The callback
`Intent` will contain internal extras such that when the caller passes it to
[`EuiccManager#startResolutionActivity`](https://developer.android.com/reference/android/telephony/euicc/EuiccManager.html#startResolutionActivity(android.app.Activity,%20int,%20android.content.Intent,%20android.app.PendingIntent)){: .external},
resolution can be requested through the LUI. Using the confirmation code for
example again,
[`EuiccManager#startResolutionActivity`](https://developer.android.com/reference/android/telephony/euicc/EuiccManager.html#startResolutionActivity(android.app.Activity,%20int,%20android.content.Intent,%20android.app.PendingIntent)){: .external}
triggers an LUI screen that allows the user to enter a confirmation code;
after the code is entered, the download operation is resumed. This approach
provides the carrier app with full control over when the UI is shown, but gives
the LPA/LUI an extensible method for adding new handling of user-recoverable
issues in the future without needing client apps to change.

Android {{ androidPVersionNumber }} defines these resolvable errors in
[`EuiccService`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/service/euicc/EuiccService.java){: .external},
which the LUI should handle:

```
/**
 * Alert the user that this action will result in an active SIM being
 * deactivated. To implement the LUI triggered by the system, you need to define
 * this in AndroidManifest.xml.
 */
public static final String ACTION_RESOLVE_DEACTIVATE_SIM =
        "android.service.euicc.action.RESOLVE_DEACTIVATE_SIM";
/**
 * Alert the user about a download/switch being done for an app that doesn't
 * currently have carrier privileges.
 */
public static final String ACTION_RESOLVE_NO_PRIVILEGES =
        "android.service.euicc.action.RESOLVE_NO_PRIVILEGES";

/** Ask the user to resolve all the resolvable errors. */
public static final String ACTION_RESOLVE_RESOLVABLE_ERRORS =
        "android.service.euicc.action.RESOLVE_RESOLVABLE_ERRORS";
```

### Carrier privileges

If you are a carrier developing your own carrier app that calls `EuiccManager`
to download profiles onto a device, your profile should include carrier
privilege rules corresponding to your carrier app in the metadata. This is
because subscription profiles belonging to different carriers can co-exist in
the eUICC of a device, and each carrier app should only be allowed to access the
profiles owned by that carrier. For example, carrier A should not be able to
download, enable, or disable a profile owned by carrier B.

To ensure a profile is only accessible to its owner, Android uses a mechanism to
grant special privileges to the profile owner's app (i.e. carrier app). The
Android platform loads certificates stored in the profile's Access Rule File
(ARF) and grants permission to apps signed by these certificates to make calls
to `EuiccManager` APIs. The high-level process is described below:

1.  Operator signs the carrier app APK; the
    [apksigner](https://developer.android.com/studio/command-line/apksigner){: .external}
    tool attaches the public-key certificate to the APK.
1.  Operator/SM-DP+ prepares a profile and its metadata, which include an ARF
    that contains:

    1.  Signature (SHA-1 or SHA-256) of the carrier app's public-key certificate
        (required)
    1.  Package name of the carrier app (optional)

1.  Carrier app tries to perform an eUICC operation via `EuiccManager` API.

1.  Android platform verifies SHA-1 or SHA-256 hash of the caller app's
    certificate matches the signature of the certificate obtained from the
    target profile's ARF. If the package name of the carrier app is included in
    the ARF, it must also match the package name of the caller app.

1.  After the signature and the package name (if included) are verified, the
    carrier privilege is granted to the caller app over the target profile.

Because profile metadata can be available outside of the profile itself (so that
LPA can retrieve the profile metadata from SM-DP+ before the profile is
downloaded, or from ISD-R when the profile is disabled), it should contain the
same carrier privilege rules as in the profile.

The eUICC OS and SM-DP+ must support a proprietary tag **BF76** in the profile
metadata. The tag content should be the same carrier privilege rules as returned
by the ARA (Access Rule Applet) defined in
[UICC Carrier Privileges](/devices/tech/config/uicc):

```
RefArDo ::= [PRIVATE 2] SEQUENCE {  -- Tag E2
    refDo [PRIVATE 1] SEQUENCE {  -- Tag E1
        deviceAppIdRefDo [PRIVATE 1] OCTET STRING (SIZE(20|32)),  -- Tag C1
        pkgRefDo [PRIVATE 10] OCTET STRING (SIZE(0..127)) OPTIONAL  -- Tag CA
    },
    arDo [PRIVATE 3] SEQUENCE {  -- Tag E3
        permArDo [PRIVATE 27] OCTET STRING (SIZE(8))  -- Tag DB
    }
}
```

For more details on app signing, see
[Sign your app](https://developer.android.com/studio/publish/app-signing){: .external}.
For details on carrier privileges, see
[UICC Carrier Privileges](/devices/tech/config/uicc).

## Making an LPA app

You can implement your own LPA, which must be hooked up with Android Euicc
APIs. The following sections give a brief overview of making an LPA app and
integrating it with the Android system.

### Hardware/modem requirements

The LPA and the eSIM OS on the eUICC chip must support at least GSMA RSP (Remote
SIM Provisioning) v2.0 or v2.2. You should also plan to use SM-DP+ and SM-DS
servers that have a matching RSP version. For detailed RSP architecture, see
[GSMA SGP.21 RSP Architecture Specification](https://www.gsma.com/newsroom/all-documents/sgp-21-rsp-architecture-v2-2/){: .external}.

In addition, to integrate with the eUICC APIs in Android
{{ androidPVersionNumber }}, the device modem should send terminal capabilities
with the support for eUICC capabilities encoded (Local Profile Management and
Profile Download). It also needs to implement the following methods:

+   IRadio HAL v1.1: setSimPower
+   IRadio HAL v1.2: getIccCardStatus

    Note: Support for IRadio HAL v1.4 is required for devices launching with
    Android {{ androidQVersionNumber }} and is recommended for all other
    Android versions.

+   IRadioConfig HAL v1.0: getSimSlotsStatus

    Note: Support for IRadioConfig HAL v1.2 is required for devices launching
    with Android {{ androidQVersionNumber }} and is recommended for all other
    Android versions.

The modem should recognize the eSIM with the default boot profile enabled as a
valid SIM and keep the SIM power on.

For devices running Android {{ androidQVersionNumber }}, a non-removable eUICC
slot ID array must be defined. For example, see
[`arrays.xml`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/res/res/values/arrays.xml){: . external}.

```
<resources>
   <!-- Device-specific array of SIM slot indexes which are are embedded eUICCs.
        e.g. If a device has two physical slots with indexes 0, 1, and slot 1 is an
        eUICC, then the value of this array should be:
            <integer-array name="non_removable_euicc_slots">
                <item>1</item>
            </integer-array>
        If a device has three physical slots and slot 1 and 2 are eUICCs, then the value of
        this array should be:
            <integer-array name="non_removable_euicc_slots">
               <item>1</item>
               <item>2</item>
            </integer-array>
        This is used to differentiate between removable eUICCs and built in eUICCs, and should
        be set by OEMs for devices which use eUICCs. -->

   <integer-array name="non_removable_euicc_slots">
       <item>1</item>
   </integer-array>
</resources>

```

For a complete list of modem requirements, see
[Modem Requirements for eSIM Support](/devices/tech/connect/esim-modem-requirements).

### EuiccService

An LPA consists of two separate components (may both be implemented in the same
APK): the LPA backend, and the LPA UI or LUI.

To implement the LPA backend, you must extend
[`EuiccService`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/service/euicc/EuiccService.java){: .external}
and declare this service in your manifest file. The service must require the
`android.permission.BIND_EUICC_SERVICE` system permission to ensure that only
the system can bind to it. The service must also include an intent filter with
the `android.service.euicc.EuiccService` action. The priority of the intent
filter should be set to a non-zero value in case multiple implementations are
present on the device. For example:

```
<service
    android:name=".EuiccServiceImpl"
    android:permission="android.permission.BIND_EUICC_SERVICE">
    <intent-filter android:priority="100">
        <action android:name="android.service.euicc.EuiccService" />
    </intent-filter>
</service>
```

Internally, the Android framework determines the active LPA and interacts with
it as needed to support the Android eUICC APIs. `PackageManager` is queried for
all apps with the `android.permission.WRITE_EMBEDDED_SUBSCRIPTIONS` permission,
which specifies a service for the `android.service.euicc.EuiccService` action.
The service with the highest priority is selected. If no service is found, LPA
support is disabled.

To implement the LUI, you must provide an activity for the following actions:

+   `android.service.euicc.action.MANAGE_EMBEDDED_SUBSCRIPTIONS`
+   `android.service.euicc.action.PROVISION_EMBEDDED_SUBSCRIPTION`

As with the service, each activity must require the
`android.permission.BIND_EUICC_SERVICE` system permission. Each should have an
intent filter with the appropriate action, the
`android.service.euicc.category.EUICC_UI` category, and a non-zero priority.
Similar logic is used to pick the implementations for these activities as
with picking the implementation of
[`EuiccService`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/service/euicc/EuiccService.java){: .external}.
For example:

```
<activity android:name=".MyLuiActivity"
          android:exported="true"
          android:permission="android.permission.BIND_EUICC_SERVICE">
    <intent-filter android:priority="100">
        <action android:name="android.service.euicc.action.MANAGE_EMBEDDED_SUBSCRIPTIONS" />
        <action android:name="android.service.euicc.action.PROVISION_EMBEDDED_SUBSCRIPTION" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.service.euicc.category.EUICC_UI" />
    </intent-filter>
</activity>
```

This implies that the UI implementing these screens can come from a different
APK from the one that implements
[`EuiccService`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/service/euicc/EuiccService.java){: .external}.
Whether to have a single APK or multiple APKs (e.g. one that implements
`EuiccService` and one that provides LUI activities) is a design choice.

### EuiccCardManager

`EuiccCardManager` is the interface for communicating with the eSIM chip. It
provides ES10 functions (as described in the GSMA RSP spec) and handles the
low-level APDU request/response commands as well as ASN.1 parsing.
`EuiccCardManager` is a system API and can be called only by system-privileged
applications.

![Carrier apps, LPA, and Euicc APIs](/devices/tech/connect/images/carrier-app-euicc-apis.png)

**Figure 2.** Both carrier app and LPA use Euicc APIs

The profile operation APIs through `EuiccCardManager` require the caller to be
an LPA. This is enforced by the Android framework. This means the caller must
extend the `EuiccService` and be declared in your manifest file, as described in
the previous sections.

Similar to the `EuiccManager`, to use the `EuiccCardManager` APIs, your LPA must
first obtain the instance of `EuiccCardManager` through
`Context#getSystemService`:

```
EuiccCardManager cardMgr = (EuiccCardManager) context.getSystemService(Context.EUICC_CARD_SERVICE);
```

Then, to get all the profiles on the eUICC:

```
ResultCallback<EuiccProfileInfo[]> callback =
       new ResultCallback<EuiccProfileInfo[]>() {
           @Override
           public void onComplete(int resultCode,
                   EuiccProfileInfo[] result) {
               if (resultCode == EuiccCardManagerReflector.RESULT_OK) {
                   // handle result
               } else {
                   // handle error
               }
           }
       };

cardMgr.requestAllProfiles(eid, AsyncTask.THREAD_POOL_EXECUTOR, callback);
```

Internally, `EuiccCardManager` binds to `EuiccCardController` (which runs in the
phone process) through an AIDL interface, and each `EuiccCardManager` method
receives its callback from the phone process through a different, dedicated AIDL
interface. When using `EuiccCardManager` APIs, the caller (LPA) must provide an
[`Executor`](https://developer.android.com/reference/java/util/concurrent/Executor){: .external}
through which the callback is invoked. This `Executor` may run on a single
thread or on a thread pool of your choice.

Most `EuiccCardManager` APIs have the same usage pattern. For example, to load a
bound profile package onto the eUICC:

```
...
cardMgr.loadBoundProfilePackage(eid, boundProfilePackage,
        AsyncTask.THREAD_POOL_EXECUTOR, callback);
```

To switch to a different profile with a given ICCID:

```
...
cardMgr.switchToProfile(eid, iccid, true /* refresh */,
        AsyncTask.THREAD_POOL_EXECUTOR, callback);
```

To get the default SM-DP+ address from the eUICC chip:

```
...
cardMgr.requestDefaultSmdpAddress(eid, AsyncTask.THREAD_POOL_EXECUTOR,
        callback);
```

To retrieve a list of notifications of the given notification events:

```
...
cardMgr.listNotifications(eid,
        EuiccNotification.Event.INSTALL
              | EuiccNotification.Event.DELETE /* events */,
        AsyncTask.THREAD_POOL_EXECUTOR, callback);
```

## Supporting multiple eSIMs

For devices running Android {{ androidQVersionNumber }} or higher, the
EuiccManager class supports devices
with multiple eSIMs. Devices with a single eSIM that are upgrading to
Android {{ androidQVersionNumber }}
don't require any modification to the LPA implementation as the platform
automatically associates the EuiccManager instance with the default eUICC. The
default eUICC is determined by the platform for devices with radio HAL version
1.2 or higher and by the LPA for devices with radio HAL versions lower than
1.2.

### Requirements

To support multiple eSIMs, the device must have more than one eUICC, which can
be either a built-in eUICC or a physical SIM slot where removable eUICCs can be
inserted.

Radio HAL version 1.2 or higher is required to support multiple eSIMs. Radio HAL
version 1.4 and RadioConfig HAL version 1.2 are recommended.

### Implementation

To support multiple eSIMs (including removable eUICCs or programmable SIMs), the
LPA must implement
[`EuiccService`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/service/euicc/EuiccService.java){: .external},
which receives the slot ID corresponding to the caller-provided card ID.

The
[`non_removable_euicc_slots`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/res/res/values/arrays.xml#202){: .external}
resource specified in
[`arrays.xml`](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/master/core/res/res/values/arrays.xml){: .external}
is an array of integers that represent the slot IDs of a device's built-in
eUICCs. You must specify this resource to allow the platform to determine
whether an inserted eUICC is removable or not.

### Carrier app for device with multiple eSIMs

When making a carrier app for a device with multiple eSIMs, use the
[`createForCardId`](https://developer.android.com/reference/android/telephony/euicc/EuiccManager#createForCardId(int)){: .external}
method in `EuiccManager` to create an `EuiccManager` object that is pinned to a
given card ID. The card ID is an integer value that uniquely identifies a UICC
or an eUICC on the device.

To get the card ID for the device's default eUICC, use the
[`getCardIdForDefaultEuicc`](https://developer.android.com/reference/android/telephony/TelephonyManager#getCardIdForDefaultEuicc()){: .external}
method in `TelephonyManager`. This method returns
[`UNSUPPORTED_CARD_ID`](https://developer.android.com/reference/android/telephony/TelephonyManager#UNSUPPORTED_CARD_ID){: .external}
if the radio HAL version is lower than 1.2 and returns
[`UNINITIALIZED_CARD_ID`](https://developer.android.com/reference/android/telephony/TelephonyManager#UNINITIALIZED_CARD_ID){: .external}
if the device hasn't read the eUICC.

You can also get card IDs from
[`getUiccCardsInfo`](https://developer.android.com/reference/android/telephony/TelephonyManager#getUiccCardsInfo()){: .external}
and `getUiccSlotsInfo` (system API) in `TelephonyManager`, and
[`getCardId`](https://developer.android.com/reference/android/telephony/SubscriptionInfo#getCardId()){: .external}
in `SubscriptionInfo`.

When an `EuiccManager` object has been instantiated with a specific card ID, all
operations are directed to the eUICC with that card ID. If the eUICC becomes
unreachable (for example, when it is turned off or removed) `EuiccManager` no
longer works.

You can use the following code samples to create a carrier app.

Example 1: Get active subscription and instantiate `EuiccManager`

```
// Get the active subscription and instantiate an EuiccManager for the eUICC which holds
// that subscription
SubscriptionManager subMan = (SubscriptionManager)
        mContext.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE);
int cardId = subMan.getActiveSubscriptionInfo().getCardId();
EuiccManager euiccMan = (EuiccManager) mContext.getSystemService(Context.EUICC_SERVICE)
            .createForCardId(cardId);
```

Example 2: Iterate through UICCs and instantiate `EuiccManager` for a
removable eUICC

```
// On a device with a built-in eUICC and a removable eUICC, iterate through the UICC cards
// to instantiate an EuiccManager associated with a removable eUICC
TelephonyManager telMan = (TelephonyManager)
        mContext.getSystemService(Context.TELEPHONY_SERVICE);
List<UiccCardInfo> infos = telMan.getUiccCardsInfo();
int removableCardId = -1; // valid cardIds are 0 or greater
for (UiccCardInfo info : infos) {
    if (info.isRemovable()) {
        removableCardId = info.getCardId();
        break;
    }
}
if (removableCardId != -1) {
    EuiccManager euiccMan = (EuiccManager) mContext.getSystemService(Context.EUICC_SERVICE)
            .createForCardId(removableCardId);
}
```

## Validation

AOSP does not come with an LPA implementation and you are not expected to
have an LPA available on all Android builds (not every phone supports eSIM). For
this reason, there are no end-to-end CTS test cases. However, basic test cases are available in AOSP to ensure the exposed eUICC APIs
are valid in Android builds.

You should make sure the builds pass the following CTS test cases (for public
APIs):

[https://android.googlesource.com/platform/cts/+/master/tests/tests/telephony/src/android/telephony/](https://android.googlesource.com/platform/cts/+/master/tests/tests/telephony/src/android/telephony/euicc/cts){: .external}

Carriers implementing a carrier app should go through their normal in-house
quality assurance
cycles to ensure all implemented features are working as expected. At the
minimum, the carrier app should be able to list all the subscription profiles
owned by the same operator, download and install a profile, activate service on
the profile, switch between profiles, and delete profiles.

If you are making your own LPA, you should go through much more rigorous
testing. You should work with your modem vendor, eUICC chip or eSIM OS vendor,
SM-DP+ vendors, and carriers to resolve issues and ensure interoperability of
your LPA within the RSP architecture. A good amount of manual testing is
inevitable. For best test coverage, you should follow the
[GSMA SGP.23 RSP Test Plan](https://www.gsma.com/newsroom/all-documents/sgp-23-v1-2-rsp-test-specification/){: .external}.
