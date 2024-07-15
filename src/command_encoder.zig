const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

pub const CommandEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
};

pub const CommandEncoder = opaque {
    // TODO: fill in methods
};