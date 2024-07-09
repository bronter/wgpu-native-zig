const testing = @import("std").testing;

const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

const WGPUInstanceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
};
pub const InstanceDescriptor = WGPUInstanceDescriptor;

extern "c" fn wgpuCreateInstance(descriptor: ?*const WGPUInstanceDescriptor) ?*WGPUInstanceImpl;
const WGPUInstanceImpl = opaque {
    pub inline fn create(descriptor: ?*const InstanceDescriptor) ?*Instance {
        return wgpuCreateInstance(descriptor);
    }

    // pub inline fn createSurface(self: *Instance, )
};
pub const Instance = WGPUInstanceImpl;

test "can create instance" {
    try testing.expect(Instance.create(null) != null);
}