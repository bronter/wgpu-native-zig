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

pub const BindGroupLayout = opaque {
    // TODO: fill in methods
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

pub const BindGroup = opaque {
    // TODO: fill in methods
};