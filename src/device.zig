const std = @import("std");

const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const FeatureName = _misc.FeatureName;
const StringView = _misc.StringView;
const Status = _misc.Status;
const SupportedFeatures = _misc.SupportedFeatures;

const _async = @import("async.zig");
const CallbackMode = _async.CallbackMode;
const Future = _async.Future;

const _limits = @import("limits.zig");
const Limits = _limits.Limits;

const AdapterInfo = @import("adapter.zig").AdapterInfo;

const _bind_group = @import("bind_group.zig");
const BindGroupDescriptor = _bind_group.BindGroupDescriptor;
const BindGroup = _bind_group.BindGroup;
const BindGroupLayoutDescriptor = _bind_group.BindGroupLayoutDescriptor;
const BindGroupLayout = _bind_group.BindGroupLayout;

const _buffer = @import("buffer.zig");
const BufferDescriptor = _buffer.BufferDescriptor;
const Buffer = _buffer.Buffer;

const _queue = @import("queue.zig");
const QueueDescriptor = _queue.QueueDescriptor;
const Queue = _queue.Queue;
const SubmissionIndex = _queue.SubmissionIndex;

const _command_encoder = @import("command_encoder.zig");
const CommandEncoderDescriptor = _command_encoder.CommandEncoderDescriptor;
const CommandEncoder = _command_encoder.CommandEncoder;

const _pipeline = @import("pipeline.zig");
const ComputePipelineDescriptor = _pipeline.ComputePipelineDescriptor;
const ComputePipeline = _pipeline.ComputePipeline;
const CreateComputePipelineAsyncCallbackInfo = _pipeline.CreateComputePipelineAsyncCallbackInfo;
const PipelineLayoutDescriptor = _pipeline.PipelineLayoutDescriptor;
const PipelineLayout = _pipeline.PipelineLayout;
const RenderPipelineDescriptor = _pipeline.RenderPipelineDescriptor;
const RenderPipeline = _pipeline.RenderPipeline;
const CreateRenderPipelineAsyncCallbackInfo = _pipeline.CreateRenderPipelineAsyncCallbackInfo;

const _query_set = @import("query_set.zig");
const QuerySetDescriptor = _query_set.QuerySetDescriptor;
const QuerySet = _query_set.QuerySet;

const _render_bundle = @import("render_bundle.zig");
const RenderBundleEncoderDescriptor = _render_bundle.RenderBundleEncoderDescriptor;
const RenderBundleEncoder = _render_bundle.RenderBundleEncoder;

const _sampler = @import("sampler.zig");
const SamplerDescriptor = _sampler.SamplerDescriptor;
const Sampler = _sampler.Sampler;

const _shader = @import("shader.zig");
const ShaderModuleDescriptor = _shader.ShaderModuleDescriptor;
const ShaderModuleDescriptorSpirV =_shader.ShaderModuleDescriptorSpirV;
const ShaderModule = _shader.ShaderModule;

const _texture = @import("texture.zig");
const TextureDescriptor = _texture.TextureDescriptor;
const Texture = _texture.Texture;

pub const DeviceLostReason = enum(u32) {
    unknown          = 0x00000001,
    destroyed        = 0x00000002,
    instance_dropped = 0x00000003,
    failed_creation  = 0x00000004,
};

pub const DeviceLostCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // Apparently in the webgpu header this has no (valid) default: https://github.com/webgpu-native/webgpu-headers/pull/471
    // As of wgpu-native v24.0.3.1, Instance.waitAny() has not been implemented, but Instance.processEvents() has,
    // so the safest mode to use currently is probably CallbackMode.allow_process_events.
    // If you really know what you're doing, CallbackMode.allow_spontaneous could also work as an option here.
    // TODO: Revisit this if/when Instance.waitAny() is implemented in wgpu-native
    mode: CallbackMode = CallbackMode.allow_process_events,
    callback: DeviceLostCallback = defaultDeviceLostCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

