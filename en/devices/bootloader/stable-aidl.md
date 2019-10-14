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

# Stable AIDL

Android {{ androidQVersionNumber }} adds support for stable Android Interface
Definition Language (AIDL), a new way to keep track of the application program
interface (API)/application binary interface (ABI) provided by AIDL interfaces.
Stable AIDL has the following key differences from AIDL:

*   Interfaces are defined in the build system with `aidl_interfaces`.
*   Interfaces can contain only structured data. Parcelables representing the
    desired types are automatically created based on their AIDL definition and
    are automatically marshalled and unmarshalled.
*   Interfaces can be declared as stable (backwards-compatible). When this
    happens, their API is tracked and versioned in a file next to the AIDL
    interface.

## Defining an AIDL interface

A definition of `aidl_interface` looks like this:

```
aidl_interface {
    name: "my-module-name",
    local_include_dir: "tests_1",
    srcs: [
        "tests_1/some/package/IFoo.aidl",
        "tests_1/some/package/Thing.aidl",
    ],
    api_dir: "api/test-piece-1",
    versions: ["1"],
}
```

*   `name`: The name of the module. In this case, two stub libraries in the
    corresponding language are created: `my-module-name-java` and
    `my-module-name-cpp`. To prevent the C++ library from being created, use
    `gen_cpp`. This also creates additional build system actions that you can
    use to check and update the API.
*   `local_include_dir`: The path to where the package starts.
*   `srcs`: The list of stable AIDL source files that are compiled into
    the target languages.
*   `api_dir`: The path where the API definition of previous versions of the
    interface is dumped; used to ensure API-breaking changes to the interface
    are caught (see process described below).
*   `versions`: The previous versions of the interface that are
    frozen under `api_dir`. This is optional.

## Writing AIDL files

Interfaces in stable AIDL are similar to traditional interfaces, with the
exception that they aren't allowed to use unstructured parcelables (because these
aren't stable!). The primary difference in stable AIDL is how parcelables are
defined. Previously, parcelables were _forward declared_; in stable AIDL,
parcelables fields and variables are defined explicitly.

```
// in a file like 'some/package/Thing.aidl'
package some.package;

parcelable SubThing {
    String a = "foo";
    int b;
}
```

A default is currently supported (but not required) for `boolean`, `char`,
`float`, `double`, `byte`, `int`, `long`, and `String`.

## Using stub libraries

After adding stub libraries as a dependency to your module, you
can include them into your files. Here are examples of stub libraries in the build
system (`Android.mk` can also be used for legacy module definitions):

```
cc_... {
    name: ...,
    shared_libs: ["my-module-name-cpp"],
    ...
}
# or
java_... {
    name: ...,
    static_libs: ["my-module-name-java"],
    ...
}
```

Example in C++:

```
#include "some/package/IFoo.h"
#include "some/package/Thing.h"
...
    // use just like traditional AIDL
```

Example in Java:

```
import some.package.IFoo;
import some.package.Thing;
...
    // use just like traditional AIDL
```

## Versioning interfaces

Declaring a module with name **foo** also creates a target in the build system
that you can use to manage the API of the module. When built, **foo-freeze-api**
adds a new API definition under `api_dir` for the next version of the interface.

To maintain the stability of an interface, you can add new:

*   Methods to the end of a method (or methods with explicitly defined new
    serials)
*   Elements to the end of a parcel (requires a default to be added for each
    element)

No other actions are permitted.

## New meta interface methods

Android {{ androidQVersionNumber }} adds several meta interface methods for the
stable AIDL.

### Querying the interface version of the remote object

Clients can query the version of the interface that the remote object is
implementing and compare the returned version with the interface version that
the client is using.

Example in C++:

```
sp<IFoo> foo = ... // the remote object
int32_t my_ver = IFoo::VERSION;
int32_t remote_ver = foo->getInterfaceVersion();
if (remote_ver < my_ver) {
  // the remote side is using an older interface
}
```

Example in Java:

```
IFoo foo = ... // the remote object
int my_ver = IFoo.VERSION;
int remote_ver = foo.getInterfaceVersion();
if (remote_ver < my_ver) {
  // the remote side is using an older interface
}
```

For Java language, the remote side MUST implement `getInterfaceVersion()` as
follows:

```
class MyFoo extends IFoo.Stubs {
    @Override
    public final int getInterfaceVersion() { return IFoo.VERSION; }
}
```

This is because the generated classes (`IFoo`, `IFoo.Stubs`, etc.) are shared
between the client and server (for example, the classes can be in the boot
classpath). When classes are shared, the server is also linked against the
newest version of the classes even though it might have been built with an older
version of the interface. If this meta interface is implemented in the shared
class, it always returns the newest version. However, by implementing the method
as above, the version number of the interface is embedded in the server's code
(because `IFoo.VERSION` is a `static final int` that is inlined when referenced)
and thus the method can return the exact version the server was built with.

### Dealing with older interfaces

It's possible that a client is updated with the newer version of an AIDL
interface but the server is using the old AIDL
interface. In such cases, the client must not call new methods that don't exist
in the old interface. Before stable AIDL, calling such a non-existent method was
silently ignored and the client had no knowledge of whether the method was
called or not.

With stable AIDL, clients have more control. In the client side, you can set
a default implementation to an AIDL interface. A method in the default
implementation is invoked only when the method isn't implemented in the remote
side (because it was built with an older version of the interface).

Example in C++:

```
class MyDefault : public IFooDefault {
  Status anAddedMethod(...) {
   // do something default
  }
};

// once per an interface in a process
IFoo::setDefaultImpl(std::unique_ptr<IFoo>(MyDefault));

foo->anAddedMethod(...); // MyDefault::anAddedMethod() will be called if the
                         // remote side is not implementing it
```

Example in Java:

```
IFoo.Stubs.setDefaultImpl(new IFoo.Default() {
    @Override
    public xxx anAddedMethod(...)  throws RemoteException {
        // do something default
    }
}); // once per an interface in a process


foo.anAddedMethod(...);
```

Note: In Java, `setDefaultImpl` is in the `Stubs` class, and not in the
`interface` class.

You don't need to provide the default implementation of all methods in an AIDL
interface. Methods that are guaranteed to be implemented in the remote side
(because you are certain that the remote is built when the methods were in the
AIDL interface description) don't need to be overridden in the default `impl`
class.

## Converting existing AIDL to structured/stable AIDL

If you have an existing AIDL interface and code that uses it, use the following
steps to convert the interface to a stable AIDL interface.

1.  Identify all of the dependencies of your interface. For every package the
    interface depends on, determine if the package is defined in stable AIDL. If
    not defined, the package must be converted.

2.  Convert all parcelables in your interface into stable parcelables (the
    interface files themselves can remain unchanged). Do this by
    expressing their structure directly in AIDL files. Management classes must
    be rewritten to use these new types. This can be done before you create an
    `aidl_interface` package (below).

3.  Create an `aidl_interface` package (as described above) that contains the
    name of your module, its dependencies, and any other information you need.
    To make it stabilized (not just structured), also specify the `api_dir` path.
