// const StringView = @import("misc.zig").StringView;

// Generic function return type for wgpuGetProcAddress
// pub const Proc = *const fn() callconv(.c) void;

// Supposedly getProcAddress is a global function, but it doesn't seem like it should work without being tied to a Device?
// Could be it's one of those functions that's meant to be called with null the first time, TODO: look into that.
// 
// Regardless, apparently the reason it exists is because different devices have different drivers and therefore different procs,
// so you need to get the version of the proc that is meant for that particular device.
// 
// Although this function appears in webgpu.h, it is currently unimplemented in wgpu-native,
// (https://github.com/gfx-rs/wgpu-native/blob/trunk/src/unimplemented.rs)
// so I'm leaving it here in case it gets implemented eventually, but commented out until/unless that happens.
// extern fn wgpuGetProcAddress(proc_name: StringView) ?Proc;
// pub inline fn getProcAddress(proc_name: StringView) ?Proc {
//     return wgpuGetProcAddress(proc_name);
// }