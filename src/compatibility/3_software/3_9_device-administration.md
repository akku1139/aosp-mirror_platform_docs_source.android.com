## 3.9\. Device Administration

Android includes features that allow security-aware applications to perform
device administration functions at the system level, such as enforcing password
policies or performing remote wipe, through the
[Android Device Administration API](http://developer.android.com/guide/topics/admin/device-admin.html)].
Device implementations MUST provide an implementation of the
[DevicePolicyManager](http://developer.android.com/reference/android/app/admin/DevicePolicyManager.html)
class. Device implementations that include support for PIN (numeric) or PASSWORD
(alphanumeric) based lock screens MUST support the full range of
[device administration](http://developer.android.com/guide/topics/admin/device-admin.html)
policies defined in the Android SDK documentation and report the platform
feature android.software.device_admin.

### 3.9.1 Device Provisioning

#### 3.9.1.1 Device owner provisioning

If a device implementation declares the android.software.device_admin feature,
the out of box setup flow MUST make it possible to enroll a Device Policy
Controller (DPC) application as the
[Device Owner app](http://developer.android.com/reference/android/app/admin/DevicePolicyManager.html#isDeviceOwnerApp(java.lang.String)).
Device implementations MAY have a preinstalled application performing device
administration functions but this application MUST NOT be set as the Device
Owner app without explicit consent or action from the user or the administrator
of the device.

The device owner provisioning process (the flow initiated by
[android.app.action.PROVISION_MANAGED_DEVICE](http://developer.android.com/reference/android/app/admin/DevicePolicyManager.html#ACTION_PROVISION_MANAGED_DEVICE))
user experience MUST align with the AOSP implementation.

If the device implementation reports android.hardware.nfc, it MUST have NFC
enabled, even during the out-of-box setup flow, in order to allow for
[NFC provisioning of Device owners](https://source.android.com/devices/tech/admin/provision.html#device_owner_provisioning_via_nfc).

#### 3.9.1.2 Managed profile provisioning

If a device implementation declares the android.software.managed_users, it MUST
be possible to enroll a Device Policy Controller (DPC) application as the
[owner of a new Managed Profile](http://developer.android.com/reference/android/app/admin/DevicePolicyManager.html#isProfileOwnerApp(java.lang.String)).

The managed profile provisioning process (the flow initiated by
[android.app.action.PROVISION_MANAGED_PROFILE](http://developer.android.com/reference/android/app/admin/DevicePolicyManager.html#ACTION_PROVISION_MANAGED_PROFILE))
user experience MUST align with the AOSP implementation.

## 3.9.2 Managed Profile Support

Managed profile capable devices are those devices that:

*   Declare android.software.device_admin (see [section 3.9 Device Administration](#3_9_device_administration)).
*   Are not low RAM devices (see [section 7.6.1](#7_6_1_minimum_memory_and_storage)).
*   Allocate internal (non-removable) storage as shared storage (see [section 7.6.2](#7_6_2_application_shared_storage)).

Managed profile capable devices MUST:

*   Declare the platform feature flag android.software.managed_users.
*   Support managed profiles via the android.app.admin.DevicePolicyManager APIs.
*   Allow one and only [one managed profile to be created](http://developer.android.com/reference/android/app/admin/DevicePolicyManager.html#ACTION_PROVISION_MANAGED_PROFILE).
*   Use an icon badge (similar to the AOSP upstream work badge) to represent the
    managed applications and widgets and other badged UI elements like Recents &
    Notifications.
*   Display a notification icon (similar to the AOSP upstream work badge) to
    indicate when user is within a managed profile application.
*   Display a toast indicating that the user is in the managed profile if and
    when the device wakes up (ACTION_USER_PRESENT) and the foreground
    application is within the managed profile.
*   Where a managed profile exists, show a visual affordance in the Intent
    'Chooser' to allow the user to forward the intent from the managed profile
    to the primary user or vice versa, if enabled by the Device Policy
    Controller.
*   Where a managed profile exists, expose the following user affordances for
    both the primary user and the managed profile:
    *   Separate accounting for battery, location, mobile data and storage usage
        for the primary user and managed profile.
    *   Independent management of VPN Applications installed within the primary
        user or managed profile.
    *   Independent management of applications installed within the primary user
        or managed profile.
    *   Independent management of accounts within the primary user or managed
        profile.
*   Ensure the default dialer can look up caller information from the managed
    profile (if one exists) alongside those from the primary profile, if the
    Device Policy Controller permits it.
*   MUST ensure that it satisfies all the security requirements applicable for a
    device with multiple users enabled (see
    [section 9.5](#9_5_multi-user_support)), even though the managed profile is not
    counted as another user in addition to the primary user.