// `device` is a reference to the device which was lost. If, and only if, the `reason` is DeviceLostReason.failed_creation, `device` is a non-null pointer to a null Device.
pub const DeviceLostCallback = *const fn(device: *const ?*Device, reason: DeviceLostReason, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;
pub fn defaultDeviceLostCallback(device: *const ?*Device, reason: DeviceLostReason, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void {
    _ = device;
    _ = userdata1;
    _ = userdata2;

    // Without a device you can't really do much of anything, so do a panic here by default.
    // For better error handling, implement DeviceLostCallback with your own error handling logic.
    // Remember you can pass pointers in through the userdata fields of the DeviceLostCallbackInfo struct;
    // you could pass in a simple pointer to a bool or something more complex like a struct.
    std.debug.panic("Device lost: reason={s} message=\"{s}\"\n", .{ @tagName(reason), message.toSlice() orelse "" });
}

pub const DeviceExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.device_extras,
    },
    trace_path: StringView,
};

pub const ErrorType = enum(u32) {
    no_error      = 0x00000001,
    validation    = 0x00000002,
    out_of_memory = 0x00000003,
    internal      = 0x00000004,
    unknown       = 0x00000005,
};

pub const UncapturedErrorCallback = *const fn(device: ?*Device, error_type: ErrorType, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const ErrorFilter = enum(u32) {
    validation    = 0x00000001,
    out_of_memory = 0x00000002,
    internal      = 0x00000003,
};

pub const UncapturedErrorCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    callback: ?UncapturedErrorCallback = null,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

pub const DeviceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    required_feature_count: usize = 0,
    required_features: [*]const FeatureName = &[0]FeatureName {},
    required_limits: ?*const Limits,
    default_queue: QueueDescriptor = QueueDescriptor{},
    device_lost_callback_info: DeviceLostCallbackInfo = DeviceLostCallbackInfo {},
    uncaptured_error_callback_info: UncapturedErrorCallbackInfo = UncapturedErrorCallbackInfo{},

    pub inline fn withTracePath(self: DeviceDescriptor, trace_path: []const u8) DeviceDescriptor {
        var dd = self;
        dd.next_in_chain = @ptrCast(&DeviceExtras {
            .trace_path = StringView.fromSlice(trace_path),
        });
        return dd;
    }
};

pub const RequestDeviceStatus = enum(u32) {
    success          = 0x00000001,
    instance_dropped = 0x00000002,
    @"error"         = 0x00000003,
    unknown          = 0x00000004,
};

// TODO: This probably belongs in adapter.zig
pub const RequestDeviceCallback = *const fn(
    status: RequestDeviceStatus, 
    device: ?*Device,
    message: StringView,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque
) callconv(.c) void;

pub const RequestDeviceResponse = struct {
    status: RequestDeviceStatus,
    message: ?[]const u8,
    device: ?*Device,
};

pub const RequestDeviceCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: RequestDeviceCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

pub const PopErrorScopeStatus = enum(u32) {
    success          = 0x00000001, // The error scope stack was successfully popped and a result was reported.
    instance_dropped = 0x00000002,
    empty_stack      = 0x00000003, // The error scope stack could not be popped, because it was empty.
};

// status
// See PopErrorScopeStatus.
//
// error_type
// The type of the error caught by the scope, or ErrorType.no_error if there was none.
// If the `status` is not PopErrorScopeStatus.success, this is ErrorType.no_error.
//
// message
// If the `type` is not ErrorType.no_error, this is a non-empty string;
// otherwise, this is an empty string.
//
pub const PopErrorScopeCallback = *const fn(
    status: PopErrorScopeStatus,
    error_type: ErrorType,
    message: StringView,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
) callconv(.c) void;

pub const PopErrorScopeCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: PopErrorScopeCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

