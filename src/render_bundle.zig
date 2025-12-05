const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const IndexFormat = _misc.IndexFormat;
const StringView = _misc.StringView;

const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const TextureFormat = @import("texture.zig").TextureFormat;
const Buffer = @import("buffer.zig").Buffer;
const BindGroup = @import("bind_group.zig").BindGroup;
const RenderPipeline = @import("pipeline.zig").RenderPipeline;
const ShaderStage = @import("shader.zig").ShaderStage;

pub const RenderBundleEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    color_format_count: usize,
    color_formats: [*]const TextureFormat,
    depth_stencil_format: TextureFormat = TextureFormat.@"undefined",
    sample_count: u32 = 1,
    depth_read_only: WGPUBool = @intFromBool(false),
    stencil_read_only: WGPUBool = @intFromBool(false),
};

pub const RenderBundleEncoderProcs = struct {
    pub const Draw = *const fn(*RenderBundleEncoder, u32, u32, u32, u32) callconv(.c) void;
    pub const DrawIndexed = *const fn(*RenderBundleEncoder, u32, u32, u32, i32, u32) callconv(.c) void;
    pub const DrawIndexedIndirect = *const fn(*RenderBundleEncoder, *Buffer, u64) callconv(.c) void;
    pub const DrawIndirect = *const fn(*RenderBundleEncoder, *Buffer, u64) callconv(.c) void;
    pub const Finish = *const fn(*RenderBundleEncoder, *const RenderBundleDescriptor) callconv(.c) ?*RenderBundle;
    pub const InsertDebugMarker = *const fn(*RenderBundleEncoder, StringView) callconv(.c) void;
    pub const PopDebugGroup = *const fn(*RenderBundleEncoder) callconv(.c) void;
    pub const PushDebugGroup = *const fn(*RenderBundleEncoder, StringView) callconv(.c) void;
    pub const SetBindGroup = *const fn(*RenderBundleEncoder, u32, *BindGroup, usize, ?[*]const u32) callconv(.c) void;
    pub const SetIndexBuffer = *const fn(*RenderBundleEncoder, *Buffer, IndexFormat, u64, u64) callconv(.c) void;
    pub const SetLabel = *const fn(*RenderBundleEncoder, StringView) callconv(.c) void;
    pub const SetPipeline = *const fn(*RenderBundleEncoder, *RenderPipeline) callconv(.c) void;
    pub const SetVertexBuffer = *const fn(*RenderBundleEncoder, u32, *Buffer, u64, u64) callconv(.c) void;
    pub const AddRef = *const fn(*RenderBundleEncoder) callconv(.c) void;
    pub const Release = *const fn(*RenderBundleEncoder) callconv(.c) void;

    // wgpu-native procs?
    // pub const SetPushConstants = *const fn(*RenderBundleEncoder, ShaderStage, u32, u32, *const anyopaque) callconv(.c) void;
};

