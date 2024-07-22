pub const LogLevel = enum(u32) {
    off      = 0x00000000,
    @"error" = 0x00000001,
    warn     = 0x00000002,
    info     = 0x00000003,
    debug    = 0x00000004,
    trace    = 0x00000005,
};

pub const LogCallback = *const fn(level: LogLevel, message: ?[*:0]const u8, userdata: ?*anyopaque) callconv(.C) void;

extern fn wgpuSetLogCallback(callback: LogCallback, userdata: ?*anyopaque) void;
extern fn wgpuSetLogLevel(level: LogLevel) void;

pub inline fn setLogCallback(callback: LogCallback, userdata: ?*anyopaque) void {
    wgpuSetLogCallback(callback, userdata);
}
pub inline fn setLogLevel(level: LogLevel) void {
    wgpuSetLogLevel(level);
}