pub const DeviceProcs = struct {
    pub const CreateBindGroup = *const fn(*Device, *const BindGroupDescriptor) callconv(.c) ?*BindGroup;
    pub const CreateBindGroupLayout = *const fn(*Device, *const BindGroupLayoutDescriptor) callconv(.c) ?*BindGroupLayout;
    pub const CreateBuffer = *const fn(*Device, *const BufferDescriptor) callconv(.c) ?*Buffer;
    pub const CreateCommandEncoder = *const fn(*Device, *const CommandEncoderDescriptor) callconv(.c) ?*CommandEncoder;
    pub const CreateComputePipeline = *const fn(*Device, *const ComputePipelineDescriptor) callconv(.c) ?*ComputePipeline;
    pub const CreateComputePipelineAsync = *const fn(*Device, *const ComputePipelineDescriptor, CreateComputePipelineAsyncCallbackInfo) callconv(.c) Future;
    pub const CreatePipelineLayout = *const fn(*Device, *const PipelineLayoutDescriptor) callconv(.c) ?*PipelineLayout;
    pub const CreateQuerySet = *const fn(*Device, *const QuerySetDescriptor) callconv(.c) ?*QuerySet;
    pub const CreateRenderBundleEncoder = *const fn(*Device, *const RenderBundleEncoderDescriptor) callconv(.c) ?*RenderBundleEncoder;
    pub const CreateRenderPipeline = *const fn(*Device, *const RenderPipelineDescriptor) callconv(.c) ?*RenderPipeline;
    pub const CreateRenderPipelineAsync = *const fn(*Device, *const RenderPipelineDescriptor, CreateRenderPipelineAsyncCallbackInfo) callconv(.c) Future;
    pub const CreateSampler = *const fn(*Device, *const SamplerDescriptor) callconv(.c) ?*Sampler;
    pub const CreateShaderModule = *const fn(*Device, *const ShaderModuleDescriptor) callconv(.c) ?*ShaderModule;
    pub const CreateTexture = *const fn(*Device, *const TextureDescriptor) callconv(.c) ?*Texture;
    pub const Destroy = *const fn(*Device) callconv(.c) void;
    pub const GetAdapterInfo = *const fn(*Device) callconv(.c) AdapterInfo;
    pub const GetFeatures = *const fn(*Device, *SupportedFeatures) callconv(.c) void;
    pub const GetLimits = *const fn(*Device, *Limits) callconv(.c) Status;
    pub const GetLostFuture = *const fn(*Device) callconv(.c) Future;
    pub const GetQueue = *const fn(*Device) callconv(.c) ?*Queue;
    pub const HasFeature = *const fn(*Device, FeatureName) callconv(.c) WGPUBool;
    pub const PopErrorScope = *const fn(*Device, PopErrorScopeCallbackInfo) callconv(.c) Future;
    pub const PushErrorScope = *const fn(*Device, ErrorFilter) callconv(.c) void;
    pub const SetLabel = *const fn(*Device, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*Device) callconv(.c) void;
    pub const Release = *const fn(*Device) callconv(.c) void;

    // wgpu-native procs?
    // pub const Poll = *const fn(*Device, WGPUBool, ?*const SubmissionIndex) callconv(.c) WGPUBool;
    // pub const CreateShaderModuleSpirV = *const fn(*Device, *const ShaderModuleDescriptorSpirV) callconv(.c) ?*ShaderModule;
};

