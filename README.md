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

## How the wrapper code differs from just doing `const wgpu = @cImport({@cInclude("webgpu.h")});`
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
* Methods that would normally require a callback are named like `methodNameWithCallback`, and a non-callback wrapper method is provided for convenience.
  * For example, requesting an adapter with a callback looks something like
    ```zig
    fn handleRequestAdapter(status: RequestAdapterStatus, adapter: ?*Adapter, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void {
        switch(status) {
            .success => {
                const ud_adapter: **Adapter = @ptrCast(@alignCast(userdata));
                ud_adapter.* = adapter.?;
            }
        } else => {
            std.log.err("{s}\n", .{message});
        }
    }
    var adapter_ptr: ?*Adapter = null;
    instance.requestAdapterWithCallback(null, handleRequestAdapter, @ptrCast(&adapter_ptr));
    ```
    whereas the non-callback version looks like
    ```zig
    const response = instance.requestAdapter(null);

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
* `WGPUBool` is replaced with `bool` whenever possible.
  * This pretty much means, it is replaced with `bool` in the parameters and return values of methods, but not in structs or the parameters/return values of procs (which are supposed to be function pointers to things returned by `wgpuGetProcAddress`).

## TODO
* Test this on other machines with different OS/CPU (currently only tested on linux x86_64)
* Create more idiomatic wrapper around `webgpu.h`/`wgpu.h` (current WIP)
* Custom-build `wgpu-native`; provided all the necessary tools/dependencies are present.
* Figure out dynamic linking