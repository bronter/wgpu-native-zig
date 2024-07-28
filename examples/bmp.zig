const std = @import("std");

pub fn write24BitBMP(file_name: []const u8, comptime width: u32, comptime height: u32, bgra_data: [width * height * 4]u8) !void {
    const file = try std.fs.cwd().createFile(file_name, .{});
    defer file.close();

    // BMP's values should be in little-endian format, use bitWriter to make sure they are.
    var bs = std.io.bitWriter(.little, file.writer());

    // ID
    _ = try bs.write(&[2]u8{'B', 'M'});

    const colors_per_line = width * 3;
    const bytes_per_line = switch(colors_per_line & 0x00000003) {
        0 => colors_per_line,
        else => (colors_per_line | 0x00000003) + 1,
    };
    const file_size = 54 + (bytes_per_line * height);
    try bs.writeBits(file_size, 32);

    // reserved
    try bs.writeBits(@as(u32, 0), 32);
    // data offset
    try bs.writeBits(@as(u32, 54), 32);
    // info size
    try bs.writeBits(@as(u32, 40), 32);
    // image width
    try bs.writeBits(width, 32);
    // image height
    try bs.writeBits(height, 32);
    // Planes
    try bs.writeBits(@as(u16, 1), 16);
    // bits per pixel
    try bs.writeBits(@as(u16, 24), 16);
    // Six 32-bit words, all set to zero:
    // compression type, compressed image size, x pixels/meter, y pixels/meter, colors used, important colors
    try bs.writeBits(@as(u192, 0), 192);

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
        _ = try bs.write(&line_buffer);
    }
}