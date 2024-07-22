# wgpu-native-zig
Zig bindings for [wgpu-native](https://github.com/gfx-rs/wgpu-native)

This package exposes two modules: `wgpu-c` and `wgpu`.

`wgpu-c` is just `wgpu.h` (and by extension `webgpu.h`) run through `translate-c`, so as close to wgpu-native's original C API as is possible in Zig.

`wgpu` is a module full of pure Zig bindings for `libwgpu_native`, it does not import any C code and instead relies on `extern fn` declarations to hook up to `wgpu-native`.

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

    // Add module to your exe (wgpu-c can also be added like this, just pass in "wgpu-c" instead)
    exe.root_module.addImport("wgpu", wgpu_native_dep.module("wgpu"));
    // Or, add to your lib similarly:
    lib.root_module.addImport("wgpu", wgpu_native_dep.module("wgpu"));
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
* Certain methods that require a callback such as requestAdapter and requestDevice are provided with wrapper methods.
  * For example, requesting an adapter with a callback looks something like
    ```zig
    fn handleRequestAdapter(status: RequestAdapterStatus, adapter: ?*Adapter, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void {
        switch(status) {
            .success => {
                const ud_adapter: **Adapter = @ptrCast(@alignCast(userdata));
                ud_adapter.* = adapter.?;
            },
            else => {
              std.log.err("{s}\n", .{message});
            }
        }
    }
    var adapter_ptr: ?*Adapter = null;
    instance.requestAdapter(null, handleRequestAdapter, @ptrCast(&adapter_ptr));
    ```
    whereas the non-callback version looks like
    ```zig
    const response = instance.requestAdapterSync(null);

    // Unfortunately propagating anything more than status codes is ugly in Zig;
    // see https://github.com/ziglang/zig/issues/2647
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
    &(PrimitiveState {
      .topology = PrimitiveTopology.triangle_list,
      .strip_index_format = IndexFormat.uint16,
      .front_face = FrontFace.ccw,
      .cull_mode = CullMode.back,
    }).withDepthClipControl(false);
    ```
* `WGPUBool` is replaced with `bool` whenever possible.
  * This pretty much means, it is replaced with `bool` in the parameters and return values of methods, but not in structs or the parameters/return values of procs (which are supposed to be function pointers to things returned by `wgpuGetProcAddress`).

## TODO
* Test this on other machines with different OS/CPU (currently only tested on linux x86_64)
* Create more idiomatic wrapper around `webgpu.h`/`wgpu.h` (mostly finished with some potential issues)
  * See if we really need `callconv(.C)` on extern fns; it seems like maybe this is the default for extern fn, or that Zig can somehow figure out the calling convention?
  * Investigate usages of many-item pointers. There are probably some many-item pointers that should be optional but aren't (potentially a breaking issue), and there are probably also some optional many-item pointers that should default to null but don't (annoying but can be worked around). Implementing more examples should uncover many of these issues. 
* Port [wgpu-native-examples](https://github.com/samdauwe/webgpu-native-examples) using wrapper code, as a basic form of documentation.
* Custom-build `wgpu-native`; provided all the necessary tools/dependencies are present.
* Figure out dynamic linking
* Normalize names from `wgpu.h` if possible
  * The names for things related OpenGL ES and DirectX seem to be inconsistent with how they're named in `WGPUBackendType` from `webgpu.h`. Specifically, OpenGL ES is capitalized like `GLES` rather than `Gles`, and DirectX is prefixed with `D3D` rather than `Dx`. It's unclear to me whether this also relates to `fxc`, `dxc`, `dxil_path`, and `dxc_path`. 
