const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

pub const QueryType = enum(u32) {
    occlusion = 0x00000000,
    timestamp = 0x00000001,
};

pub const QuerySetDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    @"type": QueryType,
    count: u32,
};

pub const QuerySet = opaque {
    // TODO: fill in methods
};