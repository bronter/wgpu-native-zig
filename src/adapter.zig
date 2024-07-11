const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const WGPUBool = @import("misc.zig").WGPUBool;
const Surface = @import("surface.zig").Surface;

pub const PowerPreference = enum(u32) {
    Undefined       = 0x00000000,
    LowPower        = 0x00000001,
    HighPerformance = 0x00000002,
};

pub const BackendType = enum(u32) {
    Undefined = 0x00000000,
    Null      = 0x00000001,
    WebGPU    = 0x00000002,
    D3D11     = 0x00000003,
    D3D12     = 0x00000004,
    Metal     = 0x00000005,
    Vulkan    = 0x00000006,
    OpenGL    = 0x00000007,
    OpenGLES  = 0x00000008,
};

pub const RequestAdapterOptions = extern struct {
    next_in_chain: ?*const ChainedStruct,
    compatible_surface: ?*Surface,
    power_preference: PowerPreference,
    backend_type: BackendType,
    force_fallback_adapter: WGPUBool,
};

pub const RequestAdapterStatus = enum(u32) {
    Success     = 0x00000000,
    Unavailable = 0x00000001,
    Error       = 0x00000002,
    Unknown     = 0x00000003,
};
pub const RequestAdapterCallback = *const fn(status: RequestAdapterStatus, adapter: ?*Adapter, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const RequestAdapterResponse = struct {
    status: RequestAdapterStatus,
    adapter: ?*Adapter,
    message: []const u8,
};

pub const Adapter = opaque{
    // TODO: fill in methods
};