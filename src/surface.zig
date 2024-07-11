const _chained_struct = @import("chained_struct.zig");
const SType = _chained_struct.SType;
const ChainedStruct = _chained_struct.ChainedStruct;
const ChainedStructOut = _chained_struct.ChainedStructOut;

const _adapter = @import("adapter.zig");
const Adapter = _adapter.Adapter;

const _texture = @import("texture.zig");
const Texture = _texture.Texture;
const TextureFormat = _texture.TextureFormat;
const TextureUsageFlags = _texture.TextureUsageFlags;

const _device = @import("device.zig");
const Device = _device.Device;

const WGPUBool = @import("misc.zig").WGPUBool;

pub const SurfaceDescriptor = extern struct {
    next_in_chain: *ChainedStruct,
    label: [*c]const u8 = "",
};

pub const SurfaceDescriptorFromAndroidNativeWindow = extern struct {
    chain: ChainedStruct,
    window: *anyopaque,
};
pub inline fn surfaceDescriptorFromAndroidNativeWindow(label: []const u8, window: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromAndroidNativeWindow {
            .chain = ChainedStruct {
                .s_type = SType.SurfaceDescriptorFromAndroidNativeWindow,
            },
            .window = window,
        }),
        .label = label,
    };
}

pub const SurfaceDescriptorFromCanvasHTMLSelector = extern struct {
    chain: ChainedStruct,
    selector: [*c]const u8,
};
pub inline fn surfaceDescriptorFromCanvasHTMLSelector(label: []const u8, selector: []const u8) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromCanvasHTMLSelector {
            .chain = ChainedStruct {
                .s_type = SType.SurfaceDescriptorFromCanvasHTMLSelector,
            },
            .selector = selector,
        }),
        .label = label,
    };
}

pub const SurfaceDescriptorFromMetalLayer = extern struct {
    chain: ChainedStruct,
    layer: *anyopaque,
};
pub inline fn surfaceDescriptorFromMetalLayer(label: []const u8, layer: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromMetalLayer {
            .chain = ChainedStruct {
                .s_type = SType.SurfaceDescriptorFromMetalLayer,
            },
            .layer = layer,
        }),
        .label = label,
    };
}

pub const SurfaceDescriptorFromWaylandSurface = extern struct {
    chain: ChainedStruct,
    display: *anyopaque,
    surface: *anyopaque,
};
pub inline fn surfaceDescriptorFromWaylandSurface(label: []const u8, display: *anyopaque, surface: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromWaylandSurface {
            .chain = ChainedStruct {
                .s_type = SType.SurfaceDescriptorFromWaylandSurface,
            },
            .display = display,
            .surface = surface,
        }),
        .label = label,
    };
}

pub const SurfaceDescriptorFromWindowsHWND = extern struct {
    chain: ChainedStruct,
    hinstance: *anyopaque,
    hwnd: *anyopaque,
};
pub inline fn surfaceDescriptorFromWindowsHWND(label: []const u8, hinstance: *anyopaque, hwnd: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromWindowsHWND {
            .chain = ChainedStruct {
                .s_type = SType.SurfaceDescriptorFromWindowsHWND,
            },
            .hinstance = hinstance,
            .hwnd = hwnd,
        }),
        .label = label,
    };
}

pub const SurfaceDescriptorFromXcbWindow = extern struct {
    chain: ChainedStruct,
    connection: *anyopaque,
    window: u32,
};
pub inline fn surfaceDescriptorFromXcbWindow(label: []const u8, connection: *anyopaque, window: u32) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromXcbWindow {
            .chain = ChainedStruct {
                .s_type = SType.SurfaceDescriptorFromXcbWindow,
            },
            .connection = connection,
            .window = window,
        }),
        .label = label,
    };
}

pub const SurfaceDescriptorFromXlibWindow = extern struct {
    chain: ChainedStruct,
    display: *anyopaque,
    window: u64,
};
pub inline fn surfaceDescriptorFromXlibWindow(label: []const u8, display: *anyopaque, window: u64) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromXlibWindow {
            .chain = ChainedStruct {
                .s_type = SType.SurfaceDescriptorFromXlibWindow,
            },
            .display = display,
            .window = window,
        }),
        .label = label,
    };
}

// CompositeAlphaMode and PresentMode only seem to be used by surface-related things, so I'm putting them here.
pub const CompositeAlphaMode = enum(u32) {
    Auto            = 0x00000000,
    Opaque          = 0x00000001,
    Premultiplied   = 0x00000002,
    Unpremultiplied = 0x00000003,
    Inherit         = 0x00000004,
};
pub const PresentMode = enum(u32) {
    Fifo        = 0x00000000,
    FifoRelaxed = 0x00000001,
    Immediate   = 0x00000002,
    Mailbox     = 0x00000003,
};

