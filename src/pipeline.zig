const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const _shader = @import("shader.zig");
const ShaderModule = _shader.ShaderModule;
const ShaderStage = _shader.ShaderStage;

const BindGroupLayout = @import("bind_group.zig").BindGroupLayout;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const IndexFormat = _misc.IndexFormat;
const CompareFunction = _misc.CompareFunction;
const WGPUFlags = _misc.WGPUFlags;
const StringView = _misc.StringView;
const OptionalBool = _misc.OptionalBool;

const _async = @import("async.zig");
const CallbackMode = _async.CallbackMode;

const TextureFormat = @import("texture.zig").TextureFormat;

pub const PushConstantRange = extern struct {
    stages: ShaderStage,
    start: u32,
    end: u32,
};

pub const PipelineLayoutExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.pipeline_layout_extras,
    },
    push_constant_range_count: usize,
    push_constant_ranges: [*]const PushConstantRange,
};

pub const PipelineLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    bind_group_layout_count: usize,
    bind_group_layouts: [*]const *BindGroupLayout,

    pub inline fn withPushConstantRanges(
        self: PipelineLayoutDescriptor,
        push_constant_range_count: usize,
        push_constant_ranges: [*]const PushConstantRange
    ) PipelineLayoutDescriptor {
        var pld = self;
        pld.next_in_chain = @ptrCast(&PipelineLayoutExtras {
            .push_constant_range_count = push_constant_range_count,
            .push_constant_ranges = push_constant_ranges,
        });
        return pld;
    }
};

pub const PipelineLayoutProcs = struct {
    pub const SetLabel = *const fn(*PipelineLayout, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*PipelineLayout) callconv(.c) void;
    pub const Release = *const fn(*PipelineLayout) callconv(.c) void;
};

extern fn wgpuPipelineLayoutSetLabel(pipeline_layout: *PipelineLayout, label: StringView) void;
extern fn wgpuPipelineLayoutAddRef(pipeline_layout: *PipelineLayout) void;
extern fn wgpuPipelineLayoutRelease(pipeline_layout: *PipelineLayout) void;

pub const PipelineLayout = opaque {

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L116
    // pub inline fn setLabel(self: *PipelineLayout, label: []const u8) void {
    //     wgpuPipelineLayoutSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *PipelineLayout) void {
        wgpuPipelineLayoutAddRef(self);
    }
    pub inline fn release(self: *PipelineLayout) void {
        wgpuPipelineLayoutRelease(self);
    }
};

pub const ConstantEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    key: StringView,
    value: f64,
};

pub const ProgrammableStageDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: *ShaderModule,
    entry_point: StringView = StringView {},
    constant_count: usize = 0,
    constants: [*]const ConstantEntry = &[0]ConstantEntry {},
};

pub const ComputePipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    layout: ?*PipelineLayout = null,
    compute: ProgrammableStageDescriptor,
};

pub const CreatePipelineAsyncStatus = enum(u32) {
    success          = 0x00000001,
    instance_dropped = 0x00000002,
    validation_error = 0x00000003,
    internal_error   = 0x00000004,
    unknown          = 0x00000005,
};

pub const CreateComputePipelineAsyncCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: CreateComputePipelineAsyncCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

// TODO: This should probably be in device.zig, as well as its RenderPipeline counterpart
pub const CreateComputePipelineAsyncCallback = *const fn(
    status: CreatePipelineAsyncStatus,
    pipeline: ?*ComputePipeline,
    message: StringView,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
) callconv(.c) void;

pub const ComputePipelineProcs = struct {
    pub const GetBindGroupLayout = *const fn(*ComputePipeline, u32) callconv(.c) ?*BindGroupLayout;
    pub const SetLabel = *const fn(*ComputePipeline, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*ComputePipeline) callconv(.c) void;
    pub const Release = *const fn(*ComputePipeline) callconv(.c) void;
};

