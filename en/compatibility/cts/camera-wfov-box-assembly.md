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

# Wide Field-of-View (WFoV) Box

Android includes ITS-in-a-box revision 2, an automated test system for both wide
field-of-view (WFoV) and regular field-of-view (RFoV) camera systems in the
[Camera Image Test Suite (ITS)](/compatibility/cts/camera-hal#its_tests).
Revision 1 was designed to test mobile device cameras with an FoV less than 90
degrees (RFoV).

The wide field-of-view box (revision 2) is designed to also test cameras that
have an FoV greater than 90 degrees (WFoV), enabling you to use one ITS-in-a-box
system to test different cameras with varying FoVs.

The [ITS-in-a-box](/compatibility/cts/camera-its-box)
system consists of a plastic box laser cut from computer-aided design (CAD)
drawings, an internal lighting system, a chart tablet, and a device under test
(DUT). You can purchase an ITS-in-a-box or build your own.

Note: For details on building ITS-in-a-box revision 1 (designed for RFoV
cameras only), see
[Regular Field-of-View Box](/compatibility/cts/camera-its-box-assembly).

## Purchasing a WFoV ITS-in-a-box {:#purchasing_a_wfov_its-in-a-box}

We recommend purchasing a WFoV ITS-in-a-box from one of the following qualified
vendors.

-   *Acu Spec, Inc.*  
    990 Richard Ave, Ste 103, Santa Clara, CA 95050  
    fred@acuspecinc.com
-   *MYWAY, Inc.*  
    No.228-4, Sec 4, Jen-Ai Road, Da'an District. Taiwan  
    sales@myway.tw

## Building a WFoV ITS-in-a-box {:#building_a_wfov_its-in-a-box}

Instead of purchasing a WFoV ITS-in-a-box (revision 2), you may build your own.
This section includes step-by-step instructions for assembling a WFoV
ITS-in-a-box (revision 2) that can test cameras with a wide field of view
(greater than 90 degrees).

### Mechanical drawings {:#mechanical_drawings}

To get started, download the latest
[mechanical drawings for the WFoV ITS-in-a-box](/compatibility/cts/wfov_its_box_assembly_2_7.zip).

![CAD drawing of WFOV ITS-in-a-box](/compatibility/cts/images/wfov-cad-wfov-box.png){: width="800"}

**Figure 1.** Mechanical drawing of WFoV ITS-in-a-box

Purchase the hardware from the bill of materials (BOM). Cut the plastic and
vinyl pieces.

### Required tools {:#required_tools}

Have the following tools available:

+   Phillips head screwdriver
+   Needle nose pliers
+   Wire cutters
+   Scissors
+   Water spray bottle
+   X-ACTO knife

Note: For more information on past versions,
see [Revision history](#revision_history).

### Step 1: Apply colored vinyl {:#step_1_apply_colored_vinyl}

To apply colored vinyl:

1.  Apply the colored vinyl on the smooth side of the acrylonitrile butadiene
    styrene (ABS) and cut out the necessary openings as shown in Figure 2. Make
    sure to apply the white vinyl with the large rectangular opening on the
    tablet side and the black vinyl with the circular opening on the mobile
    device side of the box.

    Apply the gray vinyl on the side panels as shown in Figure 2 and glue the
    feet on the four corners of the bottom panel as shown in Figure 3.

    For more information, see
    [wikiHow](https://www.wikihow.com/Install-a-Vinyl-Graphic){: .external}.

    ![ABS pieces with vinyl applied on the smooth side](/compatibility/cts/images/wfov-2.png){: width="500"}

    **Figure 2.** ABS pieces with vinyl applied on the smooth side (interior of
    the box)

1.  Apply the feet on the four corners of the bottom panel as shown in Figure 3.

    ![Bottom panel feet](/compatibility/cts/images/wfov-3.png){: width="350"}

    **Figure 3.** Feet on the four corners of the bottom panel

### Step 2: Assemble and install the light rail {:#step_2_assemble_and_install_the_light_rail}

To assemble and install the light frame structure with LED light strips:

1.  Review the mechanical drawing of the light frame structure.

    ![Light frame structure with LED light strips](/compatibility/cts/images/wfov-cad-light-frame.png){: width="800"}

    **Figure 4.** Light frame structure with LED light strips

1.  Gather the plastic light baffles, light mounts, LED light strips, and zip
    ties.

    ![Light baffles, light mounts, LED light strips, and zip ties](/compatibility/cts/images/wfov-5.png){: width="350"}

    **Figure 5.** Light baffles and light mounts

1.  Snap the plastic light baffles to the light mounts as shown in Figure 6.
    This should be a tight fit.

    ![Plastic light baffles fitted in light mounts](/compatibility/cts/images/wfov-6.png){: width="350"}

    **Figure 6.** Plastic light baffles fitted in light mounts

1.  Snap the light mounts to the side panels as shown in Figure 7. When
    complete, the light shines toward the front corners of the box
    interior.

    ![Light baffles and mounts snapped onto the side panels](/compatibility/cts/images/wfov-7.png){: width="350"}

    **Figure 7.** Light baffles and mounts snapped onto the side panels

1.  Assemble the side panels. (Optional: Sand the edges of the baffles for
    a better fit.)

    ![Side panels assembled and screwed in](/compatibility/cts/images/wfov-8.png){: width="350"}

    **Figure 8.** Side panels assembled and screwed together

1.  Secure the light baffles by squeezing the pin into the small hole on
    the rectangular tab that extends through the slot in the side panels as
    shown in Figure 9.

    ![Inserted PIN in LED mount tab](/compatibility/cts/images/wfov-9.png){: width="350"}

    **Figure 9.** Close up of inserted pin in LED mount tab on the outside of
    the box

1.  Wrap the light strips around the baffles twice on the side facing
    down. Use zip ties to tie down the strip, and snap the ends together.
    (Optional: Use the tape on the back of the LED light strip in addition to
    the zip ties for easier wrapping.)

    ![LED light strip wrapped around baffles](/compatibility/cts/images/wfov-10.png){: width="350"}

    **Figure 10.** LED light strip wrapped around the baffles with zip ties

    ![Zip ties holding LED light strips](/compatibility/cts/images/wfov-11.png){: width="350"}

    **Figure 11.** Zip ties holding the LED light strips in place

1.  Cut the ends of the zip ties as shown in Figure 12 and 13.

    ![Led lights around baffles exiting](/compatibility/cts/images/wfov-12.png){: width="350"}

    **Figure 12.** LED lights wrapped around the baffles twice and exiting
    through the side exit

    ![Zip ties facing up](/compatibility/cts/images/wfov-13.png){: width="350"}

    **Figure 13.** Zip ties showing on the side facing up (LED strips are on the
    other side)

### Step 3: Assemble tablet and phone mounts {:#step_3_assemble_tablet_and_phone_mounts}

To assemble the tablet and phone mounts:

1.  Review the mechanical drawing of the tablet mount.

    ![Mechanical drawing of tablet mount](/compatibility/cts/images/wfov-cad-mounts.png){: width="800"}

    **Figure 14.** Mechanical drawing of tablet mount

1.  Gather the parts as shown in Figure 15.

    ![Tablet and phone mount parts](/compatibility/cts/images/wfov-mount-parts.png){: width="350"}

    **Figure 15.** Tablet and phone mounts with screws, plungers, vinyl caps,
    and nuts

1.  Cut the rubber tips short enough to not interfere with plunger
    operation (roughly in half), and push them onto the
    ends of the plungers. The shorter vinyl cap length ensures that the plunger
    mechanism can be retracted and locked.

    ![Plungers with adjusted push-on cap](/compatibility/cts/images/rfov-9.png){: width="350"}

    **Figure 16.** Plungers with adjusted push-on caps

1.  Screw the plungers onto the mounts.

    ![Tablet and phone mounts with plungers attached](/compatibility/cts/images/wfov-17.png){: width="350"}

    **Figure 17.** Tablet and phone mounts with plungers attached

### Step 4: Final assembly {:#step_4_final_assembly}

To assemble the WFoV ITS box:

1.  Gather the front aperture plates and use 4-40 screws to screw the smaller
    plate with the square on top of the larger plate as shown in Figure 18.

    ![Fron aperture plate and phone mount plate](/compatibility/cts/images/wfov-18.png){: width="500"}

    **Figure 18.** Front aperture plate and phone mount plate

    ![Assembled front aperture plate](/compatibility/cts/images/wfov-19.png){: width="350"}

    **Figure 19.** Front aperture plate and phone mount plate screwed together
    with 4-40 screws

1.  Tape the front and back panels to the box.

    ![WFoV box with sides screwed together](/compatibility/cts/images/wfov-20.png){: width="350"}

    **Figure 20.** WFoV box with sides screwed together and the front and back
    panels taped

1.  Use a power drill to create pilot holes based on the existing holes.
    Make sure that the pilot holes are big enough for 4-40 screws so that the
    ABS plastic doesn't crack when inserting the screws.

    ![Pilot holes](/compatibility/cts/images/rfov-23.png){: width="350"}

    **Figure 21.** Drilling pilot holes for 4-40 screws

1.  Screw all the panels together using 4-40 self-tapping screws.

    ![4-40 screws for assembly](/compatibility/cts/images/rfov-24.png){: width="350"}

    **Figure 22.** 4-40 screws for assembly

1.  Gather the handle parts shown in Figure 23.

    ![Handle parts](/compatibility/cts/images/wfov-23.png){: width="350"}

    **Figure 23.** Handle parts

1.  Assemble the handles as shown in Figure 24.

    ![Assembled handle](/compatibility/cts/images/wfov-24.png){: width="350"}

    **Figure 24.** Assembled handle

1.  Check that the power adapter is 12V, 5A and has a UL listed
    certificate. Anything below 12V doesn't work. Anything below 5A may affect
    the brightness level of the lights.

    ![12V, 5A power adapter](/compatibility/cts/images/wfov-25.png){: width="350"}

    **Figure 25.** 12V, 5A power adapter with a UL listed certificate

1.  Using a digital lux meter, test the lux of the LED lights to make sure
    that they're at the appropriate level.

    Place the light meter on the tablet side and turn it to 2000&nbsp;lux to
    measure the light. The lux should be around 100&ndash;130. Anything
    significantly lower is too dim for the tests and can lead to test failures.

    The YF-1065 lux meter by
    [Contempo Views](https://www.contempoviews.com/){: .external}
    is used in this example.

    ![YF-1065 by Contempo Views](/compatibility/cts/images/rfov-33.png){: width="350"}

    **Figure 26.** YF-1065 by Contempo Views

    ![Lux meter](/compatibility/cts/images/wfov-lux-meter.png){: width="350"}

    **Figure 27.** Lux meter measuring light from the side with the tablet mount

1.  Follow the appropriate step depending on the lux value measured:

    * If the light is at the correct level, screw the front and back plates into
    place.
    * If the light is at the incorrect level, check that the LED and power
    supply part number are correct.

1.  Mount the phone mount on the aperture plate and the tablet mount on the
    opposite side with screws and nuts.

    ![Tablet mount](/compatibility/cts/images/wfov-28.png){: width="250"}

    **Figure 28.** Close up of tablet mount

    ![Assembled WFoV box](/compatibility/cts/images/wfov-29.png){: width="500"}

    **Figure 29.** Assembled WFoV box: rear view (left) and front view (right)

1.  Insert the 10x10&nbsp;cm gator board aperture to fit the
    DUT's camera aperture.

    ![Gator board aperture](/compatibility/cts/images/wfov-30.png){: width="350"}

    **Figure 30.** ITS-in-a-box with the gator board aperture installed

1.  Install the phone by aligning the camera with the aperture opening.
    Check the alignment through the tablet opening.

    ![Box with one phone installed](/compatibility/cts/images/wfov-31.png){: width="350"}

    **Figure 31.** ITS-in-a-box with one phone installed

1.  Cut apertures for the cameras. You can cut a single aperture (for
    testing a single phone) or two apertures (for testing two phones).
    Apertures for the Pixel and Pixel XL front and rear cameras are shown in
    Figure 32. The front camera has a circular aperture because there's no
    flash or laser, while the rear camera has a rectangular aperture that
    allows the flash and laser to operate without being blocked.

    ![Apertures for front and rear cameras](/compatibility/cts/images/rfov-31.png){: width="500"}

    **Figure 32.** Sample apertures for front and rear cameras

    ![image](/compatibility/cts/images/wfov-33.png){: width="350"}

    **Figure 33.** ITS-in-a-box with two phones installed

### Things to look out for {:#caution}

The following are examples of common manufacturing errors that can render tests
flakey.

-   Back panel with tablet holes poked through. This causes the
    `find_circle` test to fail because of the extra circles created by the
    screw holes.

    ![Back panel with holes](/compatibility/cts/images/rfov-35.png){: width="350"}

    **Figure 34.** Back panel with holes poked through

-   Missing dowels. This causes the light baffles to slip out during
    shipping.

    ![Missing dowel](/compatibility/cts/images/rfov-36.png){: width="350"}

    **Figure 35.** Missing dowel on light baffle

-   Non-UL-listed power supply. Using a UL listed power supply meets the labeled
    specifications. This is important for operating the lighting safely.

    ![UL-listed power supply](/compatibility/cts/images/rfov-37.png){: width="350"}

    **Figure 36.** Example of a UL listed power supply

-   Slipping screws on the tablet or phone mount that can't support the weight
    of a tablet or phone. This is usually caused by damaged threads and
    indicates that the hole needs to be rethreaded.

    ![Hole with damaged threads](/compatibility/cts/images/wfov-28.png){: width="250"}

    **Figure 37.** Hole with damaged threads

### Revision history {:#revision_history}

The following describes the changes made to the WFoV ITS-in-a-box.

#### Revision 2.7 {:#revision_27}

- Switched light in the BOM (#16) to UL listed LED tape for better manufacturing
  consistency.
- Switched power supply in the BOM (#17) to the same source as #16.
- Revised the tablet mount to be 35&nbsp;mm wider to match the tablet opening
  (page 4 on mechanical drawing).
- Revised the front clamp hole spacing (distance) to align with the clamp slot
  length (page 5 on mechanical drawing).
- Reduced the front aperture circle diameter by 20&nbsp;mm to match the [RFoV
  ITS-in-a-box (revision 1)](/compatibility/cts/camera-its-box-assembly) (page
  5 on mechanical drawing).

#### Revision 2.6 (released internally) {:#revision_26_released_internally}

- Made a correction to the mechanical drawing.

#### Revision 2.5 {:#revision_25}

- Simplified the tablet holder to be similar to the phone mount.
- Used a sandblast finish instead of an anodized finish to reduce costs.
- Corrected specifications for LED lights on the BOM.

#### Revision 2.4 {:#revision_24}

- Switched from acrylic to ABS material to reduce shipping damage.
- Removed 3D printing elements and replaced them with laser-cut ABS to reduce
  costs.
- Changed the box handles to use ABS instead of being a separate item to
  purchase on the BOM.
