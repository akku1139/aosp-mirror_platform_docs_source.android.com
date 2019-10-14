Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
    Copyright 2017 The Android Open Source Project
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

# Regular Field-of-View (RFoV) Box

The regular field-of-view (RFoV) ITS-in-a-box (revision 1a) consists of a
plastic box that's laser cut from computer-aided design (CAD) drawings, a chart
tablet, and a device under test (DUT). The RFoV ITS-in-a-box is designed to test
devices with an FoV less than 90 degrees (RFoV). You can purchase an
ITS-in-a-box or build your own.

Note: The wide field-of-view (WFoV) ITS-in-a-box (revision 2) can be used to
test both WFoV (FoV > 90 degrees) and RFoV devices. For details, see
[Wide Field-of-View ITS-in-a-Box](/compatibility/cts/camera-wfov-box-assembly).

## Purchasing an RFoV ITS-in-a-box {:#purchasing}

We recommend purchasing an RFoV ITS-in-a-box (revision 1a) from the following
vendor.

-   *MYWAY, Inc.*  
    No.228-4, Sec 4, Jen-Ai Road, Da'an District. Taiwan  
    sales@myway.tw

## Building an RFoV ITS-in-a-box {:#building}

Instead of purchasing an RFoV ITS-in-a-box, you may build your own. This section
provides detailed instructions for assembly.

### Mechanical drawings

The ITS-in-a-box consists of a DUT, a chart tablet, an
internal lighting system, and a plastic box that's laser cut from CAD drawings
(shown in Figure 1).

To get started, download the latest
[ITS-in-a box mechanical drawings](/compatibility/cts/rfov-its-box-assembly-1a.zip).

![ITS-in-a-box mechanical drawing](/compatibility/cts/images/rfov-1.png)

**Figure 1.** Mechanical drawing of ITS-in-a-box

Purchase the hardware from the bill of materials (BOM). Cut the plastic and
vinyl pieces.

### Required tools {:#required-tools}

Have the following tools available:

+   Torx head screwdriver
+   Power drill
+   ABS glue
+   Needle nose pliers
+   X-ACTO knife
+   Wire cutters or scissors (optional)

### Step 1: Apply vinyl and glue feet {:#apply-vinyl}

