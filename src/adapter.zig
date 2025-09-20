const std = @import("std");

const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const ChainedStructOut = _chained_struct.ChainedStructOut;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const FeatureName = _misc.FeatureName;
const StringView = _misc.StringView;
const Status = _misc.Status;
const SupportedFeatures = _misc.SupportedFeatures;

const Limits = @import("limits.zig").Limits;

const Surface = @import("surface.zig").Surface;

const Instance = @import("instance.zig").Instance;

const _device = @import("device.zig");
const Device = _device.Device;
const DeviceDescriptor = _device.DeviceDescriptor;
const RequestDeviceCallback = _device.RequestDeviceCallback;
const RequestDeviceCallbackInfo = _device.RequestDeviceCallbackInfo;
const RequestDeviceStatus = _device.RequestDeviceStatus;
const RequestDeviceResponse = _device.RequestDeviceResponse;

const _async = @import("async.zig");
const CallbackMode = _async.CallbackMode;
const Future = _async.Future;

pub const PowerPreference = enum(u32) {
    @"undefined"        = 0x00000000, // No preference.
    low_power           = 0x00000001,
    high_performance    = 0x00000002,
};

pub const AdapterType = enum(u32) {
    discrete_gpu   = 0x00000001,
    integrated_gpu = 0x00000002,
    cpu            = 0x00000003,
    unknown        = 0x00000004,
};

pub const BackendType = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument
    null         = 0x00000001,
    webgpu       = 0x00000002,
    d3d11        = 0x00000003,
    d3d12        = 0x00000004,
    metal        = 0x00000005,
    vulkan       = 0x00000006,
    opengl       = 0x00000007,
    opengl_es    = 0x00000008,
};

pub const FeatureLevel = enum(u32) {
    compatibility = 0x00000001, // "Compatibility" profile which can be supported on OpenGL ES 3.1.
    core          = 0x00000002, // "Core" profile which can be supported on Vulkan/Metal/D3D12.
};

pub const RequestAdapterOptions = extern struct {
    next_in_chain: ?*const ChainedStruct = null,

    // "Feature level" for the adapter request. If an adapter is returned,
    // it must support the features and limits in the requested feature level.
    //
    // Implementations may ignore FeatureLevel.compatibility and provide FeatureLevel.core instead.
    // FeatureLevel.core is the default in the JS API, but in C, this field is **required** (must not be undefined).
    feature_level: FeatureLevel = FeatureLevel.core,

    power_preference: PowerPreference = PowerPreference.@"undefined",

    // If true, requires the adapter to be a "fallback" adapter as defined by the JS spec.
    // If this is not possible, the request returns null.
    force_fallback_adapter: WGPUBool = @intFromBool(false),

    // If set, requires the adapter to have a particular backend type.
    // If this is not possible, the request returns null.
    backend_type: BackendType = BackendType.@"undefined",

    // If set, requires the adapter to be able to output to a particular surface.
    // If this is not possible, the request returns null.
    compatible_surface: ?*Surface = null,
};

pub const RequestAdapterStatus = enum(u32) {
    success          = 0x00000001,
    instance_dropped = 0x00000002,
    unavailable      = 0x00000003,
    @"error"         = 0x00000004,
    unknown          = 0x00000005,
};

pub const RequestAdapterCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: RequestAdapterCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

// TODO: This should maybe be relocated to instance.zig; it is only used there.
pub const RequestAdapterCallback = *const fn(
    status: RequestAdapterStatus,
    adapter: ?*Adapter,
    message: StringView,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
) callconv(.c) void;

pub const RequestAdapterResponse = struct {
    status: RequestAdapterStatus,
    message: ?[]const u8,
    adapter: ?*Adapter,
};

pub const AdapterInfoProcs = struct {
    pub const FreeMembers = *const fn(AdapterInfo) callconv(.c) void;
};

extern fn wgpuAdapterInfoFreeMembers(adapter_info: AdapterInfo) void;

pub const AdapterInfo = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    vendor: StringView,
    architecture: StringView,
    device: StringView,
    description: StringView,
    backend_type: BackendType,
    adapter_type: AdapterType,
    vendor_id: u32,
    device_id: u32,

    pub inline fn freeMembers(self: AdapterInfo) void {
        wgpuAdapterInfoFreeMembers(self);
    }
};

