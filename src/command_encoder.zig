const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const Buffer = @import("buffer.zig").Buffer;
const QuerySet = @import("query_set.zig").QuerySet;

const _texture = @import("texture.zig");
const TextureView = _texture.TextureView;
const TexelCopyBufferInfo = _texture.TexelCopyBufferInfo;
const TexelCopyTextureInfo = _texture.TexelCopyTextureInfo;
const Extent3D = _texture.Extent3D;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const IndexFormat = _misc.IndexFormat;
const StringView = _misc.StringView;
const U32_MAX = _misc.U32_MAX;

const BindGroup = @import("bind_group.zig").BindGroup;

const _pipeline = @import("pipeline.zig");
const ComputePipeline = _pipeline.ComputePipeline;
const RenderPipeline = _pipeline.RenderPipeline;

const RenderBundle = @import("render_bundle.zig").RenderBundle;

const ShaderStage = @import("shader.zig").ShaderStage;

pub const WGPU_DEPTH_SLICE_UNDEFINED = U32_MAX;
pub const WGPU_QUERY_SET_INDEX_UNDEFINED = U32_MAX;

pub const TimestampWrites = extern struct {
    query_set: *QuerySet,
    beginning_of_pass_write_index: u32 = WGPU_QUERY_SET_INDEX_UNDEFINED,
    end_of_pass_write_index: u32 = WGPU_QUERY_SET_INDEX_UNDEFINED,
};

pub const ComputePassTimestampWrites = TimestampWrites;

pub const ComputePassDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    timestamp_writes: ?*const ComputePassTimestampWrites = null,
};

pub const CommandEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
};

const ComputePassEncoderProcs = struct {
    pub const DispatchWorkgroups = *const fn(*ComputePassEncoder, u32, u32, u32) callconv(.c) void;
    pub const DispatchWorkgroupsIndirect = *const fn(*ComputePassEncoder, *Buffer, u64) callconv(.c) void;
    pub const End = *const fn(*ComputePassEncoder) callconv(.c) void;
    pub const InsertDebugMarker = *const fn(*ComputePassEncoder, StringView) callconv(.c) void;
    pub const PopDebugGroup = *const fn(*ComputePassEncoder) callconv(.c) void;
    pub const PushDebugGroup = *const fn(*ComputePassEncoder, StringView) callconv(.c) void;
    pub const SetBindGroup = *const fn(*ComputePassEncoder, u32, *BindGroup, usize, ?[*]const u32) callconv(.c) void;
    pub const SetLabel = *const fn(*ComputePassEncoder, StringView) callconv(.c) void;
    pub const SetPipeline = *const fn(*ComputePassEncoder, *ComputePipeline) callconv(.c) void;
    pub const AddRef = *const fn(*ComputePassEncoder) callconv(.c) void;
    pub const Release = *const fn(*ComputePassEncoder) callconv(.c) void;

    // wgpu-native procs?
    // pub const SetPushConstants = *const fn(*ComputePassEncoder, u32, u32, *const anyopaque) callconv(.c) void;
    // pub const BeginPipelineStatisticsQuery = *const fn(*ComputePassEncoder, *QuerySet, u32) callconv(.c) void;
    // pub const EndPipelineStatisticsQuery = *const fn(*ComputePassEncoder) callconv(.c) void;
    // pub const WriteTimestamp = *const fn(*ComputePassEncoder, *QuerySet, u32) callconv(.c) void;
};

