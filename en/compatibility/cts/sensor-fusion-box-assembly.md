Project: /_project.yaml
Book: /_book.yaml

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

# Sensor Fusion Box Assembly

This page provides step-by-step instructions for assembling a Sensor Fusion
Box. The Sensor Fusion Box is used in the CameraITS sensor_fusion test and
multi-camera sync test. It provides a consistent test environment for measuring
timestamp accuracy of camera and other sensors for Android phones. It consists
of plastic box components that are laser cut from computer-aided design (CAD)
drawings and a Servo Control Box.

You can purchase a Sensor Fusion Box or build your own.

## Purchasing a Sensor Fusion Box

We recommend purchasing a Sensor Fusion Box from one of the following qualified
vendors.

* *Acu Spec, Inc.*  
  990 Richard Ave, Ste 103, Santa Clara, CA 95050  
  fred@acuspecinc.com  
* *MYWAY, Inc*  
  4F., No. 163, Fu Ying Rd., New Taipei City, Taiwan  
  sales@myway.tw

## Building a Sensor Fusion Box

This section includes step-by-step instructions for assembling a Sensor Fusion
Box from laser-cut plastic components (shown in Figure 1):

<img src="/compatibility/cts/images/sensor_fusion_assembly_box_cad_drawing.png" width="700" alt="CAD drawing of Sensor Fusion Box components">  
**Figure 1.** CAD drawing of Sensor Fusion Box components

### Required tools

Before starting, ensure you have downloaded the technical drawings for the
Sensor Fusion Box (included in the
[Sensor Fusion Box zip file](/compatibility/cts/sensor_fusion_1.4.zip)) and
have the following tools available:

* Phillips head screwdriver
* Power drill set
* Exacto knife
* Tape

### Step 1: Apply vinyl stickers

After creating the plastic components with a laser cutter, you can apply vinyl
stickers to the plastic box components:

1. Apply vinyl on the smooth side of the ABS (acrylonitrile butadiene styrene)
   as shown in **Figure 2**. For helpful tips on applying vinyl, refer to
   [wikiHow](https://www.wikihow.com/Install-a-Vinyl-Graphic){: .external}.
1. Cut out the necessary holes on the vinyl.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_abs_pieces.png" width="350" alt="BS pieces">  
    **Figure 2.** ABS pieces with vinyl applied on the smooth side (interior of
    the box)

### Step 2: Attach servo

To attach the servo:

1. Tap three holes on the phone fixture with ¼" - 20, and make countersink
   holes on the back of the phone fixture:
    <table class="columns">
      <tr>
        <td><img src="/compatibility/cts/images/sensor_fusion_assembly_phone_fixture_holes1.png" width="250" alt="Phone fixture tap holes"></td>
        <td><img src="/compatibility/cts/images/sensor_fusion_assembly_phone_fixture_holes2.png" width="250" alt="Phone fixture countersink holes"></td>
      </tr>
    </table>
    **Figure 3.** Phone fixture with tap and countersink holes shown

1. With the large shaft that came with the servo, drill pilot holes with #43
   drill bit (2.26 mm) into the last holes from each side so 4-40 screws could
   grab onto them:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_shaft.png" width="350" alt="Servo shaft">  
    **Figure 4.** Servo shaft with pilot holes at each end

1. Apply the flat-head 4-40 screws on the front of the phone fixture and
   tighten the shaft:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_shaft_screws.png" width="350" alt="Shaft and screws">  
    **Figure 5.** Phone fixture front with shaft and screws shown

    <img src="/compatibility/cts/images/sensor_fusion_assembly_shaft.png" width="350" alt="Shaft">  
    **Figure 6.** Shaft on the back of fixture, tightened by screws applied
    from the front

### Step 3: Attach clamp & rails

To attach the clamp and rails:

1. Apply nylon thumb screws, rubber adhesive, and wire to the aluminum clamp:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_clamp.png" width="350" alt="Clamp with rubber adhesive">  
    **Figure 7.** Clamp with rubber adhesive, thumb screws and wire

1. Screw the phone clamps' thumb screws into the tapped holes of the phone
   fixture.

    * CAD Drawing:

        <img src="/compatibility/cts/images/sensor_fusion_assembly_clamp_attachment_cad_drawing.png" width="450" alt="CAD drawing of clamp attachment">  
        **Figure 8.** CAD drawing of clamp attachment to phone fixture

    * Actual clamp attachment to phone fixture:

        <img src="/compatibility/cts/images/sensor_fusion_assembly_assembled_fixture.png" width="350" alt="Assembled phone fixture">  
        **Figure 9.** Assembled phone fixture

1. Fix rails on top and bottom of box towards the front. The figure below shows
   6-32 screws on pre-tapped holes, but you can use self-tapping screws instead
   if desired.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_fixed_rail.png" width="350" alt="Fixed rail">  
    **Figure 10.** Fixed rail on top and bottom of box

### Step 4: Attach lighting

To attach the light brackets and diffuser:

1. Stack two handle pieces and connect using 6-32 screws (or use self-tapping
   screws):

    <img src="/compatibility/cts/images/sensor_fusion_assembly_handle_pieces.png" width="450" alt="Handle pieces and assembly">  
    **Figure 11.** Sensor fusion box handle pieces and assembly

1. Prepare four 4-40 screws and nuts to fix the mounting bracket from the
   lighting kit to the wall of the box:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_interior_wall_screws.png" width="350" alt="Screws and bracket on interior wall">  
    **Figure 12.** Screws and light bracket on the interior wall of the box  
    <img src="/compatibility/cts/images/sensor_fusion_assembly_exterior_bolts.png" width="350" alt="Exterior with bolts applied">  
    **Figure 13.** Bolts applied to the screws from the exterior of the box

1. Snap the lights into the brackets (can be a tight fit):

    <img src="/compatibility/cts/images/sensor_fusion_assembly_interior_wall_lights.png" width="450" alt="Lights on interior wall">  
    **Figure 14.** Lights fixed to the interior wall with brackets

1. Cut the light diffuser to an appropriate size to wrap the light strips:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_light_strips_diffusers.png" width="350" alt="Light strips and diffusers">  
    **Figure 15.** Light strips and light diffusers

1. Wrap the light diffuser around the strip and tape it at the back:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_strips_taped_back.png" width="350" alt="Strips and diffusers taped from back">  
    **Figure 16.** Light strips and light diffusers taped from the back

### Step 5: Attach phone fixture to servo plate

To attach the phone fixture to the servo plate:

1.  Prepare four 6-32 screws and servo plate to fix the servo onto the wall.
    The screws go from inside and fix themselves onto the servo plate that is
    on the exterior of the wall.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_servo_plate.png" width="450" alt="Servo and servo plate">  
    **Figure 17.** Servo and servo plate held in place with 6-32 screws

1.  Secure phone fixture onto the servo with nylocks (pushing the center of the
    shaft into the servo's rotation center):

    <img src="/compatibility/cts/images/sensor_fusion_assembly_phone_fixture.png" width="450" alt="Phone fixture on servo">  
    **Figure 18.** Phone fixture on servo

1.  Screw the phone fixture onto the servo with its servo screw:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_screw.png" width="350" alt="Phone fixture on servo with screw">  
    **Figure 19.** Securing phone fixture onto servo with servo screw

### Step 6: Final assembly

To complete final assembly of the Sensor Fusion Box:

1.  Secure servo control box on the left of the servo with 4-40 screws from the
    outside and fastened from the inside with nuts:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_on_wall.png" width="450" alt="Servo control box on wall">  
    **Figure 20.** Secure servo control box onto the wall

1. Tape the box together, then screw the parts together (you might need to
   pre-drill some holes in some parts).

    * CAD drawing:

        <img src="/compatibility/cts/images/sensor_fusion_assembly_complete_box_drawing.png" width="450" alt="Complete box CAD drawing">  
        **Figure 21.** CAD drawing of complete Sensor Box

    * Actual Sensor Fusion Box:

        <img src="/compatibility/cts/images/sensor_fusion_assembly_taped_box.png" width="450" alt="Taped box">  
        **Figure 22.** Taped box with motor assembly and servo control box and
        screw detail

1. Print out a colored copy of the checkerboard (included in the [Sensor Fusion
   Box zip file](/compatibility/cts/sensor_fusion_1.4.zip)) on A3 (or 11 x 17
   inch paper), and tape it on the opposite wall of the phone fixture.

  Make sure the red dot in the center of the checkerboard is directly facing
  the camera when placed on the fixture, as shown below:

    <img src="/compatibility/cts/images/sensor_fusion_assembly_checkerboard.png" width="350" alt="Checkerboard">  
    **Figure 23.** Checkerboard printed and taped to the opposite wall of phone
    fixture