Apply colored vinyl on the smooth side of the acrylonitrile butadiene styrene
(ABS) and cut out the necessary openings as shown in Figure 2 and 3. Apply the
white vinyl with the large rectangular opening on the tablet side of the box and
the black vinyl with the circular opening on the mobile device side of the box.
Apply gray vinyl on the side panels as shown in Figure 3 and glue the feet on
the four corners of the bottom panel as shown in Figure 4.
For more information, see
[wikiHow](https://www.wikihow.com/Install-a-Vinyl-Graphic){:.external}.

![Vinyl on front and back panels](/compatibility/cts/images/rfov-2.png){: width="500"}

**Figure 2.** Black vinyl on front panel (left), and white vinyl on back panel
(right)

![Side panels](/compatibility/cts/images/rfov-3.png){: width="500"}

**Figure 3.** Gray vinyl on side panels

![Bottom panel](/compatibility/cts/images/rfov-4.png){: width="350"}

**Figure 4.** Feet on the four corners of the bottom panel

### Step 2: Lighting {:#lighting}

To assemble the ITS-in-a-box lighting component:

1.  Gather the lighting hardware as shown in Figure 5.

    ![Light assembly parts](/compatibility/cts/images/rfov-5.png){: width="500"}

    **Figure 5.** Light assembly parts

    Hardware includes the LED light bars, plastic light baffles, plastic light
    mounts, plastic or metal light clips included in the LED lighting kit, and
    four 6-32 screws with acorn head nuts.

1.  Bolt the light clips to the plastic baffles as shown in Figure 6.
    Secure the clips using the acorn nuts on the other side of the baffles.

    ![Light baffles](/compatibility/cts/images/rfov-6.png){: width="350"}

    **Figure 6.** Plastic baffles with light clips attached

1.  To assemble the lights, attach the plastic baffles to the back of the LED
    light bars using the light clips.

    ![Light bars](/compatibility/cts/images/rfov-7.png){: width="350"}

    **Figure 7.** Light bars with the lights facing down and screws threaded
    through the clips

When the lighting component is assembled, the LED light bars should point
down, and the plastic baffles should cover the shiny, reflective surface on
the back of the LED light bar.

### Step 3: Phone mounts {:#phone-mounts}

To assemble the phone mounts:

1.   Gather the required items as shown in Figure 8.

    ![Phone mount items](/compatibility/cts/images/rfov-8.png){: width="500"}

    **Figure 8.** Phone mount items

    The hardware includes two metal phone mounts, two plungers, two rubber tips,
    four 8-32 pan-head screws, and the corresponding nuts.

1.  Cut the rubber tips short enough to not interfere with plunger
    operation (roughly in half), then apply the rubber tips to cover the tips
    of the plungers.

    ![Plungers](/compatibility/cts/images/rfov-9.png){: width="350"}

    **Figure 9.** Plungers with rubber tips

1.  Assemble the phone mounts using pan-head screws to attach the plunger
    mechanisms to the metal mounts. Ensure that the screws are tightened with
    the corresponding nuts.

    ![Assembled phone mounts](/compatibility/cts/images/rfov-10.png){: width="350"}

    **Figure 10.** Assembled phone mounts

### Step 4: Aperture plate {:#aperture-plate}

To assemble the front aperture plate:

1.  Gather the front aperture plate hardware shown in Figure 11.

    ![Front aperture plate parts](/compatibility/cts/images/rfov-11.png){: width="350"}

    **Figure 11.** Front aperture plate assembly parts

    Hardware includes the assembled phone mounts, the phone mount panel, four
    short nylon screws, and four nylon nuts (required to keep the screws from
    protruding through the back of the plastic plate).

1.  Using the screws and nuts, secure the assembled phone mounts to the
    phone mount panel. Make sure that the phone mounts are in the correct
    orientation as shown in Figure 12.

    ![Assembled front aperture plate](/compatibility/cts/images/rfov-12.png){: width="350"}

    **Figure 12.** Assembled front aperture plate

### Step 5: Tablet mount {:#tablet-mount}

To assemble the table mount:

1.  Gather the tablet mount assembly hardware shown in Figure 13.

    ![Tablet mount parts](/compatibility/cts/images/rfov-13.png){: width="500"}

    **Figure 13.** Tablet mount space assembly parts

    Hardware includes the back panel, tablet mount, one plunger, one rubber tip,
    two 8-32 pan-head screws, two short nylon screws, and the corresponding
    nuts.

2.  Assemble the tablet mount by using pan-head screws to attach the plunger
    mechanisms to the metal mount. Ensure the screws are tightened with the
    corresponding nuts.

3.  Using the screws and nuts, secure the assembled tablet mount to the back
    panel. Make sure that the phone mounts are in the correct orientation as
    shown in Figure 14.

    ![Assembled tablet mount](/compatibility/cts/images/rfov-14.png){: width="350"}

    **Figure 14.** Assembled tablet mount

### Step 6: Install lights {:#install-lights}

To install the lights:

1.  Install the light baffles on the top and bottom panels as shown in
    Figure 15.

    ![Light baffles installed](/compatibility/cts/images/rfov-15.png){: width="500"}

    **Figure 15.** Light baffles installed on the top and bottom panels

1.  Secure the light baffles by squeezing the pin into the small hole on
    the rectangular tab that extends through the slot in the top and bottom
    panel as in Figure 16.

    ![Inserted pin](/compatibility/cts/images/rfov-16.png){: width="350"}

    **Figure 16.** Close up of inserted pin in LED mount tab on outside of box

    To secure the pins, gently squeeze the pins until you feel some pressure on
    the plastic as the pins are secured into place.

    ![Pliers](/compatibility/cts/images/rfov-17.png){: width="350"}

    **Figure 17.** Pliers used to install pin

1.  Assemble the front and side panels in the correct orientation as
    shown in Figure 18, and tape them together from the exterior.

    ![Light placement orientation](/compatibility/cts/images/rfov-18.png){: width="350"}

    **Figure 18.** Light placement orientation

1.  Attach the power cord to the power light bar as shown in Figure 19.

    ![Lighting power cord](/compatibility/cts/images/rfov-19.png){: width="350"}

    **Figure 19.** Lighting power cord

    Thread the power cord through the hole on the left panel. The power cord
    has different connectors at each end: the narrower connector attaches to
    the LED light bar and the larger connector attaches to the power adapter.

    ![Power cord](/compatibility/cts/images/rfov-20.png){: width="350"}

    **Figure 20.** Power cord exiting the test rig on its left side

1.  Wire the top lights to the bottom lights and secure the cable on the
    left panel.

    ![Light cord](/compatibility/cts/images/rfov-21.png){: width="350"}

    **Figure 21.** Light cord anchored on the left panel

### Step 7: Assemble side panels, tablet mount, and handles {:#assemble}

To assemble the ITS-in-a-box side panels, tablet mount, and handles with
screws:

1.  Assemble all the sides of the panels and tape them together as
    shown in Figure 22.

    ![Taped box for assembly](/compatibility/cts/images/rfov-22.png){: width="350"}

    **Figure 22.** ITS-in-a-box taped together for assembly

1.  Use a power drill to create pilot holes based on the existing holes.
    Make sure that the pilot holes are big enough for 4-40 screws so that the
    ABS plastic doesn't crack when inserting the screws.

    ![Drilling holes](/compatibility/cts/images/rfov-23.png){: width="350"}

    **Figure 23.** Drilling pilot holes for 4-40 screws

1.   Screw all the panels together using 4-40 self-tapping screws.

    ![Power drill](/compatibility/cts/images/rfov-24.png){: width="350"}

    **Figure 24.** 4-40 screws for assembling panels

1.  Gather the handle parts shown in Figure 25.

    ![Handle parts](/compatibility/cts/images/rfov-25.png){: width="350"}

    **Figure 25.** Handle parts

    Hardware includes four rectangular plastic pieces and four 6-32 screws.

1.  Assemble the handles as shown in Figure 26.

    ![Assembled handle](/compatibility/cts/images/rfov-26.png){: width="350"}

    **Figure 26.** Assembled handle

### Step 8: Final assembly and setup {:#final-assembly}

To perform final assembly of the ITS-in-a-box:

1.  Attach the tablet mount to the back panel and adjust the height
    according to tablet size.

    ![Tablet mount on back of box](/compatibility/cts/images/rfov-27.png){: width="350"}

    **Figure 27.** Tablet in the tablet mount on the back of the box

1.  Attach the square aperture panel without phone mounts to the front of
    the box with 4-40 screws as shown in Figure 28.

    ![Assembled front panel](/compatibility/cts/images/rfov-28.png){: width="350"}

    **Figure 28.** Assembled front phone panel

1.  Insert the 10x10 cm gator board aperture to fit the
    DUT's camera aperture.

    ![Gator board aperture](/compatibility/cts/images/rfov-29.png){: width="350"}

    **Figure 29.** ITS-in-a-box with gator board aperture installed

1.  Install the phone by aligning the camera with the aperture opening. Check
    the alignment through the tablet opening.

    ![Box with one phone](/compatibility/cts/images/rfov-30.png){: width="350"}

    **Figure 30.** ITS-in-a-box with one phone installed

1.  Cut apertures for the cameras. You can cut a single aperture (for
    testing a single phone) or two apertures (for testing two phones).
    Apertures for the Pixel and Pixel XL front and rear cameras are shown in
    Figure 31. The front camera has a circular aperture because there's no
    flash or laser, while the rear camera has a rectangular aperture that
    allows the flash and laser to operate without being blocked.

    ![Sample apertures](/compatibility/cts/images/rfov-31.png){: width="500"}

    **Figure 31.** Sample apertures for both front and rear cameras

    ![Box with two phones](/compatibility/cts/images/rfov-32.png){: width="350"}

    **Figure 32.** ITS-in-a-box with two phones installed

1.  Using a digital lux tester, test the lux of the LED lights. The
    YF-1065 by Contempo View is used in this example.

    ![YF-1065 by Contempo Views](/compatibility/cts/images/rfov-33.png){: width="350"}

    **Figure 33.** YF-1065 by Contempo Views

1.  Place the light meter on the tablet side and turn it to 2000 lux to
    measure the light. The lux level should be around 100&ndash;300 lux.
    Anything significantly lower is too dim for the test and can lead to test
    failures.

    ![Lux meter](/compatibility/cts/images/rfov-34.png){: width="350"}

    **Figure 34.** Lux meter measuring light from the back with tablet mount

1.  Follow the appropriate step depending on the lux value measured:

    * If the light is at the correct level, screw the front and back plates into
    place.
    * If the light is at the incorrect level, check that the LED and power
    supply part number are correct.

### Things to look out for {:#caution}

The following are examples of common manufacturing errors that can render tests
flaky.

-   Back panel with tablet holes poked through. This causes the
    `find_circle` test to fail because of the extra circles created by the
    screw holes.

    ![Back panel with holes](/compatibility/cts/images/rfov-35.png){: width="350"}

    **Figure 35.** Back panel with holes poked through

-   Missing dowels. This causes the light baffles to slip out during
    shipping.

    ![Missing dowel](/compatibility/cts/images/rfov-36.png){: width="350"}

    **Figure 36.** Missing dowel on light baffle

-   Non-UL-listed power supply. Using a UL-listed power supply ensures
    that the power supply doesn't break.

    ![UL-listed power supply](/compatibility/cts/images/rfov-37.png){: width="350"}

    **Figure 37.** Example of a UL-listed power supply

### Revision history {:#revision-history}

The following describes the revision history for the RFoV ITS-in-a-box.

#### Revision 1a {:#1a}

-   Changed the material from Delrin to ABS.
-   Altered the light holder design to be more flexible and be able to handle
    different LED bar sizes.
-   Unified the construction methods.
-   Simplified the tablet mount design and made it more robust.
-   Increased the depth of the phone mount to handle thicker phones.
-   Increased the mounting options on the front panel to accommodate a mount
    for foldables and rugged phone profiles.