extern fn wgpuComputePassEncoderDispatchWorkgroups(compute_pass_encoder: *ComputePassEncoder, workgroup_count_x: u32, workgroup_count_y: u32, workgroup_count_z: u32) void;
extern fn wgpuComputePassEncoderDispatchWorkgroupsIndirect(compute_pass_encoder: *ComputePassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void;
extern fn wgpuComputePassEncoderEnd(compute_pass_encoder: *ComputePassEncoder) void;
extern fn wgpuComputePassEncoderInsertDebugMarker(compute_pass_encoder: *ComputePassEncoder, marker_label: StringView) void;
extern fn wgpuComputePassEncoderPopDebugGroup(compute_pass_encoder: *ComputePassEncoder) void;
extern fn wgpuComputePassEncoderPushDebugGroup(compute_pass_encoder: *ComputePassEncoder, group_label: StringView) void;
extern fn wgpuComputePassEncoderSetBindGroup(compute_pass_encoder: *ComputePassEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void;
extern fn wgpuComputePassEncoderSetLabel(compute_pass_encoder: *ComputePassEncoder, label: StringView) void;
extern fn wgpuComputePassEncoderSetPipeline(compute_pass_encoder: *ComputePassEncoder, pipeline: *ComputePipeline) void;
extern fn wgpuComputePassEncoderAddRef(compute_pass_encoder: *ComputePassEncoder) void;
extern fn wgpuComputePassEncoderRelease(compute_pass_encoder: *ComputePassEncoder) void;

// wgpu-native
extern fn wgpuComputePassEncoderSetPushConstants(compute_pass_encoder: *ComputePassEncoder, offset: u32, size_bytes: u32, data: *const anyopaque) void;
extern fn wgpuComputePassEncoderBeginPipelineStatisticsQuery(compute_pass_encoder: *ComputePassEncoder, query_set: *QuerySet, query_index: u32) void;
extern fn wgpuComputePassEncoderEndPipelineStatisticsQuery(compute_pass_encoder: *ComputePassEncoder) void;
extern fn wgpuComputePassEncoderWriteTimestamp(compute_pass_encoder: *ComputePassEncoder, query_set: *QuerySet, query_index: u32) void;

pub const ComputePassEncoder = opaque {
    pub inline fn dispatchWorkgroups(self: *ComputePassEncoder, workgroup_count_x: u32, workgroup_count_y: u32, workgroup_count_z: u32) void {
        wgpuComputePassEncoderDispatchWorkgroups(self, workgroup_count_x, workgroup_count_y, workgroup_count_z);
    }
    pub inline fn dispatchWorkgroupsIndirect(self: *ComputePassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        wgpuComputePassEncoderDispatchWorkgroupsIndirect(self, indirect_buffer, indirect_offset);
    }
    pub inline fn end(self: *ComputePassEncoder) void {
        wgpuComputePassEncoderEnd(self);
    }
    pub inline fn insertDebugMarker(self: *ComputePassEncoder, marker_label: []const u8) void {
        wgpuComputePassEncoderInsertDebugMarker(self, StringView.fromSlice(marker_label));
    }
    pub inline fn popDebugGroup(self: *ComputePassEncoder) void {
        wgpuComputePassEncoderPopDebugGroup(self);
    }
    pub inline fn pushDebugGroup(self: *ComputePassEncoder, group_label: []const u8) void {
        wgpuComputePassEncoderPushDebugGroup(self, StringView.fromSlice(group_label));
    }
    pub inline fn setBindGroup(self: *ComputePassEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        wgpuComputePassEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L51
    // pub inline fn setLabel(self: *ComputePassEncoder, label: []const u8) void {
    //     wgpuComputePassEncoderSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn setPipeline(self: *ComputePassEncoder, pipeline: *ComputePipeline) void {
        wgpuComputePassEncoderSetPipeline(self, pipeline);
    }
    pub inline fn addRef(self: *ComputePassEncoder) void {
        wgpuComputePassEncoderAddRef(self);
    }
    pub inline fn release(self: *ComputePassEncoder) void {
        wgpuComputePassEncoderRelease(self);
    }

    // wgpu-native
    pub inline fn setPushConstants(self: *ComputePassEncoder, offset: u32, size_bytes: u32, data: *const anyopaque) void {
        wgpuComputePassEncoderSetPushConstants(self, offset, size_bytes, data);
    }
    pub inline fn beginPipelineStatisticsQuery(self: *ComputePassEncoder, query_set: *QuerySet, query_index: u32) void {
        wgpuComputePassEncoderBeginPipelineStatisticsQuery(self, query_set, query_index);
    }
    pub inline fn endPipelineStatisticsQuery(self: *ComputePassEncoder) void {
        wgpuComputePassEncoderEndPipelineStatisticsQuery(self);
    }
    pub inline fn writeTimestamp(self: *ComputePassEncoder, query_set: *QuerySet, query_index: u32) void {
        wgpuComputePassEncoderWriteTimestamp(self, query_set, query_index);
    }
};

pub const LoadOp = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument.
    load         = 0x00000001,
    clear        = 0x00000002,
};

pub const StoreOp = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument
    store        = 0x00000001,
    discard      = 0x00000002,
};

