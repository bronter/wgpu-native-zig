const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

const _misc = @import("misc.zig");
const WGPUFlags = _misc.WGPUFlags;
const WGPUBool = _misc.WGPUBool;

const Buffer = @import("buffer.zig").Buffer;

pub const TextureFormat = enum(u32) {
    @"undefined"            = 0x00000000,
    r8_unorm                = 0x00000001,
    r8_snorm                = 0x00000002,
    r8_uint                 = 0x00000003,
    r8_sint                 = 0x00000004,
    r16_uint                = 0x00000005,
    r16_sint                = 0x00000006,
    r16_float               = 0x00000007,
    rg8_unorm               = 0x00000008,
    rg8_snorm               = 0x00000009,
    rg8_uint                = 0x0000000A,
    rg8_sint                = 0x0000000B,
    r32_float               = 0x0000000C,
    r32_uint                = 0x0000000D,
    r32_sint                = 0x0000000E,
    rg16_uint               = 0x0000000F,
    rg16_sint               = 0x00000010,
    rg16_float              = 0x00000011,
    rgba8_unorm             = 0x00000012,
    rgba8_unorm_srgb        = 0x00000013,
    rgba8_snorm             = 0x00000014,
    rgba8_uint              = 0x00000015,
    rgba8_sint              = 0x00000016,
    bgra8_unorm             = 0x00000017,
    bgra8_unorm_srgb        = 0x00000018,
    rgb10a2_uint            = 0x00000019,
    rgb10a2_unorm           = 0x0000001A,
    rg11b10_ufloat          = 0x0000001B,
    rgb9e5_ufloat           = 0x0000001C,
    rg32_float              = 0x0000001D,
    rg32_uint               = 0x0000001E,
    rg32_sint               = 0x0000001F,
    rgba16_uint             = 0x00000020,
    rgba16_sint             = 0x00000021,
    rgba16_float            = 0x00000022,
    rgba32_float            = 0x00000023,
    rgba32_uint             = 0x00000024,
    rgba32_sint             = 0x00000025,
    stencil8                = 0x00000026,
    depth16_unorm           = 0x00000027,
    depth24_plus            = 0x00000028,
    depth24_plus_stencil8   = 0x00000029,
    depth32_float           = 0x0000002A,
    depth32_float_stencil8  = 0x0000002B,
    bc1_rgba_unorm          = 0x0000002C,
    bc1_rgba_unorm_srgb     = 0x0000002D,
    bc2_rgba_unorm          = 0x0000002E,
    bc2_rgba_unorm_srgb     = 0x0000002F,
    bc3_rgba_unorm          = 0x00000030,
    bc3_rgba_unorm_srgb     = 0x00000031,
    bc4_r_unorm             = 0x00000032,
    bc4_r_snorm             = 0x00000033,
    bc5_rg_unorm            = 0x00000034,
    bc5_rg_snorm            = 0x00000035,
    bc6_hrgb_ufloat         = 0x00000036,
    bc6_hrgb_float          = 0x00000037,
    bc7_rgba_unorm          = 0x00000038,
    bc7_rgba_unorm_srgb     = 0x00000039,
    etc2_rgb8_unorm         = 0x0000003A,
    etc2_rgb8_unorm_srgb    = 0x0000003B,
    etc2_rgb8a1_unorm       = 0x0000003C,
    etc2_rgb8a1_unorm_srgb  = 0x0000003D,
    etc2_rgba8_unorm        = 0x0000003E,
    etc2_rgba8_unorm_srgb   = 0x0000003F,
    eacr11_unorm            = 0x00000040,
    eacr11_snorm            = 0x00000041,
    eacrg11_unorm           = 0x00000042,
    eacrg11_snorm           = 0x00000043,
    astc4x4_unorm           = 0x00000044,
    astc4x4_unorm_srgb      = 0x00000045,
    astc5x4_unorm           = 0x00000046,
    astc5x4_unorm_srgb      = 0x00000047,
    astc5x5_unorm           = 0x00000048,
    astc5x5_unorm_srgb      = 0x00000049,
    astc6x5_unorm           = 0x0000004A,
    astc6x5_unorm_srgb      = 0x0000004B,
    astc6x6_unorm           = 0x0000004C,
    astc6x6_unorm_srgb      = 0x0000004D,
    astc8x5_unorm           = 0x0000004E,
    astc8x5_unorm_srgb      = 0x0000004F,
    astc8x6_unorm           = 0x00000050,
    astc8x6_unorm_srgb      = 0x00000051,
    astc8x8_unorm           = 0x00000052,
    astc8x8_unorm_srgb      = 0x00000053,
    astc10x5_unorm          = 0x00000054,
    astc10x5_unorm_srgb     = 0x00000055,
    astc10x6_unorm          = 0x00000056,
    astc10x6_unorm_srgb     = 0x00000057,
    astc10x8_unorm          = 0x00000058,
    astc10x8_unorm_srgb     = 0x00000059,
    astc10x10_unorm         = 0x0000005A,
    astc10x10_unorm_srgb    = 0x0000005B,
    astc12x10_unorm         = 0x0000005C,
    astc12x10_unorm_srgb    = 0x0000005D,
    astc12x12_unorm         = 0x0000005E,
    astc12x12_unorm_srgb    = 0x0000005F,
};

