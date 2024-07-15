const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const PipelineLayout = @import("pipeline.zig").PipelineLayout;

const WGPUFlags = @import("misc.zig").WGPUFlags;

pub const ShaderStageFlags = WGPUFlags;
pub const ShaderStage = struct {
    pub const none     = @as(ShaderStageFlags, 0x00000000);
    pub const vertex   = @as(ShaderStageFlags, 0x00000001);
    pub const fragment = @as(ShaderStageFlags, 0x00000002);
    pub const compute  = @as(ShaderStageFlags, 0x00000004);
};

pub const ShaderModuleCompilationHint = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    entry_point: [*:0]const u8,
    layout: *PipelineLayout,
};

pub const ShaderModuleDescriptor = extern struct {
    next_in_chain: *const ChainedStruct,
    label: ?[*:0]const u8 = null,
    hint_count: usize,
    hints: [*]const ShaderModuleCompilationHint,
};

pub const ShaderModuleSPIRVDescriptor = extern struct {
    chain: ChainedStruct,
    code_size: u32,
    code: [*]const u32,
};
pub inline fn shaderModuleSPIRVDescriptor(label: ?[*:0]const u8, hint_count: usize, hints: [*]const ShaderModuleCompilationHint, code_size: u32, code: [*]const u32) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderModuleSPIRVDescriptor {
            .chain = ChainedStruct {
                .next = null,
                .s_type = SType.shader_module_spirv_descriptor,
            },
            .code_size = code_size,
            .code = code,
        }),
        .label = label,
        .hint_count = hint_count,
        .hints = hints,
    };
}

pub const ShaderModuleWGSLDescriptor = extern struct {
    chain: ChainedStruct,
    code: [*:0]const u8,
};
pub inline fn shaderModuleWGSLDescriptor(label: ?[*:0]const u8, hint_count: usize, hints: [*]const ShaderModuleCompilationHint, code: [*:0]const u8) ShaderModuleDescriptor {
    return ShaderModuleDescriptor {
        .next_in_chain = @ptrCast(&ShaderModuleWGSLDescriptor {
            .chain = ChainedStruct {
                .next = null,
                .s_type = SType.shader_module_wgsl_descriptor,
            },
            .code = code,
        }),
        .label = label,
        .hint_count = hint_count,
        .hints = hints,
    };
}

pub const ShaderModule = opaque {
    // TODO: fill in methods
};