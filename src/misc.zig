const std = @import("std");

pub const U32_MAX: u32 = std.math.maxInt(u32);
pub const U64_MAX: u64 = std.math.maxInt(u64);
pub const USIZE_MAX: usize = std.math.maxInt(usize);

pub const WGPU_WHOLE_SIZE = U64_MAX;

pub const WGPUBool = u32;
pub const WGPUFlags = u64;

// Status code returned (synchronously) from many operations.
// Generally indicates an invalid input like an unknown enum value or OutStructChainError.
pub const Status = enum(u32) {
    success  = 0x00000001,
    @"error" = 0x00000002,
};

pub const OptionalBool = enum(u32) {
    false        = 0x00000000,
    true         = 0x00000001,
    @"undefined" = 0x00000002,
};

// Used by both device and adapter
// FeatureName and Limits are clearly related
// but idk if they should go in device.zig, adapter.zig, or their own separate file.
// So they're going in the "miscellaneous" pile for now.
pub const FeatureName = enum(u32) {
    @"undefined"                                                  = 0x00000000,
    depth_clip_control                                            = 0x00000001,
    depth32_float_stencil8                                        = 0x00000002,
    timestamp_query                                               = 0x00000003,
    texture_compression_bc                                        = 0x00000004,
    texture_compression_bc_sliced_3d                              = 0x00000005,
    texture_compression_etc2                                      = 0x00000006,
    texture_compression_astc                                      = 0x00000007,
    texture_compression_astc_sliced_3d                            = 0x00000008,
    indirect_first_instance                                       = 0x00000009,
    shader_f16                                                    = 0x0000000A,
    rg11b10_ufloat_renderable                                     = 0x0000000B,
    bgra8_unorm_storage                                           = 0x0000000C,
    float32_filterable                                            = 0x0000000D,
    float32_blendable                                             = 0x0000000E,
    clip_distances                                                = 0x0000000F,
    dual_source_blending                                          = 0x00000010,

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
    texture_format_16bit_norm                                     = 0x0003000B,
    texture_compression_astc_hdr                                  = 0x0003000C,
    mappable_primary_buffers                                      = 0x0003000E,
    buffer_binding_array                                          = 0x0003000F,
    uniform_buffer_and_storage_texture_array_non_uniform_indexing = 0x00030010,
    spirv_shader_passthrough                                      = 0x00030017,
    vertex_attribute_64bit                                        = 0x00030019,
    texture_format_nv12                                           = 0x0003001A,
    ray_tracing_acceleration_structure                            = 0x0003001B,
    ray_query                                                     = 0x0003001C,
    shader_f64                                                    = 0x0003001D,
    shader_i16                                                    = 0x0003001E,
    shader_primitive_index                                        = 0x0003001F,
    shader_early_depth_test                                       = 0x00030020,
    subgroup                                                      = 0x00030021,
    subgroup_vertex                                               = 0x00030022,
    subgroup_barrier                                              = 0x00030023,
    timestamp_query_inside_encoders                               = 0x00030024,
    timestamp_query_inside_passes                                 = 0x00030025,
};

pub const SupportedFeaturesProcs = struct {
    pub const FreeMembers = *const fn(SupportedFeatures) callconv(.c) void;
};

extern fn wgpuSupportedFeaturesFreeMembers(supported_features: SupportedFeatures) void;

pub const SupportedFeatures = extern struct {
    feature_count: usize,
    features: [*]const FeatureName,

    // Frees array members of SupportedFeatures which were allocated by the API.
    pub inline fn freeMembers(self: SupportedFeatures) void {
        wgpuSupportedFeaturesFreeMembers(self);
    }
};

pub const IndexFormat = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument.
    uint16       = 0x00000001,
    uint32       = 0x00000002,
};

pub const CompareFunction = enum(u32) {
    @"undefined"  = 0x00000000, // Indicates no value is passed for this argument
    never         = 0x00000001,
    less          = 0x00000002,
    equal         = 0x00000003,
    less_equal    = 0x00000004,
    greater       = 0x00000005,
    not_equal     = 0x00000006,
    greater_equal = 0x00000007,
    always        = 0x00000008,
};

extern fn wgpuGetVersion() u32;
pub inline fn getVersion() u32 {
    return wgpuGetVersion();
}

// Max of usize
pub const WGPU_STRLEN = USIZE_MAX;

// Nullable value defining a pointer+length view into a UTF-8 encoded string.
//
// Values passed into the API may use the special length value WGPU_STRLEN
// to indicate a null-terminated string.
// Non-null values passed out of the API (for example as callback arguments)
// always provide an explicit length and **may or may not be null-terminated**.
//
// Some inputs to the API accept null values. Those which do not accept null
// values "default" to the empty string when null values are passed.
//
// Values are encoded as follows:
// - `.{ .data = null, .length = WGPU_STRLEN }`: the null value.
// - `.{ .data = <non_null_pointer>, .length = WGPU_STRLEN }`: a null-terminated string view.
// - `.{ .data = <any>, .length = 0 }`: the empty string.
// - `.{ .data = null, .length = <non_zero_length> }`: not allowed (null dereference).
// - `.{ .data = <non_null_pointer>, .length = <non_zero_length> }`: an explictly-sized string view with
//   size `non_zero_length` (in bytes).
//
pub const StringView = extern struct {
    data: ?[*]const u8 = null,
    length: usize = WGPU_STRLEN,

    pub inline fn fromSlice(slice: []const u8) StringView {
        return StringView {
            .data = slice.ptr,
            .length = slice.len,
        };
    }

    pub fn toSlice(self: StringView) ?[]const u8 {
        const data = self.data orelse return null;

        // test if null-terminated string
        if (self.length == WGPU_STRLEN) {
            // Returns the slice up to, but not including, the null terminator
            // I feel like there should be a builtin for this or something, but I don't see one in the docs.
            // Maybe there's a simpler way to do it and I'm just overthinking it.
            return std.mem.sliceTo(@as([*:0]const u8, @ptrCast(data)), 0);
        }

        return data[0..self.length];
    }
};

test "StringView can be constructed from slice" {
    const test_slice = "test";
    try std.testing.expectEqualDeep(StringView {
        .data = test_slice.ptr,
        .length = test_slice.len,
    }, StringView.fromSlice("test"));
}

test "slice can be constructed from normal StringView" {
    const test_slice = "test";
    const sv = StringView {
        .data = test_slice.ptr,
        .length = test_slice.len,
    };

    try std.testing.expectEqualSlices(u8, "test", sv.toSlice().?);
}

test "slice can be constructed from null-terminated StringView" {
    const test_slice = "test";
    const sv = StringView {
        .data = test_slice.ptr,
        .length = WGPU_STRLEN,
    };

    try std.testing.expectEqualSlices(u8, "test", sv.toSlice().?);
}

test "StringView.toSlice returns null if data is null" {
    const sv = StringView {
        .data = null,
        .length = WGPU_STRLEN,
    };

    try std.testing.expectEqual(null, sv.toSlice());
}