pub const SurfaceConfiguration = extern struct {
    next_in_chain: *ChainedStruct,
    device: *Device,
    format: TextureFormat,
    usage: TextureUsageFlags,
    view_format_count: usize,
    view_formats: [*c]const TextureFormat,
    alpha_mode: CompositeAlphaMode,
    width: u32,
    height: u32,
    present_mode: PresentMode,
};

pub const SurfaceCapabilitiesProcs = struct {
    const FreeMembers = *const fn(*SurfaceCapabilities) callconv(.C) void;
};
extern fn wgpuSurfaceCapabilitiesFreeMembers(capabilities: *SurfaceCapabilities) void;
pub const SurfaceCapabilities = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    format_count: usize,
    formats: [*c] TextureFormat,
    present_mode_count: usize,
    present_modes: [*c] PresentMode,
    alpha_mode_count: usize,
    alpha_modes: [*c] CompositeAlphaMode,

    pub inline fn FreeMembers(self: *SurfaceCapabilities) void {
        wgpuSurfaceCapabilitiesFreeMembers(self);
    }
};

pub const GetCurrentTextureStatus = enum(u32) {
    Success     = 0x00000000,
    Timeout     = 0x00000001,
    Outdated    = 0x00000002,
    Lost        = 0x00000003,
    OutOfMemory = 0x00000004,
    DeviceLost  = 0x00000005,
};

pub const SurfaceTexture = extern struct {
    texture: *Texture,
    suboptimal: WGPUBool,
    status: GetCurrentTextureStatus,
};

pub const SurfaceProcs = struct {
    const Configure = *const fn(*Surface, *const SurfaceConfiguration) callconv(.C) void;
    const GetCapabilities = *const fn(*Surface, *Adapter, *SurfaceCapabilities) callconv(.C) void;
    const GetCurrentTexture = *const fn(*Surface, *SurfaceTexture) callconv(.C) void;
    const GetPreferredFormat = *const fn(*Surface, *Adapter) callconv(.C) TextureFormat;
    const Present = *const fn(*Surface) callconv(.C) void;
    const Unconfigure = *const fn(*Surface) callconv(.C) void;
    const Reference = *const fn(*Surface) callconv(.C) void;
    const Release = *const fn(*Surface) callconv(.C) void;
};

extern fn wgpuSurfaceConfigure(surface: *Surface, config: *SurfaceConfiguration) void;
extern fn wgpuSurfaceGetCapabilities(surface: *Surface, adapter: *Adapter, capabilities: *SurfaceCapabilities) void;
extern fn wgpuSurfaceGetCurrentTexture(surface: *Surface, surface_texture: *SurfaceTexture) void;
extern fn wgpuSurfaceGetPreferredFormat(surface: *Surface, adapter: *Adapter) TextureFormat;
extern fn wgpuSurfacePresent(surface: *Surface) void;
extern fn wgpuSurfaceUnconfigure(surface: *Surface) void;
extern fn wgpuSurfaceReference(surface: *Surface) void;
extern fn wgpuSurfaceRelease(surface: *Surface) void;

pub const Surface = opaque {
    pub inline fn configure(self: *Surface, config: *const SurfaceConfiguration) void {
        wgpuSurfaceConfigure(self, config);
    }
    pub inline fn getCapabilities(self: *Surface, adapter: *Adapter, capabilities: *SurfaceCapabilities) void {
        wgpuSurfaceGetCapabilities(self, adapter, capabilities);
    }
    pub inline fn getCurrentTexture(self: *Surface, surface_texture: *SurfaceTexture) void {
        wgpuSurfaceGetCurrentTexture(self, surface_texture);
    }
    pub inline fn getPreferredFormat(self: *Surface, adapter: *Adapter) TextureFormat {
        return wgpuSurfaceGetPreferredFormat(self, adapter);
    }
    pub inline fn present(self: *Surface) void {
        wgpuSurfacePresent(self);
    }
    pub inline fn unconfigure(self: *Surface) void {
        wgpuSurfaceUnconfigure(self);
    }
    pub inline fn reference(self: *Surface) void {
        wgpuSurfaceReference(self);
    }
    pub inline fn release(self: *Surface) void {
        wgpuSurfaceRelease(self);
    }
};