extern fn wgpuRenderBundleEncoderDraw(render_bundle_encoder: *RenderBundleEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void;
extern fn wgpuRenderBundleEncoderDrawIndexed(render_bundle_encoder: *RenderBundleEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void;
extern fn wgpuRenderBundleEncoderDrawIndexedIndirect(render_bundle_encoder: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void;
extern fn wgpuRenderBundleEncoderDrawIndirect(render_bundle_encoder: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void;
extern fn wgpuRenderBundleEncoderFinish(render_bundle_encoder: *RenderBundleEncoder, descriptor: *const RenderBundleDescriptor) ?*RenderBundle;
extern fn wgpuRenderBundleEncoderInsertDebugMarker(render_bundle_encoder: *RenderBundleEncoder, marker_label: StringView) void;
extern fn wgpuRenderBundleEncoderPopDebugGroup(render_bundle_encoder: *RenderBundleEncoder) void;
extern fn wgpuRenderBundleEncoderPushDebugGroup(render_bundle_encoder: *RenderBundleEncoder, group_label: StringView) void;
extern fn wgpuRenderBundleEncoderSetBindGroup(render_bundle_encoder: *RenderBundleEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void;
extern fn wgpuRenderBundleEncoderSetIndexBuffer(render_bundle_encoder: *RenderBundleEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void;
extern fn wgpuRenderBundleEncoderSetLabel(render_bundle_encoder: *RenderBundleEncoder, label: StringView) void;
extern fn wgpuRenderBundleEncoderSetPipeline(render_bundle_encoder: *RenderBundleEncoder, pipeline: *RenderPipeline) void;
extern fn wgpuRenderBundleEncoderSetVertexBuffer(render_bundle_encoder: *RenderBundleEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void;
extern fn wgpuRenderBundleEncoderAddRef(render_bundle_encoder: *RenderBundleEncoder) void;
extern fn wgpuRenderBundleEncoderRelease(render_bundle_encoder: *RenderBundleEncoder) void;

// wgpu-native
extern fn wgpuRenderBundleEncoderSetPushConstants(render_bundle_encoder: *RenderBundleEncoder, stages: ShaderStage, offset: u32, size_bytes: u32, data: *const anyopaque) void;

// TODO: This is very similar to CommandEncoder; should it go in the same file? There's a lot of duplicated import code.
pub const RenderBundleEncoder = opaque {
    pub inline fn draw(self: *RenderBundleEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        wgpuRenderBundleEncoderDraw(self, vertex_count, instance_count, first_vertex, first_instance);
    }
    pub inline fn drawIndexed(self: *RenderBundleEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        wgpuRenderBundleEncoderDrawIndexed(self, index_count, instance_count, first_index, base_vertex, first_instance);
    }
    pub inline fn drawIndexedIndirect(self: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        wgpuRenderBundleEncoderDrawIndexedIndirect(self, indirect_buffer, indirect_offset);
    }
    pub inline fn drawIndirect(self: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        wgpuRenderBundleEncoderDrawIndirect(self, indirect_buffer, indirect_offset);
    }
    pub inline fn finish(self: *RenderBundleEncoder, descriptor: *const RenderBundleDescriptor) ?*RenderBundle {
        return wgpuRenderBundleEncoderFinish(self, descriptor);
    }
    pub inline fn insertDebugMarker(self: *RenderBundleEncoder, marker_label: []const u8) void {
        wgpuRenderBundleEncoderInsertDebugMarker(self, StringView.fromSlice(marker_label));
    }
    pub inline fn popDebugGroup(self: *RenderBundleEncoder) void {
        wgpuRenderBundleEncoderPopDebugGroup(self);
    }
    pub inline fn pushDebugGroup(self: *RenderBundleEncoder, group_label: []const u8) void {
        wgpuRenderBundleEncoderPushDebugGroup(self, StringView.fromSlice(group_label));
    }
    pub inline fn setBindGroup(self: *RenderBundleEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        wgpuRenderBundleEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }
    pub inline fn setIndexBuffer(self: *RenderBundleEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void {
        wgpuRenderBundleEncoderSetIndexBuffer(self, buffer, format, offset, size);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L145
    // pub inline fn setLabel(self: *RenderBundleEncoder, label: []const u8) void {
    //     wgpuRenderBundleEncoderSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn setPipeline(self: *RenderBundleEncoder, pipeline: *RenderPipeline) void {
        wgpuRenderBundleEncoderSetPipeline(self, pipeline);
    }
    pub inline fn setVertexBuffer(self: *RenderBundleEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void {
        wgpuRenderBundleEncoderSetVertexBuffer(self, slot, buffer, offset, size);
    }
    pub inline fn addRef(self: *RenderBundleEncoder) void {
        wgpuRenderBundleEncoderAddRef(self);
    }
    pub inline fn release(self: *RenderBundleEncoder) void {
        wgpuRenderBundleEncoderRelease(self);
    }

    // wgpu-native
    pub inline fn setPushConstants(self: *RenderBundleEncoder, stages: ShaderStage, offset: u32, size_bytes: u32, data: *const anyopaque) void {
        wgpuRenderBundleEncoderSetPushConstants(self, stages, offset, size_bytes, data);
    }
};

pub const RenderBundleDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
};

pub const RenderBundleProcs = struct {
    pub const SetLabel = *const fn(*RenderBundle, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*RenderBundle) callconv(.c) void;
    pub const Release = *const fn(*RenderBundle) callconv(.c) void;
};

extern fn wgpuRenderBundleSetLabel(render_bundle: *RenderBundle, label: StringView) void;
extern fn wgpuRenderBundleAddRef(render_bundle: *RenderBundle) void;
extern fn wgpuRenderBundleRelease(render_bundle: *RenderBundle) void;

pub const RenderBundle = opaque {
    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L137
    // pub inline fn setLabel(self: *RenderBundle, label: []const u8) void {
    //     wgpuRenderBundleSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *RenderBundle) void {
        wgpuRenderBundleAddRef(self);
    }
    pub inline fn release(self: *RenderBundle) void {
        wgpuRenderBundleRelease(self);
    }
};