const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const WGPUFlags = _misc.WGPUFlags;

const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

pub const BufferBindingType = enum(u32) {
    @"undefined"      = 0x00000000,
    uniform           = 0x00000001,
    storage           = 0x00000002,
    read_only_storage = 0x00000003,
};

pub const BufferBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    @"type": BufferBindingType,
    has_dynamic_offset: WGPUBool,
    min_binding_size: u64,
};

pub const BufferUsageFlags = WGPUFlags;
pub const BufferUsage = struct {
    pub const none          = @as(u32, 0x00000000);
    pub const map_read      = @as(u32, 0x00000001);
    pub const map_write     = @as(u32, 0x00000002);
    pub const copy_src      = @as(u32, 0x00000004);
    pub const copy_dst      = @as(u32, 0x00000008);
    pub const index         = @as(u32, 0x00000010);
    pub const vertex        = @as(u32, 0x00000020);
    pub const uniform       = @as(u32, 0x00000040);
    pub const storage       = @as(u32, 0x00000080);
    pub const indirect      = @as(u32, 0x00000100);
    pub const query_resolve = @as(u32, 0x00000200);
};

pub const BufferDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: BufferUsageFlags,
    size: u64,
    mapped_at_creation: WGPUBool,
};

pub const Buffer = opaque {
    // TODO: fill in methods
};