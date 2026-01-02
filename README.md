# wgpu_native_zig
Zig bindings for [wgpu-native](https://github.com/gfx-rs/wgpu-native)

This package exposes two modules: `wgpu-c` and `wgpu`.

`wgpu-c` is just `wgpu.h` (and by extension `webgpu.h`) run through `translate-c`, so as close to wgpu-native's original C API as is possible in Zig.

`wgpu` is a module full of pure Zig bindings for `libwgpu_native`, it does not import any C code and instead relies on `extern fn` declarations to hook up to `wgpu-native`.

## Adding this package to your build
Add the package to your dependencies, either with:
```sh
zig fetch --save https://github.com/bronter/wgpu_native_zig/archive/refs/tags/v6.5.0.tar.gz
```
or by manually adding to your `build.zig.zon`:
```zig
.{
    // ...other stuff
    .dependencies = .{
        // ...other dependencies
        .wgpu_native_zig = .{
            // You can either use a commit hash:
            .url="https://github.com/bronter/wgpu_native_zig/archive/<commit_hash>.tar.gz",
            // or a tagged release:
            // .url = "https://github.com/bronter/wgpu_native_zig/archive/refs/tags/v6.5.0.tar.gz`
            .hash="<dependency hash>"
        }
    }
}
```
Then, in `build.zig` add:
```zig
    const wgpu_native_dep = b.dependency("wgpu_native_zig", .{});

    // Add module to your exe (wgpu-c can also be added like this, just pass in "wgpu-c" instead)
    exe.root_module.addImport("wgpu", wgpu_native_dep.module("wgpu"));
    // Or, add to your lib similarly:
    lib.root_module.addImport("wgpu", wgpu_native_dep.module("wgpu"));
```

### Building on Windows
Windows x86_64 has two options for ABI: GNU and MSVC. For i686 and aarch64, only the MSVC option is available.
If you need to specify the build target, you can do that with:
```zig
const target = b.standardTargetOptions(.{
    .default_target = .{
        // If not specified, defaults to the GNU abi
        .abi = .msvc,
    }
});
```
Or, specify it with your build command. For example, the triangle example in this repository can be run like so:
```sh
zig build run-triangle-example -Dtarget=x86_64-windows-msvc
```
Either way, pass the resolved target to the dependency like so:
```zig
const wgpu_native_dep = b.dependency("wgpu_native_zig", .{
  .target = target
});
```

When using static linking with MSVC, you might encounter duplicate symbol errors. If so, try
```zig
if (target.result.abi == .msvc) {
  // "exe" here is the *std.Build.Step.Compile from b.addExecutable() (or b.addTest())
  exe.bundle_compiler_rt = false;
  exe.bundle_ubsan_rt = false;
}
```
An example of using `wgpu-native-zig` with static linking on Windows can be found at [wgpu-native-zig-windows-test](https://github.com/bronter/wgpu-native-zig-windows-test).

### Dynamic linking
Dynamic linking can be made to work, though it is a bit messy to use.
When you initialize your `wgpu_native_dep`, add the option for dynamic linking like so:
```zig
const wgpu_native_dep = b.dependency("wgpu_native_zig", .{
  // Defaults to .static if you don't specify
  .link_mode = .dynamic
});
```
Then add the following with your install step dependencies:
```zig
const lib_dir = wgpu_native_dep.namedWriteFiles("lib").getDirectory();

// This would also work with .so files on linux
const dll_path = lib_dir.join(b.allocator, "wgpu_native.dll") catch return;

// addInstallBinFile puts the dll in the same directory as your executable
const install_dll = b.addInstallBinFile(dll_path, "wgpu_native.dll");

