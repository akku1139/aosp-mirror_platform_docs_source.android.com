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

# Implementing IMS

Android {{ androidPVersionNumber }} introduces a new SystemApi interface called
[ImsService](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/ims/)
to help you implement IP Multimedia Subsystem (IMS). The ImsService API is a
well-defined interface between the Android platform and a vendor or
carrier-provided IMS implementation.

<img src="/devices/tech/connect/images/imsservice.png" alt="ImsService overview" width="">

**Figure 1.** ImsService overview

By using the ImsService interface, the IMS implementer can provide important
signaling information to the platform, such as IMS registration information, SMS
over IMS integration, and MmTel feature integration to provide voice and video
calling. The ImsService API is an Android System API as well, meaning it can be
built against the Android SDK directly instead of against the source. An IMS
application that has been pre-installed on the device can also be configured to
be Play Store updatable.

## Examples and source

Android provides an application on AOSP that implements portions of the
ImsService API for testing and development purposes. You can find the
application at
[/testapps/ImsTestService](https://android.googlesource.com/platform/packages/services/Telephony/+/master/testapps/ImsTestService/).

You can find the documentation for the ImsService API in
[ImsService](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/ims/ImsService.java)
and in the other classes in the API.

## Implementation

The ImsService API is a high level API that lets you implement IMS in many ways,
depending on the hardware available. For example, the implementation changes
depending on whether the IMS implementation is fully on the application
processor or if it is partially or fully offloaded to the modem. Android does
not provide a public HAL for offloading to the baseband processor, so any
offloading must occur using your HAL extension to the modem.

### Compatibility with older IMS implementations

Although Android {{ androidPVersionNumber }} includes the ImsService API,
devices using an older implementation for IMS are not able to support the API.
For these devices, the older AIDL interfaces and wrapper classes have been moved
to the `android.telephony.ims.compat` namespace. When upgrading to Android
{{ androidPVersionNumber }}, older devices must do the following to continue
the support of the older API.

+   Change the namespace of the ImsService implementation to extend from the
    `android.telephony.ims.compat` namespace API.
+   Modify the ImsService service definition in AndroidManifest.xml to use the
    `android.telephony.ims.compat.ImsService` intent-filter action, instead of
    the `android.telephony.ims.ImsService` action.

The framework will then bind to the ImsService using the compatibility layer
provided in Android {{ androidPVersionNumber }} to work with the legacy
`ImsService` implementation.

### ImsService registration with the framework

The ImsService API is implemented as a service, which the Android framework
binds to in order to communicate with the IMS implementation. Three steps are
necessary to register an application that implements an ImsService with the
framework. First, the ImsService implementation must register itself with the
platform using the `AndroidManifest.xml` of the application; second, it must
define which IMS features the implementation supports (MmTel or RCS); and third,
it must be verified as the trusted IMS implementation either in the carrier
configuration or device overlay.

#### Service definition

The IMS application registers an ImsService with the framework by adding a
`service` entry into the manifest using the following format:

```
<service
    android:name="com.egcorp.ims.EgImsService"
    android:directBootAware="true"
    Android:persistent="true"
    ...
    android:permission="android.permission.BIND_IMS_SERVICE" >
    ...
    <intent-filter>
        <action android:name="android.telephony.ims.ImsService" />
    </intent-filter>
</service>
```

The `service` definition in `AndroidManifest.xml` defines the following
attributes, which are necessary for correct operation:

+   `directBootAware="true"`: Allows the `service` to be found and bound before
    the file system has been decrypted. This means that the ImsService must not
    do any file system access with encrypted files. For more information about
    File-Based Encryption (FBE), see
    [File-Based Encryption](/security/encryption/file-based).
+   `persistent="true"`: Allows this service to be run persistently and not be
    killed by the system to reclaim memory. This attribute ONLY works if the
    application is built as a system application.
+   `permission="android.permission.BIND_IMS_SERVICE"`: Ensures that only a
    process that has had the `BIND_IMS_SERVICE` permission granted to it can
    bind to the application. This prevents a rogue app from binding to the
    service, since only system applications can be granted the permission by the
    framework.

The service must also specify the `intent-filter` element with the action
`android.telephony.ims.ImsService`. This allows the framework to find the
`ImsService`.

### IMS feature specification

After the ImsService has been defined as an Android service in
AndroidManifest.xml, the ImsService must define which IMS features it supports.
Android currently supports the MmTel and RCS features, however only MmTel is
integrated into the framework. Although there are no RCS APIs integrated into
the framework, there are still advantages to declaring it as a feature of the
ImsService.

Below are the valid features defined in `android.telephony.ims.ImsFeature` that
an ImsService can provide and an explanation and example as to why an IMS
application would want to implement one or all of these features. After each
feature is defined, this page outlines how the `ImsService` declares the set of
features that it defines for each SIM slot.

#### FEATURE_MMTEL

The `ImsService` implements the IMS MMTEL feature, which contains support for
all IMS media (IR.92 and IR.94 specifications) except emergency attach to the
IMS PDN for emergency calling. Any implementation of `ImsService` that wishes to
support the MMTEL features should extend the
`android.telephony.ims.MmTelFeature` base class and return a custom
`MmTelFeature` implementation in
[`ImsService#createMmTelFeature`](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/ims/ImsService.java#335).

#### FEATURE_EMERGENCY_MMTEL

Declaring this feature only signals to the platform that emergency attach to the
IMS PDN for emergency services is possible. If this feature is not declared for
your `ImsService`, the platform will always default to Circuit Switch Fallback
for emergency services. The `FEATURE_MMTEL` feature must be defined for this
feature to be defined.

#### FEATURE_RCS

The ImsService API does not implement any IMS RCS features, but the
`android.telephony.ims.RcsFeature` base class can still be useful. The framework
automatically binds to the ImsService and calls `ImsService#createRcsFeature`
when it detects that the package should provide RCS. If the SIM card associated
with the RCS service is removed, the framework automatically calls
`RcsFeature#onFeatureRemoved` and then cleans up the `ImsService` associated
with the RCS feature. This functionality can remove some of the custom
detection/binding logic that an RCS feature would otherwise have to provide.

#### Registration of supported features

The telephony framework first binds to the ImsService to query the features that
it supports using the `ImsService#querySupportedImsFeatures` API. After the
framework calculates which features the ImsService will support, it will call
`ImsService#create[...]Feature` for each feature that the ImsService will be
responsible for. If the features that the IMS application supports changes, you
can use `ImsService#onUpdateSupportedImsFeatures` to signal the framework to
recalculate supported features. See the diagram below for more information on
the initialization and binding of the ImsService.

![ImsService initializing and binding](/devices/tech/connect/images/imsservice-sequence.png)

**Figure 2:** ImsService initialization and binding

### Framework detection and verification of ImsServices

Once the ImsService has been defined correctly in AndroidManifest.xml, the
platform must be configured to (securely) bind to the ImsService when
appropriate. There are two types of ImsServices that the framework binds to:

1.  Carrier "override" ImsService: These ImsServices are preloaded onto the
    device but are attached to one or more cellular carriers and will only be
    bound when a matching SIM card is inserted. This is configured using the
    [`key_config_ims_package_override`](https://android.googlesource.com/platform/frameworks/base/+/master/telephony/java/android/telephony/CarrierConfigManager.java#309)
    CarrierConfig key.
1.  Device "default" ImsService: This is the default ImsService that is loaded
    onto the device by an OEM and should be designed to provide IMS services in
    all situations when a carrier ImsService is not available and is useful in
    situations where the device has no SIM card inserted or the SIM card
    inserted does not have a carrier ImsService installed with it. This is
    defined in the device overlay
    [`config_ims_package`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml#2705)
    key.

Both of these ImsService implementations are required to be System applications,
or to reside in the /system/priv-app/ folder to grant the appropriate
user-granted permissions (namely phone, microphone, location, camera, and
contacts permissions). By verifying whether the package name of the IMS
implementation matches the CarrierConfig or device overlay values defined above,
only trusted applications are bound.

## Customization

The ImsService allows the IMS features that it supports (MMTEL and RCS) to be
enabled or disabled dynamically via updates using the
`ImsService#onUpdateSupportedImsFeatures` method. This triggers the framework to
recalculate which ImsServices are bound and which features they support. If the
IMS application updates the framework with no features supported, the ImsService
will be unbound until the phone is rebooted or a new SIM card is inserted that
matches the IMS application.

### Binding priority for multiple ImsService

The framework cannot support binding to all of the possible ImsServices that are
preloaded onto the device and will bind to up to two ImsServices per SIM slot
(one ImsService for each feature) in the following order:

1.  The ImsService package name defined by the CarrierConfig value
    `key_config_ims_package_override` when there is a SIM card inserted.
1.  The ImsService package name defined in the device overlay value for
    `config_ims_package`including the case where there is no SIM card inserted.
    This ImsService MUST support the Emergency MmTel feature.

You must either have the package name of your ImsService defined in the
CarrierConfig for each of the carriers that will use that package or in the
device overlay if your ImsService will be the default, as defined above.

Let's break this down for each feature. For a single SIM device, two IMS
features are possible: MMTel and RCS. The framework will try to bind in the
order defined above for each feature and if the feature is not available for the
ImsService defined in the Carrier Configuration override, the framework will
fallback to your default ImsService. So, for example, the table below describes
which IMS feature the framework will use given three IMS applications
implementing ImsServices installed on a system with the following features:

+   Carrier A ImsService supports RCS
+   Carrier B ImsService supports RCS and MMTel
+   OEM ImsService supports RCS, MMTel, and Emergency MMTel

<table>
<thead>
<tr>
<th><strong>SIM Card Inserted</strong></th>
<th><strong>RCS Feature</strong></th>
<th><strong>MMTel Feature</strong></th>
<th><strong>Emergency MMTel Feature</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td>Carrier A</td>
<td>Carrier A</td>
<td>OEM</td>
<td>OEM</td>
</tr>
<tr>
<td>Carrier B</td>
<td>Carrier B</td>
<td>Carrier B</td>
<td>OEM</td>
</tr>
<tr>
<td>No SIM</td>
<td>OEM</td>
<td>OEM</td>
<td>OEM</td>
</tr>
</tbody>
</table>

## Validation

The ImsService APIs include a GTS test suite that verifies the functionality of
the ImsService API in the framework as well as the IMS application Service
binding logic. The `GtsImsServiceTestCases` GTS APK can be run as part of the
GTS test suite to ensure that the API surface functions consistently across all
Android {{ androidPVersionNumber }} implementations.

Tools for verifying the IMS implementation itself are not included since the IMS
specifications are extremely large and use special verification equipment. The
tests can only verify that the telephony framework properly responds to the
ImsService API.
