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
const WGPUDeviceDescriptor = _device.WGPUDeviceDescriptor;
const WGPUDeviceExtras = _device.WGPUDeviceExtras;
const RequestDeviceCallbackInfo = _device.RequestDeviceCallbackInfo;
const RequestDeviceError = _device.RequestDeviceError;

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
    force_fallback_adapter: bool = false,

    // If set, requires the adapter to have a particular backend type.
    // If this is not possible, the request returns null.
    backend_type: BackendType = BackendType.@"undefined",

    // If set, requires the adapter to be able to output to a particular surface.
    // If this is not possible, the request returns null.
    compatible_surface: ?*Surface = null,

    pub fn toWGPU(self: RequestAdapterOptions) WGPURequestAdapterOptions {
        return WGPURequestAdapterOptions{
            .next_in_chain = self.next_in_chain,
            .feature_level = self.feature_level,
            .power_preference = self.power_preference,
            .force_fallback_adapter = @intFromBool(self.force_fallback_adapter),
            .backend_type = self.backend_type,
            .compatible_surface = self.compatible_surface,
        };
    }
};

pub const WGPURequestAdapterOptions = extern struct {
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

    pub fn toRequestAdapterOptions(self: WGPURequestAdapterOptions) RequestAdapterOptions {
        return RequestAdapterOptions{
            .next_in_chain = self.next_in_chain,
            .feature_level = self.feature_level,
            .power_preference = self.power_preference,
            .force_fallback_adapter = self.force_fallback_adapter != 0,
            .backend_type = self.backend_type,
            .compatible_surface = self.compatible_surface,
        };
    }
};

const RequestAdapterStatus = enum(u32) {
    success          = 0x00000001,
    instance_dropped = 0x00000002,
    unavailable      = 0x00000003,
    @"error"         = 0x00000004,
    unknown          = 0x00000005,
};

pub const RequestAdapterError = error {
    RequestAdapterInstanceDropped,
    RequestAdapterUnavailable,
    RequestAdapterError,
    RequestAdapterUnknown,
};

pub const RequestAdapterCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: RequestAdapterCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,

    pub fn init(
        mode: ?CallbackMode,
        userdata: anytype,
        callback: *const fn(RequestAdapterError!*Adapter, message: ?[]const u8, _userdata: @TypeOf(userdata)) void,
    ) RequestAdapterCallbackInfo {
        const UserDataType = @TypeOf(userdata);
        const CallbackType = @TypeOf(callback);
        if (@typeInfo(UserDataType) != .pointer) {
            @compileError("userdata should be a pointer type");
        }
        const Trampoline = struct {
            fn cb(status: RequestAdapterStatus, adapter: ?*Adapter, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.C) void {
                const wrapped_callback: CallbackType = @ptrCast(userdata2);
                const _userdata: UserDataType = @ptrCast(@alignCast(userdata1));
                const response: RequestAdapterError!*Adapter = switch (status) {
                    .success => adapter.?,
                    .instance_dropped => RequestAdapterError.RequestAdapterInstanceDropped,
                    .unavailable => RequestAdapterError.RequestAdapterUnavailable,
                    .@"error" => RequestAdapterError.RequestAdapterError,
                    .unknown => RequestAdapterError.RequestAdapterUnknown,
                };
                wrapped_callback(response, message.toSlice(), _userdata);
            }
        };

        return RequestAdapterCallbackInfo {
            // TODO: Revisit this default if/when Instance.waitAny() is implemented.
            .mode = mode orelse CallbackMode.allow_process_events,

            .callback = Trampoline.cb,
            .userdata1 = @ptrCast(userdata),
            .userdata2 = @constCast(@ptrCast(callback)),
        };
    }
};

// TODO: This should maybe be relocated to instance.zig; it is only used there.
pub const RequestAdapterCallback = *const fn(
    status: RequestAdapterStatus,
    adapter: ?*Adapter,
    message: StringView,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
) callconv(.C) void;


extern fn wgpuAdapterInfoFreeMembers(adapter_info: WGPUAdapterInfo) void;

pub const AdapterInfo = struct {
    next_in_chain: ?*ChainedStructOut = null,
    vendor: ?[]const u8,
    architecture: ?[]const u8,
    device: ?[]const u8,
    description: ?[]const u8,
    backend_type: BackendType,
    adapter_type: AdapterType,
    vendor_id: u32,
    device_id: u32,

    pub inline fn freeMembers(self: AdapterInfo) void {
        wgpuAdapterInfoFreeMembers(WGPUAdapterInfo{
            .next_in_chain = self.next_in_chain,
            .vendor = .fromSlice(self.vendor),
            .architecture = .fromSlice(self.architecture),
            .device = .fromSlice(self.device),
            .description = .fromSlice(self.description),
            .backend_type = self.backend_type,
            .adapter_type = self.adapter_type,
            .vendor_id = self.vendor_id,
            .device_id = self.device_id,
        });
    }
};

pub const WGPUAdapterInfo = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    vendor: StringView,
    architecture: StringView,
    device: StringView,
    description: StringView,
    backend_type: BackendType,
    adapter_type: AdapterType,
    vendor_id: u32,
    device_id: u32,

    pub inline fn freeMembers(self: WGPUAdapterInfo) void {
        wgpuAdapterInfoFreeMembers(self);
    }
};

