const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

const _misc = @import("misc.zig");
const CompareFunction = _misc.CompareFunction;
const StringView = _misc.StringView;

pub const SamplerBindingType = enum(u32) {
    // Indicates that this SamplerBindingLayout member of its parent BindGroupLayoutEntry is not used.
    binding_not_used = 0x00000000,

    // Indicates no value is passed for this argument.
    @"undefined"     = 0x00000001,

    filtering        = 0x00000002,
    non_filtering    = 0x00000003,
    comparison       = 0x00000004,
};

pub const SamplerBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    @"type": SamplerBindingType = SamplerBindingType.@"undefined",
};

pub const AddressMode = enum(u32) {
    @"undefined"  = 0x00000000, // Indicates no value is passed for this argument
    clamp_to_edge = 0x00000001,
    repeat        = 0x00000002,
    mirror_repeat = 0x00000003,
};

pub const FilterMode = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument.
    nearest      = 0x00000001,
    linear       = 0x00000002,
};

pub const MipmapFilterMode = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument.
    nearest      = 0x00000001,
    linear       = 0x00000002,
};

pub const SamplerDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    address_mode_u: AddressMode = AddressMode.clamp_to_edge,
    address_mode_v: AddressMode = AddressMode.clamp_to_edge,
    address_mode_w: AddressMode = AddressMode.clamp_to_edge,
    mag_filter: FilterMode = FilterMode.nearest,
    min_filter: FilterMode = FilterMode.nearest,
    mipmap_filter: MipmapFilterMode = MipmapFilterMode.nearest,
    lod_min_clamp: f32 = 0.0,
    lod_max_clamp: f32 = 32.0,
    compare: CompareFunction = CompareFunction.@"undefined",
    max_anisotropy: u16 = 1,
};

pub const SamplerProcs = struct {
    pub const SetLabel = *const fn(*Sampler, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*Sampler) callconv(.c) void;
    pub const Release = *const fn(*Sampler) callconv(.c) void;
};

extern fn wgpuSamplerSetLabel(sampler: *Sampler, label: StringView) void;
extern fn wgpuSamplerAddRef(sampler: *Sampler) void;
extern fn wgpuSamplerRelease(sampler: *Sampler) void;

pub const Sampler = opaque {
    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L169
    // pub inline fn setLabel(self: *Sampler, label: []const u8) void {
    //     wgpuSamplerSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *Sampler) void {
        wgpuSamplerAddRef(self);
    }
    pub inline fn release(self: *Sampler) void {
        wgpuSamplerRelease(self);
    }
};