const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

pub const QueueDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
};