extern fn wgpuAdapterGetFeatures(adapter: *Adapter, features: *SupportedFeatures) void;
extern fn wgpuAdapterGetLimits(adapter: *Adapter, limits: *Limits) Status;
extern fn wgpuAdapterGetInfo(adapter: *Adapter, info: *WGPUAdapterInfo) Status;
extern fn wgpuAdapterHasFeature(adapter: *Adapter, feature: FeatureName) WGPUBool;
extern fn wgpuAdapterRequestDevice(adapter: *Adapter, descriptor: ?*const WGPUDeviceDescriptor, callback_info: RequestDeviceCallbackInfo) Future;
extern fn wgpuAdapterAddRef(adapter: *Adapter) void;
extern fn wgpuAdapterRelease(adapter: *Adapter) void;

pub const AdapterError = error {
    FailedToGetLimits,
    FailedToGetInfo,
} || RequestDeviceError || std.mem.Allocator.Error;

pub const Adapter = opaque{
    pub inline fn getFeatures(self: *Adapter, allocator: std.mem.Allocator) AdapterError![]FeatureName {
        var features: SupportedFeatures = undefined;
        defer features.freeMembers();

        wgpuAdapterGetFeatures(self, &features);
        
        return try allocator.dupe(FeatureName, features.features[0..features.feature_count]);
    }
    pub inline fn getLimits(self: *Adapter) AdapterError!Limits {
        var limits = Limits{};
        if(wgpuAdapterGetLimits(self, &limits) == .@"error")
            return error.FailedToGetLimits;
        return limits;
    }
    pub inline fn getInfo(self: *Adapter) AdapterError!AdapterInfo {
        var adapter_info = WGPUAdapterInfo{};
        if(wgpuAdapterGetInfo(self, &adapter_info) == .@"error")
            return error.FailedToGetAdapterInfo;
        return AdapterInfo{
            .next_in_chain = adapter_info.next_in_chain,
            .vendor = adapter_info.vendor.toSlice(),
            .architecture = adapter_info.architecture.toSlice(),
            .device = adapter_info.device.toSlice(),
            .description = adapter_info.description.toSlice(),
            .backend_type = adapter_info.backend_type,
            .adapter_type = adapter_info.adapter_type,
            .vendor_id = adapter_info.vendor_id,
            .device_id = adapter_info.device_id,
        };
    }
    pub inline fn hasFeature(self: *Adapter, feature: FeatureName) bool {
        return wgpuAdapterHasFeature(self, feature) != 0;
    }

    fn defaultDeviceCallback(response: RequestDeviceError!*Device, maybe_message: ?[]const u8, userdata: *?RequestDeviceError!*Device) void {
        userdata.* = response catch blk: {
            if (maybe_message) |message| {
                std.log.err("{s}\n", .{message});
            }
            break :blk response;
        };
    }

    // This is a synchronous wrapper that handles asynchronous (callback) logic.
    // It uses polling to see when the request has been fulfilled, so needs a polling interval parameter.
    pub fn requestDeviceSync(self: *Adapter, instance: *Instance, descriptor: ?DeviceDescriptor, polling_interval_nanoseconds: u64) AdapterError!*Device {
        var device_response: ?RequestDeviceError!*Device = null;

        const callback_info = RequestDeviceCallbackInfo.init(
            null,
            &device_response,
            defaultDeviceCallback,
        );
        const device_future = self.requestDevice(
            descriptor,
            callback_info,
        );

        // TODO: Revisit once Instance.waitAny() is implemented in wgpu-native,
        //       it takes in futures and returns when one of them completes.
        _ = device_future;
        instance.processEvents();
        while (device_response == null) {
            std.Thread.sleep(polling_interval_nanoseconds);
            instance.processEvents();
        }

        return device_response.?;
    }

    pub fn requestDevice(
        self: *Adapter,
        descriptor: ?DeviceDescriptor,
        callback_info: RequestDeviceCallbackInfo,
    ) Future {
        if(descriptor) |d| {
            return wgpuAdapterRequestDevice(self, &d.toWGPU(), callback_info);
        } else {
            return wgpuAdapterRequestDevice(self, null, callback_info);
        }
    }

    pub inline fn addRef(self: *Adapter) void {
        wgpuAdapterAddRef(self);
    }
    pub inline fn release(self: *Adapter) void {
        wgpuAdapterRelease(self);
    }
};

test "can request device" {
    const instance = try Instance.create(null);
    const adapter = try instance.requestAdapterSync(null, 0);
    const device = try adapter.requestDeviceSync(instance, null, 0);
    _ = device;
}

test "can request device with descriptor" {
    const instance = try Instance.create(null);
    const adapter = try instance.requestAdapterSync(null, 0);

    const allocator = std.testing.allocator;
    const required_features = try adapter.getFeatures(allocator);
    defer allocator.free(required_features);

    const limits = try adapter.getLimits(); 

    const descriptor = DeviceDescriptor {
        .label = "test device",
        .required_features = required_features,
        .required_limits = limits,
        .native_extras = .{
            .trace_path = "./device_trace",
        },
        .default_queue = .{
            // TODO: Will need to revisit this after refactoring QueueDescriptor
            .label = StringView.fromSlice("test queue"),
        },

        .device_lost_callback_info = .{},
        .uncaptured_error_callback_info = .{},
    };

    const device = try adapter.requestDeviceSync(instance, descriptor, 0);

    _ = device;
}