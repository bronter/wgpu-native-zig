const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const ChainedStructOut = _chained_struct.ChainedStructOut;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const FeatureName = _misc.FeatureName;

const SupportedLimits = @import("limits.zig").SupportedLimits;

const Surface = @import("surface.zig").Surface;

const _device = @import("device.zig");
const Device = _device.Device;
const DeviceDescriptor = _device.DeviceDescriptor;
const RequestDeviceCallback = _device.RequestDeviceCallback;
const RequestDeviceStatus = _device.RequestDeviceStatus;
const RequestDeviceResponse = _device.RequestDeviceResponse;

pub const PowerPreference = enum(u32) {
    @"undefined"        = 0x00000000,
    low_power           = 0x00000001,
    high_performance    = 0x00000002,
};

pub const AdapterType = enum(u32) {
    discrete_gpu   = 0x00000000,
    integrated_gpu = 0x00000001,
    cpu            = 0x00000002,
    unknown        = 0x00000003,
};

pub const BackendType = enum(u32) {
    @"undefined" = 0x00000000,
    null         = 0x00000001,
    webgpu       = 0x00000002,
    d3d11        = 0x00000003,
    d3d12        = 0x00000004,
    metal        = 0x00000005,
    vulkan       = 0x00000006,
    opengl       = 0x00000007,
    opengl_es    = 0x00000008,
};

pub const RequestAdapterOptions = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    compatible_surface: ?*Surface = null,
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

pub const RequestAdapterResponse = struct {
    status: RequestAdapterStatus,
    message: ?[*:0]const u8,
    adapter: ?*Adapter,
};

const AdapterProperties = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    vendor_id: u32,
    vendor_name: [*:0]const u8,
    architecture: [*:0]const u8,
    device_id: u32,
    name: [*:0]const u8,
    driver_description: [*:0]const u8,
    adapter_type: AdapterType,
    backend_type: BackendType,
};

pub const AdapterProcs = struct {
    pub const EnumerateFeatures = *const fn(Adapter, [*]FeatureName) callconv(.C) usize;
    pub const GetLimits = *const fn(Adapter, *SupportedLimits) callconv(.C) WGPUBool;
    pub const GetProperties = *const fn(Adapter, *AdapterProperties) callconv(.C) void;
    pub const HasFeature = *const fn(Adapter, FeatureName) callconv(.C) WGPUBool;
    pub const RequestDevice = *const fn(Adapter, ?*const DeviceDescriptor, RequestDeviceCallback, ?*anyopaque) callconv(.C) void;
    pub const Reference = *const fn(Adapter) callconv(.C) void;
    pub const Release = *const fn(Adapter) callconv(.C) void;
};

extern fn wgpuAdapterEnumerateFeatures(adapter: *Adapter, features: [*]FeatureName) callconv(.C) usize;
extern fn wgpuAdapterGetLimits(adapter: *Adapter, limits: *SupportedLimits) callconv(.C) WGPUBool;
extern fn wgpuAdapterGetProperties(adapter: *Adapter, properties: *AdapterProperties) callconv(.C) void;
extern fn wgpuAdapterHasFeature(adapter: *Adapter, feature: FeatureName) callconv(.C) WGPUBool;
extern fn wgpuAdapterRequestDevice(adapter: *Adapter, descriptor: ?*const DeviceDescriptor, callback: RequestDeviceCallback, userdata: ?*anyopaque) callconv(.C) void;
extern fn wgpuAdapterReference(adapter: *Adapter) callconv(.C) void;
extern fn wgpuAdapterRelease(adapter: *Adapter) callconv(.C) void;

pub const Adapter = opaque{
    pub inline fn enumerateFeatures(self: *Adapter, features: [*]FeatureName) usize {
        return wgpuAdapterEnumerateFeatures(self, features);
    }
    pub inline fn getLimits(self: *Adapter, limits: *SupportedLimits) bool {
        return wgpuAdapterGetLimits(self, limits) != 0;
    }
    pub inline fn getProperties(self: *Adapter, properties: *AdapterProperties) void {
        wgpuAdapterGetProperties(self, properties);
    }
    pub inline fn hasFeature(self: *Adapter, feature: FeatureName) bool {
        return wgpuAdapterHasFeature(self, feature) != 0;
    }

    fn defaultDeviceCallback(status: RequestDeviceStatus, device: ?*Device, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void {
        const ud_response: *RequestDeviceResponse = @ptrCast(@alignCast(userdata));
        ud_response.* = RequestDeviceResponse {
            .status = status,
            .message = message,
            .device = device,
        };
    }
    pub fn requestDeviceSync(self: *Adapter, descriptor: ?*const DeviceDescriptor) RequestDeviceResponse {
        var response: RequestDeviceResponse = undefined;
        wgpuAdapterRequestDevice(self, descriptor, defaultDeviceCallback, @ptrCast(&response));
        return response;
    }
    pub inline fn requestDevice(self: *Adapter, descriptor: ?*const DeviceDescriptor, callback: RequestDeviceCallback, userdata: ?*anyopaque) void {
        wgpuAdapterRequestDevice(self, descriptor, callback, userdata);
    }
    pub inline fn reference(self: *Adapter) void {
        wgpuAdapterReference(self);
    }
    pub inline fn release(self: *Adapter) void {
        wgpuAdapterRelease(self);
    }
};

test "can request device" {
    const testing = @import("std").testing;

    const Instance = @import("instance.zig").Instance;
    const instance = Instance.create(null);
    const adapter_response = instance.?.requestAdapterSync(null);
    const adapter: ?*Adapter = switch(adapter_response.status) {
        .success => adapter_response.adapter,
        else => null,
    };
    const device_response = adapter.?.requestDeviceSync(null);
    const device: ?*Device = switch(device_response.status) {
        .success => device_response.device,
        else => null
    };
    try testing.expect(device != null);
}