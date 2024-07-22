const std = @import("std");
const testing = std.testing;

const wgpu = @import("wgpu");

fn handle_buffer_map(status: wgpu.BufferMapAsyncStatus, _: ?*anyopaque) callconv(.C) void {
    std.debug.print("buffer_map status={x:.8}\n", .{@intFromEnum(status)});
}

fn compute_collatz() ![4]u32 {
    const numbers = [_]u32{ 1, 2, 3, 4 };
    const numbers_size = @sizeOf(@TypeOf(numbers));
    const numbers_length = numbers_size / @sizeOf(u32);

    const instance = wgpu.Instance.create(null).?;
    defer instance.release();

    const adapter_response = instance.requestAdapterSync(null);
    const adapter = switch(adapter_response.status) {
        .success => adapter_response.adapter.?,
        else => return error.NoAdapter,
    };
    defer adapter.release();

    const device_response = adapter.requestDeviceSync(null);
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
        .label = "staging_buffer",
        .usage = wgpu.BufferUsage.map_read | wgpu.BufferUsage.copy_dst,
        .size = numbers_size,
        .mapped_at_creation = @as(u32, @intFromBool(false)),
    }).?;
    defer staging_buffer.release();

    const storage_buffer = device.createBuffer(&wgpu.BufferDescriptor {
        .label = "storage_buffer",
        .usage = wgpu.BufferUsage.storage | wgpu.BufferUsage.copy_dst | wgpu.BufferUsage.copy_src,
        .size = numbers_size,
        .mapped_at_creation = @as(u32, @intFromBool(false)),
    }).?;
    defer storage_buffer.release();

    const compute_pipeline = device.createComputePipeline(&wgpu.ComputePipelineDescriptor {
        .label = "compute_pipeline",
        .compute = wgpu.ProgrammableStageDescriptor {
            .module = shader_module,
            .entry_point = "main",
        },
    }).?;
    defer compute_pipeline.release();

    const bind_group_layout = compute_pipeline.getBindGroupLayout(0).?;
    defer bind_group_layout.release();

    const bind_group = device.createBindGroup(&wgpu.BindGroupDescriptor {
        .label = "bind_group",
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
        .label = "command_encoder"
    }).?;
    defer command_encoder.release();

    const compute_pass_encoder = command_encoder.beginComputePass(&wgpu.ComputePassDescriptor {
        .label = "compute_pass",
    }).?;
    defer compute_pass_encoder.release();

    compute_pass_encoder.setPipeline(compute_pipeline);
    compute_pass_encoder.setBindGroup(0, bind_group, 0, null);
    compute_pass_encoder.dispatchWorkgroups(numbers_length, 1, 1);
    compute_pass_encoder.end();

    command_encoder.copyBufferToBuffer(storage_buffer, 0, staging_buffer, 0, numbers_size);

    const command_buffer = command_encoder.finish(&wgpu.CommandBufferDescriptor {
        .label = "command_buffer",
    }).?;
    defer command_buffer.release();

    queue.writeBuffer(storage_buffer, 0, &numbers, numbers_size);
    queue.submit(&[_]*const wgpu.CommandBuffer{command_buffer});

    staging_buffer.mapAsync(wgpu.MapMode.read, 0, numbers_size, handle_buffer_map, null);
    _ = device.poll(true, null);

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