extern fn wgpuComputePipelineGetBindGroupLayout(compute_pipeline: *ComputePipeline, group_index: u32) ?*BindGroupLayout;
extern fn wgpuComputePipelineSetLabel(compute_pipeline: *ComputePipeline, label: StringView) void;
extern fn wgpuComputePipelineAddRef(compute_pipeline: *ComputePipeline) void;
extern fn wgpuComputePipelineRelease(compute_pipeline: *ComputePipeline) void;

pub const ComputePipeline = opaque {
    pub inline fn getBindGroupLayout(self: *ComputePipeline, group_index: u32) ?*BindGroupLayout {
        return wgpuComputePipelineGetBindGroupLayout(self, group_index);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L59
    // pub inline fn setLabel(self: *ComputePipeline, label: []const u8) void {
    //     wgpuComputePipelineSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *ComputePipeline) void {
        wgpuComputePipelineAddRef(self);
    }
    pub inline fn release(self: *ComputePipeline) void {
        wgpuComputePipelineRelease(self);
    }
};

pub const VertexStepMode = enum(u32) {
    vertex_buffer_not_used = 0x00000000, // This VertexBufferLayout is a "hole" in the VertexState `buffers` array.
    @"undefined"           = 0x00000001, // Indicates no value is passed for this argument.
    vertex                 = 0x00000002,
    instance               = 0x00000003,
};

pub const VertexFormat = enum(u32) {
    uint8           = 0x00000001,
    uint8x2         = 0x00000002,
    uint8x4         = 0x00000003,
    sint8           = 0x00000004,
    sint8x2         = 0x00000005,
    sint8x4         = 0x00000006,
    unorm8          = 0x00000007,
    unorm8x2        = 0x00000008,
    unorm8x4        = 0x00000009,
    snorm8          = 0x0000000A,
    snorm8x2        = 0x0000000B,
    snorm8x4        = 0x0000000C,
    uint16          = 0x0000000D,
    uint16x2        = 0x0000000E,
    uint16x4        = 0x0000000F,
    sint16          = 0x00000010,
    sint16x2        = 0x00000011,
    sint16x4        = 0x00000012,
    unorm16         = 0x00000013,
    unorm16x2       = 0x00000014,
    unorm16x4       = 0x00000015,
    snorm16         = 0x00000016,
    snorm16x2       = 0x00000017,
    snorm16x4       = 0x00000018,
    float16         = 0x00000019,
    float16x2       = 0x0000001A,
    float16x4       = 0x0000001B,
    float32         = 0x0000001C,
    float32x2       = 0x0000001D,
    float32x3       = 0x0000001E,
    float32x4       = 0x0000001F,
    uint32          = 0x00000020,
    uint32x2        = 0x00000021,
    uint32x3        = 0x00000022,
    uint32x4        = 0x00000023,
    sint32          = 0x00000024,
    sint32x2        = 0x00000025,
    sint32x3        = 0x00000026,
    sint32x4        = 0x00000027,
    unorm10_10_10_2 = 0x00000028,
    unorm8x4_bgra   = 0x00000029,
};

pub const VertexAttribute = extern struct {
    format: VertexFormat,
    offset: u64,
    shader_location: u32,
};

pub const VertexBufferLayout = extern struct {
    // The step mode for the vertex buffer. If VertexStepMode.vertex_buffer_not_used,
    // indicates a "hole" in the parent VertexState `buffers` array:
    // the pipeline does not use a vertex buffer at this `location`.
    step_mode: VertexStepMode = VertexStepMode.vertex,

    array_stride: u64,
    attribute_count: usize,
    attributes: [*]const VertexAttribute,
};

pub const VertexState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: *ShaderModule,
    entry_point: StringView = StringView {},
    constant_count: usize = 0,
    constants: [*]const ConstantEntry = &[0]ConstantEntry {},
    buffer_count: usize = 0,
    buffers: [*]const VertexBufferLayout = &[0]VertexBufferLayout {},
};

