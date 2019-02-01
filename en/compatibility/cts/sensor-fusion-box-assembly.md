<<<<<<< HEAD   (b056d3 Update dalvikvm configuration docs for 7.1)
=======
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

# Sensor Fusion Box Details

This page provides information on how to purchase or assemble a Sensor Fusion
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
* *MYWAY DESIGN*  
  4F., No. 163, Fu Ying Rd., New Taipei City, Taiwan  
  sales@myway.tw  
  http://www.myway.tw/

## Building a Sensor Fusion Box

This section includes step-by-step instructions for assembling a Sensor Fusion
Box from laser-cut acrylonitrile butadiene styrene (ABS) components (shown in
Figure 1):

<img src="/compatibility/cts/images/sensor_fusion_assembly_box_cad_drawing.png" width="700" alt="CAD drawing of Sensor Fusion Box components" class="screenshot">  
**Figure 1.** Mechanical drawing of Sensor Fusion Box components

### Required tools

Before starting, ensure you have downloaded the technical drawings for the
Sensor Fusion Box (included in the
[Sensor Fusion Box zip file](/compatibility/cts/sensor_fusion_1_5.zip)) and
have the following tools available:

* Phillips head screwdriver
* Hex keys
* Power drill set
* Exacto knife
* Tape

### Step 1: Apply vinyl stickers

After creating the ABS components with a laser
cutter, apply vinyl stickers to the plastic box to get the proper color control
on the interior of the test box:

1. Apply vinyl on the smooth side of the ABS
   as shown in Figure 2. For helpful tips on applying vinyl, refer to
   [wikiHow](https://www.wikihow.com/Install-a-Vinyl-Graphic){: .external}.
1. Cut out the necessary holes on the vinyl with the exacto knife.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_abs_pieces.png" width="350" alt="BS pieces">  
    **Figure 2.** ABS pieces with vinyl applied on the smooth side (interior of
    the box)

### Step 2: Prepare phone mount and attach servo mount

To prepare the phone mount to attach to the servo:

1. Tap 16 holes on the phone fixture with ¼" - 20 and make countersink
   holes on the back of the phone fixture.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_phone_fixture_holes.png" width="350" alt="Phone fixture holes">  
    **Figure 3.** Phone fixture with tap and countersink holes

1. With the large shaft that came with the servo, drill pilot holes with a #43
   drill bit (2.26 mm) into the last holes from each side so 4-40 screws can be
   inserted through the holes.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_shaft.png" width="350" alt="Servo shaft">  
    **Figure 4.** Servo shaft with pilot holes at each end

1. Insert and tighten the flat-head 4-40 screws as shown in figure 5 on the
   front of the phone fixture and tighten the shaft as shown in figure 6.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_screws.png" width="350" alt="Shaft and screws">  
    **Figure 5.** Flat-head 4-40 screws

    <img src="/compatibility/cts/images/sensor_fusion_assembly_shaft.png" width="350" alt="Shaft">  
    **Figure 6.** Shaft on the back of fixture, tightened by screws applied
    from the front

### Step 3: Attach phone clamps

To attach the phone clamps:

1. Apply nylon thumb screws, rubber adhesive, and wire spring to the aluminum
   clamp.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_clamp.png" width="350" alt="Clamp with rubber adhesive">  
    **Figure 7.** Clamp with rubber adhesive, thumb screws and wire spring

1. Screw the phone clamps' thumb screws into the tapped holes of the phone
   fixture as shown in figure 8. You can adjust the location of the phone mounts
   depending on the size of the phones as shown in figure 9.

    * Mechanical drawing:

        <img src="/compatibility/cts/images/sensor_fusion_assembly_clamp_attachment_drawing.png" width="600" alt="CAD drawing of clamp attachment" class="screenshot">  
        **Figure 8.** Mechanical drawing of clamp attachment to phone fixture

    * Phone mounts attachment to phone fixture:

        <img src="/compatibility/cts/images/sensor_fusion_assembly_assembled_fixture.png" width="350" alt="Assembled phone fixture">  
        **Figure 9.** Assembled phone fixture

### Step 4: Assemble sliding door rail

1. Fix sliding panel rails on the top and bottom of the box towards the front.
   Figure 10 shows 6-32 screws on pre-tapped holes. Alternatively, you can use
   self-tapping screws.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_fixed_rail.png" width="450" alt="Fixed rail">  
    **Figure 10.** Fixed sliding panel rail on top and bottom of box

### Step 5: Attach lighting

To attach the light brackets and diffuser:

1. Stack two handle pieces on top of each other and assemble them using 6-32
   screws (or use self-tapping screws).

    <img src="/compatibility/cts/images/sensor_fusion_assembly_handle_pieces.png" width="450" alt="Handle pieces and assembly">  
    **Figure 11.** Sensor fusion box handle pieces and assembly

1. Prepare four 4-40 screws, nuts, and acorn nuts to fix the mounting bracket
   from the lighting kit to the wall of the box.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_interior_wall_screws.png" width="350" alt="Screws and bracket on interior wall">  
    **Figure 12.** 4-40 screws and light bracket on the interior wall of the box  
    <img src="/compatibility/cts/images/sensor_fusion_assembly_exterior_bolts.png" width="350" alt="Exterior with bolts applied">  
    **Figure 13.** Bolts and acorn bolts applied to the screws from the exterior
    of the box

1. Cut the light diffuser to an appropriate size to wrap the light strips.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_light_strips_diffusers.png" width="350" alt="Light strips and diffusers">  
    **Figure 14.** Light strips and light diffusers

1. Wrap the light diffuser around the strip and tape it at the back.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_strips_taped_back.png" width="350" alt="Strips and diffusers taped from back">  
    **Figure 15.** Light strips and light diffusers taped from the back

1. Snap the lights into the brackets (can be a tight fit).

    <img src="/compatibility/cts/images/sensor_fusion_assembly_interior_wall_lights.png" width="450" alt="Lights on interior wall">  
    **Figure 16.** Lights not mounted in brackets (left). Lights mounted in brackets (right).

### Step 6: Attach phone fixture to servo plate

To attach the phone fixture to the servo plate:

1.  Prepare four 6-32 screws and a servo plate to fix the servo onto the wall.
    Fix the servo onto the interior wall and insert the screws from the inside
    into the servo plate on the exterior wall.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_servo_plate.png" width="450" alt="Servo and servo plate">  
    **Figure 17.** Servo and servo plate held in place with 6-32 screws

1.  Secure phone fixture onto the servo with nylocks (pushing the center of the
    shaft into the servo's rotation center).

    <img src="/compatibility/cts/images/sensor_fusion_assembly_phone_mount_servo.png" width="450" alt="Phone fixture on servo">  
    **Figure 18.** Phone mount fixed on servo shaft with nylocks

1.  Screw the phone fixture onto the servo with its servo screw.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_screw.png" width="350" alt="Phone fixture on servo with screw">  
    **Figure 19.** Securing phone fixture onto servo with servo screw

### Step 7: Final assembly

To complete assembly of the Sensor Fusion Box:

1.  Secure servo control box on the left of the servo with 4-40 screws from the
    outside and fasten from the inside with nuts.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_servo_on_wall.png" width="450" alt="Servo control box on wall">  
    **Figure 20.** Secure servo control box onto the wall

1. Tape the box together, then screw the parts together (you might need to
   pre-drill holes in some parts).

    * Assembled Sensor Fusion Box:

        <img src="/compatibility/cts/images/sensor_fusion_assembly_taped_box.png" width="450" alt="Taped box">  
        **Figure 21.** Taped box with motor assembly and servo control box and
        screw detail

1. Print out a colored copy of the checkerboard (included in the [Sensor Fusion
   Box zip file](/compatibility/cts/sensor_fusion_1_5.zip)) on A3 (or 11 x 17
   inch) paper, and tape it on the opposite wall of the phone fixture.

   Make sure the red dot in the center of the checkerboard is directly facing
   the camera when placed on the fixture, as shown below.

    <img src="/compatibility/cts/images/sensor_fusion_assembly_checkerboard.png" width="350" alt="Checkerboard">  
    **Figure 22.** Checkerboard printed and taped to the opposite wall of phone
    fixture
>>>>>>> CHANGE (3fbb9e Docs: Changes to source.android.com)
