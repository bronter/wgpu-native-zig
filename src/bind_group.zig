const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

const _buffer = @import("buffer.zig");
const Buffer = _buffer.Buffer;
const BufferBindingLayout = _buffer.BufferBindingLayout;

const _sampler = @import("sampler.zig");
const Sampler = _sampler.Sampler;
const SamplerBindingLayout = _sampler.SamplerBindingLayout;

const _texture = @import("texture.zig");
const TextureView = _texture.TextureView;
const TextureBindingLayout = _texture.TextureBindingLayout;
const StorageTextureBindingLayout = _texture.StorageTextureBindingLayout;

const ShaderStageFlags = @import("shader.zig").ShaderStageFlags;

pub const BindGroupLayoutEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding: u32,
    visibility: ShaderStageFlags,
    buffer: BufferBindingLayout,
    sampler: SamplerBindingLayout,
    texture: TextureBindingLayout,
    storage_texture: StorageTextureBindingLayout,
};

pub const BindGroupLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    entry_count: usize,
    entries: [*]const BindGroupLayoutEntry,
};

pub const BindGroupLayoutProcs = struct {
    pub const SetLabel = *const fn(*BindGroupLayout, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*BindGroupLayout) callconv(.C) void;
    pub const Release = *const fn(*BindGroupLayout) callconv(.C) void;
};

extern fn wgpuBindGroupLayoutSetLabel(bind_group_layout: *BindGroupLayout, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuBindGroupLayoutReference(bind_group_layout: *BindGroupLayout) callconv(.C) void;
extern fn wgpuBindGroupLayoutRelease(bind_group_layout: *BindGroupLayout) callconv(.C) void;

pub const BindGroupLayout = opaque {
    pub inline fn setLabel(self: *BindGroupLayout, label: ?[*:0]const u8) void {
        wgpuBindGroupLayoutSetLabel(self, label);
    }
    pub inline fn reference(self: *BindGroupLayout) void {
        wgpuBindGroupLayoutReference(self);
    }
    pub inline fn release(self: *BindGroupLayout) void {
        wgpuBindGroupLayoutRelease(self);
    }
};

pub const BindGroupEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding: u32,
    buffer: ?*Buffer = null,
    offset: u64,
    size: u64,
    sampler: ?*Sampler = null,
    texture_view: ?*TextureView = null,
};

pub const BindGroupDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    layout: *BindGroupLayout,
    entry_count: usize,
    entries: [*]const BindGroupEntry,
};

pub const BindGroupProcs = struct {
    pub const SetLabel = *const fn(*BindGroup, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*BindGroup) callconv(.C) void;
    pub const Release = *const fn(*BindGroup) callconv(.C) void;
};

extern fn wgpuBindGroupSetLabel(bind_group: *BindGroup, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuBindGroupReference(bind_group: *BindGroup) callconv(.C) void;
extern fn wgpuBindGroupRelease(bind_group: *BindGroup) callconv(.C) void;

pub const BindGroup = opaque {
    pub inline fn setLabel(self: *BindGroup, label: ?[*:0]const u8) void {
        wgpuBindGroupSetLabel(self, label);
    }
    pub inline fn reference(self: *BindGroup) void {
        wgpuBindGroupReference(self);
    }
    pub inline fn release(self: *BindGroup) void {
        wgpuBindGroupRelease(self);
    }
};