const _chained_struct = @import("chained_struct.zig");
const ChainedStruct = _chained_struct.ChainedStruct;
const SType = _chained_struct.SType;

const StringView = @import("misc.zig").StringView;

pub const QueryType = enum(u32) {
    occlusion           = 0x00000001,
    timestamp           = 0x00000002,

    // wgpu-native pipeline statistics
    pipeline_statistics = 0x00030000,
};

pub const PipelineStatisticName = enum(u32) {
    vertex_shader_invocations   = 0x00000000,
    clipper_invocations         = 0x00000001,
    clipper_primitives_out      = 0x00000002,
    fragment_shader_invocations = 0x00000003,
    compute_shader_invocations  = 0x00000004,
};

pub const QuerySetDescriptorExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.query_set_descriptor_extras,
    },
    pipeline_statistics: [*]const PipelineStatisticName,
    pipeline_statistic_count: usize,
};

pub const QuerySetDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
    @"type": QueryType,
    count: u32,

    pub inline fn withPipelineStatistics(
        self: QuerySetDescriptor,
        pipeline_statistic_count: usize,
        pipeline_statistics: [*]const PipelineStatisticName
    ) QuerySetDescriptor {
        var qsd = self;
        qsd.next_in_chain = @ptrCast(&QuerySetDescriptorExtras {
            .pipeline_statistics = pipeline_statistics,
            .pipeline_statistic_count = pipeline_statistic_count,
        });
        return qsd;
    }
};

pub const QuerySetProcs = struct {
    pub const Destroy = *const fn(*QuerySet) callconv(.c) void;
    pub const GetCount = *const fn(*QuerySet) callconv(.c) u32;
    pub const GetType = *const fn(*QuerySet) callconv(.c) QueryType;
    pub const SetLabel = *const fn(*QuerySet, StringView) callconv(.c) void;
    pub const AddRef = *const fn(*QuerySet) callconv(.c) void;
    pub const Release = *const fn(*QuerySet) callconv(.c) void;
};

extern fn wgpuQuerySetDestroy(query_set: *QuerySet) void;
extern fn wgpuQuerySetGetCount(query_set: *QuerySet) u32;
extern fn wgpuQuerySetGetType(query_set: *QuerySet) QueryType;
extern fn wgpuQuerySetSetLabel(query_set: *QuerySet, label: StringView) void;
extern fn wgpuQuerySetAddRef(query_set: *QuerySet) void;
extern fn wgpuQuerySetRelease(query_set: *QuerySet) void;

pub const QuerySet = opaque {
    pub inline fn destroy(self: *QuerySet) void {
        wgpuQuerySetDestroy(self);
    }
    pub inline fn getCount(self: *QuerySet) u32 {
        return wgpuQuerySetGetCount(self);
    }
    pub inline fn getType(self: *QuerySet) QueryType {
        return wgpuQuerySetGetType(self);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L124
    // pub inline fn setLabel(self: *QuerySet, label: []const u8) void {
    //     wgpuQuerySetSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn addRef(self: *QuerySet) void {
        wgpuQuerySetAddRef(self);
    }
    pub inline fn release(self: *QuerySet) void {
        wgpuQuerySetRelease(self);
    }
};