// Make sure that the dll is installed when the install step is run
b.getInstallStep().dependOn(&install_dll.step);
```


## How the `wgpu` module differs from `wgpu-c`
* Names are shortened to remove redundancy.
  * For example `wgpu.WGPUSurfaceDescriptor` becomes `wgpu.SurfaceDescriptor`
* C pointers (`[*c]`) are replaced with more specific pointer types.
  * For example `[*c]const u8` is replaced with `?[*:0]const u8`.
* Pointers to opaque structs are made explicit (and only optional when they need to be).
  * For example `wgpu.WGPUAdapter` from `webgpu.h` would instead be expressed as `*wgpu.Adapter` or `?*wgpu.Adapter`, depending on the context.
* Methods are expressed as decls inside of structs
  * For example 
    ```zig
    wgpu.wgpuInstanceCreateSurface(instance: WGPUInstance, descriptor: [*c]const WGPUSurfaceDescriptor) WGPUSurface
    ``` 
    becomes
    ```zig
    Instance.createSurface(self: *Instance, descriptor: *const SurfaceDescriptor) ?*Surface
    ```
* Certain asynchronous methods such as requestAdapter and requestDevice are provided with wrapper methods.
  * For example, requesting an adapter with a callback looks something like
    ```zig
    fn handleRequestAdapter(
        status: RequestAdapterStatus,
        adapter: ?*Adapter,
        message: StringView,
        userdata1: ?*anyopaque,
        userdata2: ?*anyopaque
    ) callconv(.c) void {
        switch(status) {
            .success => {
                const ud_adapter: **Adapter = @ptrCast(@alignCast(userdata1));
                ud_adapter.* = adapter.?;
            },
            else => {
              std.log.err("{s}\n", .{message.toSlice()});
            }
        }
        const completed: *bool = @ptrCast(@alignCast(userdata2));
        completed.* = true;
    }
    var adapter_ptr: ?*Adapter = null;
    var completed = false;
    const request_adapter_info = RequestAdapterInfo {
        .callback = handleRequestAdapter,
        .userdata1 = @ptrCast(&adapter_ptr),
        .userdata2 = @ptrCast(&completed),
    }
    const ra_future = instance.requestAdapter(null, request_adapter_info);

    // There is currently no way to use a `Future`,
    // it's supposed to be passed into `Instance.waitAny()`,
    // which is unimplemented as of `wgpu_native` v24.0.3.1.
    _ = ra_future; 

    instance.processEvents();
    while(!completed) {
      std.Thread.sleep(200_000_000);
      instance.processEvents();
    }
    ```
    whereas the non-callback version looks like
    ```zig
    // The wrapper methods use polling, so 200_000_000 is the polling interval in nanoseconds.
    const response = instance.requestAdapterSync(null, 200_000_000);

    const adapter_ptr: ?*Adapter = switch (response.status) {
        .success => response.adapter,
        else => blk: {
            std.log.err("{s}\n", .{response.message});
            break :blk null;
        }
    };
    ```
* Chained structs are provided with inline functions for constructing them, which come in two forms depending on whether or not the chained struct is likely to always be required.
  * For required chained structs, you can either write them explicitely:
    ```zig
    SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromXlibWindow {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_xlib_window,
            },
            .display = display,
            .window = window,
        }),
        .label = "xlib_surface_descriptor",
    };
    ```
    or use a function to construct them:
    ```zig
    // Here the descriptors from SurfaceDescriptor and SurfaceDescriptorFromXlibWindow have been merged,
    // so just pass in an anonymous struct with the things that you need; default values will take care of the rest.
    surfaceDescriptorFromXlibWindow(.{
        .label = "xlib_surface_descriptor",
        .display = display,
        .window = window
    });
    ```
  * For optional chained structs, you can either write them explicitely like in the example above, or you can use a method of the parent struct instance to add them, for example:
    ```zig
    &(SurfaceConfiguration {
      .device = device,
      // other stuff
    }).withDesiredMaxFrameLatency(2);
    ```
* `WGPUBool` is replaced with `bool` whenever possible.
  * This pretty much means, it is replaced with `bool` in the parameters and return values of methods, but not in structs or the parameters/return values of procs (which are supposed to be function pointers to things returned by `wgpuGetProcAddress`).

## TODO
* Test this on other machines with different OS/CPU. Currently only tested on x86_64-linux-gnu and x86_64-windows (msvc and gnu); zig version 0.14.0.
* Cleanup/organization: 
  * If types are only tied to a specific opaque struct, they should be decls inside that struct.
  * The associated Procs struct should probably be a decl of the opaque struct as well.
  * There are many things that seem to be in the wrong file.
    * For example a lot of what is in `pipeline.zig` is actually only used by `Device`, and should probably be in `device.zig` instead.
  * Since pointers to opaque structs are made explicit, it would be more consistent if pointers to callback functions are explicit as well.
* Port [wgpu-native-examples](https://github.com/samdauwe/webgpu-native-examples) using wrapper code, as a basic form of documentation.
* Custom-build `wgpu-native`; provided all the necessary tools/dependencies are present.
* Bindgen using [the webgpu-headers yaml](https://github.com/webgpu-native/webgpu-headers/blob/main/webgpu.yml)?
* The proc definitions are mainly there since they are also present in the webgpu headers and I didn't fully understand what they were for when I started working on this project. However, I know better now and they aren't really used for anything currently. They're supposed to be used with `wgpuGetProcAddress` but it's [unimplemented in `wgpu-native`](https://github.com/gfx-rs/wgpu-native/issues/223). They are a pain to update by hand, so maybe they should be removed for now and made optional once we have a working bindings generator? Like the bindgen could put them in a separate `wgpu-procs` module.