pub const Color = extern struct {
    r: f64 = 0.0,
    g: f64 = 0.0,
    b: f64 = 0.0,
    a: f64 = 0.0,
};

pub const ColorAttachment = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    view: ?*TextureView,
    depth_slice: u32 = WGPU_DEPTH_SLICE_UNDEFINED,
    resolve_target: ?*TextureView = null,
    load_op: LoadOp = LoadOp.clear,
    store_op: StoreOp = StoreOp.store,
    clear_value: Color = Color {},
};

pub const DepthStencilAttachment = extern struct {
    view: *TextureView,
    depth_load_op: LoadOp = LoadOp.@"undefined",
    depth_store_op: StoreOp = StoreOp.@"undefined",
    depth_clear_value: f32 = 0,
    depth_read_only: WGPUBool = @intFromBool(false),
    stencil_load_op: LoadOp = LoadOp.@"undefined",
    stencil_store_op: StoreOp = StoreOp.@"undefined",
    stencil_clear_value: u32 = 0,
    stencil_read_only: WGPUBool = @intFromBool(false),
};

pub const RenderPassTimestampWrites = TimestampWrites;

pub const RenderPassMaxDrawCount = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.render_pass_max_draw_count
    },
    max_draw_count: u64 = 50000000,
};

pub const RenderPassDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    color_attachment_count: usize,
    color_attachments: [*]const ColorAttachment,
    depth_stencil_attachment: ?*const DepthStencilAttachment = null,
    occlusion_query_set: ?*QuerySet = null,
    timestamp_writes: ?*const RenderPassTimestampWrites = null,

    pub inline fn withMaxDrawCount(self: RenderPassDescriptor, max_draw_count: u64) RenderPassDescriptor {
        var descriptor = self;
        descriptor.next_in_chain = @ptrCast(&RenderPassMaxDrawCount {
            .max_draw_count = max_draw_count,
        });

        return descriptor;
    }
};

pub const RenderPassEncoderProcs = struct {
    pub const BeginOcclusionQuery = *const fn(*RenderPassEncoder, u32) callconv(.c) void;
    pub const Draw = *const fn(*RenderPassEncoder, u32, u32, u32, u32) callconv(.c) void;
    pub const DrawIndexed = *const fn(*RenderPassEncoder, u32, u32, u32, i32, u32) callconv(.c) void;
    pub const DrawIndexedIndirect = *const fn(*RenderPassEncoder, *Buffer, u64) callconv(.c) void;
    pub const DrawIndirect = *const fn(*RenderPassEncoder, *Buffer, u64) callconv(.c) void;
    pub const End = *const fn(*RenderPassEncoder) callconv(.c) void;
    pub const EndOcclusionQuery = *const fn(*RenderPassEncoder) callconv(.c) void;
    pub const ExecuteBundles = *const fn(*RenderPassEncoder, usize, [*]const *const RenderBundle) callconv(.c) void;
    pub const InsertDebugMarker = *const fn(*RenderPassEncoder, StringView) callconv(.c) void;
    pub const PopDebugGroup = *const fn(*RenderPassEncoder) callconv(.c) void;
    pub const PushDebugGroup = *const fn(*RenderPassEncoder, StringView) callconv(.c) void;
    pub const SetBindGroup = *const fn(*RenderPassEncoder, u32, *BindGroup, usize, ?[*]const u32) callconv(.c) void;
    pub const SetBlendConstant = *const fn(*RenderPassEncoder, *const Color) callconv(.c) void;
    pub const SetIndexBuffer = *const fn(*RenderPassEncoder, *Buffer, IndexFormat, u64, u64) callconv(.c) void;
    pub const SetLabel = *const fn(*RenderPassEncoder, StringView) callconv(.c) void;
    pub const SetPipeline = *const fn(*RenderPassEncoder, *RenderPipeline) callconv(.c) void;
    pub const SetScissorRect = *const fn(*RenderPassEncoder, u32, u32, u32, u32) callconv(.c) void;
    pub const SetStencilReference = *const fn(*RenderPassEncoder, u32) callconv(.c) void;
    pub const SetVertexBuffer = *const fn(*RenderPassEncoder, u32, *Buffer, u64, u64) callconv(.c) void;
    pub const SetViewport = *const fn(*RenderPassEncoder, f32, f32, f32, f32, f32, f32) callconv(.c) void;
    pub const AddRef = *const fn(*RenderPassEncoder) callconv(.c) void;
    pub const Release = *const fn(*RenderPassEncoder) callconv(.c) void;

    // wgpu-native procs?
    // pub const SetPushConstants = *const fn(*RenderPassEncoder, ShaderStage, u32, u32, *const anyopaque) callconv(.c) void;
    // pub const MultiDrawIndirect = *const fn(*RenderPassEncoder, *Buffer, u64, u32) callconv(.c) void;
    // pub const MultiDrawIndexedIndirect = *const fn(*RenderPassEncoder, *Buffer, u64, u32) callconv(.c) void;
    // pub const MultiDrawIndirectCount = *const fn(*RenderPassEncoder, *Buffer, u64, *Buffer, u64, u32) callconv(.c) void;
    // pub const MultiDrawIndexedIndirectCount = *const fn(*RenderPassEncoder, *Buffer, u64, *Buffer, u64, u32) callconv(.c) void;
    // pub const BeginPipelineStatisticsQuery = *const fn(*RenderPassEncoder, *QuerySet, u32) callconv(.c) void;
    // pub const EndPipelineStatisticsQuery = *const fn(*RenderPassEncoder) callconv(.c) void;
    // pub const WriteTimestamp = *const fn(*RenderPassEncoder, *QuerySet, u32) callconv(.c) void;
};

