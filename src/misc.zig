pub const WGPUBool = u32;
pub const WGPUFlags = u32;

// Used by both device and adapter
// FeatureName, Limits, and SupportedLimits are clearly related
// but idk if they should go in device.zig, adapter.zig, or their own separate file.
// So they're going in the "miscellaneous" pile for now.
pub const FeatureName = enum(u32) {
    @"undefined"                                                  = 0x00000000,
    depth_clip_control                                            = 0x00000001,
    depth32_float_stencil8                                        = 0x00000002,
    timestamp_query                                               = 0x00000003,
    texture_compression_bc                                        = 0x00000004,
    texture_compression_etc2                                      = 0x00000005,
    texture_compression_astc                                      = 0x00000006,
    indirect_first_instance                                       = 0x00000007,
    shader_f16                                                    = 0x00000008,
    rg11b10_ufloat_renderable                                     = 0x00000009,
    bgra8_unorm_storage                                           = 0x0000000A,
    float32_filterable                                            = 0x0000000B,

    // wgpu-native extras
    push_constants                                                = 0x00030001,
    texture_adapter_specific_format_features                      = 0x00030002,
    multi_draw_indirect                                           = 0x00030003,
    multi_draw_indirect_count                                     = 0x00030004,
    vertex_writable_storage                                       = 0x00030005,
    texture_binding_array                                         = 0x00030006,
    sampled_texture_and_storage_buffer_array_non_uniform_indexing = 0x00030007,
    pipeline_statistics_query                                     = 0x00030008,
    storage_resource_binding_array                                = 0x00030009,
    partially_bound_binding_array                                 = 0x0003000A,
};

pub const IndexFormat = enum(u32) {
    @"undefined" = 0x00000000,
    uint16       = 0x00000001,
    uint32       = 0x00000002,
};

pub const CompareFunction = enum(u32) {
    @"undefined"  = 0x00000000,
    never         = 0x00000001,
    less          = 0x00000002,
    less_equal    = 0x00000003,
    greater       = 0x00000004,
    greater_equal = 0x00000005,
    equal         = 0x00000006,
    not_equal     = 0x00000007,
    always        = 0x00000008,
};

extern fn wgpuGetVersion() callconv(.C) u32;
pub inline fn getVersion() u32 {
    return wgpuGetVersion();
}