pub const PrimitiveTopology = enum(u32) {
    @"undefined"   = 0x00000000, // Indicates no value is passed for this argument.
    point_list     = 0x00000001,
    line_list      = 0x00000002,
    line_strip     = 0x00000003,
    triangle_list  = 0x00000004,
    triangle_strip = 0x00000005,
};

pub const FrontFace = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument.
    ccw          = 0x00000001,
    cw           = 0x00000002,
};

pub const CullMode = enum(u32) {
    @"undefined" = 0x00000000, // Indicates no value is passed for this argument
    none         = 0x00000001,
    front        = 0x00000002,
    back         = 0x00000003,
};

pub const PrimitiveState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    topology: PrimitiveTopology = PrimitiveTopology.triangle_list,
    strip_index_format: IndexFormat = IndexFormat.@"undefined",
    front_face: FrontFace = FrontFace.ccw,
    cull_mode: CullMode = CullMode.none,
    unclipped_depth: WGPUBool = @intFromBool(false),
};

pub const StencilOperation = enum(u32) {
    @"undefined"    = 0x00000000, // Indicates no value is passed for this argument.
    keep            = 0x00000001,
    zero            = 0x00000002,
    replace         = 0x00000003,
    invert          = 0x00000004,
    increment_clamp = 0x00000005,
    decrement_clamp = 0x00000006,
    increment_wrap  = 0x00000007,
    decrement_wrap  = 0x00000008,
};

pub const StencilFaceState = extern struct {
    compare: CompareFunction = CompareFunction.always,
    fail_op: StencilOperation = StencilOperation.keep,
    depth_fail_op: StencilOperation = StencilOperation.keep,
    pass_op: StencilOperation = StencilOperation.keep,
};

pub const DepthStencilState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    format: TextureFormat,
    depth_write_enabled: OptionalBool = OptionalBool.@"undefined",
    depth_compare: CompareFunction = CompareFunction.@"undefined",
    stencil_front: StencilFaceState,
    stencil_back: StencilFaceState,
    stencil_read_mask: u32 = 0xffffffff,
    stencil_write_mask: u32 = 0xffffffff,
    depth_bias: i32 = 0,
    depth_bias_slope_scale: f32 = 0.0,
    depth_bias_clamp: f32 = 0.0,
};

pub const MultisampleState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    count: u32 = 1,
    mask: u32 = 0xffffffff,
    alpha_to_coverage_enabled: WGPUBool = @intFromBool(false),
};

pub const BlendOperation = enum(u32) {
    @"undefined"     = 0x00000000, // Indicates no value is passed for this argument
    add              = 0x00000001,
    subtract         = 0x00000002,
    reverse_subtract = 0x00000003,
    min              = 0x00000004,
    max              = 0x00000005,
};

pub const BlendFactor = enum(u32) {
    @"undefined"          = 0x00000000, // Indicates no value is passed for this argument
    zero                  = 0x00000001,
    one                   = 0x00000002,
    src                   = 0x00000003,
    one_minus_src         = 0x00000004,
    src_alpha             = 0x00000005,
    one_minus_src_alpha   = 0x00000006,
    dst                   = 0x00000007,
    one_minus_dst         = 0x00000008,
    dst_alpha             = 0x00000009,
    one_minus_dst_alpha   = 0x0000000A,
    src_alpha_saturated   = 0x0000000B,
    constant              = 0x0000000C,
    one_minus_constant    = 0x0000000D,
    src_1                 = 0x0000000E,
    one_minus_src_1       = 0x0000000F,
    src_1_alpha           = 0x00000010,
    one_minus_src_1_alpha = 0x00000011,
};

pub const BlendComponent = extern struct {
    operation: BlendOperation = BlendOperation.add,
    src_factor: BlendFactor = BlendFactor.one,
    dst_factor: BlendFactor = BlendFactor.zero,

    // Preset components borrowed from wgpu-types
    pub const replace = BlendComponent {
        .operation = BlendOperation.add,
        .src_factor = BlendFactor.one,
        .dst_factor = BlendFactor.zero,
    };
    pub const over = BlendComponent {
        .operation = BlendOperation.add,
        .src_factor = BlendFactor.one,
        .dst_factor = BlendFactor.one_minus_src_alpha,
    };
};

