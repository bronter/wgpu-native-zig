const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const ShaderModule = @import("shader.zig").ShaderModule;
const BindGroupLayout = @import("bind_group.zig").BindGroupLayout;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const IndexFormat = _misc.IndexFormat;
const CompareFunction = _misc.CompareFunction;
const WGPUFlags = _misc.WGPUFlags;

const TextureFormat = @import("texture.zig").TextureFormat;

pub const PipelineLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    bind_group_layout_count: usize,
    bind_group_layouts: [*]const BindGroupLayout,
};

pub const PipelineLayoutProcs = struct {
    pub const SetLabel = *const fn(*PipelineLayout, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*PipelineLayout) callconv(.C) void;
    pub const Release = *const fn(*PipelineLayout) callconv(.C) void;
};

extern fn wgpuPipelineLayoutSetLabel(pipeline_layout: *PipelineLayout, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuPipelineLayoutReference(pipeline_layout: *PipelineLayout) callconv(.C) void;
extern fn wgpuPipelineLayoutRelease(pipeline_layout: *PipelineLayout) callconv(.C) void;

pub const PipelineLayout = opaque {
    pub inline fn setLabel(self: *PipelineLayout, label: ?[*:0]const u8) void {
        wgpuPipelineLayoutSetLabel(self, label);
    }
    pub inline fn reference(self: *PipelineLayout) void {
        wgpuPipelineLayoutReference(self);
    }
    pub inline fn release(self: *PipelineLayout) void {
        wgpuPipelineLayoutRelease(self);
    }
};

pub const ConstantEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    key: [*:0]const u8 = null,
    value: f64,
};

pub const ProgrammableStageDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: *ShaderModule,
    entry_point: ?[*:0]const u8 = null,
    constant_count: usize,
    constants: [*]const ConstantEntry,
};

pub const ComputePipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    layout: ?*PipelineLayout,
    compute: ProgrammableStageDescriptor,
};

pub const CreatePipelineAsyncStatus = enum(u32) {
    success          = 0x00000000,
    validation_error = 0x00000001,
    internal_error   = 0x00000002,
    device_lost      = 0x00000003,
    device_destroyed = 0x00000004,
    unknown          = 0x00000005,
};

pub const CreatComputePipelineAsyncCallback = *const fn(
    status: CreatePipelineAsyncStatus,
    pipeline: ?*ComputePipeline,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque
) callconv(.C) void;

pub const ComputePipelineProcs = struct {
    pub const GetBindGroupLayout = *const fn(*ComputePipeline, u32) callconv(.C) ?*BindGroupLayout;
    pub const SetLabel = *const fn(*ComputePipeline, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*ComputePipeline) callconv(.C) void;
    pub const Release = *const fn(*ComputePipeline) callconv(.C) void;
};

