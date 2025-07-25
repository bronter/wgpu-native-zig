const std = @import("std");

const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const ChainedStructOut = _chained_struct.ChainedStructOut;
const SType = _chained_struct.SType;

const _adapter = @import("adapter.zig");
const Adapter = _adapter.Adapter;
const RequestAdapterOptions = _adapter.RequestAdapterOptions;
const WGPURequestAdapterOptions = _adapter.WGPURequestAdapterOptions;
const RequestAdapterCallbackInfo = _adapter.RequestAdapterCallbackInfo;
const RequestAdapterCallback = _adapter.RequestAdapterCallback;
const RequestAdapterError = _adapter.RequestAdapterError;
const BackendType = _adapter.BackendType;

const _surface = @import("surface.zig");
const Surface = _surface.Surface;
const SurfaceDescriptor = _surface.SurfaceDescriptor;

const _misc = @import("misc.zig");
const WGPUFlags = _misc.WGPUFlags;
const WGPUBool = _misc.WGPUBool;
const StringView = _misc.StringView;
const Status = _misc.Status;

const _async = @import("async.zig");
const Future = _async.Future;
const WaitStatus = _async.WaitStatus;
const FutureWaitInfo = _async.FutureWaitInfo;
const CallbackMode = _async.CallbackMode;

pub const InstanceBackend = packed struct(WGPUFlags) {
    vulkan: bool = false,
    gl: bool = false,
    metal: bool = false,
    dx12: bool = false,
    dx11: bool = false,
    browser_webgpu: bool = false,
    _: u58 = 0,
    
    pub const all = Instance{};
    pub const primary = InstanceBackend{ .vulkan = true , .metal = true, .dx12 = true, .browser_webgpu = true };
    pub const secondary = InstanceBackend{ .gl = true, .dx11 = true };
};

pub const InstanceFlag = packed struct(WGPUFlags) {
    debug: bool = false,
    validation: bool = false,
    discard_hal_labels: bool = false,
    _: u61 = 0,

    pub const default = InstanceFlag{};
};

pub const Dx12Compiler = enum(u32) {
    @"undefined" = 0x00000000,
    fxc          = 0x00000001,
    dxc          = 0x00000002,
};

pub const Gles3MinorVersion = enum(u32) {
    automatic  = 0x00000000,
    version_0  = 0x00000001,
    version_1  = 0x00000002,
    version_2  = 0x00000003,
};

pub const DxcMaxShaderModel = enum(u32) {
    dxc_max_shader_model_v6_0 = 0x00000000,
    dxc_max_shader_model_v6_1 = 0x00000001,
    dxc_max_shader_model_v6_2 = 0x00000002,
    dxc_max_shader_model_v6_3 = 0x00000003,
    dxc_max_shader_model_v6_4 = 0x00000004,
    dxc_max_shader_model_v6_5 = 0x00000005,
    dxc_max_shader_model_v6_6 = 0x00000006,
    dxc_max_shader_model_v6_7 = 0x00000007,
};

pub const GLFenceBehaviour = enum(u32) {
    gl_fence_behaviour_normal      = 0x00000000,
    gl_fence_behaviour_auto_finish = 0x00000001,
};

pub const InstanceExtras = struct {
    backends: InstanceBackend,
    flags: InstanceFlag,
    dx12_shader_compiler: Dx12Compiler,
    gles3_minor_version: Gles3MinorVersion,
    gl_fence_behavior: GLFenceBehaviour,
    dxil_path: []const u8 = "",
    dxc_path: []const u8 = "",
    dxc_max_shader_model: DxcMaxShaderModel,

    fn toWGPU(self: InstanceExtras) WGPUInstanceExtras {
        return WGPUInstanceExtras {
            .backends = self.backends,
            .flags = self.flags,
            .dx12_shader_compiler = self.dx12_shader_compiler,
            .gles3_minor_version = self.gles3_minor_version,
            .gl_fence_behavior = self.gl_fence_behavior,
            .dxil_path = StringView.fromSlice(self.dxil_path),
            .dxc_path = StringView.fromSlice(self.dxc_path),
            .dxc_max_shader_model = self.dxc_max_shader_model,
        };
    }
};

const WGPUInstanceExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.instance_extras,
    },
    backends: InstanceBackend,
    flags: InstanceFlag,
    dx12_shader_compiler: Dx12Compiler,
    gles3_minor_version: Gles3MinorVersion,
    gl_fence_behavior: GLFenceBehaviour,
    dxil_path: StringView = StringView {},
    dxc_path: StringView = StringView {},
    dxc_max_shader_model: DxcMaxShaderModel,
};

pub const InstanceCapabilities = struct {
    // This struct chain is used as mutable in some places and immutable in others.
    next_in_chain: ?*ChainedStructOut = null,

    // Enable use of Instance.waitAny() with `timeoutNS > 0`.
    timed_wait_any_enable: bool,

    // The maximum number FutureWaitInfo supported in a call to Instance.waitAny() with `timeoutNS > 0`.
    timed_wait_any_max_count: usize,

    fn toWGPU(self: InstanceCapabilities) WGPUInstanceCapabilities {
        return WGPUInstanceCapabilities {
            .timed_wait_any_enable = @intFromBool(self.timed_wait_any_enable),
            .timed_wait_any_max_count = self.timed_wait_any_max_count,
        };
    }
};

const WGPUInstanceCapabilities = extern struct {
    // This struct chain is used as mutable in some places and immutable in others.
    next_in_chain: ?*ChainedStructOut = null,

    // Enable use of ::wgpuInstanceWaitAny with `timeoutNS > 0`.
    timed_wait_any_enable: WGPUBool,

    // The maximum number FutureWaitInfo supported in a call to ::wgpuInstanceWaitAny with `timeoutNS > 0`.
    timed_wait_any_max_count: usize,

    fn toInstanceCapabilities(self: WGPUInstanceCapabilities) InstanceCapabilities {
        return InstanceCapabilities {
            .next_in_chain = self.next_in_chain,
            .timed_wait_any_enable = self.timed_wait_any_enable != 0,
            .timed_wait_any_max_count = self.timed_wait_any_max_count,
        };
    }
};

pub const InstanceDescriptor = struct {
    // Instance features to enable
    features: InstanceCapabilities,
    native_extras: ?InstanceExtras = null,

    fn toWGPU(self: InstanceDescriptor) WGPUInstanceDescriptor {
        var instance_extras: ?*const ChainedStruct = undefined;
        if (self.native_extras) |native_extras| {
            instance_extras = @ptrCast(&native_extras.toWGPU());
        } else {
            instance_extras = null;
        }

        return WGPUInstanceDescriptor {
            .next_in_chain = instance_extras,
            .features = self.features.toWGPU(),
        };
    }
};

const WGPUInstanceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,

    // Instance features to enable
    features: WGPUInstanceCapabilities,
};

pub const WGSLLanguageFeatureName = enum(u32) {
    readonly_and_readwrite_storage_textures = 0x00000001,
    packed4x8_integer_dot_product           = 0x00000002,
    unrestricted_pointer_parameters         = 0x00000003,
    pointer_composite_access                = 0x00000004,
};

extern fn wgpuSupportedWGSLLanguageFeaturesFreeMembers(supported_wgsl_language_features: SupportedWGSLLanguageFeatures) void;

pub const SupportedWGSLLanguageFeatures = struct {
    features: []const WGSLLanguageFeatureName,
};

const WGPUSupportedWGSLLanguageFeatures = extern struct {
    feature_count: usize,
    features: [*]const WGSLLanguageFeatureName,

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L193
    // pub inline fn freeMembers(self: SupportedWGSLLanguageFeatures) void {
    //     wgpuSupportedWGSLLanguageFeaturesFreeMembers(self);
    // }
};

extern fn wgpuGetInstanceCapabilities(capabilities: *WGPUInstanceCapabilities) Status;

