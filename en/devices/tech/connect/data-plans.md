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

# Implementing Data Plans

Android {{ androidPVersionNumber }} lets carriers directly provide authoritative
plan details to users in the Settings app to reduce user confusion and support
calls. On devices running Android 4.0 and higher, users are able to manually
configure their carrier-specific data plan details in the Settings app, for
example, setting warnings and limits to manage their data usage.

## Configuration by Carrier

To configure data plans, carriers can add functionality to their existing
Android apps using the
[`SubscriptionPlan` APIs](https://developer.android.com/reference/android/telephony/SubscriptionPlan.Builder).
The APIs are designed to support a wide range of data plan types, including both
recurring and non-recurring plans, and plans that change over time.

Here's an example of how to configure a common type of data plan that recurs
monthly:

```
SubscriptionManager sm =
    context.getSystemService(SubscriptionManager.class);
sm.setSubscriptionPlans(subId, Lists.newArrayList(
    SubscriptionPlan.Builder.createRecurringMonthly(
            ZonedDateTime.parse("2016-12-03T10:00:00Z"))
        .setTitle("G-Mobile")
        .setDataLimit(4_000_000_000L,
            SubscriptionPlan.LIMIT_BEHAVIOR_BILLED)
        .setDataUsage(200_493_293L, dataUsageTimestamp)
        .build()));
```

The device only lets an app configure data plans under one of these conditions:

+   The SIM card has explicitly defined an app that can manage it, as defined by
    [`SubscriptionManager.canManageSubscription()`](https://developer.android.com/reference/android/telephony/SubscriptionManager.html#canManageSubscription\(android.telephony.SubscriptionInfo\)).
+   The carrier has pushed the
    [`KEY_CONFIG_PLANS_PACKAGE_OVERRIDE_STRING`](https://developer.android.com/reference/android/telephony/CarrierConfigManager#KEY_CONFIG_PLANS_PACKAGE_OVERRIDE_STRING)
    value via `CarrierConfigManager` to indicate which app can manage the
    carrier's data plans.
+   The device has an app built into the system image that has the
    `MANAGE_SUBSCRIPTION_PLANS` permission.

The first two conditions enable the carrier app to be installed by the user,
without requiring that it be pre-installed into the system image at the factory.
The OS enforces (and the CDD requires) that all configured data plan details are
protected and are only made available to the carrier app that originally
provided the details to the OS.

One suggested design is for a carrier app to use an idle maintenance service to
update data plan details on a daily basis, but carriers are free to use a wide
range of mechanisms, such as receiving data plan details via carrier-internal
SMS messages. Idle maintenance services are best implemented with a
`JobScheduler` job that uses
[`setRequiresDeviceIdle()`](https://developer.android.com/reference/android/app/job/JobInfo.Builder#setRequiresDeviceIdle\(boolean\))
and
[`setRequiresCharging()`](https://developer.android.com/reference/android/app/job/JobInfo.Builder.html#setRequiresCharging\(boolean\)).

## Usage by OS

The OS uses the data plan details provided by the SubscriptionPlan APIs in the
following ways:

+   The plan details are surfaced via the Settings app to display accurate data
    usage to users and to provide
    [direct deep links into the carrier app](https://developer.android.com/reference/android/telephony/SubscriptionManager.html#ACTION_MANAGE_SUBSCRIPTION_PLANS)
    for upgrade/upsell opportunities.
+   The data usage warning and limit notification thresholds are automatically
    configured based on the plan details; the warning is set to 90% of the
    limit.
+   If the carrier temporarily indicates the network is
    ["congested"](https://developer.android.com/reference/android/telephony/SubscriptionManager.html#setSubscriptionOverrideCongested\(int,%20boolean,%20long\)),
    the OS delays JobScheduler jobs that can be time-shifted, reducing the load
    on the carrier network.
+   If the carrier temporarily indicates the network is
    ["unmetered"](https://developer.android.com/reference/android/telephony/SubscriptionManager#setSubscriptionOverrideUnmetered\(int,%20boolean,%20long\)),
    the OS can report the cellular connection as "unmetered" until the carrier
    clears the override, or until the timeout value (if provided) is reached.
+   By comparing the user's current data usage with the overall data limit, the
    OS estimates the user's normal data usage at the end of the billing cycle
    and conservatively allocates 10% of any surplus data to improve the user
    experience, for example, by letting apps use multi-path data.

## Customization and validation

The Android Settings app displays all carrier-configured data plan details,
ensuring that users see the most accurate status of their carrier relationship,
and offering users a path into the carrier app to upgrade their plan. Device
manufacturers choosing to customize the Settings app are recommended to continue
surfacing these details.

The `SubscriptionManager` APIs described above are tested by
`android.telephony.cts.SubscriptionManagerTest`, which ensures that data plan
details can be configured by carrier apps and that changes are propagated within
the OS.
