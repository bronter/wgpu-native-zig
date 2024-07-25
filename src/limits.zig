const _chained_struct = @import("chained_struct.zig");
const ChainedStructOut = _chained_struct.ChainedStructOut;
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

// A lot of limits used to default to these, but I don't think they're used anymore?
// https://github.com/gfx-rs/wgpu-native/pull/239
pub const WGPU_LIMIT_U32_UNDEFINED = @as(u32, 0xffffffff);
pub const WGPU_LIMIT_U64_UNDEFINED = @as(u64, 0xffffffffffffffff);

pub const Limits = extern struct {
    max_texture_dimension_1d: u32,
    max_texture_dimension_2d: u32,
    max_texture_dimension_3d: u32,
    max_texture_array_layers: u32,
    max_bind_groups: u32,
    max_bind_groups_plus_vertex_buffers: u32,
    max_bindings_per_bind_group: u32,
    max_dynamic_uniform_buffers_per_pipeline_layout: u32,
    max_dynamic_storage_buffers_per_pipeline_layout: u32,
    max_sampled_textures_per_shader_stage: u32,
    max_samplers_per_shader_stage: u32,
    max_storage_buffers_per_shader_stage: u32,
    max_storage_textures_per_shader_stage: u32,
    max_uniform_buffers_per_shader_stage: u32,
    max_uniform_buffer_binding_size: u64,
    max_storage_buffer_binding_size: u64,
    min_uniform_buffer_offset_alignment: u32,
    min_storage_buffer_offset_alignment: u32,
    max_vertex_buffers: u32,
    max_buffer_size: u64,
    max_vertex_attributes: u32,
    max_vertex_buffer_array_stride: u32,
    max_inter_stage_shader_components: u32,
    max_inter_stage_shader_variables: u32,
    max_color_attachments: u32,
    max_color_attachment_bytes_per_sample: u32,
    max_compute_workgroup_storage_size: u32,
    max_compute_invocations_per_workgroup: u32,
    max_compute_workgroup_size_x: u32,
    max_compute_workgroup_size_y: u32,
    max_compute_workgroup_size_z: u32,
    max_compute_workgroups_per_dimension: u32,
};

pub const WGPUNativeLimits = extern struct {
    max_push_constant_size: u32,
    max_non_sampler_bindings: u32,
};

pub const SupportedLimitsExtras = extern struct {
    chain: ChainedStructOut = ChainedStructOut {
        .s_type = SType.supported_limits_extras,
    },
    limits: WGPUNativeLimits,
};

pub const SupportedLimits = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    limits: Limits,

    pub inline fn withNativeLimits(self: SupportedLimits, native_limits: WGPUNativeLimits) SupportedLimits {
        var sl = self;
        sl.next_in_chain = @ptrCast(&SupportedLimitsExtras {
            .limits = native_limits,
        });
        return sl;
    }
};

pub const RequiredLimitsExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.required_limits_extras,
    },
    limits: WGPUNativeLimits,
};

pub const RequiredLimits = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    limits: Limits,

    pub inline fn withNativeLimits(self: RequiredLimits, native_limits: WGPUNativeLimits) RequiredLimits {
        var rl = self;
        rl.next_in_chain = @ptrCast(&RequiredLimitsExtras {
            .limits = native_limits,
        });
        return rl;
    }
};