extern fn wgpuCreateInstance(descriptor: ?*const WGPUInstanceDescriptor) ?*Instance;
extern fn wgpuInstanceCreateSurface(instance: *Instance, descriptor: *const SurfaceDescriptor) ?*Surface;
extern fn wgpuInstanceGetWGSLLanguageFeatures(instance: *Instance, features: *WGPUSupportedWGSLLanguageFeatures) Status;
extern fn wgpuInstanceHasWGSLLanguageFeature(instance: *Instance, feature: WGSLLanguageFeatureName) WGPUBool;
extern fn wgpuInstanceProcessEvents(instance: *Instance) void;
extern fn wgpuInstanceRequestAdapter(instance: *Instance, options: ?*const WGPURequestAdapterOptions, callback_info: RequestAdapterCallbackInfo) Future;
extern fn wgpuInstanceWaitAny(instance: *Instance, future_count: usize, futures: ?[*] FutureWaitInfo, timeout_ns: u64) WaitStatus;
extern fn wgpuInstanceAddRef(instance: *Instance) void;
extern fn wgpuInstanceRelease(instance: *Instance) void;

pub const RegistryReport = extern struct {
    num_allocated: usize,
    num_kept_from_user: usize,
    num_released_from_user: usize,
    element_size: usize,
};

pub const HubReport = extern struct {
    adapters: RegistryReport,
    devices: RegistryReport,
    queues: RegistryReport,
    pipeline_layouts: RegistryReport,
    shader_modules: RegistryReport,
    bind_group_layouts: RegistryReport,
    bind_groups: RegistryReport,
    command_buffers: RegistryReport,
    render_bundles: RegistryReport,
    render_pipelines: RegistryReport,
    compute_pipelines: RegistryReport,
    pipeline_caches: RegistryReport,
    query_sets: RegistryReport,
    buffers: RegistryReport,
    textures: RegistryReport,
    texture_views: RegistryReport,
    samplers: RegistryReport,
};

pub const GlobalReport = extern struct {
    surfaces: RegistryReport,
    hub: HubReport,
};

pub const EnumerateAdapterOptions = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    backends: InstanceBackend,
};

// wgpu-native
extern fn wgpuGenerateReport(instance: *Instance, report: *GlobalReport) void;
extern fn wgpuInstanceEnumerateAdapters(instance: *Instance, options: ?*EnumerateAdapterOptions, adapters: ?[*]*Adapter) usize;

pub const InstanceError = error {
    FailedToCreateInstance,
    FailedToGetCapabilities,
} || RequestAdapterError || std.mem.Allocator.Error;

