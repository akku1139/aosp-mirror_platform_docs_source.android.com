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

# Wi-Fi Infrastructure Features

The Android Wi-Fi framework helps users connect to a good Wi-Fi network when
networks are available and needed. Android does that in multiple ways:

+   **Open network notification**: Informing users about available _good_ open
    Wi-Fi networks
+   **Turn on Wi-Fi automatically**: Re-enabling Wi-Fi when the user is near a
    previously saved network
+   **Connect to open networks**: Automatically connecting the user to _good_
    open Wi-Fi networks
+   **Badging**: Displaying information about the quality of the available
    networks

The features described are implemented by AOSP code and you do not have to
explicitly enable or configure them.

## Open network notification

The *Open network notification* feature raises a notification to the user
whenever:

+   Wi-Fi is enabled
+   The device is not connected to a Wi-Fi network
+   A Wi-Fi network that is both **open** and has a *sufficiently*
    **high RSSI** (the same RSSI threshold as used by the internal Wi-Fi
    selection algorithm) is available

The feature can be enabled or disabled by the user using the Settings app at:

**Settings** > **Network & internet** > **Wi-Fi** > **Wi-Fi preferences** >
**Open network notification**

<figure>
  <img src="/devices/tech/connect/images/open-network-notification.png"
       alt="Open network notification feature" class="screenshot" width="350">
  <figcaption><strong>Figure 1.</strong> Open network notification
  feature</figcaption>
</figure>

## Turn on Wi-Fi automatically

Users may disable Wi-Fi for a variety of reasons (e.g. a connection to a bad
network) and can then forget to re-enable it when arriving back home, resulting
in a bad experience (e.g. not being able to control home automation devices).
The _Turn on Wi-Fi automatically_ feature, introduced in
Android {{ androidPVersionNumber }},
solves this issue by automatically
re-enabling Wi-Fi whenever the device is near a Wi-Fi network that is both a
**saved** network (i.e. one which the user explicitly connected to in the past)
and has a _sufficiently_ **high RSSI.**

The feature can be enabled or disabled by the user using the Settings app at:

**Settings** > **Network & internet** > **Wi-Fi** > **Wi-Fi preferences** >
**Turn on Wi-Fi automatically**

<figure>
  <img src="/devices/tech/connect/images/auto-wifi.png"
       alt="Turn on Wi-Fi automatically" class="screenshot" width="350">
  <figcaption><strong>Figure 2.</strong> Turn on Wi-Fi automatically
  feature</figcaption>
</figure>

Wi-Fi Scanning (for Location) must be enabled for this feature to function. If
Wi-Fi Scanning is not enabled the user is prompted for permission to enable it.
Wi-Fi Scanning is required because scan results are used to determine whether
the device is in the vicinity of a Wi-Fi network that meets the criteria to
re-enable Wi-Fi connectivity.

The feature avoids re-enabling Wi-Fi immediately after a user disables it, even
if the device observes a saved Wi-Fi network of sufficient quality. For
example, if the user is in the office and is connected to the office Wi-Fi (a
_saved_ network) and then disables Wi-Fi, the feature will not re-enable Wi-Fi
until the user arrives at a different environment with a different saved
network that meets the re-enabling criteria.

## Auto connect to open networks

The _Connect to open networks_ feature, available on Android 8.0 and higher,
automatically connects the device to
available high quality networks. The criteria are:

+   Wi-Fi is enabled
+   The device is not connected to a Wi-Fi network
+   A Wi-Fi network that is both **open** and is _good_, as reported by the
    external _Network rating provider_ (see next section), is available.

The feature can be enabled or disabled by the user using the Settings app at:

**Settings** > **Network & internet** > **Wi-Fi** > **Wi-Fi preferences** >
**Connect to open networks**

<figure>
  <img src="/devices/tech/connect/images/connect-open-networks.png"
       alt="Connect to open networks" class="screenshot" width="350">
  <figcaption><strong>Figure 3.</strong> Connect to open networks feature and
  Network rating provider menu</figcaption>
</figure>

The _Connect to open networks_ feature is disabled if an external
_Network rating provider_ is not selected. The
user can select any of the available network rating providers using the Network
rating provider menu.

### External network rating provider

Note: As an alternative to the `NetworkScoreManager` API, it is recommended to
use the
[`WifiNetworkSuggestion`](https://developer.android.com/reference/android/net/wifi/WifiNetworkSuggestion){: .external}
class.

To help determine what constitutes a _good_ Wi-Fi network, Android supports
external _Network rating providers_ (also known as _Network scorers_) that
provide information about the quality of open Wi-Fi networks. For instance, a
network scorer may use historical performance data (e.g. this AP worked really
well in the past, good idea to try it now) to determine that a particular Wi-Fi
network is good.

The list of available network rating providers is available to the user from
the **Settings** > **Network & internet** > **Wi-Fi** > **Wi-Fi preferences** >
**Advanced** > **Network rating provider** menu. The user may select one or
none of them. If none are available or selected, the _Connect to open networks_
feature is disabled.

You do not have to provide an external network rating provider. To create a
provider:

+   Implement the class documented in
    [`NetworkScoreManager`](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/net/NetworkScoreManager.java){: .external}.
+   The external network rating provider must be a privileged app.
+   Configure your system to use your custom implementation by updating the
    `config_defaultNetworkRecommendationProviderPackage` key in your product's
    overlay configuration file of
    `frameworks/base/core/res/res/values/config.xml`.

If you do not want to include the default network rating provider
functionality, you can choose not to set a default provider property and hide
the **Network rating provider** screen in AOSP.

### Wi-Fi network badging

The information provided by the network rating provider is also used by the
_Wi-Fi Picker_ to add information on the quality of available Wi-Fi networks,
which can help the user with selecting Wi-Fi networks manually. Networks for
which information is available (provided by the external network rating
provider) will display speed information below the network name.

<figure>
  <img src="/devices/tech/connect/images/wifi-network-quality.png"
       alt="Wi-Fi network quality" class="screenshot" width="350">
  <figcaption><strong>Figure 4.</strong> Wi-Fi networks with information
  about network quality </figcaption>
</figure>

Because this feature requires an external network rating provider, it is not
available, and no speed/quality information is displayed, if no such provider
is available or selected.