pub const AdapterProcs = struct {
    pub const GetFeatures = *const fn(*Adapter, *SupportedFeatures) callconv(.c) void;
    pub const GetLimits = *const fn(*Adapter, *Limits) callconv(.c) Status;
    pub const GetInfo = *const fn(*Adapter, *AdapterInfo) callconv(.c) Status;
    pub const HasFeature = *const fn(*Adapter, FeatureName) callconv(.c) WGPUBool;
    pub const RequestDevice = *const fn(*Adapter, ?*const DeviceDescriptor, RequestDeviceCallbackInfo) callconv(.c) Future;
    pub const AddRef = *const fn(*Adapter) callconv(.c) void;
    pub const Release = *const fn(*Adapter) callconv(.c) void;
};

extern fn wgpuAdapterGetFeatures(adapter: *Adapter, features: *SupportedFeatures) void;
extern fn wgpuAdapterGetLimits(adapter: *Adapter, limits: *Limits) Status;
extern fn wgpuAdapterGetInfo(adapter: *Adapter, info: *AdapterInfo) Status;
extern fn wgpuAdapterHasFeature(adapter: *Adapter, feature: FeatureName) WGPUBool;
extern fn wgpuAdapterRequestDevice(adapter: *Adapter, descriptor: ?*const DeviceDescriptor, callback_info: RequestDeviceCallbackInfo) Future;
extern fn wgpuAdapterAddRef(adapter: *Adapter) void;
extern fn wgpuAdapterRelease(adapter: *Adapter) void;

pub const Adapter = opaque{
    pub inline fn getFeatures(self: *Adapter, features: *SupportedFeatures) void {
        wgpuAdapterGetFeatures(self, features);
    }
    pub inline fn getLimits(self: *Adapter, limits: *Limits) Status {
        return wgpuAdapterGetLimits(self, limits);
    }
    pub inline fn getInfo(self: *Adapter, info: *AdapterInfo) Status {
        return wgpuAdapterGetInfo(self, info);
    }
    pub inline fn hasFeature(self: *Adapter, feature: FeatureName) bool {
        return wgpuAdapterHasFeature(self, feature) != 0;
    }

    fn defaultDeviceCallback(status: RequestDeviceStatus, device: ?*Device, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void {
        const ud_response: *RequestDeviceResponse = @ptrCast(@alignCast(userdata1));
        ud_response.* = RequestDeviceResponse {
            .status = status,
            .message = message.toSlice(),
            .device = device,
        };

        const completed: *bool = @ptrCast(@alignCast(userdata2));
        completed.* = true;
    }

    // This is a synchronous wrapper that handles asynchronous (callback) logic.
    // It uses polling to see when the request has been fulfilled, so needs a polling interval parameter.
    pub fn requestDeviceSync(self: *Adapter, instance: *Instance, descriptor: ?*const DeviceDescriptor, polling_interval_nanoseconds: u64) RequestDeviceResponse {
        var response: RequestDeviceResponse = undefined;
        var completed = false;
        const callback_info = RequestDeviceCallbackInfo {
            .callback = defaultDeviceCallback,
            .userdata1 = @ptrCast(&response),
            .userdata2 = @ptrCast(&completed),
        };
        const device_future = wgpuAdapterRequestDevice(self, descriptor, callback_info);

        // TODO: Revisit once Instance.waitAny() is implemented in wgpu-native,
        //       it takes in futures and returns when one of them completes.
        _ = device_future;
        instance.processEvents();
        while(!completed) {
            std.Thread.sleep(polling_interval_nanoseconds);
            instance.processEvents();
        }

        return response;
    }

    pub inline fn requestDevice(self: *Adapter, descriptor: ?*const DeviceDescriptor, callback_info: RequestDeviceCallbackInfo) Future {
        return wgpuAdapterRequestDevice(self, descriptor, callback_info);
    }
    pub inline fn addRef(self: *Adapter) void {
        wgpuAdapterAddRef(self);
    }
    pub inline fn release(self: *Adapter) void {
        wgpuAdapterRelease(self);
    }
};

test "can request device" {
    const testing = @import("std").testing;

    const instance = Instance.create(null);
    const adapter_response = instance.?.requestAdapterSync(null, 200_000_000);
    const adapter: ?*Adapter = switch(adapter_response.status) {
        .success => adapter_response.adapter,
        else => null,
    };
    const device_response = adapter.?.requestDeviceSync(instance.?, null, 200_000_000);
    const device: ?*Device = switch(device_response.status) {
        .success => device_response.device,
        else => null
    };
    try testing.expect(device != null);
}
