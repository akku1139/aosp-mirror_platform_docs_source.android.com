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

# Wide Field of View (WFoV) Box

Android {{ androidPVersionNumber }} introduces ITS-in-a-box revision 2, an
automated test system for both wide field of view (WFoV) and regular field of
view (RFoV) camera systems in the Camera Image Test Suite (ITS). Revision 1 was
designed to test mobile device cameras with an FoV less than 90 degrees
(RFoV). Revision
2 is designed to also test cameras that have an FoV greater 90 degrees (WFoV),
enabling you to use one ITS-in-a-box system to test different cameras with
varying FoVs.

The ITS-in-a-box system consists of a plastic box laser cut from computer-aided
design (CAD) drawings, an internal lighting system, a chart tablet, and a device
under test (DUT). You can purchase an ITS-in-a-box or build your own.

Note: For details on building ITS-in-a-box revision 1 (designed for RFoV cameras
only), see
[ITS-in-a-Box Assembly](/compatibility/cts/camera-its-box-assembly).

## Purchasing a WFoV ITS-in-a-box

We recommend purchasing a WFoV ITS-in-a-box from one of the following qualified
vendors.

* *Acu Spec, Inc.*  
  990 Richard Ave, Ste 103, Santa Clara, CA 95050  
  fred@acuspecinc.com  
* *MYWAY, Inc*  
  4F., No. 163, Fu Ying Rd., New Taipei City, Taiwan  
  sales@myway.tw

## Building a WFoV ITS-in-a-box

This section includes step-by-step instructions for assembling a WFoV
ITS-in-a-box (revision 2) that can test cameras with a wide field of view
(greater than 90 degrees).

### Overview

The WFoV ITS-in-a-box consists of a device under test (DUT), a chart tablet, an
internal lighting system, and a plastic box that is laser cut from CAD drawings
(shown in Figure 1).

![CAD drawing of WFOV ITS-in-a-box](/compatibility/cts/images/wfov-cad-wfov-box.png){: width="800"}

**Figure 1.** Mechanical drawing of WFoV ITS-in-a-box

### Required tools

To get started, download the latest
[technical drawings for the WFoV ITS-in-a-box](/compatibility/cts/wfov_its_box_assembly_2_7.zip),
cut the plastic and vinyl pieces, purchase the hardware from the bill of
materials (BOM), and gather these tools:

+   Phillips head screwdriver
+   Pliers
+   Wire cutters
+   Scissors
+   Water spray bottle
+   X-acto knife

