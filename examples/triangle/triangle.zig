const std = @import("std");
const wgpu = @import("wgpu");
const bmp = @import("bmp");

const output_extent = wgpu.Extent3D {
    .width = 640,
    .height = 480,
    .depth_or_array_layers = 1,
};
const output_bytes_per_row = 4 * output_extent.width;
const output_size = output_bytes_per_row * output_extent.height;

fn handle_buffer_map(status: wgpu.BufferMapAsyncStatus, _: ?*anyopaque) callconv(.C) void {
    std.debug.print("buffer_map status={x:.8}\n", .{@intFromEnum(status)});
}

// Based off of headless triangle example from https://github.com/eliemichel/LearnWebGPU-Code/tree/step030-headless

pub fn main() !void {
    const instance = wgpu.Instance.create(null).?;
    defer instance.release();

    const adapter_request = instance.requestAdapterSync(&wgpu.RequestAdapterOptions {});
    const adapter = switch(adapter_request.status) {
        .success => adapter_request.adapter.?,
        else => return error.NoAdapter,
    };
    defer adapter.release();

    const device_request = adapter.requestDeviceSync(&wgpu.DeviceDescriptor {
        .required_limits = &wgpu.RequiredLimits {
            .limits = wgpu.Limits {},
        },
    });
    const device = switch(device_request.status) {
        .success => device_request.device.?,
        else => return error.NoDevice,
    };
    defer device.release();

    const queue = device.getQueue().?;
    defer queue.release();

    const swap_chain_format = wgpu.TextureFormat.bgra8_unorm_srgb;

    const target_texture = device.createTexture(&wgpu.TextureDescriptor {
        .label = "Render texture",
        .size = output_extent,
        .format = swap_chain_format,
        .usage = wgpu.TextureUsage.render_attachment | wgpu.TextureUsage.copy_src,
    }).?;
    defer target_texture.release();

    const target_texture_view = target_texture.createView(&wgpu.TextureViewDescriptor {
        .label = "Render texture view",
        .mip_level_count = 1,
        .array_layer_count = 1,
    }).?;

    const shader_module = device.createShaderModule(&wgpu.shaderModuleWGSLDescriptor(.{
        .code = @embedFile("./shader.wgsl"),
    })).?;
    defer shader_module.release();

    const staging_buffer = device.createBuffer(&wgpu.BufferDescriptor {
        .label = "staging_buffer",
        .usage = wgpu.BufferUsage.map_read | wgpu.BufferUsage.copy_dst,
        .size = output_size,
        .mapped_at_creation = @as(u32, @intFromBool(false)),
    }).?;
    defer staging_buffer.release();

    const color_targets = &[_] wgpu.ColorTargetState{
        wgpu.ColorTargetState {
            .format = swap_chain_format,
            .blend = &wgpu.BlendState {
                .color = wgpu.BlendComponent {
                    .operation = .add,
                    .src_factor = .src_alpha,
                    .dst_factor = .one_minus_src_alpha,
                },
                .alpha = wgpu.BlendComponent {
                    .operation = .add,
                    .src_factor = .zero,
                    .dst_factor = .one,
                },
            },
        },
    };

    const pipeline = device.createRenderPipeline(&wgpu.RenderPipelineDescriptor {
        .vertex = wgpu.VertexState {
            .module = shader_module,
            .entry_point = "vs_main",
        },
        .primitive = wgpu.PrimitiveState {},
        .fragment = &wgpu.FragmentState {
            .module = shader_module,
            .entry_point = "fs_main",
            .target_count = color_targets.len,
            .targets = color_targets.ptr
        },
        .multisample = wgpu.MultisampleState {},
    }).?;
    defer pipeline.release();

    { // Mock main "loop"
        const next_texture = target_texture_view;

        const encoder = device.createCommandEncoder(&wgpu.CommandEncoderDescriptor {
            .label = "Command Encoder",
        }).?;
        defer encoder.release();

        const color_attachments = &[_]wgpu.ColorAttachment{
            wgpu.ColorAttachment {
                .view = next_texture,
                .clear_value = wgpu.Color {},
            }
        };
        const render_pass = encoder.beginRenderPass(&wgpu.RenderPassDescriptor {
            .color_attachment_count = color_attachments.len,
            .color_attachments = color_attachments.ptr,
        }).?;
        defer next_texture.release();
        defer render_pass.release();

        render_pass.setPipeline(pipeline);
        render_pass.draw(3, 1, 0, 0);
        render_pass.end();

        const img_copy_src = wgpu.ImageCopyTexture {
            .origin = wgpu.Origin3D {},
            .texture = target_texture,
        };
        const img_copy_dst = wgpu.ImageCopyBuffer {
            .layout = wgpu.TextureDataLayout {
                .bytes_per_row = output_bytes_per_row,
                .rows_per_image = output_extent.height,
            },
            .buffer = staging_buffer,
        };

        encoder.copyTextureToBuffer(&img_copy_src, &img_copy_dst, &output_extent);

        const command_buffer = encoder.finish(&wgpu.CommandBufferDescriptor {
            .label = "Command Buffer",
        }).?;
        defer command_buffer.release();

        queue.submit(&[_]*const wgpu.CommandBuffer{command_buffer});

        staging_buffer.mapAsync(wgpu.MapMode.read, 0, output_size, handle_buffer_map, null);
        _ = device.poll(true, null);

        const buf: [*]u8 = @ptrCast(@alignCast(staging_buffer.getMappedRange(0, output_size).?));
        defer staging_buffer.unmap();

        const output = buf[0..output_size].*;
        try bmp.write24BitBMP("examples/output/triangle.bmp", output_extent.width, output_extent.height, output);
    }
}