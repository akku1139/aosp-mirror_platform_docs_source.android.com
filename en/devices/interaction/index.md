Project: /_project.yaml
Book: /_book.yaml

{% include "_versions.html" %}

<!--
  Copyright 2019 The Android Open Source Project

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

# Interaction in Android

This section explains how Android processes the various inputs it receives from
the keyboard, sensors, and more.

## Automotive

The Android Automotive hardware abstraction layer (HAL) provides a consistent
interface to the Android framework regardless of physical transport layer. This
vehicle HAL is the interface for developing Android Automotive implementations.

## Input

The Android input subsystem nominally consists of an event pipeline that
traverses multiple layers of the system. At the lowest layer, the physical input
device produces signals that describe state changes such as key presses and
touch contact points.

## Neural Networks

The Android Neural Networks API (NNAPI) runs computationally intensive
operations for machine learning. This document provides an overview on how to
implement a Neural Networks API driver for Android 9.

## Peripherals and accessories

Using a suite of standard protocols, you can implement compelling peripherals
and other accessories that extend Android capabilities in a wide range of
Android-powered devices.

## Sensors

Android sensors give applications access to a mobile device's underlying
physical sensors. They are data-providing virtual devices defined by
`sensors.h`, the sensor Hardware Abstraction Layer (HAL).