Note: For more information on past versions, see [Revision history](#revision_history).

### Step 1: Apply colored vinyl

To apply colored vinyl:

1.  Apply colored vinyl on the smooth side of the acrylonitrile butadiene
    styrene (ABS) and cut out the necessary openings as shown in Figure 1. Make
    sure to apply the white vinyl with the large rectangular opening on the
    tablet side and the black vinyl with the circular opening on the mobile
    device side of the box. For more information, see
    [wikiHow](https://www.wikihow.com/Install-a-Vinyl-Graphic){: .external}.

    ![ABS pieces with vinyl applied on the smooth side](/compatibility/cts/images/wfov-abs-pieces.png){: width="500"}

    **Figure 2.** ABS pieces with vinyl applied on the smooth side (interior of
    the box)

### Step 2: Assemble and install the light rail

To assemble and install the light frame structure with LED light strips:

1.  Review the mechanical drawing of the light frame structure.

    ![Light frame structure with LED light strips](/compatibility/cts/images/wfov-cad-light-frame.png){: width="800"}

    **Figure 3.** Light frame structure with LED light strips

1.  Gather the plastic light baffles, light mounts, LED light strip, and zip
    ties.

    ![Light baffles, light mounts, LED light strips, and zip ties](/compatibility/cts/images/wfov-parts.png){: width="350"}

    **Figure 4.** Light baffles, light mounts, LED light strips, and zip ties

1.  Snap the plastic light baffles to the light mounts as shown in figure 5.
    This should be a tight fit.

    ![Plastic light baffles fitted in light mounts](/compatibility/cts/images/wfov-light-mounts.png){: width="350"}

    **Figure 5.** Plastic light baffles fitted in light mounts

1.  Snap the light mounts to the side panels as shown in figure 6. When
    complete, the light will shine towards the front corners of the box
    interior.

    ![Light baffles and mounts snapped onto the side panels](/compatibility/cts/images/wfov-side-panels-baffles.png){: width="350"}

    **Figure 6.** Light baffles and mounts snapped onto the side panels

1.  Assemble the side panels. (Optional: Sand the edges of the baffles for
    a better fit.)

    ![Side panels assembled and screwed in](/compatibility/cts/images/wfov-assembled-side-panels.png){: width="350"}

    **Figure 7.** Side panels assembled and screwed together

1.  Wrap the LED strip on the side facing the panel, between the holes used for
    fastening. (Optional: Use the tape on the back of the LED light strip for
    easier wrapping.)

    ![LED light strip wrapped around the baffles ](/compatibility/cts/images/wfov-light-strip.png){: width="350"}

    **Figure 8.** LED light strip wrapped around the baffles

1.  Wrap the light strips around the baffles twice, use zip ties to tie down the
    strip, and snap the ends together.

    ![Zip ties holding the LED light strips in place](/compatibility/cts/images/wfov-zip-ties.png){: width="350"}

    **Figure 9.** Zip ties holding the LED light strips in place

    ![LED lights wrapped around the baffles](/compatibility/cts/images/wfov-lights-exiting.png){: width="350"}

    **Figure 10.** LED lights wrapped around the baffles twice and exiting
    through side exit

    ![Zip ties showing on the side facing up](/compatibility/cts/images/wfov-zip-ties-facing-up.png){: width="350"}

    **Figure 11.** Zip ties showing on the side facing up. LED strips are on the
    other side.

### Step 3: Assemble tablet and phone mounts

To assemble the tablet and phone mounts:

1.  Review the mechanical drawing of the tablet mount.

    ![Mechanical drawing of tablet mount](/compatibility/cts/images/wfov-cad-mounts.png){: width="800"}

    **Figure 12.** Mechanical drawing of tablet mount

1.  Gather the parts as shown in figure 13.

    ![Tablet and phone mount parts](/compatibility/cts/images/wfov-mount-parts.png){: width="350"}

    **Figure 13.** Tablet and phone mounts with screws, plungers, vinyl caps,
    and nuts

1.  Cut the push-on vinyl cap by ⅓ of its length and push it onto the end of the
    plunger. This ensures the plunger mechanism can be retracted and locked.

    ![Plunger with adjusted push-on cap](/compatibility/cts/images/wfov-plunger.png){: width="350"}

    **Figure 14.** Plunger with adjusted push-on cap

1.  Screw the plungers onto the mounts.

    ![Tablet and phone mounts with plungers attached](/compatibility/cts/images/wfov-mounts-with-plungers.png){: width="350"}

    **Figure 15.** Tablet and phone mounts with plungers attached

### Step 4: Final assembly

To assemble the WFoV ITS box:

1.  Gather the front aperture plates and screw the smaller plate with the square
    on top of the larger plate as shown in figure 16.

    ![Assembled aperture plates](/compatibility/cts/images/wfov-aperture-plates.png){: width="500"}

    **Figure 16.** Front aperture plates screwed together with 4-40 screws

1.  Tape the front and back panels to the rest of the box.

    ![WFoV box with sides screwed together](/compatibility/cts/images/wfov-box.png){: width="350"}

    **Figure 17.** WFoV box with sides screwed together and the front and back
    panels taped

1.  Check that the power adapter is 12V, 5A. Anything below 12V will not work;
    anything below 5A may affect the brightness level of the lights.

    ![12V, 5A power adapter](/compatibility/cts/images/wfov-power-adapter.png){: width="350"}

    **Figure 18.** 12V, 5A power adapter

1.  Using a digital lux tester, test the lux of the LED lights to make sure they
    are at the appropriate level. The YF-1065 by
    [Contempo Views](https://www.contempoviews.com/){: .external}
    is used in this example.

    ![YF-1065 by Contempo Views](/compatibility/cts/images/wfov-yf1065.png){: width="350"}

    **Figure 19.** YF-1065 by Contempo Views

1.  Place the light meter on the tablet side and turn it to 2000 lux to measure
    the light. The lux should be around 100 to 130. Anything significantly lower
    will be too dim for the tests and can lead to test failures.

    ![Lux meter](/compatibility/cts/images/wfov-lux-meter.png){: width="350"}

    **Figure 20.** Lux meter measuring light from the side with tablet mount

1.  Follow the appropriate step depending on the lux value measured:

    * If the light is at the correct level, screw the front and back plates into
    place.  
    * If the light is not at the correct level, check the LED and power supply
    part number.

1.  Mount the phone mount on the aperture plate and the tablet mount on the
    opposite side with screws and nuts.

    ![Phone mount and tablet mount](/compatibility/cts/images/wfov-attached-mounts.png){: width="500"}

    **Figure 21.** Phone mount (left) and tablet mount (right)

    ![Assembled WFoV box](/compatibility/cts/images/wfov-assembled-box.png){: width="500"}

    **Figure 22.** Assembled WFoV box: rear view (left) and front view (right)

### Revision history

The following describes the changes made to the WFoV ITS-in-a-box.

#### Revision 2.7

- Switched light in the BOM (#16) to UL listed LED tape for better manufacturing
  consistency.
- Switched power supply in the BOM (#17) to the same source as #16.
- Revised the tablet mount to be 35mm wider to match the tablet opening (page 4
  on mechanical drawing)
- Revised the front clamp hole spacing (distance) to align with the clamp slot
  length (page 5 on mechanical drawing)
- Reduced the front aperture circle diameter by 20mm to match the [RFoV
  ITS-in-a-box (revision 1)](/compatibility/cts/camera-its-box-assembly) (page
  5 on mechanical drawing)

#### Revision 2.6 (released internally)

- Made a correction to the mechanical drawing

#### Revision 2.5

- Simplified tablet holder to be similar to the phone mount
- Used a sandblast finish instead of an anodized finish to reduce costs
- Corrected specifications for LED lights on the BOM

#### Revision 2.4

- Switched from acrylic to ABS material to reduce shipping damage
- Removed 3D printing elements and replaced them with laser-cut ABS to reduce
  costs
- Changed the box handles to use ABS instead of being a separate item to
  purchase on the BOM
