const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const IndexFormat = _misc.IndexFormat;

const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const TextureFormat = @import("texture.zig").TextureFormat;
const Buffer = @import("buffer.zig").Buffer;
const BindGroup = @import("bind_group.zig").BindGroup;
const RenderPipeline = @import("pipeline.zig").RenderPipeline;

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

pub const RenderBundleEncoderProcs = struct {
    pub const Draw = *const fn(*RenderBundleEncoder, u32, u32, u32, u32) callconv(.C) void;
    pub const DrawIndexed = *const fn(*RenderBundleEncoder, u32, u32, u32, i32, u32) callconv(.C) void;
    pub const DrawIndexedIndirect = *const fn(*RenderBundleEncoder, *Buffer, u64) callconv(.C) void;
    pub const DrawIndirect = *const fn(*RenderBundleEncoder, *Buffer, u64) callconv(.C) void;
    pub const Finish = *const fn(*RenderBundleEncoder, *const RenderBundleDescriptor) callconv(.C) ?*RenderBundle;
    pub const InsertDebugMarker = *const fn(*RenderBundleEncoder, [*:0]const u8) callconv(.C) void;
    pub const PopDebugGroup = *const fn(*RenderBundleEncoder) callconv(.C) void;
    pub const PushDebugGroup = *const fn(*RenderBundleEncoder, [*:0]const u8) callconv(.C) void;
    pub const SetBindGroup = *const fn(*RenderBundleEncoder, u32, *BindGroup, usize, ?[*]const u32) callconv(.C) void;
    pub const SetIndexBuffer = *const fn(*RenderBundleEncoder, *Buffer, IndexFormat, u64, u64) callconv(.C) void;
    pub const SetLabel = *const fn(*RenderBundleEncoder, ?[*:0]const u8) callconv(.C) void;
    pub const SetPipeline = *const fn(*RenderBundleEncoder, *RenderPipeline) callconv(.C) void;
    pub const SetVertexBuffer = *const fn(*RenderBundleEncoder, u32, *Buffer, u64, u64) callconv(.C) void;
    pub const Reference = *const fn(*RenderBundleEncoder) callconv(.C) void;
    pub const Release = *const fn(*RenderBundleEncoder) callconv(.C) void;
};

extern fn wgpuRenderBundleEncoderDraw(render_bundle_encoder: *RenderBundleEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void;
extern fn wgpuRenderBundleEncoderDrawIndexed(render_bundle_encoder: *RenderBundleEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void;
extern fn wgpuRenderBundleEncoderDrawIndexedIndirect(render_bundle_encoder: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void;
extern fn wgpuRenderBundleEncoderDrawIndirect(render_bundle_encoder: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void;
extern fn wgpuRenderBundleEncoderFinish(render_bundle_encoder: *RenderBundleEncoder, descriptor: *const RenderBundleDescriptor) ?*RenderBundle;
extern fn wgpuRenderBundleEncoderInsertDebugMarker(render_bundle_encoder: *RenderBundleEncoder, marker_label: [*:0]const u8) void;
extern fn wgpuRenderBundleEncoderPopDebugGroup(render_bundle_encoder: *RenderBundleEncoder) void;
extern fn wgpuRenderBundleEncoderPushDebugGroup(render_bundle_encoder: *RenderBundleEncoder, group_label: [*:0]const u8) void;
extern fn wgpuRenderBundleEncoderSetBindGroup(render_bundle_encoder: *RenderBundleEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void;
extern fn wgpuRenderBundleEncoderSetIndexBuffer(render_bundle_encoder: *RenderBundleEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void;
extern fn wgpuRenderBundleEncoderSetLabel(render_bundle_encoder: *RenderBundleEncoder, label: ?[*:0]const u8) void;
extern fn wgpuRenderBundleEncoderSetPipeline(render_bundle_encoder: *RenderBundleEncoder, pipeline: *RenderPipeline) void;
extern fn wgpuRenderBundleEncoderSetVertexBuffer(render_bundle_encoder: *RenderBundleEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void;
extern fn wgpuRenderBundleEncoderReference(render_bundle_encoder: *RenderBundleEncoder) void;
extern fn wgpuRenderBundleEncoderRelease(render_bundle_encoder: *RenderBundleEncoder) void;

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
    pub inline fn insertDebugMarker(self: *RenderBundleEncoder, marker_label: [*:0]const u8) void {
        wgpuRenderBundleEncoderInsertDebugMarker(self, marker_label);
    }
    pub inline fn popDebugGroup(self: *RenderBundleEncoder) void {
        wgpuRenderBundleEncoderPopDebugGroup(self);
    }
    pub inline fn pushDebugGroup(self: *RenderBundleEncoder, group_label: [*:0]const u8) void {
        wgpuRenderBundleEncoderPushDebugGroup(self, group_label);
    }
    pub inline fn setBindGroup(self: *RenderBundleEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        wgpuRenderBundleEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }
    pub inline fn setIndexBuffer(self: *RenderBundleEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void {
        wgpuRenderBundleEncoderSetIndexBuffer(self, buffer, format, offset, size);
    }
    pub inline fn setLabel(self: *RenderBundleEncoder, label: ?[*:0]const u8) void {
        wgpuRenderBundleEncoderSetLabel(self, label);
    }
    pub inline fn setPipeline(self: *RenderBundleEncoder, pipeline: *RenderPipeline) void {
        wgpuRenderBundleEncoderSetPipeline(self, pipeline);
    }
    pub inline fn setVertexBuffer(self: *RenderBundleEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void {
        wgpuRenderBundleEncoderSetVertexBuffer(self, slot, buffer, offset, size);
    }
    pub inline fn reference(self: *RenderBundleEncoder) void {
        wgpuRenderBundleEncoderReference(self);
    }
    pub inline fn release(self: *RenderBundleEncoder) void {
        wgpuRenderBundleEncoderRelease(self);
    }
};

pub const RenderBundleDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
};

pub const RenderBundleProcs = struct {
    pub const SetLabel = *const fn(*RenderBundle, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*RenderBundle) callconv(.C) void;
    pub const Release = *const fn(*RenderBundle) callconv(.C) void;
};

extern fn wgpuRenderBundleSetLabel(render_bundle: *RenderBundle, label: ?[*:0]const u8) void;
extern fn wgpuRenderBundleReference(render_bundle: *RenderBundle) void;
extern fn wgpuRenderBundleRelease(render_bundle: *RenderBundle) void;

pub const RenderBundle = opaque {
    pub inline fn setLabel(self: *RenderBundle, label: ?[*:0]const u8) void {
        wgpuRenderBundleSetLabel(self, label);
    }
    pub inline fn reference(self: *RenderBundle) void {
        wgpuRenderBundleReference(self);
    }
    pub inline fn release(self: *RenderBundle) void {
        wgpuRenderBundleRelease(self);
    }
};