extern fn wgpuDeviceCreateBindGroup(device: *Device, descriptor: *const BindGroupDescriptor) ?*BindGroup;
extern fn wgpuDeviceCreateBindGroupLayout(device: *Device, descriptor: *const BindGroupLayoutDescriptor) ?*BindGroupLayout;
extern fn wgpuDeviceCreateBuffer(device: *Device, descriptor: *const BufferDescriptor) ?*Buffer;
extern fn wgpuDeviceCreateCommandEncoder(device: *Device, descriptor: *const CommandEncoderDescriptor) ?*CommandEncoder;
extern fn wgpuDeviceCreateComputePipeline(device: *Device, descriptor: *const ComputePipelineDescriptor) ?*ComputePipeline;
extern fn wgpuDeviceCreateComputePipelineAsync(device: *Device, descriptor: *const ComputePipelineDescriptor, callback_info: CreateComputePipelineAsyncCallbackInfo) Future;
extern fn wgpuDeviceCreatePipelineLayout(device: *Device, descriptor: *const PipelineLayoutDescriptor) ?*PipelineLayout;
extern fn wgpuDeviceCreateQuerySet(device: *Device, descriptor: *const QuerySetDescriptor) ?*QuerySet;
extern fn wgpuDeviceCreateRenderBundleEncoder(device: *Device, descriptor: *const RenderBundleEncoderDescriptor) ?*RenderBundleEncoder;
extern fn wgpuDeviceCreateRenderPipeline(device: *Device, descriptor: *const RenderPipelineDescriptor) ?*RenderPipeline;
extern fn wgpuDeviceCreateRenderPipelineAsync(device: *Device, descriptor: *const RenderPipelineDescriptor, callback_info: CreateRenderPipelineAsyncCallbackInfo) Future;
extern fn wgpuDeviceCreateSampler(device: *Device, descriptor: *const SamplerDescriptor) ?*Sampler;
extern fn wgpuDeviceCreateShaderModule(device: *Device, descriptor: *const ShaderModuleDescriptor) ?*ShaderModule;
extern fn wgpuDeviceCreateTexture(device: *Device, descriptor: *const TextureDescriptor) ?*Texture;
extern fn wgpuDeviceDestroy(device: *Device) void;
extern fn wgpuDeviceGetAdapterInfo(device: *Device) AdapterInfo;
extern fn wgpuDeviceGetFeatures(device: *Device, features: *SupportedFeatures) void;
extern fn wgpuDeviceGetLimits(device: *Device, limits: *Limits) Status;
extern fn wgpuDeviceGetLostFuture(device: *Device) Future;
extern fn wgpuDeviceGetQueue(device: *Device) ?*Queue;
extern fn wgpuDeviceHasFeature(device: *Device, feature: FeatureName) WGPUBool;
extern fn wgpuDevicePopErrorScope(device: *Device, callback_info: PopErrorScopeCallbackInfo) Future;
extern fn wgpuDevicePushErrorScope(device: *Device, filter: ErrorFilter) void;
extern fn wgpuDeviceSetLabel(device: *Device, label: StringView) void;
extern fn wgpuDeviceAddRef(device: *Device) void;
extern fn wgpuDeviceRelease(device: *Device) void;

// wgpu-native
extern fn wgpuDevicePoll(device: *Device, wait: WGPUBool, submission_index: ?*const SubmissionIndex) WGPUBool;
extern fn wgpuDeviceCreateShaderModuleSpirV(device: *Device, descriptor: *const ShaderModuleDescriptorSpirV) ?*ShaderModule;

