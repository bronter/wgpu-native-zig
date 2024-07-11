const std = @import("std");
const testing = std.testing;

const ChainedStruct = @import("chained_struct.zig").ChainedStruct;
const adapter = @import("adapter.zig");
const surface = @import("surface.zig");

pub const InstanceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
};

pub const InstanceProcs = struct {
    pub const CreateInstance = *const fn(?*const InstanceDescriptor) callconv(.C) ?*Instance;
    pub const ProcessEvents = *const fn(*Instance) callconv(.C) void;
    pub const RequestAdapter = *const fn(*Instance, ?*const adapter.RequestAdapterOptions, adapter.RequestAdapterCallback, ?*anyopaque) callconv(.C) void;
    pub const InstanceReference = *const fn(*Instance) callconv(.C) void;
    pub const InstanceRelease = *const fn(*Instance) callconv(.C) void;
};


extern "c" fn wgpuCreateInstance(descriptor: ?*const InstanceDescriptor) ?*Instance;
extern "c" fn wgpuInstanceCreateSurface(instance: *Instance, descriptor: *const surface.SurfaceDescriptor) ?*surface.Surface;
extern "c" fn wgpuInstanceProcessEvents(instance: *Instance) void;
extern "c" fn wgpuInstanceRequestAdapter(instance: *Instance, options: ?*const adapter.RequestAdapterOptions, callback: adapter.RequestAdapterCallback, userdata: ?*anyopaque) void;
extern "c" fn wgpuInstanceReference(instance: *Instance) callconv(.C) void;
extern "c" fn wgpuInstanceRelease(instance: *Instance) callconv(.C) void;

const Instance = opaque {
    pub inline fn create(descriptor: ?*const InstanceDescriptor) ?*Instance {
        return wgpuCreateInstance(descriptor);
    }

    pub inline fn createSurface(self: *Instance, descriptor: *const surface.SurfaceDescriptor) ?*surface.Surface {
        return wgpuInstanceCreateSurface(self, descriptor);
    }

    pub inline fn processEvents(self: *Instance) void {
        wgpuInstanceProcessEvents(self);
    }

    fn defaultAdapterCallback(status: adapter.RequestAdapterStatus, _adapter: ?*adapter.Adapter, message: [*c]const u8, userdata: ?*anyopaque) callconv(.C) void {
        switch(status) {
            .Success => {
                const ud_adapter: **adapter.Adapter = @ptrCast(@alignCast(userdata));
                ud_adapter.* = _adapter.?;
            },
            else => {
                std.log.err("requestAdapter returned status {s}; message:\n    {s}", .{
                    @tagName(status),
                    message,
                });
            }
        }
    }

    pub fn requestAdapter(self: *Instance, options: ?*const adapter.RequestAdapterOptions) ?*adapter.Adapter {
        var adapter_ptr: ?*adapter.Adapter = null;
        wgpuInstanceRequestAdapter(self, options, defaultAdapterCallback, @ptrCast(&adapter_ptr));
        return adapter_ptr;
    }

    pub inline fn requestAdapterWithCallback(self: *Instance, options: ?*const adapter.RequestAdapterOptions, callback: adapter.RequestAdapterCallback, userdata: ?*anyopaque) void {
        wgpuInstanceRequestAdapter(self, options, callback, userdata);
    }

    // Dunno what this does, but it appears in webgpu.h so I guess it's important?
    pub inline fn reference(self: *Instance) void {
        // TODO: Find out WTF wgpuInstanceReference does.
        wgpuInstanceReference(self);
    }

    pub inline fn release(self: *Instance) void {
        wgpuInstanceRelease(self);
    }
};

test "can create instance (and release it afterwards)" {
    const instance = Instance.create(null);
    try testing.expect(instance != null);
    instance.?.release();
}