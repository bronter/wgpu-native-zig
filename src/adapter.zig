const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const WGPUBool = @import("misc.zig").WGPUBool;
const Surface = @import("surface.zig").Surface;

pub const PowerPreference = enum(u32) {
    undefined        = 0x00000000,
    low_power        = 0x00000001,
    high_performance = 0x00000002,
};

pub const BackendType = enum(u32) {
    undefined = 0x00000000,
    null      = 0x00000001,
    webgpu    = 0x00000002,
    d3d11     = 0x00000003,
    d3d12     = 0x00000004,
    metal     = 0x00000005,
    vulkan    = 0x00000006,
    opengl    = 0x00000007,
    opengles  = 0x00000008,
};

pub const RequestAdapterOptions = extern struct {
    next_in_chain: ?*const ChainedStruct,
    compatible_surface: ?*Surface,
    power_preference: PowerPreference,
    backend_type: BackendType,
    force_fallback_adapter: WGPUBool,
};

pub const RequestAdapterStatus = enum(u32) {
    success     = 0x00000000,
    unavailable = 0x00000001,
    @"error"    = 0x00000002,
    unknown     = 0x00000003,
};
pub const RequestAdapterCallback = *const fn(status: RequestAdapterStatus, adapter: ?*Adapter, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;

pub const Adapter = opaque{
    // TODO: fill in methods
};