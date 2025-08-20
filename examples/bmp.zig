const std = @import("std");

pub fn write24BitBMP(file_name: []const u8, comptime width: u32, comptime height: u32, bgra_data: *[width * height * 4]u8) !void {
    const file = try std.fs.cwd().createFile(file_name, .{});
    defer file.close();

    var writer = file.writer();

    // ID
    _ = try writer.write(&[2]u8{ 'B', 'M' });

    const colors_per_line = width * 3;
    const bytes_per_line = switch (colors_per_line & 0x00000003) {
        0 => colors_per_line,
        else => (colors_per_line | 0x00000003) + 1,
    };
    const file_size = 54 + (bytes_per_line * height);
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
    try writer.writeByteNTimes(0, 4 * 6);

    var line_buffer = [_]u8{0} ** bytes_per_line;
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
}
