# 3\. Software

## 3.1\. Managed API Compatibility

The managed Dalvik bytecode execution environment is the primary vehicle for
Android applications. The Android application programming interface (API) is the
set of Android platform interfaces exposed to applications running in the
managed runtime environment. Device implementations MUST provide complete
implementations, including all documented behaviors, of any documented API
exposed by the [Android
SDK](http://developer.android.com/reference/packages.html) or any API decorated
with the “@SystemApi” marker in the upstream Android source code.

Device implementations MUST NOT omit any managed APIs, alter API interfaces or
signatures, deviate from the documented behavior, or include no-ops, except
where specifically allowed by this Compatibility Definition.

This Compatibility Definition permits some types of hardware for which Android
includes APIs to be omitted by device implementations. In such cases, the APIs
MUST still be present and behave in a reasonable way. See [section
7](#7_hardware_compatibility) for specific requirements for this scenario.