pub const TextureUsageFlags = WGPUFlags;
pub const TextureUsage = struct {
    pub const none              = @as(TextureUsageFlags, 0x00000000);
    pub const copy_src          = @as(TextureUsageFlags, 0x00000001);
    pub const copy_dst          = @as(TextureUsageFlags, 0x00000002);
    pub const texture_binding   = @as(TextureUsageFlags, 0x00000004);
    pub const storage_binding   = @as(TextureUsageFlags, 0x00000008);
    pub const render_attachment = @as(TextureUsageFlags, 0x00000010);
};

// TODO: Like a lot of things in this file, this breaks from the wrapper code convention by having an unneeded prefix ("Texture")
//       in front of the name, even though "Aspect" is exclusively used in TextureAspect. I've done this because just calling
//       it "Aspect" seems like it'd confuse people thinking it is an aspect ratio or something, but should it just be "Aspect"?
pub const TextureAspect = enum(u32) {
    all          = 0x00000000,
    stencil_only = 0x00000001,
    depth_only   = 0x00000002,
};

pub const TextureViewDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    format: TextureFormat,
    dimension: ViewDimension,
    base_mip_level: u32,
    mip_level_count: u32,
    base_array_layer: u32,
    array_layer_count: u32,
    aspect: TextureAspect,
};

pub const TextureViewProcs = struct {
    pub const SetLabel = *const fn(*TextureView, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*TextureView) callconv(.C) void;
    pub const Release = *const fn(*TextureView) callconv(.C) void;
};

extern fn wgpuTextureViewSetLabel(texture_view: *TextureView, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuTextureViewReference(texture_view: *TextureView) callconv(.C) void;
extern fn wgpuTextureViewRelease(texture_view: *TextureView) callconv(.C) void;

pub const TextureView = opaque {
    pub inline fn setLabel(self: *TextureView, label: ?[*:0]const u8) void {
        wgpuTextureViewSetLabel(self, label);
    }
    pub inline fn reference(self: *TextureView) void {
        wgpuTextureViewReference(self);
    }
    pub inline fn release(self: *TextureView) void {
        wgpuTextureViewRelease(self);
    }
};

// TODO: Should this maybe go in sampler.zig instead?
pub const SampleType = enum(u32) {
    @"undefined"       = 0x00000000,
    float              = 0x00000001,
    unfilterable_float = 0x00000002,
    depth              = 0x00000003,
    s_int              = 0x00000004,
    u_int              = 0x00000005,
};

pub const ViewDimension = enum(u32) {
    @"undefined" = 0x00000000,
    @"1d"        = 0x00000001,
    @"2d"        = 0x00000002,
    @"2d_array"  = 0x00000003,
    cube         = 0x00000004,
    cube_array   = 0x00000005,
    @"3d"        = 0x00000006,
};

pub const TextureBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    sample_type: SampleType,
    view_dimension: ViewDimension,
    multisampled: WGPUBool,
};

pub const StorageTextureAccess = enum(u32) {
    @"undefined" = 0x00000000,
    write_only   = 0x00000001,
    read_only    = 0x00000002,
    read_write   = 0x00000003,
};

pub const StorageTextureBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    access: StorageTextureAccess,
    format: TextureFormat,
    view_dimension: ViewDimension,
};

pub const TextureDimension = enum(u32) {
    @"1d" = 0x00000000,
    @"2d" = 0x00000001,
    @"3d" = 0x00000002,
};

pub const Extent3D = extern struct {
    width: u32,
    height: u32,
    depth_or_array_layers: u32,
};

pub const TextureDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: TextureUsageFlags,
    dimension: TextureDimension,
    size: Extent3D,
    format: TextureFormat,
    mip_level_count: u32,
    sample_count: u32,
    view_format_count: usize,
    view_formats: [*]const TextureFormat,
};

