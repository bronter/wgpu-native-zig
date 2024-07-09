const std = @import("std");
const testing = std.testing;

const wgpu = @import("wgpu");

fn handle_request_adapter(_: wgpu.WGPURequestAdapterStatus, adapter: wgpu.WGPUAdapter, _: [*c]const u8, userdata: ?*anyopaque) callconv(.C) void {
    const ud: *wgpu.WGPUAdapter = @ptrCast(@alignCast(userdata));
    ud.* = adapter.?;
}

fn handle_request_device(_: wgpu.WGPURequestDeviceStatus, device: wgpu.WGPUDevice, _: [*c]const u8, userdata: ?*anyopaque) callconv(.C) void {
    const ud: *wgpu.WGPUDevice = @ptrCast(@alignCast(userdata));
    ud.* = device.?;
}

fn handle_buffer_map(status: wgpu.WGPUBufferMapAsyncStatus, _: ?*anyopaque) callconv(.C) void {
    std.debug.print("buffer_map status={x:.8}\n", .{status});
}

fn compute_collatz() [4]u32 {
    const numbers = [_]u32{ 1, 2, 3, 4 };
    const numbers_size = @sizeOf(@TypeOf(numbers));
    const numbers_length = numbers_size / @sizeOf(u32);

    const instance = wgpu.wgpuCreateInstance(null);
    defer wgpu.wgpuInstanceRelease(instance);

    var adapter: wgpu.WGPUAdapter = null;
    wgpu.wgpuInstanceRequestAdapter(instance, null, handle_request_adapter, @ptrCast(&adapter));
    defer wgpu.wgpuAdapterRelease(adapter);

    var device: wgpu.WGPUDevice = null;
    wgpu.wgpuAdapterRequestDevice(adapter.?, null, handle_request_device, @ptrCast(&device));
    defer wgpu.wgpuDeviceRelease(device);

    const queue = wgpu.wgpuDeviceGetQueue(device.?);
    defer wgpu.wgpuQueueRelease(queue);

    const shader_module = wgpu.wgpuDeviceCreateShaderModule(device.?, &wgpu.WGPUShaderModuleDescriptor {
        .label = "compute.wgsl",
        .nextInChain = @ptrCast(&wgpu.WGPUShaderModuleWGSLDescriptor {
            .chain = wgpu.WGPUChainedStruct {
                .sType = wgpu.WGPUSType_ShaderModuleWGSLDescriptor,
            },
            .code = @embedFile("./compute.wgsl")
        }),
    });
    defer wgpu.wgpuShaderModuleRelease(shader_module);

    const staging_buffer = wgpu.wgpuDeviceCreateBuffer(device.?, &wgpu.WGPUBufferDescriptor {
        .label = "staging_buffer",
        .usage = wgpu.WGPUBufferUsage_MapRead | wgpu.WGPUBufferUsage_CopyDst,
        .size = numbers_size,
        .mappedAtCreation = @as(u32, @intFromBool(false)),
    });
    defer wgpu.wgpuBufferRelease(staging_buffer);

    const storage_buffer = wgpu.wgpuDeviceCreateBuffer(device.?, &wgpu.WGPUBufferDescriptor {
        .label = "storage_buffer",
        .usage = wgpu.WGPUBufferUsage_Storage | wgpu.WGPUBufferUsage_CopyDst | wgpu.WGPUBufferUsage_CopySrc,
        .size = numbers_size,
        .mappedAtCreation = @as(u32, @intFromBool(false)),
    });
    defer wgpu.wgpuBufferRelease(storage_buffer);

    const compute_pipeline = wgpu.wgpuDeviceCreateComputePipeline(device.?, &wgpu.WGPUComputePipelineDescriptor {
        .label = "compute_pipeline",
        .compute = wgpu.WGPUProgrammableStageDescriptor{
            .module = shader_module,
            .entryPoint = "main",
        },
    });
    defer wgpu.wgpuComputePipelineRelease(compute_pipeline);

    const bind_group_layout = wgpu.wgpuComputePipelineGetBindGroupLayout(compute_pipeline, 0);
    defer wgpu.wgpuBindGroupLayoutRelease(bind_group_layout);

    const bind_group = wgpu.wgpuDeviceCreateBindGroup(device.?, &wgpu.WGPUBindGroupDescriptor {
        .label = "bind_group",
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
        .label = "command_encoder",
    });
    defer wgpu.wgpuCommandEncoderRelease(command_encoder);

    const compute_pass_encoder = wgpu.wgpuCommandEncoderBeginComputePass(command_encoder, &wgpu.WGPUComputePassDescriptor {
        .label = "compute_pass",
    });
    defer wgpu.wgpuComputePassEncoderRelease(compute_pass_encoder);

    wgpu.wgpuComputePassEncoderSetPipeline(compute_pass_encoder, compute_pipeline);
    wgpu.wgpuComputePassEncoderSetBindGroup(compute_pass_encoder, 0, bind_group, 0, null);
    wgpu.wgpuComputePassEncoderDispatchWorkgroups(compute_pass_encoder, numbers_length, 1, 1);
    wgpu.wgpuComputePassEncoderEnd(compute_pass_encoder);

    wgpu.wgpuCommandEncoderCopyBufferToBuffer(command_encoder, storage_buffer, 0, staging_buffer, 0, numbers_size);

    const command_buffer = wgpu.wgpuCommandEncoderFinish(command_encoder, &wgpu.WGPUCommandBufferDescriptor {
        .label = "command_buffer",
    });
    defer wgpu.wgpuCommandBufferRelease(command_buffer);

    wgpu.wgpuQueueWriteBuffer(queue, storage_buffer, 0, &numbers, numbers_size);
    wgpu.wgpuQueueSubmit(queue, 1, &command_buffer);

    wgpu.wgpuBufferMapAsync(staging_buffer, wgpu.WGPUMapMode_Read, 0, numbers_size, handle_buffer_map, null);
    _ = wgpu.wgpuDevicePoll(device.?, @as(u32, @intFromBool(true)), null);

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
