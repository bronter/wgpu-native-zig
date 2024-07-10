# wgpu-native-zig
Zig bindings for [wgpu-native](https://github.com/gfx-rs/wgpu-native)

Currently all this does is download the appropriate pre-built lib/headers, run the headers through @cImport, and re-export that as a module that you should hopefully be able to use.

## Adding this package to your build
In your `build.zig.zon` add:
```zig
.{
    // ...other stuff
    .dependencies = .{
        // ...other dependencies
        .wgpu_native_zig = .{
            .url="https://github.com/bronter/wgpu-native-zig/archive/<commit_hash>.tar.gz",
            .hash="<dependency hash>"
        }
    }
}
```
Then, in `build.zig` add:
```zig
    const wgpu_native_dep = b.dependency("wgpu_native_zig");

    // Add module to your exe
    exe.root_module.addImport("wgpu", wgpu_native_dep.module("wgpu"));
    // Or, add to your lib similarly:
    lib.root_module.addImport("wgpu", wgpu_native_dep.module("wgpu"));
```

## TODO
* Test this on other machines with different OS/CPU (currently only tested on linux x86_64)
* Create more idiomatic wrapper around `webgpu.h`/`wgpu.h` (current WIP)
* Custom-build `wgpu-native`; provided all the necessary tools/dependencies are present.