extern fn wgpuComputePipelineGetBindGroupLayout(compute_pipeline: *ComputePipeline, group_index: u32) callconv(.C) ?*BindGroupLayout;
extern fn wgpuComputePipelineSetLabel(compute_pipeline: *ComputePipeline, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuComputePipelineReference(compute_pipeline: *ComputePipeline) callconv(.C) void;
extern fn wgpuComputePipelineRelease(compute_pipeline: *ComputePipeline) callconv(.C) void;

pub const ComputePipeline = opaque {
    pub inline fn getBindGroupLayout(self: *ComputePipeline, group_index: u32) ?*BindGroupLayout {
        return wgpuComputePipelineGetBindGroupLayout(self, group_index);
    }
    pub inline fn setLabel(self: *ComputePipeline, label: ?[*:0]const u8) void {
        wgpuComputePipelineSetLabel(self, label);
    }
    pub inline fn reference(self: *ComputePipeline) void {
        wgpuComputePipelineReference(self);
    }
    pub inline fn release(self: *ComputePipeline) void {
        wgpuComputePipelineRelease(self);
    }
};

pub const VertexStepMode = enum(u32) {
    vertex                 = 0x00000000,
    instance               = 0x00000001,
    vertex_buffer_not_used = 0x00000002,
};

pub const VertexFormat = enum(u32) {
    @"undefined" = 0x00000000,
    uint8x2   = 0x00000001,
    uint8x4   = 0x00000002,
    sint8x2   = 0x00000003,
    sint8x4   = 0x00000004,
    unorm8x2  = 0x00000005,
    unorm8x4  = 0x00000006,
    snorm8x2  = 0x00000007,
    snorm8x4  = 0x00000008,
    uint16x2  = 0x00000009,
    uint16x4  = 0x0000000A,
    sint16x2  = 0x0000000B,
    sint16x4  = 0x0000000C,
    unorm16x2 = 0x0000000D,
    unorm16x4 = 0x0000000E,
    snorm16x2 = 0x0000000F,
    snorm16x4 = 0x00000010,
    float16x2 = 0x00000011,
    float16x4 = 0x00000012,
    float32   = 0x00000013,
    float32x2 = 0x00000014,
    float32x3 = 0x00000015,
    float32x4 = 0x00000016,
    uint32    = 0x00000017,
    uint32x2  = 0x00000018,
    uint32x3  = 0x00000019,
    uint32x4  = 0x0000001A,
    sint32    = 0x0000001B,
    sint32x2  = 0x0000001C,
    sint32x3  = 0x0000001D,
    sint32x4  = 0x0000001E,
};

pub const VertexAttribute = extern struct {
    format: VertexFormat,
    offset: u64,
    shader_location: u32,
};

pub const VertexBufferLayout = extern struct {
    array_stride: u64,
    step_mode: VertexStepMode,
    attribute_count: usize,
    attributes: [*]const VertexAttribute,
};

pub const VertexState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: *ShaderModule,
    entry_point: ?[*:0]const u8 = null,
    constant_count: usize,
    constants: [*]const ConstantEntry,
    buffer_count: usize,
    buffers: [*]const VertexBufferLayout,
};

pub const PrimitiveTopology = enum(u32) {
    point_list     = 0x00000000,
    line_list      = 0x00000001,
    line_strip     = 0x00000002,
    triangle_list  = 0x00000003,
    triangle_strip = 0x00000004,
};

pub const FrontFace = enum(u32) {
    ccw = 0x00000000,
    cw  = 0x00000001,
};

pub const CullMode = enum(u32) {
    none  = 0x00000000,
    front = 0x00000001,
    back  = 0x00000002,
};

pub const PrimitiveDepthClipControl = extern struct {
    chain: ChainedStruct,
    unclipped_depth: WGPUBool,
};
pub const PrimitiveState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    topology: PrimitiveTopology,
    strip_index_format: IndexFormat,
    front_face: FrontFace,
    cull_mode: CullMode,

    pub inline fn withDepthClipControl(self: PrimitiveState, unclipped_depth: bool) PrimitiveState {
        var ps = self;
        ps.next_in_chain = @ptrCast(&PrimitiveDepthClipControl {
            .chain = ChainedStruct {
                .s_type = SType.primitive_depth_clip_control,
            },
            .unclipped_depth = @intFromBool(unclipped_depth),
        });

        return ps;
    }
};

test "chain method compiles" {
    _ = &(PrimitiveState {
        .topology = PrimitiveTopology.triangle_list,
        .strip_index_format = IndexFormat.uint16,
        .front_face = FrontFace.ccw,
        .cull_mode = CullMode.back
    }).withDepthClipControl(false);
}

pub const StencilOperation = enum(u32) {
    keep            = 0x00000000,
    zero            = 0x00000001,
    replace         = 0x00000002,
    invert          = 0x00000003,
    increment_clamp = 0x00000004,
    decrement_clamp = 0x00000005,
    increment_wrap  = 0x00000006,
    decrement_wrap  = 0x00000007,
};

pub const StencilFaceState = extern struct {
    compare: CompareFunction,
    fail_op: StencilOperation,
    depth_fail_op: StencilOperation,
    pass_op: StencilOperation,
};

pub const DepthStencilState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    format: TextureFormat,
    depth_write_enabled: WGPUBool,
    depth_compare: CompareFunction,
    stencil_front: StencilFaceState,
    stencil_back: StencilFaceState,
    stencil_read_mask: u32,
    stencil_write_mask: u32,
    depth_bias: i32,
    depth_bias_slope_scale: f32,
    depth_bias_clamp: f32,
};

