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

# Native Metric Tests

Native metric tests are typically used for exercising hardware abstraction
layers (HALs) or interacting directly with lower-level system services. To
leverage continuous testing service, native metric tests should be built with
the [google-benchmark](https://github.com/google/benchmark){: .external}
framework.

## Example

See sample native test module setup at:
[bionic/benchmarks/bionic-benchmarks](https://android.googlesource.com/platform/bionic/+/master/benchmarks/bionic_benchmarks.cpp)

## Summary of steps

1. Test module configuration file should use the `BUILD_NATIVE_BENCHMARK` build
   rule so that google-benchmark dependencies are included automatically.
1. Build the test module with make:

   ```shell
   make -j40 bionic-benchmarks
   ```
1.  Automatic installation and run with the Trade Federation test harness:

    ```
    make tradefed-all -j
    tradefed.sh run template/local_min --template:map test=bionic-benchmarks
    ```

1. Manually install and run like so:

   1. Push the generated test binary onto device:

      ```
      adb push ${OUT}/data/benchmarktest/bionic-benchmarks/bionic-benchmarks32 \
        /data/benchmarktest/bionic-benchmarks/bionic-benchmarks32
      ```
   1. Execute the test by invoking test binary on device:

      ```
      adb shell /data/benchmarktest/bionic-benchmarks/bionic-benchmarks32
      ```
