const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

pub const QueryType = enum(u32) {
    occlusion = 0x00000000,
    timestamp = 0x00000001,
};

pub const QuerySetDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    @"type": QueryType,
    count: u32,
};

pub const QuerySetProcs = struct {
    pub const Destroy = *const fn(*QuerySet) callconv(.C) void;
    pub const GetCount = *const fn(*QuerySet) callconv(.C) u32;
    pub const GetType = *const fn(*QuerySet) callconv(.C) QueryType;
    pub const SetLabel = *const fn(*QuerySet, ?[*:0]const u8) callconv(.C) void;
    pub const Reference = *const fn(*QuerySet) callconv(.C) void;
    pub const Release = *const fn(*QuerySet) callconv(.C) void;
};

extern fn wgpuQuerySetDestroy(query_set: *QuerySet) callconv(.C) void;
extern fn wgpuQuerySetGetCount(query_set: *QuerySet) callconv(.C) u32;
extern fn wgpuQuerySetGetType(query_set: *QuerySet) callconv(.C) QueryType;
extern fn wgpuQuerySetSetLabel(query_set: *QuerySet, label: ?[*:0]const u8) callconv(.C) void;
extern fn wgpuQuerySetReference(query_set: *QuerySet) callconv(.C) void;
extern fn wgpuQuerySetRelease(query_set: *QuerySet) callconv(.C) void;

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
    pub inline fn setLabel(self: *QuerySet, label: ?[*:0]const u8) void {
        wgpuQuerySetSetLabel(self, label);
    }
    pub inline fn reference(self: *QuerySet) void {
        wgpuQuerySetReference(self);
    }
    pub inline fn release(self: *QuerySet) void {
        wgpuQuerySetRelease(self);
    }
};