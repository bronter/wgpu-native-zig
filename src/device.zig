const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

const _misc = @import("misc.zig");
const FeatureName = _misc.FeatureName;
const Limits = _misc.Limits;

const QueueDescriptor = @import("queue.zig").QueueDescriptor;

pub const RequiredLimits = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    limits: Limits,
};

pub const DeviceLostReason = enum(u32) {
    undefined = 0x00000000,
    destroyed = 0x00000001,
};

pub const DeviceLostCallback = *const fn(reason: DeviceLostReason, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;

pub const DeviceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    required_feature_count: usize,
    required_features: [*]const FeatureName,
    required_limits: ?*const RequiredLimits,
    default_queue: QueueDescriptor,
    device_lost_callback: DeviceLostCallback,
    device_lost_user_data: ?*anyopaque,
};

pub const RequestDeviceStatus = enum(u32) {
    success  = 0x00000000,
    @"error" = 0x00000001,
    unknown  = 0x00000002,
};

pub const RequestDeviceCallback = *const fn(status: RequestDeviceStatus, device: ?*Device, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;
pub const RequestDeviceResponse = struct {
    status: RequestDeviceStatus,
    message: ?[*:0]const u8,
    device: ?*Device,
};

pub const Device = opaque {
    // TODO: fill in methods
};