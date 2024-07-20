const WGPUBool = @import("misc.zig").WGPUBool;
const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const TextureFormat = @import("texture.zig").TextureFormat;

pub const RenderBundleEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    color_format_count: usize,
    color_formats: [*]const TextureFormat,
    depth_stencil_format: TextureFormat,
    sample_count: u32,
    depth_read_only: WGPUBool,
    stencil_read_only: WGPUBool,
};

// TODO: This is very similar to CommandEncoder; should it go in the same file? There's a lot of duplicated import code.
pub const RenderBundleEncoder = opaque {
    // TODO: fill in methods
};

pub const RenderBundle = opaque {
    // TODO: fill in methods
};