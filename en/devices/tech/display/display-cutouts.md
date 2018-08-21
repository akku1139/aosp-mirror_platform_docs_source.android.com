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

# Display Cutouts

Android {{ androidPVersionNumber }} adds support for implementing different
types of display cutouts on devices. Display cutouts allow you to create
immersive, edge-to-edge experiences while still allowing space for important
sensors on the front of devices.

<img src="/devices/tech/display/images/top-center-cutout.png" alt="Top center display cutout" width="250px">

**Figure 1.** Top center display cutout

Android {{ androidPVersionNumber }} supports the following types of cutouts:

+   Top center: Cutout at the center of the top edge
+   Top uncentered: Cutout may be in the corner or slightly off-center
+   Bottom: Cutout at the bottom
+   Dual: One cutout on top and one on the bottom

## Examples and source

The following window manager code at
[PhoneWindowManager.java](https://android.googlesource.com/platform/frameworks/base/+/master/services/core/java/com/android/server/policy/PhoneWindowManager.java){: .external}
shows how display frames are inset to the safe area when
`LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS` is not set.

```java
// Ensure that windows with a DEFAULT or NEVER display cutout mode are laid out in
// the cutout safe zone.
if (cutoutMode != LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS) {
    final Rect displayCutoutSafeExceptMaybeBars = mTmpDisplayCutoutSafeExceptMaybeBarsRect;
    displayCutoutSafeExceptMaybeBars.set(displayFrames.mDisplayCutoutSafe);
    if (layoutInScreen && layoutInsetDecor && !requestedFullscreen
            && cutoutMode == LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT) {
        // At the top we have the status bar, so apps that are
        // LAYOUT_IN_SCREEN | LAYOUT_INSET_DECOR but not FULLSCREEN
        // already expect that there's an inset there and we don't need to exclude
        // the window from that area.
        displayCutoutSafeExceptMaybeBars.top = Integer.MIN_VALUE;
    }
    if (layoutInScreen && layoutInsetDecor && !requestedHideNavigation
            && cutoutMode == LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT) {
        // Same for the navigation bar.
        switch (mNavigationBarPosition) {
            case NAV_BAR_BOTTOM:
                displayCutoutSafeExceptMaybeBars.bottom = Integer.MAX_VALUE;
                break;
            case NAV_BAR_RIGHT:
                displayCutoutSafeExceptMaybeBars.right = Integer.MAX_VALUE;
                break;
            case NAV_BAR_LEFT:
                displayCutoutSafeExceptMaybeBars.left = Integer.MIN_VALUE;
                break;
        }
    }
    if (type == TYPE_INPUT_METHOD && mNavigationBarPosition == NAV_BAR_BOTTOM) {
        // The IME can always extend under the bottom cutout if the navbar is there.
        displayCutoutSafeExceptMaybeBars.bottom = Integer.MAX_VALUE;
    }
    // Windows that are attached to a parent and laid out in said parent already avoid
    // the cutout according to that parent and don't need to be further constrained.
    // Floating IN_SCREEN windows get what they ask for and lay out in the full screen.
    // They will later be cropped or shifted using the displayFrame in WindowState,
    // which prevents overlap with the DisplayCutout.
    if (!attachedInParent && !floatingInScreenWindow) {
        mTmpRect.set(pf);
        pf.intersectUnchecked(displayCutoutSafeExceptMaybeBars);
        parentFrameWasClippedByDisplayCutout |= !mTmpRect.equals(pf);
    }
    // Make sure that NO_LIMITS windows clipped to the display don't extend under the
    // cutout.
    df.intersectUnchecked(displayCutoutSafeExceptMaybeBars);
}
```

SystemUI renders in the cutout area, and needs to determine where it can draw.
[PhoneStatusBarView.java](https://android.googlesource.com/platform/frameworks/base/+/master/packages/SystemUI/src/com/android/systemui/statusbar/phone/PhoneStatusBarView.java){: .external}
provides an example of a view that determines where the display cutout is, how
big it is, and whether or not the inset from the nav bar avoids the cutout area.

By overriding `onApplyWindowInsets()`, a view can determine where the cutout is
and update its layout accordingly.

```java
@Override
    public WindowInsets onApplyWindowInsets(WindowInsets insets) {
        if (updateOrientationAndCutout(mLastOrientation)) {
            updateLayoutForCutout();
            requestLayout();
        }
        return super.onApplyWindowInsets(insets);
    }
```

These methods outline how cutouts are handled in the status bar in all cases
(i.e. top center, top uncentered, bottom, and dual-cutouts in all rotations).

## Requirements

To ensure that apps are not negatively impacted by cutouts, you must ensure
that:

+   The status bar extends to at least the height of the cutout in portrait mode
+   The cutout area must be letterboxed in fullscreen and landscape modes

Your device can have up to one cutout on each short edge (top and bottom).

For more information, see the [CDD](/compatibility/android-cdd#3_8_15_display_cutout).

Note: For apps targeting Android 8.0 or lower, you can provide users with an
option to extend a fullscreen or landscape app into the cutout area (e.g. toggle
in the navigation bar). As this may lead to content getting cut off, the
`layoutInDisplayCutoutMode` activity theme attribute has been backported to
Android 8.1 to allow apps to opt out. If the attribute is set, you may not show
a special mode toggle.

## Implementation

To implement display cutouts on your device, you must configure the following
values for System UI.

<table>
<thead>
<tr>
<th>Value</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>
quick_qs_offset_height
</code>
</td>
<td><p>Defines the top margin for the quick settings panel. The clock and battery
are displayed in the space above the panel.</p>
<p>In values-land, set to <code>status_bar_height_landscape</code>, and in
portrait set to either the default of 48dp, or the height of the cutout,
whichever is larger. Can optionally be taller than the cutout if
desired.</p></td>
</tr>
<tr>
<td><code>
quick_qs_total_height
</code>
</td>
<td><p>Total height of the quick-quick settings panel (collapsed quick settings
panel) when the notification shade is expanded, including the space above
the panel containing the clock.</p>
<p>
Because of the way quick settings is laid out, the total height of the
quick-quick settings panel (including the offset) must be known statically,
so this value must be adjusted by the same delta
<code>quick_qs_offset_height</code>. Values-land defaults this to 152dp,
while the portrait default is 176dp.</p></td>
</tr>
<tr>
<td><code>
status_bar_height_portrait
</code>
</td>
<td><p>The default height of the status bar from the framework's perspective.</p>
<p>In most devices, this defaults to 24dp. When there is a cutout, set this
value to the height of the cutout. Can optionally be taller than the cutout
if desired.</p></td>
</tr>
<tr>
<td><code>
status_bar_height_landscape
</code>
</td>
<td><p>The height of the status bar in landscape. Cutouts are only supported on
the short edges of the device, so this will always be an unaltered status
bar height.</p>
<p>In a device with no cutout, this is equivalent to
<code>status_bar_height_portrait</code>. When a cutout is present, keep
this value at the default status bar height.</p></td>
</tr>
<tr>
<td><code>
config_mainBuiltInDisplayCutout
</code>
</td>
<td><p>The path defining the shape of the cutout. This is a string parsable by
<code>android.util.PathParser</code>, and is how the size and shape of the
cutout is defined to the system.</p>
<p><code>@dp</code> can be specified on the path to emulate a shape targeting
different devices. Because physical cutouts have an exact pixel size, do
not use the <code>@dp</code> specifier when defining the path for a
hardware notch.</p></td>
</tr>
<tr>
<td><code>
config_fillMainBuiltinDisplayCutout
</code>
</td>
<td><p>A boolean value that determines whether to draw the cutout path (defined
above) in software. Can be used to emulate a cutout, or to fill in a
physical cutout to achieve anti-aliasing.</p>
<p>If true, <code>config_mainBuiltInDisplayCutout</code> is filled in
black.</p></td>
</tr>
</tbody>
</table>

See these `dimens` files for the default definitions:

+   [`core/res/res/values-land/dimens.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values-land/dimens.xml){: .external}  
+   [`core/res/res/values/dimens.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/dimens.xml){: .external}  

Example overlay for an emulated cutout:

```
<resources xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2">

    <!-- The bounding path of the cutout region of the main built-in display.
         Must either be empty if there is no cutout region, or a string that is parsable by
         {@link android.util.PathParser}.

         The path is assumed to be specified in display coordinates with pixel units and in
         the display's native orientation, with the origin of the coordinate system at the
         center top of the display.

         To facilitate writing device-independent emulation overlays, the marker `@dp` can be
         appended after the path string to interpret coordinates in dp instead of px units.
         Note that a physical cutout should be configured in pixels for the best results.
         -->
    <string translatable="false" name="config_mainBuiltInDisplayCutout">
        M 0,0
        L -48, 0
        L -44.3940446283, 36.0595537175
        C -43.5582133885, 44.4178661152 -39.6, 48.0 -31.2, 48.0
        L 31.2, 48.0
        C 39.6, 48.0 43.5582133885, 44.4178661152 44.3940446283, 36.0595537175
        L 48, 0
        Z
        @dp
    </string>

    <!-- Whether the display cutout region of the main built-in display should be forced to
         black in software (to avoid aliasing or emulate a cutout that is not physically existent).
     -->
    <bool name="config_fillMainBuiltInDisplayCutout">true</bool>

    <!-- Height of the status bar -->
    <dimen name="status_bar_height_portrait">48dp</dimen>
    <dimen name="status_bar_height_landscape">28dp</dimen>
    <!-- Height of area above QQS where battery/time go (equal to status bar height if > 48dp) -->
    <dimen name="quick_qs_offset_height">48dp</dimen>
    <!-- Total height of QQS (quick_qs_offset_height + 128) -->
    <dimen name="quick_qs_total_height">176dp</dimen>

</resources>
```

## Validation

To validate your implementation of display cutouts, run the CTS tests at
[tests/framework/base/windowmanager/src/android/server/wm](https://android.googlesource.com/platform/cts/+/master/tests/framework/base/windowmanager/src/android/server/wm){: .external}.