pub const MultiSampleState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    count: u32,
    mask: u32,
    alpha_to_coverage_enabled: WGPUBool,
};

pub const BlendOperation = enum(u32) {
    add              = 0x00000000,
    subtract         = 0x00000001,
    reverse_subtract = 0x00000002,
    min              = 0x00000003,
    max              = 0x00000004,
};

pub const BlendFactor = enum(u32) {
    zero                = 0x00000000,
    one                 = 0x00000001,
    src                 = 0x00000002,
    one_minus_src       = 0x00000003,
    src_alpha           = 0x00000004,
    one_minus_src_alpha = 0x00000005,
    dst                 = 0x00000006,
    one_minus_dst       = 0x00000007,
    dst_alpha           = 0x00000008,
    one_minus_dst_alpha = 0x00000009,
    src_alpha_saturated = 0x0000000A,
    constant            = 0x0000000B,
    one_minus_constant  = 0x0000000C,
};

pub const BlendComponent = extern struct {
    operation: BlendOperation,
    src_factor: BlendFactor,
    dst_factor: BlendFactor,
};

pub const BlendState = extern struct {
    color: BlendComponent,
    alpha: BlendComponent,
};

pub const ColorWriteMaskFlags = WGPUFlags;
pub const ColorWriteMask = struct {
    pub const none = @as(u32, 0x00000000);
    pub const red = @as(u32, 0x00000001);
    pub const green = @as(u32, 0x00000002);
    pub const blue = @as(u32, 0x00000004);
    pub const alpha = @as(u32, 0x00000008);
    pub const all = @as(u32, 0x0000000F);
};

pub const ColorTargetState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    format: TextureFormat,
    blend: ?*const BlendState = null,
    write_mask: ColorWriteMaskFlags,
};

pub const FragmentState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: ShaderModule,
    entry_point: ?[*:0]const u8 = null,
    constant_count: usize,
    constants: [*]const ConstantEntry,
    target_count: usize,
    targets: [*]const ColorTargetState,
};

pub const RenderPipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    layout: ?*PipelineLayout = null,
    vertex: VertexState,
    primitive: PrimitiveState,
    depth_stencil: ?*const DepthStencilState = null,
    multisample: MultiSampleState,
    fragment: ?*const FragmentState = null,
};

pub const RenderPipelineProcs = struct {
    pub const GetBindGroupLayout = *const fn(*RenderPipeline, u32) callconv(.C) ?*BindGroupLayout;
    pub const SetLabel = *const fn(*RenderPipeline, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*RenderPipeline) callconv(.C) void;
    pub const Release = *const fn(*RenderPipeline) callconv(.C) void;
};

extern fn wgpuRenderPipelineGetBindGroupLayout(render_pipeline: *RenderPipeline, group_index: u32) callconv(.C) ?*BindGroupLayout;
extern fn wgpuRenderPipelineSetLabel(render_pipeline: *RenderPipeline, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuRenderPipelineReference(render_pipeline: *RenderPipeline) callconv(.C) void;
extern fn wgpuRenderPipelineRelease(render_pipeline: *RenderPipeline) callconv(.C) void;

pub const RenderPipeline = opaque {
    pub inline fn getBindGroupLayout(self: *RenderPipeline, group_index: u32) ?*BindGroupLayout {
        return wgpuRenderPipelineGetBindGroupLayout(self, group_index);
    }
    pub inline fn setLabel(self: *RenderPipeline, label: ?[*:0]const u8) void {
        wgpuRenderPipelineSetLabel(self, label);
    }
    pub inline fn reference(self: *RenderPipeline) void {
        wgpuRenderPipelineReference(self);
    }
    pub inline fn release(self: *RenderPipeline) void {
        wgpuRenderPipelineRelease(self);
    }
};

pub const CreateRenderPipelineAsyncCallback = *const fn(
    status: CreatePipelineAsyncStatus,
    pipeline: ?*RenderPipeline,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque
) callconv(.C) void;