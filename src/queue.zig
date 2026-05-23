const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const CommandBuffer = @import("command_encoder.zig").CommandBuffer;
const Buffer = @import("buffer.zig").Buffer;

const _texture = @import("texture.zig");
const TexelCopyTextureInfo = _texture.TexelCopyTextureInfo;
const TexelCopyBufferLayout = _texture.TexelCopyBufferLayout;
const Extent3D = _texture.Extent3D;

const _async = @import("async.zig");
const CallbackMode = _async.CallbackMode;
const Future = _async.Future;

const StringView = @import("misc.zig").StringView;

pub const SubmissionIndex = u64;

pub const QueueDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: StringView = StringView {},
};

pub const WorkDoneStatus = enum(u32) {
    success          = 0x00000001,
    instance_dropped = 0x00000002,
    @"error"         = 0x00000003,
    unknown          = 0x00000004,
};

pub const QueueWorkDoneCallbackInfo = extern struct {
    next_in_chain: ?*ChainedStruct = null,

    // TODO: Revisit this default if/when Instance.waitAny() is implemented.
    mode: CallbackMode = CallbackMode.allow_process_events,

    callback: QueueWorkDoneCallback,
    userdata1: ?*anyopaque = null,
    userdata2: ?*anyopaque = null,
};

pub const QueueWorkDoneCallback = *const fn(status: WorkDoneStatus, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const QueueProcs = struct {
    pub const OnSubmittedWorkDone = *const fn(*Queue, QueueWorkDoneCallbackInfo) callconv(.c) Future;
    pub const SetLabel = *const fn(*Queue, StringView) callconv(.c) void;
    pub const Submit = *const fn(*Queue, usize, [*]const *const CommandBuffer) callconv(.c) void;
    pub const WriteBuffer = *const fn(*Queue, Buffer, u64, *const anyopaque, usize) callconv(.c) void;
    pub const WriteTexture = *const fn(*Queue, *const TexelCopyTextureInfo, *const anyopaque, usize, *const TexelCopyBufferLayout, *const Extent3D) callconv(.c) void;
    pub const AddRef = *const fn(*Queue) callconv(.c) void;
    pub const Release = *const fn(*Queue) callconv(.c) void;

    // wgpu-native procs?
    // pub const SubmitForIndex = *const fn(*Queue, usize, [*]const *const CommandBuffer) callconv(.c) SubmissionIndex;
};

extern fn wgpuQueueOnSubmittedWorkDone(queue: *Queue, callback_info: QueueWorkDoneCallbackInfo) Future;
extern fn wgpuQueueSetLabel(queue: *Queue, label: StringView) void;
extern fn wgpuQueueSubmit(queue: *Queue, command_count: usize, commands: [*]const *const CommandBuffer) void;
extern fn wgpuQueueWriteBuffer(queue: *Queue, buffer: *Buffer, buffer_offset: u64, data: *const anyopaque, size: usize) void;
extern fn wgpuQueueWriteTexture(queue: *Queue, destination: *const TexelCopyTextureInfo, data: *const anyopaque, data_size: usize, data_layout: *const TexelCopyBufferLayout, write_size: *const Extent3D) void;
extern fn wgpuQueueAddRef(queue: *Queue) void;
extern fn wgpuQueueRelease(queue: *Queue) void;

// wgpu-native
extern fn wgpuQueueSubmitForIndex(queue: *Queue, command_count: usize, commands: [*]const *const CommandBuffer) SubmissionIndex;

pub const Queue = opaque {
    pub inline fn onSubmittedWorkDone(self: *Queue, callback_info: QueueWorkDoneCallbackInfo) Future {
        return wgpuQueueOnSubmittedWorkDone(self, callback_info);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L132
    // pub inline fn setLabel(self: *Queue, label: []const u8) void {
    //     wgpuQueueSetLabel(self, StringView.fromSlice(label));
    // }

    pub inline fn submit(self: *Queue, commands: []const *const CommandBuffer) void {
        wgpuQueueSubmit(self, commands.len, commands.ptr);
    }

    pub inline fn writeBuffer(self: *Queue, buffer: *Buffer, buffer_offset: u64, data: *const anyopaque, size: usize) void {
        wgpuQueueWriteBuffer(self, buffer, buffer_offset, data, size);
    }

    pub inline fn writeTexture(self: *Queue, destination: *const TexelCopyTextureInfo, data: *const anyopaque, data_size: usize, data_layout: *const TexelCopyBufferLayout, write_size: *const Extent3D) void {
        wgpuQueueWriteTexture(self, destination, data, data_size, data_layout, write_size);
    }
    pub inline fn addRef(self: *Queue) void {
        wgpuQueueAddRef(self);
    }
    pub inline fn release(self: *Queue) void {
        wgpuQueueRelease(self);
    }

    // wgpu-native
    pub inline fn submitForIndex(self: *Queue, commands: []const *const CommandBuffer) SubmissionIndex {
        return wgpuQueueSubmitForIndex(self, commands.len, commands.ptr);
    }
};