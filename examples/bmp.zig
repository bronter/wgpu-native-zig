const std = @import("std");

pub fn write24BitBMP(file_name: []const u8, comptime width: u32, comptime height: u32, bgra_data: *[width * height * 4]u8) !void {
    const file = try std.fs.cwd().createFile(file_name, .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var fw = file.writer(&buffer);
    const writer = &fw.interface;

    const bytes_per_line = comptime std.mem.alignForward(u32, width * 3, 4);
    const file_size = 54 + (bytes_per_line * height);

    // ID
    _ = try writer.write(&[2]u8{ 'B', 'M' });

    try writer.writeInt(u32, file_size, .little);

    // reserved
    try writer.writeInt(u32, 0, .little);
    // data offset
    try writer.writeInt(u32, 54, .little);
    // info size
    try writer.writeInt(u32, 40, .little);
    // image width
    try writer.writeInt(u32, width, .little);
    // image height
    try writer.writeInt(u32, height, .little);
    // Planes
    try writer.writeInt(u16, 1, .little);
    // bits per pixel
    try writer.writeInt(u16, 24, .little);
    // Six 32-bit words, all set to zero:
    // compression type, compressed image size, x pixels/meter, y pixels/meter, colors used, important colors
    try writer.splatByteAll(0 , 4 * 6);

    var line_buffer: [bytes_per_line]u8 = @splat(0);
    const bgra_pixels_per_line = width * 4;
    for (0..height) |i_y| {
        const y = height - i_y - 1;
        const line_offset = y * bgra_pixels_per_line;
        for (0..width) |x| {
            const bgr_pixel_offset = x * 3;
            const bgra_pixel_offset = line_offset + (x * 4);
            line_buffer[bgr_pixel_offset] = bgra_data[bgra_pixel_offset];
            line_buffer[bgr_pixel_offset + 1] = bgra_data[bgra_pixel_offset + 1];
            line_buffer[bgr_pixel_offset + 2] = bgra_data[bgra_pixel_offset + 2];
        }
        _ = try writer.write(&line_buffer);
    }

    try writer.flush();
}