pub const Instance = opaque {
    // This is a global function, but it creates an instance so I put it here.
    pub fn create(descriptor: ?InstanceDescriptor) InstanceError!*Instance {
        var maybe_instance: ?*Instance = undefined;
        if (descriptor) |d| {
            maybe_instance = wgpuCreateInstance(&d.toWGPU());
        } else {
            maybe_instance = wgpuCreateInstance(null);
        }

        return maybe_instance orelse InstanceError.FailedToCreateInstance;
    }

    // This is also a global function, but I think it would make sense being a member of Instance;
    // You'd use it like `const capabilities = try Instance.getCapabilities();`
    pub inline fn getCapabilities() InstanceError!InstanceCapabilities {
        var wgpu_capabilities: WGPUInstanceCapabilities = undefined;
        if (wgpuGetInstanceCapabilities(&wgpu_capabilities) == Status.success) {
            return wgpu_capabilities.toInstanceCapabilities();
        } else {
            return InstanceError.FailedToGetCapabilities;
        }
    }

    pub inline fn createSurface(self: *Instance, descriptor: *const SurfaceDescriptor) ?*Surface {
        return wgpuInstanceCreateSurface(self, descriptor);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L100
    // pub inline fn getWGSLLanguageFeatures(self: *Instance, features: *SupportedWGSLLanguageFeatures) Status {
    //     return wgpuInstanceGetWGSLLanguageFeatures(self, features);
    // }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L108
    // pub inline fn hasWGSLLanguageFeature(self: *Instance, feature: WGSLLanguageFeatureName) bool {
    //     return wgpuInstanceHasWGSLLanguageFeature(self, feature) != 0;
    // }

    // Processes asynchronous events on this Instance, calling any callbacks for asynchronous operations created with `CallbackMode.allow_process_events`.
    pub inline fn processEvents(self: *Instance) void {
        wgpuInstanceProcessEvents(self);
    }

    // Meant to be used within requestAdapterSync, though it might be a good default to expose.
    fn defaultAdapterCallback(response: RequestAdapterError!*Adapter, maybe_message: ?[]const u8, userdata: *?RequestAdapterError!*Adapter) void {
        userdata.* = response catch blk: {
            if (maybe_message) |message| {
                std.log.err("{s}\n", .{message});
            }
            break :blk response;
        };
    }

    // This is a synchronous wrapper that handles asynchronous (callback) logic.
    // It uses polling to see when the request has been fulfilled, so needs a polling interval parameter.
    // A polling interval of 0 is valid, and probably what you'd want in most cases.
    pub fn requestAdapterSync(self: *Instance, options: ?RequestAdapterOptions, polling_interval_nanoseconds: u64) InstanceError!*Adapter {
        var adapter_response: ?RequestAdapterError!*Adapter = null;

        const callback_info = RequestAdapterCallbackInfo.init(
            null, 
            &adapter_response,
            defaultAdapterCallback,
        );
        const adapter_future = self.requestAdapter(
            options,
            callback_info,
        );

        // TODO: Revisit once Instance.waitAny() is implemented in wgpu-native,
        //       it takes in futures and returns when one of them completes.
        _ = adapter_future;
        self.processEvents();
        while (adapter_response == null) {
            std.Thread.sleep(polling_interval_nanoseconds);
            self.processEvents();
        }

        return adapter_response.?;
    }


    pub fn requestAdapter(
        self: *Instance,
        options: ?RequestAdapterOptions,
        callback_info: RequestAdapterCallbackInfo,
    ) Future {
        if (options) |o| {
            return wgpuInstanceRequestAdapter(self, &o.toWGPU(), callback_info);
        } else {
            return wgpuInstanceRequestAdapter(self, null, callback_info);
        }
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L224
    // Wait for at least one Future in `futures` to complete, and call callbacks of the respective completed asynchronous operations.
    // pub inline fn waitAny(self: *Instance, future_count: usize, futures: ?[*] FutureWaitInfo, timeout_ns: u64) WaitStatus {
    //     return wgpuInstanceWaitAny(self, future_count, futures, timeout_ns);
    // }

    pub inline fn addRef(self: *Instance) void {
        wgpuInstanceAddRef(self);
    }


    pub inline fn release(self: *Instance) void {
        wgpuInstanceRelease(self);
    }

    // wgpu-native
    pub inline fn generateReport(self: *Instance, report: *GlobalReport) void {
        wgpuGenerateReport(self, report);
    }

    // Allocates memory to store the list of Adapters
    pub inline fn enumerateAdapters(self: *Instance, allocator: std.mem.Allocator, options: ?*EnumerateAdapterOptions) InstanceError![]*Adapter {
        const count = wgpuInstanceEnumerateAdapters(self, options, null);
        const adapters = try allocator.alloc(*Adapter, count);

        // TODO: Should we bother checking the returned count at this point or just trust that it matches what we got in the previous call?
        _ = wgpuInstanceEnumerateAdapters(self, options, adapters.ptr);
        return adapters;
    }
};

test "can create instance (and release it afterwards)" {
    const instance = try Instance.create(null);
    instance.release();
}

test "requestAdapterSync returns adapter" {
    const instance = try Instance.create(null);
    const response = try instance.requestAdapterSync(null, 0);
    _ = response;
}

test "can enumerate adapters" {
    const testing = @import("std").testing;

    const instance = try Instance.create(null);
    const adapters = try instance.enumerateAdapters(testing.allocator, null);
    defer testing.allocator.free(adapters);
    try testing.expect(adapters.len != 0);
}