pub const TextureProcs = struct {
    pub const CreateView = *const fn(*Texture, *const TextureViewDescriptor) callconv(.C) ?*TextureView;
    pub const Destroy = *const fn(*Texture) callconv(.C) void;
    pub const GetDepthOrArrayLayers = *const fn(*Texture) callconv(.C) u32;
    pub const GetDimension = *const fn(*Texture) callconv(.C) TextureDimension;
    pub const GetFormat = *const fn(*Texture) callconv(.C) TextureFormat;
    pub const GetHeight = *const fn(*Texture) callconv(.C) u32;
    pub const GetMipLevelCount = *const fn(*Texture) callconv(.C) u32;
    pub const GetSampleCount = *const fn(*Texture) callconv(.C) u32;
    pub const GetUsage = *const fn(*Texture) callconv(.C) TextureUsageFlags;
    pub const GetWidth = *const fn(*Texture) callconv(.C) u32;
    pub const SetLabel = *const fn(*Texture, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*Texture) callconv(.C) void;
    pub const Release = *const fn(*Texture) callconv(.C) void;
};

extern fn wgpuTextureCreateView(texture: *Texture, descriptor: *const TextureViewDescriptor) callconv(.C) ?*TextureView;
extern fn wgpuTextureDestroy(texture: *Texture) callconv(.C) void;
extern fn wgpuTextureGetDepthOrArrayLayers(texture: *Texture) callconv(.C) u32;
extern fn wgpuTextureGetDimension(texture: *Texture) callconv(.C) TextureDimension;
extern fn wgpuTextureGetFormat(texture: *Texture) callconv(.C) TextureFormat;
extern fn wgpuTextureGetHeight(texture: *Texture) callconv(.C) u32;
extern fn wgpuTextureGetMipLevelCount(texture: *Texture) callconv(.C) u32;
extern fn wgpuTextureGetSampleCount(texture: *Texture) callconv(.C) u32;
extern fn wgpuTextureGetUsage(texture: *Texture) callconv(.C) TextureUsageFlags;
extern fn wgpuTextureGetWidth(texture: *Texture) callconv(.C) u32;
extern fn wgpuTextureSetLabel(texture: *Texture, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuTextureReference(texture: *Texture) callconv(.C) void;
extern fn wgpuTextureRelease(texture: *Texture) callconv(.C) void;

pub const Texture = opaque {
    pub inline fn createView(self: *Texture, descriptor: *const TextureViewDescriptor) ?*TextureView {
        return wgpuTextureCreateView(self, descriptor);
    }
    pub inline fn destroy(self: *Texture) void {
        wgpuTextureDestroy(self);
    }
    pub inline fn getDepthOrArrayLayers(self: *Texture) u32 {
        return wgpuTextureGetDepthOrArrayLayers(self);
    }
    pub inline fn getDimension(self: *Texture) TextureDimension {
        return wgpuTextureGetDimension(self);
    }
    pub inline fn getFormat(self: *Texture) TextureFormat {
        return wgpuTextureGetFormat(self);
    }
    pub inline fn getHeight(self: *Texture) u32 {
        return wgpuTextureGetHeight(self);
    }
    pub inline fn getMipLevelCount(self: *Texture) u32 {
        return wgpuTextureGetMipLevelCount(self);
    }
    pub inline fn getSampleCount(self: *Texture) u32 {
        return wgpuTextureGetSampleCount(self);
    }
    pub inline fn getUsage(self: *Texture) TextureUsageFlags {
        return wgpuTextureGetUsage(self);
    }
    pub inline fn getWidth(self: *Texture) u32 {
        return wgpuTextureGetWidth(self);
    }
    pub inline fn setLabel(self: *Texture, label: ?[*:0]const u8) void {
        wgpuTextureSetLabel(self, label);
    }
    pub inline fn reference(self: *Texture) void {
        wgpuTextureReference(self);
    }
    pub inline fn release(self: *Texture) void {
        wgpuTextureRelease(self);
    }
};

pub const Origin3D = extern struct {
    x: u32,
    y: u32,
    z: u32,
};

pub const ImageCopyTexture = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    texture: *Texture,
    mip_level: u32,
    origin: Origin3D,
    aspect: TextureAspect,
};

pub const TextureDataLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    offset: u64,
    bytes_per_row: u32,
    rows_per_image: u32,
};

// Seems a little weird to put this in texture.zig,
// but it seems to have more to do with images/textures than with buffers.
pub const ImageCopyBuffer = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    layout: TextureDataLayout,
    buffer: *Buffer,
};