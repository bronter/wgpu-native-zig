const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const _buffer = @import("buffer.zig");
const Buffer = _buffer.Buffer;
const BufferBindingLayout = _buffer.BufferBindingLayout;
const BufferBindingType = _buffer.BufferBindingType;

const _sampler = @import("sampler.zig");
const Sampler = _sampler.Sampler;
const SamplerBindingLayout = _sampler.SamplerBindingLayout;
const SamplerBindingType = _sampler.SamplerBindingType;

const _texture = @import("texture.zig");
const TextureView = _texture.TextureView;
const TextureBindingLayout = _texture.TextureBindingLayout;
const StorageTextureBindingLayout = _texture.StorageTextureBindingLayout;
const StorageTextureAccess = _texture.StorageTextureAccess;
const SampleType = _texture.SampleType;

const ShaderStage = @import("shader.zig").ShaderStage;

const _misc = @import("misc.zig");
const WGPU_WHOLE_SIZE = _misc.WGPU_WHOLE_SIZE;
const StringView = _misc.StringView;

pub const BindGroupLayoutEntryExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.bind_group_layout_entry_extras,
    },

    // Why does this exist? Is this different from entry_count on BindGroupLayoutDescriptor?
    count: u32,
};

pub const BindGroupLayoutEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding: u32,
    visibility: ShaderStage,
    buffer: BufferBindingLayout = BufferBindingLayout {
        .@"type" = BufferBindingType.binding_not_used,
    },
    sampler: SamplerBindingLayout = SamplerBindingLayout {
        .@"type" = SamplerBindingType.binding_not_used,
    },
    texture: TextureBindingLayout = TextureBindingLayout {
        .sample_type = SampleType.binding_not_used,
    },
    storage_texture: StorageTextureBindingLayout = StorageTextureBindingLayout {
        .access = StorageTextureAccess.binding_not_used,
    },

    pub inline fn withCount(self: BindGroupLayoutEntry, count: u32) BindGroupLayoutEntry {
        var bgle = self;
        bgle.next_in_chain = @ptrCast(&BindGroupLayoutEntryExtras {
            .count = count,
        });
        return bgle;
    }
};

pub const BindGroupLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    entry_count: usize,
    entries: [*]const BindGroupLayoutEntry,
};

pub const BindGroupLayoutProcs = struct {
    pub const SetLabel = *const fn(*BindGroupLayout, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*BindGroupLayout) callconv(.c) void;
    pub const Release = *const fn(*BindGroupLayout) callconv(.c) void;
};

extern fn wgpuBindGroupLayoutSetLabel(bind_group_layout: *BindGroupLayout, label: StringView) void;
extern fn wgpuBindGroupLayoutAddRef(bind_group_layout: *BindGroupLayout) void;
extern fn wgpuBindGroupLayoutRelease(bind_group_layout: *BindGroupLayout) void;

pub const BindGroupLayout = opaque {
    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L17
    // pub inline fn setLabel(self: *BindGroupLayout, label: []const u8) void {
    //     wgpuBindGroupLayoutSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *BindGroupLayout) void {
        wgpuBindGroupLayoutAddRef(self);
    }
    pub inline fn release(self: *BindGroupLayout) void {
        wgpuBindGroupLayoutRelease(self);
    }
};

pub const BindGroupEntryExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.bind_group_entry_extras,
    },
    buffers: ?[*]const *Buffer,
    buffer_count: usize = 0,
    samplers: ?[*]const *Sampler,
    sampler_count: usize = 0,
    texture_views: ?[*]const *TextureView,
    texture_view_count: usize = 0,
};

pub const BindGroupEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding: u32,
    buffer: ?*Buffer = null,
    offset: u64 = 0,
    size: u64 = WGPU_WHOLE_SIZE,
    sampler: ?*Sampler = null,
    texture_view: ?*TextureView = null,

    pub inline fn withNativeExtras(self: BindGroupEntry, extras: *BindGroupEntryExtras) BindGroupEntry {
        var bge = self;
        bge.next_in_chain = @ptrCast(extras);
        return bge;
    }
};

pub const BindGroupDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    layout: *BindGroupLayout,
    entry_count: usize,
    entries: [*]const BindGroupEntry,
};

pub const BindGroupProcs = struct {
    pub const SetLabel = *const fn(*BindGroup, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*BindGroup) callconv(.c) void;
    pub const Release = *const fn(*BindGroup) callconv(.c) void;
};

extern fn wgpuBindGroupSetLabel(bind_group: *BindGroup, label: StringView) void;
extern fn wgpuBindGroupAddRef(bind_group: *BindGroup) void;
extern fn wgpuBindGroupRelease(bind_group: *BindGroup) void;

pub const BindGroup = opaque {
    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L9
    // pub inline fn setLabel(self: *BindGroup, label: []const u8) void {
    //     wgpuBindGroupSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *BindGroup) void {
        wgpuBindGroupAddRef(self);
    }
    pub inline fn release(self: *BindGroup) void {
        wgpuBindGroupRelease(self);
    }
};
