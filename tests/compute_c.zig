const std = @import("std");
const testing = std.testing;

const wgpu = @import("wgpu-c");

fn handleRequestAdapter(status: wgpu.WGPURequestAdapterStatus, adapter: wgpu.WGPUAdapter, _: wgpu.WGPUStringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void {
    switch(status) {
        wgpu.WGPURequestAdapterStatus_Success => {
            const ud_adapter: *wgpu.WGPUAdapter = @ptrCast(@alignCast(userdata1));
            ud_adapter.* = adapter;
        },
        else => {
            std.log.err("adapter request failed", .{});
        }
    }
    const completed: *bool = @ptrCast(@alignCast(userdata2));
    completed.* = true;
}

fn handleRequestDevice(status: wgpu.WGPURequestDeviceStatus, device: wgpu.WGPUDevice, _: wgpu.WGPUStringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void {
    switch(status) {
        wgpu.WGPURequestDeviceStatus_Success => {
            const ud_device: *wgpu.WGPUDevice = @ptrCast(@alignCast(userdata1));
            ud_device.* = device;
        },
        else => {
            std.log.err("device request failed", .{});
        }
    }
    const completed: *bool = @ptrCast(@alignCast(userdata2));
    completed.* = true;
}

fn handleBufferMap(status: wgpu.WGPUMapAsyncStatus, _: wgpu.WGPUStringView, userdata1: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    std.log.info("buffer_map status={x:.8}\n", .{status});
    const completed: *bool = @ptrCast(@alignCast(userdata1));
    completed.* = true;
}

fn waitForCompletion(instance: wgpu.WGPUInstance, complete: *bool) void {
    wgpu.wgpuInstanceProcessEvents(instance);
    while(!complete.*) {
        wgpu.wgpuInstanceProcessEvents(instance);
    }
}

fn compute_collatz() [4]u32 {
    const numbers = [_]u32{ 1, 2, 3, 4 };
    const numbers_size = @sizeOf(@TypeOf(numbers));
    const numbers_length = numbers_size / @sizeOf(u32);

    const instance = wgpu.wgpuCreateInstance(null);
    defer wgpu.wgpuInstanceRelease(instance);


    var adapter: wgpu.WGPUAdapter = null;
    {
        var request_complete = false;
        _ = wgpu.wgpuInstanceRequestAdapter(instance, null, wgpu.WGPURequestAdapterCallbackInfo {
            .nextInChain = null,
            .mode = wgpu.WGPUCallbackMode_AllowProcessEvents,
            .callback = handleRequestAdapter,
            .userdata1 = @ptrCast(&adapter),
            .userdata2 = @ptrCast(&request_complete),
        });
        waitForCompletion(instance, &request_complete);
    }
    defer wgpu.wgpuAdapterRelease(adapter);

    var device: wgpu.WGPUDevice = null;
    {
        var request_complete = false;
        _ = wgpu.wgpuAdapterRequestDevice(adapter.?, null, wgpu.WGPURequestDeviceCallbackInfo {
            .nextInChain = null,
            .mode = wgpu.WGPUCallbackMode_AllowProcessEvents,
            .callback = handleRequestDevice,
            .userdata1 = @ptrCast(&device),
            .userdata2 = @ptrCast(&request_complete),
        });
        waitForCompletion(instance, &request_complete);
    }
    defer wgpu.wgpuDeviceRelease(device);

    const queue = wgpu.wgpuDeviceGetQueue(device.?);
    defer wgpu.wgpuQueueRelease(queue);

    const compute_shader = @embedFile("./compute.wgsl");
    const shader_module = wgpu.wgpuDeviceCreateShaderModule(device.?, &wgpu.WGPUShaderModuleDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "compute.wgsl",
            .length = wgpu.WGPU_STRLEN, // Treat as null-terminated string
        },
        .nextInChain = @ptrCast(&wgpu.WGPUShaderSourceWGSL {
            .chain = wgpu.WGPUChainedStruct {
                .sType = wgpu.WGPUSType_ShaderSourceWGSL,
            },
            .code = wgpu.WGPUStringView {
                .data = compute_shader.ptr,
                .length = compute_shader.len,
            },
        }),
    });
    defer wgpu.wgpuShaderModuleRelease(shader_module);

    const staging_buffer = wgpu.wgpuDeviceCreateBuffer(device.?, &wgpu.WGPUBufferDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "staging_buffer",
            .length = wgpu.WGPU_STRLEN,
        },
        .usage = wgpu.WGPUBufferUsage_MapRead | wgpu.WGPUBufferUsage_CopyDst,
        .size = numbers_size,
        .mappedAtCreation = @as(u32, @intFromBool(false)),
    });
    defer wgpu.wgpuBufferRelease(staging_buffer);

    const storage_buffer = wgpu.wgpuDeviceCreateBuffer(device.?, &wgpu.WGPUBufferDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "storage_buffer",
            .length = wgpu.WGPU_STRLEN,
        },
        .usage = wgpu.WGPUBufferUsage_Storage | wgpu.WGPUBufferUsage_CopyDst | wgpu.WGPUBufferUsage_CopySrc,
        .size = numbers_size,
        .mappedAtCreation = @as(u32, @intFromBool(false)),
    });
    defer wgpu.wgpuBufferRelease(storage_buffer);

    const compute_pipeline = wgpu.wgpuDeviceCreateComputePipeline(device.?, &wgpu.WGPUComputePipelineDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "compute_pipeline",
            .length = wgpu.WGPU_STRLEN,
        },
        .compute = wgpu.WGPUProgrammableStageDescriptor{
            .module = shader_module,
            .entryPoint = wgpu.WGPUStringView {
                .data = "main",
                .length = wgpu.WGPU_STRLEN,
            },
        },
    });
    defer wgpu.wgpuComputePipelineRelease(compute_pipeline);

    const bind_group_layout = wgpu.wgpuComputePipelineGetBindGroupLayout(compute_pipeline, 0);
    defer wgpu.wgpuBindGroupLayoutRelease(bind_group_layout);

    const bind_group = wgpu.wgpuDeviceCreateBindGroup(device.?, &wgpu.WGPUBindGroupDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "bind_group",
            .length = wgpu.WGPU_STRLEN,
        },
        .layout = bind_group_layout,
        .entryCount = 1,
        .entries = &[_]wgpu.WGPUBindGroupEntry {
            wgpu.WGPUBindGroupEntry {
                .binding = 0,
                .buffer = storage_buffer,
                .offset = 0,
                .size = numbers_size,
            },
        },
    });
    defer wgpu.wgpuBindGroupRelease(bind_group);

    const command_encoder = wgpu.wgpuDeviceCreateCommandEncoder(device.?, &wgpu.WGPUCommandEncoderDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "command_encoder",
            .length = wgpu.WGPU_STRLEN,
        },
    });
    defer wgpu.wgpuCommandEncoderRelease(command_encoder);

    const compute_pass_encoder = wgpu.wgpuCommandEncoderBeginComputePass(command_encoder, &wgpu.WGPUComputePassDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "compute_pass",
            .length = wgpu.WGPU_STRLEN,
        },
    });

    wgpu.wgpuComputePassEncoderSetPipeline(compute_pass_encoder, compute_pipeline);
    wgpu.wgpuComputePassEncoderSetBindGroup(compute_pass_encoder, 0, bind_group, 0, null);
    wgpu.wgpuComputePassEncoderDispatchWorkgroups(compute_pass_encoder, numbers_length, 1, 1);
    wgpu.wgpuComputePassEncoderEnd(compute_pass_encoder);

    // Must be released here: https://github.com/gfx-rs/wgpu-native/issues/412#issuecomment-2311719154
    wgpu.wgpuComputePassEncoderRelease(compute_pass_encoder);

    wgpu.wgpuCommandEncoderCopyBufferToBuffer(command_encoder, storage_buffer, 0, staging_buffer, 0, numbers_size);

    const command_buffer = wgpu.wgpuCommandEncoderFinish(command_encoder, &wgpu.WGPUCommandBufferDescriptor {
        .label = wgpu.WGPUStringView {
            .data = "command_buffer",
            .length = wgpu.WGPU_STRLEN,
        },
    });
    defer wgpu.wgpuCommandBufferRelease(command_buffer);

    wgpu.wgpuQueueWriteBuffer(queue, storage_buffer, 0, &numbers, numbers_size);
    wgpu.wgpuQueueSubmit(queue, 1, &command_buffer);

    var buffer_map_complete = false;
    _ = wgpu.wgpuBufferMapAsync(staging_buffer, wgpu.WGPUMapMode_Read, 0, numbers_size, wgpu.WGPUBufferMapCallbackInfo {
        .nextInChain = null,
        .mode = wgpu.WGPUCallbackMode_AllowProcessEvents,
        .callback = handleBufferMap,
        .userdata1 = @ptrCast(&buffer_map_complete),
        .userdata2 = null,
    });
    waitForCompletion(instance, &buffer_map_complete);

    const buf: [*]u32 = @ptrCast(@alignCast(wgpu.wgpuBufferGetMappedRange(staging_buffer, 0, numbers_size)));
    defer wgpu.wgpuBufferUnmap(staging_buffer);

    const ret = [4]u32 {buf[0], buf[1], buf[2], buf[3]};
    return ret;
}

test "compute functionality" {
    const values = compute_collatz();

    try testing.expect(values[0] == 0);
    try testing.expect(values[1] == 1);
    try testing.expect(values[2] == 7);
    try testing.expect(values[3] == 2);
}
