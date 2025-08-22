const std = @import("std");
const testing = std.testing;

const wgpu = @import("wgpu");

fn handleBufferMap(status: wgpu.MapAsyncStatus, _: wgpu.StringView, userdata1: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    std.log.info("buffer_map status={x:.8}\n", .{@intFromEnum(status)});
    const completed: *bool = @ptrCast(@alignCast(userdata1));
    completed.* = true;
}

fn compute_collatz() ![4]u32 {
    const numbers = [_]u32{ 1, 2, 3, 4 };
    const numbers_size = @sizeOf(@TypeOf(numbers));
    const numbers_length = numbers_size / @sizeOf(u32);

    const instance = wgpu.Instance.create(null).?;
    defer instance.release();

    const adapter_response = instance.requestAdapterSync(null, 200_000_000);
    const adapter = switch(adapter_response.status) {
        .success => adapter_response.adapter.?,
        else => return error.NoAdapter,
    };
    defer adapter.release();

    const device_response = adapter.requestDeviceSync(instance, null, 200_000_000);
    const device = switch(device_response.status) {
        .success => device_response.device.?,
        else => return error.NoDevice,
    };
    defer device.release();

    const queue = device.getQueue().?;
    defer queue.release();

    const shader_module = device.createShaderModule(&wgpu.shaderModuleWGSLDescriptor(.{
        .label = "compute.wgsl",
        .code = @embedFile("./compute.wgsl"),
    })).?;
    defer shader_module.release();

    const staging_buffer = device.createBuffer(&wgpu.BufferDescriptor {
        .label = wgpu.StringView.fromSlice("staging_buffer"),
        .usage = wgpu.BufferUsages.map_read | wgpu.BufferUsages.copy_dst,
        .size = numbers_size,
        .mapped_at_creation = @as(u32, @intFromBool(false)),
    }).?;
    defer staging_buffer.release();

    const storage_buffer = device.createBuffer(&wgpu.BufferDescriptor {
        .label = wgpu.StringView.fromSlice("storage_buffer"),
        .usage = wgpu.BufferUsages.storage | wgpu.BufferUsages.copy_dst | wgpu.BufferUsages.copy_src,
        .size = numbers_size,
        .mapped_at_creation = @as(u32, @intFromBool(false)),
    }).?;
    defer storage_buffer.release();

    const compute_pipeline = device.createComputePipeline(&wgpu.ComputePipelineDescriptor {
        .label = wgpu.StringView.fromSlice("compute_pipeline"),
        .compute = wgpu.ProgrammableStageDescriptor {
            .module = shader_module,
            .entry_point = wgpu.StringView.fromSlice("main"),
        },
    }).?;
    defer compute_pipeline.release();

    const bind_group_layout = compute_pipeline.getBindGroupLayout(0).?;
    defer bind_group_layout.release();

    const bind_group = device.createBindGroup(&wgpu.BindGroupDescriptor {
        .label = wgpu.StringView.fromSlice("bind_group"),
        .layout = bind_group_layout,
        .entry_count = 1,
        .entries = &[_]wgpu.BindGroupEntry {
            wgpu.BindGroupEntry {
                .binding = 0,
                .buffer = storage_buffer,
                .offset = 0,
                .size = numbers_size,
            }
        },
    }).?;
    defer bind_group.release();

    const command_encoder = device.createCommandEncoder(&wgpu.CommandEncoderDescriptor {
        .label = wgpu.StringView.fromSlice("command_encoder"),
    }).?;
    defer command_encoder.release();

    const compute_pass_encoder = command_encoder.beginComputePass(&wgpu.ComputePassDescriptor {
        .label = wgpu.StringView.fromSlice("compute_pass"),
    }).?;

    compute_pass_encoder.setPipeline(compute_pipeline);
    compute_pass_encoder.setBindGroup(0, bind_group, 0, null);
    compute_pass_encoder.dispatchWorkgroups(numbers_length, 1, 1);
    compute_pass_encoder.end();

    // Must be released here: https://github.com/gfx-rs/wgpu-native/issues/412#issuecomment-2311719154
    compute_pass_encoder.release();

    command_encoder.copyBufferToBuffer(storage_buffer, 0, staging_buffer, 0, numbers_size);

    const command_buffer = command_encoder.finish(&wgpu.CommandBufferDescriptor {
        .label = wgpu.StringView.fromSlice("command_buffer"),
    }).?;
    defer command_buffer.release();

    queue.writeBuffer(storage_buffer, 0, &numbers, numbers_size);
    queue.submit(&[_]*const wgpu.CommandBuffer{command_buffer});

    var buffer_map_complete = false;
    _ = staging_buffer.mapAsync(wgpu.MapModes.read, 0, numbers_size, wgpu.BufferMapCallbackInfo {
        .callback = handleBufferMap,
        .userdata1 = @ptrCast(&buffer_map_complete),
    });
    instance.processEvents();
    while(!buffer_map_complete) {
        instance.processEvents();
    }

    const buf: [*]u32 = @ptrCast(@alignCast(staging_buffer.getMappedRange(0, numbers_size).?));
    defer staging_buffer.unmap();

    const ret = [4]u32 {buf[0], buf[1], buf[2], buf[3]};
    return ret;
}

test "compute functionality" {
    const values = try compute_collatz();

    try testing.expect(values[0] == 0);
    try testing.expect(values[1] == 1);
    try testing.expect(values[2] == 7);
    try testing.expect(values[3] == 2);
}
