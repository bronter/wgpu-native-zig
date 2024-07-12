const ChainedStructOut = @import("chained_struct.zig").ChainedStructOut;

pub const WGPUBool = u32;

// Used by both device and adapter
// FeatureName, Limits, and SupportedLimits are clearly related
// but idk if they should go in device.zig, adapter.zig, or their own separate file.
// So they're going in the "miscellaneous" pile for now.
pub const FeatureName = enum(u32) {
    undefined                  = 0x00000000,
    depth_clip_control         = 0x00000001,
    depth32_float_stencil8     = 0x00000002,
    timestamp_query            = 0x00000003,
    texture_compression_bc     = 0x00000004,
    texture_compression_etc2   = 0x00000005,
    texture_compression_astc   = 0x00000006,
    indirect_first_instance    = 0x00000007,
    shader_f16                 = 0x00000008,
    rg11b10_ufloat_renderable  = 0x00000009,
    bgra8_unorm_storage        = 0x0000000A,
    float32_filterable         = 0x0000000B,
};
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
pub const SupportedLimits = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    limits: Limits,
};