pub const BlendState = extern struct {
    color: BlendComponent,
    alpha: BlendComponent,

    // Preset blend states borrowed from wgpu-types
    pub const replace = BlendState {
        .color = BlendComponent.replace,
        .alpha = BlendComponent.replace,
    };
    pub const alpha_blending = BlendState {
        .color = BlendComponent {
            .operation = BlendOperation.add,
            .src_factor = BlendFactor.src_alpha,
            .dst_factor = BlendFactor.one_minus_src_alpha,
        },
        .alpha = BlendComponent.over,
    };
    pub const premultiplied_alpha_blending = BlendState {
        .color = BlendComponent.over,
        .alpha = BlendComponent.over,
    };
};

pub const ColorWriteMask = WGPUFlags;
pub const ColorWriteMasks = struct {
    pub const none  = @as(ColorWriteMask, 0x0000000000000000);
    pub const red   = @as(ColorWriteMask, 0x0000000000000001);
    pub const green = @as(ColorWriteMask, 0x0000000000000002);
    pub const blue  = @as(ColorWriteMask, 0x0000000000000004);
    pub const alpha = @as(ColorWriteMask, 0x0000000000000008);
    pub const all        = none | red | green | blue | alpha;
};

pub const ColorTargetState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,

    // The texture format of the target. If TextureFormat.@"undefined",
    // indicates a "hole" in the parent FragmentState `targets` array:
    // the pipeline does not output a value at this `location`.
    format: TextureFormat,

    blend: ?*const BlendState = null,
    write_mask: ColorWriteMask = ColorWriteMasks.all,
};

pub const FragmentState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: *ShaderModule,
    entry_point: StringView = StringView {},
    constant_count: usize = 0,
    constants: [*]const ConstantEntry = &[0]ConstantEntry {},
    target_count: usize,
    targets: [*]const ColorTargetState,
};

pub const RenderPipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    layout: ?*PipelineLayout = null,
    vertex: VertexState,
    primitive: PrimitiveState,
    depth_stencil: ?*const DepthStencilState = null,
    multisample: MultisampleState,
    fragment: ?*const FragmentState = null,
};

pub const RenderPipelineProcs = struct {
    pub const GetBindGroupLayout = *const fn(*RenderPipeline, u32) callconv(.c) ?*BindGroupLayout;
    pub const SetLabel = *const fn(*RenderPipeline, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*RenderPipeline) callconv(.c) void;
    pub const Release = *const fn(*RenderPipeline) callconv(.c) void;
};

extern fn wgpuRenderPipelineGetBindGroupLayout(render_pipeline: *RenderPipeline, group_index: u32) ?*BindGroupLayout;
extern fn wgpuRenderPipelineSetLabel(render_pipeline: *RenderPipeline, label: StringView) void;
extern fn wgpuRenderPipelineAddRef(render_pipeline: *RenderPipeline) void;
extern fn wgpuRenderPipelineRelease(render_pipeline: *RenderPipeline) void;

pub const RenderPipeline = opaque {
    pub inline fn getBindGroupLayout(self: *RenderPipeline, group_index: u32) ?*BindGroupLayout {
        return wgpuRenderPipelineGetBindGroupLayout(self, group_index);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L161
    // pub inline fn setLabel(self: *RenderPipeline, label: []const u8) void {
    //     wgpuRenderPipelineSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *RenderPipeline) void {
        wgpuRenderPipelineAddRef(self);
    }
    pub inline fn release(self: *RenderPipeline) void {
        wgpuRenderPipelineRelease(self);
    }
};

pub const CreateRenderPipelineAsyncCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: CreateRenderPipelineAsyncCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

pub const CreateRenderPipelineAsyncCallback = *const fn(
    status: CreatePipelineAsyncStatus,
    pipeline: ?*RenderPipeline,
    message: StringView,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
) callconv(.c) void;
