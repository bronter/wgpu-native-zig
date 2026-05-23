const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const PipelineLayout = @import("pipeline.zig").PipelineLayout;

const _misc = @import("misc.zig");
const WGPUFlags = _misc.WGPUFlags;
const StringView = _misc.StringView;

const _async = @import("async.zig");
const CallbackMode = _async.CallbackMode;
const Future = _async.Future;

pub const ShaderStage = WGPUFlags;
pub const ShaderStages = struct {
    pub const none     = @as(ShaderStage, 0x0000000000000000);
    pub const vertex   = @as(ShaderStage, 0x0000000000000001);
    pub const fragment = @as(ShaderStage, 0x0000000000000002);
    pub const compute  = @as(ShaderStage, 0x0000000000000004);
};

pub const ShaderModuleDescriptor = extern struct {
    next_in_chain: *const ChainedStruct,
    label: StringView = StringView {},
};

// This is specific to wgpu-native (from wgpu.h), and unfortunately it is *NOT* the same thing as ShaderSourceSPIRV
pub const ShaderModuleDescriptorSpirV = extern struct {
    label: StringView = StringView {},
    source_size: u32,
    source: [*]const u32,
};

pub const ShaderSourceSPIRV = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.shader_source_spirv,
    },
    code_size: u32,
    code: [*]const u32,
};
pub const ShaderModuleSPIRVMergedDescriptor = struct {
    label: []const u8 = "",
    code_size: u32,
    code: [*]const u32,
};
pub inline fn shaderModuleSPIRVDescriptor(
    descriptor: ShaderModuleSPIRVMergedDescriptor
) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderSourceSPIRV {
            .code_size = descriptor.code_size,
            .code = descriptor.code,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

pub const ShaderSourceWGSL = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.shader_source_wgsl,
    },
    code: StringView
};
pub const ShaderModuleWGSLMergedDescriptor = struct {
    label: []const u8 = "",
    code: []const u8,
};
pub inline fn shaderModuleWGSLDescriptor(
    descriptor: ShaderModuleWGSLMergedDescriptor,
) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderSourceWGSL {
            .code = StringView.fromSlice(descriptor.code),
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

pub const ShaderDefine = extern struct {
    name: StringView,
    value: StringView,
};
pub const ShaderSourceGLSL = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.shader_source_glsl,
    },
    stage: ShaderStage,
    code: StringView,
    define_count: u32 = 0,
    defines: ?[*]ShaderDefine = null,
};
pub const ShaderModuleGLSLMergedDescriptor = struct {
    label: []const u8 = "",
    stage: ShaderStage,
    code: []const u8,
    define_count: u32 = 0,
    defines: ?[*]ShaderDefine = null,
};
pub inline fn shaderModuleGLSLDescriptor(
    descriptor: ShaderModuleGLSLMergedDescriptor,
) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderSourceGLSL {
            .stage = descriptor.stage,
            .code = StringView.fromSlice(descriptor.code),
            .define_count = descriptor.define_count,
            .defines = descriptor.defines,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

pub const CompilationInfoRequestStatus = enum(u32) {
    success          = 0x00000001,
    instance_dropped = 0x00000002,
    @"error"         = 0x00000003,
    unknown          = 0x00000004,
};

pub const CompilationMessageType = enum(u32) {
    @"error" = 0x00000001,
    warning  = 0x00000002,
    info     = 0x00000003,
};

pub const CompilationMessage = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    message: StringView,

    // Severity level of the message.
    @"type": CompilationMessageType,

    // Line number where the message is attached, starting at 1.
    line_num: u64,

    // Offset in UTF-8 code units (bytes) from the beginning of the line, starting at 1.
    line_pos: u64,

    // Offset in UTF-8 code units (bytes) from the beginning of the shader code, starting at 0.
    offset: u64,

    // Length in UTF-8 code units (bytes) of the span the message corresponds to.
    length: u64,
};

pub const CompilationInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    message_count: usize,
    messages: [*]const CompilationMessage,
};

pub const CompilationInfoCallback = *const fn(status: CompilationInfoRequestStatus, compilationInfo: ?*const CompilationInfo, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const CompilationInfoCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: CompilationInfoCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

pub const ShaderModuleProcs = struct {
    pub const GetCompilationInfo = *const fn(*ShaderModule, CompilationInfoCallbackInfo) callconv(.c) Future;
    pub const SetLabel = *const fn(*ShaderModule, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*ShaderModule) callconv(.c) void;
    pub const Release = *const fn(*ShaderModule) callconv(.c) void;
};

extern fn wgpuShaderModuleGetCompilationInfo(shader_module: *ShaderModule, callback_info: CompilationInfoCallbackInfo) Future;
extern fn wgpuShaderModuleSetLabel(shader_module: *ShaderModule, label: StringView) void;
extern fn wgpuShaderModuleAddRef(shader_module: *ShaderModule) void;
extern fn wgpuShaderModuleRelease(shader_module: *ShaderModule) void;

pub const ShaderModule = opaque {
    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L177
    // pub inline fn getCompilationInfo(self: *ShaderModule, callback_info: CompilationInfoCallbackInfo) Future {
    //     return wgpuShaderModuleGetCompilationInfo(self, callback_info);
    // }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L185
    // pub inline fn setLabel(self: *ShaderModule, label: []const u8) void {
    //     wgpuShaderModuleSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *ShaderModule) void {
        wgpuShaderModuleAddRef(self);
    }
    pub inline fn release(self: *ShaderModule) void {
        wgpuShaderModuleRelease(self);
    }
};