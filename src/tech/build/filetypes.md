<!--
   Copyright 2011 The Android Open Source Project

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

# Makefile types in the Android build system #

This section explores the various kinds of makefiles that are used in
the Android build system, the roles they play, and how they interact
with one another.

## High-level view ##

There are essentially 4 kinds of makefiles:

 - product definitions

 - board definitions

 - module definitions

 - the core build system (a.k.a. "everything else")

The core build system knows how to build a flat list of modules from the
module definitions. The product definitions list which modules are useful
for a given product, and the board definitions fine-tune how the modules
are actually built.

## The individual file types ##

### Product definitions ###

Product definitions are files like full.mk that specify what must be used
in each product.

They specify a list of modules to be included (which then
match the names in the module definition makefiles), a list of additional
files to be included in the final image, a list of system properties, a
list of locales.  They also specify the target hardware for this product.

Which product definition to use for a given build is specified by the lunch
command, or by specifying a PRODUCT-xxx-yyy goal (e.g. make PRODUCT-full-eng).

The product definition files set variables named PRODUCT_* which are later used
by the core build system. Because product definitions are parsed first, they
cannot be conditional on anything that's set by any other type of makefile,
and they're purely declarative.

Product definitions follow an inheritance scheme: a product can inherit from
other products (which adds up all the variables set by those other products)
or override what those other products set. It's common for product definitions
to be specialized, and for a high-level product definition to inherit from
smaller specialized ones: some product definitions specifically list the apps
used for a given partner, some other ones list the modules and files that are
specific to a device, and some other ones list the common parts that are shared
between all Android devices and are at the root of the inheritance hierarchy.

If through the inheritance chain there are multiple source files specified to
be copied into a single location, the first one takes precedence. The same
behavior is true for system properties.

Through that inheritance mechanism, not all product definitions are buildable
independently, and some intermediate ones are only meant to be inherited from.
Product definitions are often maintained by many different people, so it's quite
important to keep them simple, consistent, and well-documented.

An example of product inheritance would be full_passion.mk. It fundamentally
inherits on one side from passion_us.mk (all the passion-specific modules, files
and properties) and from there from htc/common.mk (aspects that are specific to
HTC but used in all there phones. On the other side full_passion.mk inherits
from full_base.mk (fully-configured open-source configuration), and from
there from generic.mk (the base config for all phones) and then from
core.mk (the base config for all builds, both phones and SDKs).

### Board definitions ###

Board definitions are files called BoardConfig.mk, which contain details
about how to fine-tune the build process for a specific device: which
instruction set to use, which filesystem to use when building images,
how to configure the various modules and the target toolchains.

They contain variables prefixed by BOARD_ which are used in module
definitions, in toolchain definitions and in the core build system.

The current product definition specifies which board definition gets used.
Board definitions are fundamentally purely declarative, though it's
acceptable to use conditionals within a single board definition (i.e. when
a conditional tests a variable set earlier in the same file).

Those are most often created and maintained by systems engineers who work
on the associated device.

### Module definitions ###

Module definitions are the Android.mk files that are scattered all around the
source tree. They give the core build systems the parameters needed to build and
handle a single module (which is typically be a file that ends up on the device,
or a library, or a tool).

Module definition files must be independent from one another: they must not
depend on being included in any specific order, and they must not alter
one another's behaviors. Specifically, any module definition file must
always unconditionally include all module definition files that are
located under it in the filesystem.  If a module definition file depends
on being conditionally executed, it must not depend on that condition
being handled in another module definition file. Keeping the module
definition files independent from one another allows to re-factor the
source tree much more easily.

Module definitions may use BOARD_ variables when the commands to build that
specific module vary between devices.

Module definitions are typically created and maintained by the engineers to
work on the associated modules.

Module definitions conceptually contain function calls, but since GNU make
doesn't support true function calls the Android build system uses a
different trick: the parameters to pseudo-functions are set in LOCAL_*
variables (after clearing all those potential variables to avoid leftovers),
and a makefile is included from the core build system that reads those
LOCAL_* variables and sets up the matching rules. The names of all such
pseudo-function makefiles are stored in BUILD_* variables.

### Core build system ###

Finally, the core build system is where everything else happens.

The core build systems contains all the logic to manage product definitions,
board definitions and module definitions, as well as toolchains and toolchain
configurations, but also all the aspects that are only used from a single
location or for a single purpose, e.g. generating documentation or SDK stubs,
creating filesystem images or recovery packages.

Because it's central and by definition deals with unique cases, the core
build system should only be changed by people with reasonable experience
with the Android build system.