extern fn wgpuRenderPassEncoderBeginOcclusionQuery(render_pass_encoder: *RenderPassEncoder, query_index: u32) void;
extern fn wgpuRenderPassEncoderDraw(render_pass_encoder: *RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void;
extern fn wgpuRenderPassEncoderDrawIndexed(render_pass_encoder: *RenderPassEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void;
extern fn wgpuRenderPassEncoderDrawIndexedIndirect(render_pass_encoder: *RenderPassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void;
extern fn wgpuRenderPassEncoderDrawIndirect(render_pass_encoder: *RenderPassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void;
extern fn wgpuRenderPassEncoderEnd(render_pass_encoder: *RenderPassEncoder) void;
extern fn wgpuRenderPassEncoderEndOcclusionQuery(render_pass_encoder: *RenderPassEncoder) void;
extern fn wgpuRenderPassEncoderExecuteBundles(render_pass_encoder: *RenderPassEncoder, bundle_count: usize, bundles: [*]const *const RenderBundle) void;
extern fn wgpuRenderPassEncoderInsertDebugMarker(render_pass_encoder: *RenderPassEncoder, marker_label: StringView) void;
extern fn wgpuRenderPassEncoderPopDebugGroup(render_pass_encoder: *RenderPassEncoder) void;
extern fn wgpuRenderPassEncoderPushDebugGroup(render_pass_encoder: *RenderPassEncoder, group_label: StringView) void;
extern fn wgpuRenderPassEncoderSetBindGroup(render_pass_encoder: *RenderPassEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void;
extern fn wgpuRenderPassEncoderSetBlendConstant(render_pass_encoder: *RenderPassEncoder, color: *const Color) void;
extern fn wgpuRenderPassEncoderSetIndexBuffer(render_pass_encoder: *RenderPassEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void;
extern fn wgpuRenderPassEncoderSetLabel(render_pass_encoder: *RenderPassEncoder, label: StringView) void;
extern fn wgpuRenderPassEncoderSetPipeline(render_pass_encoder: *RenderPassEncoder, pipeline: *RenderPipeline) void;
extern fn wgpuRenderPassEncoderSetScissorRect(render_pass_encoder: *RenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void;
extern fn wgpuRenderPassEncoderSetStencilReference(render_pass_encoder: *RenderPassEncoder, stencil_reference: u32) void;
extern fn wgpuRenderPassEncoderSetVertexBuffer(render_pass_encoder: *RenderPassEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void;
extern fn wgpuRenderPassEncoderSetViewport(render_pass_encoder: *RenderPassEncoder, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void;
extern fn wgpuRenderPassEncoderAddRef(render_pass_encoder: *RenderPassEncoder) void;
extern fn wgpuRenderPassEncoderRelease(render_pass_encoder: *RenderPassEncoder) void;

// wgpu-native
extern fn wgpuRenderPassEncoderSetPushConstants(render_pass_encoder: *RenderPassEncoder, stages: ShaderStage, offset: u32, size_bytes: u32, data: *const anyopaque) void;
extern fn wgpuRenderPassEncoderMultiDrawIndirect(render_pass_encoder: *RenderPassEncoder, buffer: *Buffer, offset: u64, count: u32) void;
extern fn wgpuRenderPassEncoderMultiDrawIndexedIndirect(render_pass_encoder: *RenderPassEncoder, buffer: *Buffer, offset: u64, count: u32) void;
extern fn wgpuRenderPassEncoderMultiDrawIndirectCount(render_pass_encoder: *RenderPassEncoder, buffer: *Buffer, offset: u64, count_buffer: *Buffer, count_buffer_offset: u64, max_count: u32) void;
extern fn wgpuRenderPassEncoderMultiDrawIndexedIndirectCount(render_pass_encoder: *RenderPassEncoder, buffer: *Buffer, offset: u64, count_buffer: *Buffer, count_buffer_offset: u64, max_count: u32) void;
extern fn wgpuRenderPassEncoderBeginPipelineStatisticsQuery(render_pass_encoder: *RenderPassEncoder, query_set: *QuerySet, query_index: u32) void;
extern fn wgpuRenderPassEncoderEndPipelineStatisticsQuery(render_pass_encoder: *RenderPassEncoder) void;
extern fn wgpuRenderPassEncoderWriteTimestamp(render_pass_encoder: *RenderPassEncoder, query_set: *QuerySet, query_index: u32) void;

pub const RenderPassEncoder = opaque {
    pub inline fn beginOcclusionQuery(self: *RenderPassEncoder, query_index: u32) void {
        wgpuRenderPassEncoderBeginOcclusionQuery(self, query_index);
    }
    pub inline fn draw(self: *RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        wgpuRenderPassEncoderDraw(self, vertex_count, instance_count, first_vertex, first_instance);
    }
    pub inline fn drawIndexed(self: *RenderPassEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        wgpuRenderPassEncoderDrawIndexed(self, index_count, instance_count, first_index, base_vertex, first_instance);
    }
    pub inline fn drawIndexedIndirect(self: *RenderPassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        wgpuRenderPassEncoderDrawIndexedIndirect(self, indirect_buffer, indirect_offset);
    }
    pub inline fn drawIndirect(self: *RenderPassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        wgpuRenderPassEncoderDrawIndirect(self, indirect_buffer, indirect_offset);
    }
    pub inline fn end(self: *RenderPassEncoder) void {
        wgpuRenderPassEncoderEnd(self);
    }
    pub inline fn endOcclusionQuery(self: *RenderPassEncoder) void {
        wgpuRenderPassEncoderEndOcclusionQuery(self);
    }
    pub inline fn executeBundles(self: *RenderPassEncoder, bundles: []const *const RenderBundle) void {
        wgpuRenderPassEncoderExecuteBundles(self, bundles.len, bundles.ptr);
    }
    pub inline fn insertDebugMarker(self: *RenderPassEncoder, marker_label: []const u8) void {
        wgpuRenderPassEncoderInsertDebugMarker(self, StringView.fromSlice(marker_label));
    }
    pub inline fn popDebugGroup(self: *RenderPassEncoder) void {
        wgpuRenderPassEncoderPopDebugGroup(self);
    }
    pub inline fn pushDebugGroup(self: *RenderPassEncoder, group_label: []const u8) void {
        wgpuRenderPassEncoderPushDebugGroup(self, StringView.fromSlice(group_label));
    }
    pub inline fn setBindGroup(self: *RenderPassEncoder, group_index: u32, group: *BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        wgpuRenderPassEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }
    pub inline fn setBlendConstant(self: *RenderPassEncoder, color: *const Color) void {
        wgpuRenderPassEncoderSetBlendConstant(self, color);
    }
    pub inline fn setIndexBuffer(self: *RenderPassEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void {
        wgpuRenderPassEncoderSetIndexBuffer(self, buffer, format, offset, size);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L153
    // pub inline fn setLabel(self: *RenderPassEncoder, label: []const u8) void {
    //     wgpuRenderPassEncoderSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn setPipeline(self: *RenderPassEncoder, pipeline: *RenderPipeline) void {
        wgpuRenderPassEncoderSetPipeline(self, pipeline);
    }
    pub inline fn setScissorRect(self: *RenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void {
        wgpuRenderPassEncoderSetScissorRect(self, x, y, width, height);
    }
    pub inline fn setStencilReference(self: *RenderPassEncoder, stencil_reference: u32) void {
        wgpuRenderPassEncoderSetStencilReference(self, stencil_reference);
    }
    pub inline fn setVertexBuffer(self: *RenderPassEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void {
        wgpuRenderPassEncoderSetVertexBuffer(self, slot, buffer, offset, size);
    }
    pub inline fn setViewport(self: *RenderPassEncoder, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
        wgpuRenderPassEncoderSetViewport(self, x, y, width, height, min_depth, max_depth);
    }
    pub inline fn addRef(self: *RenderPassEncoder) void {
        wgpuRenderPassEncoderAddRef(self);
    }
    pub inline fn release(self: *RenderPassEncoder) void {
        wgpuRenderPassEncoderRelease(self);
    }

    // wgpu-native
    pub inline fn setPushConstants(self: *RenderPassEncoder, stages: ShaderStage, offset: u32, size_bytes: u32, data: *const anyopaque) void {
        wgpuRenderPassEncoderSetPushConstants(self, stages, offset, size_bytes, data);
    }
    pub inline fn multiDrawIndirect(self: *RenderPassEncoder, buffer: *Buffer, offset: u64, count: u32) void {
        wgpuRenderPassEncoderMultiDrawIndirect(self, buffer, offset, count);
    }
    pub inline fn multiDrawIndexedIndirect(self: *RenderPassEncoder, buffer: *Buffer, offset: u64, count: u32) void {
        wgpuRenderPassEncoderMultiDrawIndexedIndirect(self, buffer, offset, count);
    }
    pub inline fn multiDrawIndirectCount(self: *RenderPassEncoder, buffer: *Buffer, offset: u64, count_buffer: *Buffer, count_buffer_offset: u64, max_count: u32) void {
        wgpuRenderPassEncoderMultiDrawIndirectCount(self, buffer, offset, count_buffer, count_buffer_offset, max_count);
    }
    pub inline fn multiDrawIndexedIndirectCount(self: *RenderPassEncoder, buffer: *Buffer, offset: u64, count_buffer: *Buffer, count_buffer_offset: u64, max_count: u32) void {
        wgpuRenderPassEncoderMultiDrawIndexedIndirectCount(self, buffer, offset, count_buffer, count_buffer_offset, max_count);
    }
    pub inline fn beginPipelineStatisticsQuery(self: *RenderPassEncoder, query_set: *QuerySet, query_index: u32) void {
        wgpuRenderPassEncoderBeginPipelineStatisticsQuery(self, query_set, query_index);
    }
    pub inline fn endPipelineStatisticsQuery(self: *RenderPassEncoder) void {
        wgpuRenderPassEncoderEndPipelineStatisticsQuery(self);
    }
    pub inline fn writeTimestamp(self: *RenderPassEncoder, query_set: *QuerySet, query_index: u32) void {
        wgpuRenderPassEncoderWriteTimestamp(self, query_set, query_index);
    }
};

pub const CommandBufferDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
};

pub const CommandBufferProcs = struct {
    pub const SetLabel = *const fn(*CommandBuffer, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*CommandBuffer) callconv(.c) void;
    pub const Release = *const fn(*CommandBuffer) callconv(.c) void;
};

extern fn wgpuCommandBufferSetLabel(command_buffer: *CommandBuffer, label: StringView) void;
extern fn wgpuCommandBufferAddRef(command_buffer: *CommandBuffer) void;
extern fn wgpuCommandBufferRelease(command_buffer: *CommandBuffer) void;

pub const CommandBuffer = opaque {
    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L35
    // pub inline fn setLabel(self: *CommandBuffer, label: []const u8) void {
    //     wgpuCommandBufferSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *CommandBuffer) void {
        wgpuCommandBufferAddRef(self);
    }
    pub inline fn release(self: *CommandBuffer) void {
        wgpuCommandBufferRelease(self);
    }
};

pub const CommandEncoderProcs = struct {
    pub const BeginComputePass = *const fn(*CommandEncoder, ?*const ComputePassDescriptor) callconv(.c) ?*ComputePassEncoder;
    pub const BeginRenderPass = *const fn(*CommandEncoder, *const RenderPassDescriptor) callconv(.c) ?*RenderPassEncoder;
    pub const ClearBuffer = *const fn(*CommandEncoder, *Buffer, u64, u64) callconv(.c) void;
    pub const CopyBufferToBuffer = *const fn(*CommandEncoder, *Buffer, u64, *Buffer, u64, u64) callconv(.c) void;
    pub const CopyBufferToTexture = *const fn(*CommandEncoder, *const TexelCopyBufferInfo, *const TexelCopyTextureInfo, *const Extent3D) callconv(.c) void;
    pub const CopyTextureToBuffer = *const fn(*CommandEncoder, *const TexelCopyTextureInfo, *const TexelCopyBufferInfo, *const Extent3D) callconv(.c) void;
    pub const CopyTextureToTexture = *const fn(*CommandEncoder, *const TexelCopyTextureInfo, *const TexelCopyTextureInfo, *const Extent3D) callconv(.c) void;
    pub const Finish = *const fn(*CommandEncoder, ?*const CommandBufferDescriptor) callconv(.c) ?*CommandBuffer;
    pub const InsertDebugMarker = *const fn(*CommandEncoder, StringView) callconv(.c) void;
    pub const PopDebugGroup = *const fn(*CommandEncoder) callconv(.c) void;
    pub const PushDebugGroup = *const fn(*CommandEncoder, StringView) callconv(.c) void;
    pub const ResolveQuerySet = *const fn(*CommandEncoder, *QuerySet, u32, u32, *Buffer, u64) callconv(.c) void;
    pub const SetLabel = *const fn(*CommandEncoder, StringView) callconv(.c) void;
    pub const WriteTimestamp = *const fn(*CommandEncoder, *QuerySet, u32) callconv(.c) void;
    pub const AddRef = *const fn(*CommandEncoder) callconv(.c) void;
    pub const Release = *const fn(*CommandEncoder) callconv(.c) void;
};

extern fn wgpuCommandEncoderBeginComputePass(command_encoder: *CommandEncoder, descriptor: ?*const ComputePassDescriptor) ?*ComputePassEncoder;
extern fn wgpuCommandEncoderBeginRenderPass(command_encoder: *CommandEncoder, descriptor: *const RenderPassDescriptor) ?*RenderPassEncoder;
extern fn wgpuCommandEncoderClearBuffer(command_encoder: *CommandEncoder, buffer: *Buffer, offset: u64, size: u64) void;
extern fn wgpuCommandEncoderCopyBufferToBuffer(command_encoder: *CommandEncoder, source: *Buffer, source_offset: u64, destination: *Buffer, destination_offset: u64, size: u64) void;
extern fn wgpuCommandEncoderCopyBufferToTexture(command_encoder: *CommandEncoder, source: *const TexelCopyBufferInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void;
extern fn wgpuCommandEncoderCopyTextureToBuffer(command_encoder: *CommandEncoder, source: *const TexelCopyTextureInfo, destination: *const TexelCopyBufferInfo, copy_size: *const Extent3D) void;
extern fn wgpuCommandEncoderCopyTextureToTexture(command_encoder: *CommandEncoder, source: *const TexelCopyTextureInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void;
extern fn wgpuCommandEncoderFinish(command_encoder: *CommandEncoder, descriptor: ?*const CommandBufferDescriptor) ?*CommandBuffer;
extern fn wgpuCommandEncoderInsertDebugMarker(command_encoder: *CommandEncoder, marker_label: StringView) void;
extern fn wgpuCommandEncoderPopDebugGroup(command_encoder: *CommandEncoder) void;
extern fn wgpuCommandEncoderPushDebugGroup(command_encoder: *CommandEncoder, group_label: StringView) void;
extern fn wgpuCommandEncoderResolveQuerySet(command_encoder: *CommandEncoder, query_set: *QuerySet, first_query: u32, query_count: u32, destination: *Buffer, destination_offset: u64) void;
extern fn wgpuCommandEncoderSetLabel(command_encoder: *CommandEncoder, label: StringView) void;
extern fn wgpuCommandEncoderWriteTimestamp(command_encoder: *CommandEncoder, query_set: *QuerySet, query_index: u32) void;
extern fn wgpuCommandEncoderAddRef(command_encoder: *CommandEncoder) void;
extern fn wgpuCommandEncoderRelease(command_encoder: *CommandEncoder) void;

pub const CommandEncoder = opaque {
    pub inline fn beginComputePass(self: *CommandEncoder, descriptor: ?*const ComputePassDescriptor) ?*ComputePassEncoder {
        return wgpuCommandEncoderBeginComputePass(self, descriptor);
    }
    pub inline fn beginRenderPass(self: *CommandEncoder, descriptor: *const RenderPassDescriptor) ?*RenderPassEncoder {
        return wgpuCommandEncoderBeginRenderPass(self, descriptor);
    }
    pub inline fn clearBuffer(self: *CommandEncoder, buffer: *Buffer, offset: u64, size: u64) void {
        wgpuCommandEncoderClearBuffer(self, buffer, offset, size);
    }
    pub inline fn copyBufferToBuffer(self: *CommandEncoder, source: *Buffer, source_offset: u64, destination: *Buffer, destination_offset: u64, size: u64) void {
        wgpuCommandEncoderCopyBufferToBuffer(self, source, source_offset, destination, destination_offset, size);
    }
    pub inline fn copyBufferToTexture(self: *CommandEncoder, source: *const TexelCopyBufferInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void {
        wgpuCommandEncoderCopyBufferToTexture(self, source, destination, copy_size);
    }
    pub inline fn copyTextureToBuffer(self: *CommandEncoder, source: *const TexelCopyTextureInfo, destination: *const TexelCopyBufferInfo, copy_size: *const Extent3D) void {
        wgpuCommandEncoderCopyTextureToBuffer(self, source, destination, copy_size);
    }
    pub inline fn copyTextureToTexture(self: *CommandEncoder, source: *const TexelCopyTextureInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void {
        wgpuCommandEncoderCopyTextureToTexture(self, source, destination, copy_size);
    }
    pub inline fn finish(self: *CommandEncoder, descriptor: ?*const CommandBufferDescriptor) ?*CommandBuffer {
        return wgpuCommandEncoderFinish(self, descriptor);
    }
    pub inline fn insertDebugMarker(self: *CommandEncoder, marker_label: []const u8) void {
        wgpuCommandEncoderInsertDebugMarker(self, StringView.fromSlice(marker_label));
    }
    pub inline fn popDebugGroup(self: *CommandEncoder) void {
        wgpuCommandEncoderPopDebugGroup(self);
    }
    pub inline fn pushDebugGroup(self: *CommandEncoder, group_label: []const u8) void {
        wgpuCommandEncoderPushDebugGroup(self, StringView.fromSlice(group_label));
    }
    pub inline fn resolveQuerySet(self: *CommandEncoder, query_set: *QuerySet, first_query: u32, query_count: u32, destination: *Buffer, destination_offset: u64) void {
        wgpuCommandEncoderResolveQuerySet(self, query_set, first_query, query_count, destination, destination_offset);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L43
    // pub inline fn setLabel(self: *CommandEncoder, label: []const u8) void {
    //     wgpuCommandEncoderSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn writeTimestamp(self: *CommandEncoder, query_set: *QuerySet, query_index: u32) void {
        wgpuCommandEncoderWriteTimestamp(self, query_set, query_index);
    }
    pub inline fn addRef(self: *CommandEncoder) void {
        wgpuCommandEncoderAddRef(self);
    }
    pub inline fn release(self: *CommandEncoder) void {
        wgpuCommandEncoderRelease(self);
    }
};