pub const Device = opaque {
    pub inline fn createBindGroup(self: *Device, descriptor: *const BindGroupDescriptor) ?*BindGroup {
        return wgpuDeviceCreateBindGroup(self, descriptor);
    }
    pub inline fn createBindGroupLayout(self: *Device, descriptor: *const BindGroupLayoutDescriptor) ?*BindGroupLayout {
        return wgpuDeviceCreateBindGroupLayout(self, descriptor);
    }
    pub inline fn createBuffer(self: *Device, descriptor: *const BufferDescriptor) ?*Buffer {
        return wgpuDeviceCreateBuffer(self, descriptor);
    }
    pub inline fn createCommandEncoder(self: *Device, descriptor: *const CommandEncoderDescriptor) ?*CommandEncoder {
        return wgpuDeviceCreateCommandEncoder(self, descriptor);
    }
    pub inline fn createComputePipeline(self: *Device, descriptor: *const ComputePipelineDescriptor) ?*ComputePipeline {
        return wgpuDeviceCreateComputePipeline(self, descriptor);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L67
    // pub inline fn createComputePipelineAsync(self: *Device, descriptor: *const ComputePipelineDescriptor, callback_info: CreateComputePipelineAsyncCallbackInfo) Future {
    //     return wgpuDeviceCreateComputePipelineAsync(self, descriptor, callback_info);
    // }

    pub inline fn createPipelineLayout(self: *Device, descriptor: *const PipelineLayoutDescriptor) ?*PipelineLayout {
        return wgpuDeviceCreatePipelineLayout(self, descriptor);
    }
    pub inline fn createQuerySet(self: *Device, descriptor: *const QuerySetDescriptor) ?*QuerySet {
        return wgpuDeviceCreateQuerySet(self, descriptor);
    }
    pub inline fn createRenderBundleEncoder(self: *Device, descriptor: *const RenderBundleEncoderDescriptor) ?*RenderBundleEncoder {
        return wgpuDeviceCreateRenderBundleEncoder(self, descriptor);
    }
    pub inline fn createRenderPipeline(self: *Device, descriptor: *const RenderPipelineDescriptor) ?*RenderPipeline {
        return wgpuDeviceCreateRenderPipeline(self, descriptor);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L76
    // pub inline fn createRenderPipelineAsync(self: *Device, descriptor: *const RenderPipelineDescriptor, callback_info: CreateRenderPipelineAsyncCallbackInfo) Future {
    //     return wgpuDeviceCreateRenderPipelineAsync(self, descriptor, callback_info);
    // }

    pub inline fn createSampler(self: *Device, descriptor: *const SamplerDescriptor) ?*Sampler {
        return wgpuDeviceCreateSampler(self, descriptor);
    }
    pub inline fn createShaderModule(self: *Device, descriptor: *const ShaderModuleDescriptor) ?*ShaderModule {
        return wgpuDeviceCreateShaderModule(self, descriptor);
    }
    pub inline fn createTexture(self: *Device, descriptor: *const TextureDescriptor) ?*Texture {
        return wgpuDeviceCreateTexture(self, descriptor);
    }
    pub inline fn destroy(self: *Device) void {
        wgpuDeviceDestroy(self);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L85
    // pub inline fn getAdapterInfo(self: *Device) AdapterInfo {
    //     return wgpuDeviceGetAdapterInfo(self);
    // }

    pub inline fn getFeatures(self: *Device, features: *SupportedFeatures) void {
        wgpuDeviceGetFeatures(self, features);
    }
    pub inline fn getLimits(self: *Device, limits: *Limits) Status {
        return wgpuDeviceGetLimits(self, limits);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L90
    // Returns the Future for the device-lost event of the device.
    // pub inline fn getLostFuture(self: *Device) Future {
    //     return wgpuDeviceGetLostFuture(self);
    // }

    pub inline fn getQueue(self: *Device) ?*Queue {
        return wgpuDeviceGetQueue(self);
    }
    pub inline fn hasFeature(self: *Device, feature: FeatureName) WGPUBool {
        return wgpuDeviceHasFeature(self, feature);
    }

    pub inline fn popErrorScope(self: *Device, callback_info: PopErrorScopeCallbackInfo) Future {
        return wgpuDevicePopErrorScope(self, callback_info);
    }
    pub inline fn pushErrorScope(self: *Device, filter: ErrorFilter) void {
        wgpuDevicePushErrorScope(self, filter);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L95
    // pub inline fn setLabel(self: *Device, label: []const u8) void {
    //     wgpuDeviceSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *Device) void {
        wgpuDeviceAddRef(self);
    }
    pub inline fn release(self: *Device) void {
        wgpuDeviceRelease(self);
    }

    // wgpu-native
    pub inline fn poll(self: *Device, wait: bool, submission_index: ?*const SubmissionIndex) bool {
        return wgpuDevicePoll(self, @intFromBool(wait), submission_index) != 0;
    }
    pub inline fn createShaderModuleSpirV(self: *Device, descriptor: *const ShaderModuleDescriptorSpirV) ?*ShaderModule {
        return wgpuDeviceCreateShaderModuleSpirV(self, descriptor);
    }
};

// TODO: Test methods of Device (as long as they can be tested headlessly: see https://eliemichel.github.io/LearnWebGPU/advanced-techniques/headless.html)