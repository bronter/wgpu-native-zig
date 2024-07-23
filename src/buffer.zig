const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const WGPUFlags = _misc.WGPUFlags;

const ChainedStruct = @import("chained_struct.zig").ChainedStruct;

pub const BufferBindingType = enum(u32) {
    @"undefined"      = 0x00000000,
    uniform           = 0x00000001,
    storage           = 0x00000002,
    read_only_storage = 0x00000003,
};

pub const BufferBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    @"type": BufferBindingType,
    has_dynamic_offset: WGPUBool,
    min_binding_size: u64,
};

pub const BufferUsageFlags = WGPUFlags;
pub const BufferUsage = struct {
    pub const none          = @as(BufferUsageFlags, 0x00000000);
    pub const map_read      = @as(BufferUsageFlags, 0x00000001);
    pub const map_write     = @as(BufferUsageFlags, 0x00000002);
    pub const copy_src      = @as(BufferUsageFlags, 0x00000004);
    pub const copy_dst      = @as(BufferUsageFlags, 0x00000008);
    pub const index         = @as(BufferUsageFlags, 0x00000010);
    pub const vertex        = @as(BufferUsageFlags, 0x00000020);
    pub const uniform       = @as(BufferUsageFlags, 0x00000040);
    pub const storage       = @as(BufferUsageFlags, 0x00000080);
    pub const indirect      = @as(BufferUsageFlags, 0x00000100);
    pub const query_resolve = @as(BufferUsageFlags, 0x00000200);
};

pub const BufferMapState = enum(u32) {
    unmapped = 0x00000000,
    pending  = 0x00000001,
    mapped   = 0x00000002,
};

pub const MapModeFlags = WGPUFlags;
pub const MapMode = struct {
    pub const none  = @as(MapModeFlags, 0x00000000);
    pub const read  = @as(MapModeFlags, 0x00000001);
    pub const write = @as(MapModeFlags, 0x00000002);
};

pub const BufferMapAsyncStatus = enum(u32) {
    success                   = 0x00000000,
    validation_error          = 0x00000001,
    unknown                   = 0x00000002,
    device_lost               = 0x00000003,
    destroyed_before_callback = 0x00000004,
    unmapped_before_callback  = 0x00000005,
    mapping_already_pending   = 0x00000006,
    offset_out_of_range       = 0x00000007,
    size_out_of_range         = 0x00000008,
};

pub const BufferMapCallback = *const fn(status: BufferMapAsyncStatus, userdata: ?*anyopaque) callconv(.C) void;

pub const BufferDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: BufferUsageFlags,
    size: u64,
    mapped_at_creation: WGPUBool,
};

pub const BufferProcs = struct {
    pub const Destroy = *const fn(*Buffer) callconv(.C) void;
    pub const GetConstMappedRange = *const fn(*Buffer, usize, usize) callconv(.C) ?*const anyopaque;
    pub const GetMapState = *const fn(*Buffer) callconv(.C) BufferMapState;
    pub const GetMappedRange = *const fn(*Buffer, usize, usize) callconv(.C) ?*anyopaque;
    pub const GetSize = *const fn(*Buffer) callconv(.C) u64;
    pub const GetUsage = *const fn(*Buffer) callconv(.C) BufferUsageFlags;
    pub const MapAsync = *const fn(*Buffer, MapModeFlags, usize, usize, BufferMapCallback, ?*anyopaque) callconv(.C) void;
    pub const SetLabel = *const fn(*Buffer, ?[*:0]const u8) callconv(.C) void;
    pub const Unmap = *const fn(*Buffer) callconv(.C) void;
    pub const Reference = *const fn(*Buffer) callconv(.C) void;
    pub const Release = *const fn(*Buffer) callconv(.C) void;
};

extern fn wgpuBufferDestroy(buffer: *Buffer) void;
extern fn wgpuBufferGetConstMappedRange(buffer: *Buffer, offset: usize, size: usize) ?*const anyopaque;
extern fn wgpuBufferGetMapState(buffer: *Buffer) BufferMapState;
extern fn wgpuBufferGetMappedRange(buffer: *Buffer, offset: usize, size: usize) ?*anyopaque;
extern fn wgpuBufferGetSize(buffer: *Buffer) u64;
extern fn wgpuBufferGetUsage(buffer: *Buffer) BufferUsageFlags;
extern fn wgpuBufferMapAsync(buffer: *Buffer, mode: MapModeFlags, offset: usize, size: usize, callback: BufferMapCallback, userdata: ?*anyopaque) void;
extern fn wgpuBufferSetLabel(buffer: *Buffer, label: ?[*:0]const u8) void;
extern fn wgpuBufferUnmap(buffer: *Buffer) void;
extern fn wgpuBufferReference(buffer: *Buffer) void;
extern fn wgpuBufferRelease(buffer: *Buffer) void;

pub const Buffer = opaque {
    pub inline fn destroy(self: *Buffer) void {
        wgpuBufferDestroy(self);
    }
    pub inline fn getConstMappedRange(self: *Buffer, offset: usize, size: usize) ?*const anyopaque {
        return wgpuBufferGetConstMappedRange(self, offset, size);
    }
    pub inline fn getMapState(self: *Buffer) BufferMapState {
        return wgpuBufferGetMapState(self);
    }
    pub inline fn getMappedRange(self: *Buffer, offset: usize, size: usize) ?*anyopaque {
        return wgpuBufferGetMappedRange(self, offset, size);
    }
    pub inline fn getSize(self: *Buffer) u64 {
        return wgpuBufferGetSize(self);
    }
    pub inline fn getUsage(self: *Buffer) BufferUsageFlags {
        return wgpuBufferGetUsage(self);
    }

    // TODO: Not sure if it makes sense to try to write a sync wrapper for this.
    //       This is probably the sort of thing that should use a native async syntax,
    //       if/when Zig ever gets async back: https://github.com/ziglang/zig/issues/6025
    pub inline fn mapAsync(self: *Buffer, mode: MapModeFlags, offset: usize, size: usize, callback: BufferMapCallback, userdata: ?*anyopaque) void {
        wgpuBufferMapAsync(self, mode, offset, size, callback, userdata);
    }

    pub inline fn setLabel(self: *Buffer, label: ?[*:0]const u8) void {
        wgpuBufferSetLabel(self, label);
    }
    pub inline fn unmap(self: *Buffer) void {
        wgpuBufferUnmap(self);
    }
    pub inline fn reference(self: *Buffer) void {
        wgpuBufferReference(self);
    }
    pub inline fn release(self: *Buffer) void {
        wgpuBufferRelease(self);
    }
};