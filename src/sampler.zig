const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const CompareFunction = @import("misc.zig").CompareFunction;

pub const SamplerBindingType = enum(u32) {
    @"undefined"  = 0x00000000,
    filtering     = 0x00000001,
    non_filtering = 0x00000002,
    comparison    = 0x00000003,
};

pub const SamplerBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    @"type": SamplerBindingType,
};

pub const AddressMode = enum(u32) {
    repeat        = 0x00000000,
    mirror_repeat = 0x00000001,
    clamp_to_edge = 0x00000002,
};

pub const FilterMode = enum(u32) {
    nearest = 0x00000000,
    linear  = 0x00000001
};

pub const MipmapFilterMode = enum(u32) {
    nearest = 0x00000000,
    linear  = 0x00000001,
};

pub const SamplerDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    address_mode_u: AddressMode,
    address_mode_v: AddressMode,
    address_mode_w: AddressMode,
    mag_filter: FilterMode,
    min_filter: FilterMode,
    mipmap_filter: MipmapFilterMode,
    lod_min_clamp: f32,
    lod_max_clamp: f32,
    compare: CompareFunction,
    max_anisotropy: u16,
};

pub const SamplerProcs = struct {
    pub const SetLabel = *const fn(*Sampler, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*Sampler) callconv(.C) void;
    pub const Release = *const fn(*Sampler) callconv(.C) void;
};

extern fn wgpuSamplerSetLabel(sampler: *Sampler, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuSamplerReference(sampler: *Sampler) callconv(.C) void;
extern fn wgpuSamplerRelease(sampler: *Sampler) callconv(.C) void;

pub const Sampler = opaque {
    pub inline fn setLabel(self: *Sampler, label: ?[*:0]const u8) void {
        wgpuSamplerSetLabel(self, label);
    }
    pub inline fn reference(self: *Sampler) void {
        wgpuSamplerReference(self);
    }
    pub inline fn release(self: *Sampler) void {
        wgpuSamplerRelease(self);
    }
};