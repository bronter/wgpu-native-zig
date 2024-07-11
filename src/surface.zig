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
    label: ?[*:0]const u8 = null,
};

pub const SurfaceDescriptorFromAndroidNativeWindow = extern struct {
    chain: ChainedStruct,
    window: *anyopaque,
};
pub inline fn surfaceDescriptorFromAndroidNativeWindow(label: ?[:0]const u8, window: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromAndroidNativeWindow {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_android_native_window,
            },
            .window = window,
        }),
        .label = label,
    };
}

pub const SurfaceDescriptorFromCanvasHTMLSelector = extern struct {
    chain: ChainedStruct,
    selector: [*:0]const u8,
};
pub inline fn surfaceDescriptorFromCanvasHTMLSelector(label: ?[:0]const u8, selector: [:0]const u8) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromCanvasHTMLSelector {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_canvas_html_selector,
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
pub inline fn surfaceDescriptorFromMetalLayer(label: ?[:0]const u8, layer: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromMetalLayer {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_metal_layer,
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
pub inline fn surfaceDescriptorFromWaylandSurface(label: ?[:0]const u8, display: *anyopaque, surface: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromWaylandSurface {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_wayland_surface,
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
pub inline fn surfaceDescriptorFromWindowsHWND(label: ?[:0]const u8, hinstance: *anyopaque, hwnd: *anyopaque) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromWindowsHWND {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_windows_hwnd,
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
pub inline fn surfaceDescriptorFromXcbWindow(label: ?[:0]const u8, connection: *anyopaque, window: u32) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromXcbWindow {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_xcb_window,
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
pub inline fn surfaceDescriptorFromXlibWindow(label: ?[:0]const u8, display: *anyopaque, window: u64) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceDescriptorFromXlibWindow {
            .chain = ChainedStruct {
                .s_type = SType.surface_descriptor_from_xlib_window,
            },
            .display = display,
            .window = window,
        }),
        .label = label,
    };
}

// CompositeAlphaMode and PresentMode only seem to be used by surface-related things, so I'm putting them here.
pub const CompositeAlphaMode = enum(u32) {
    auto            = 0x00000000,
    @"opaque"       = 0x00000001,
    premultiplied   = 0x00000002,
    unpremultiplied = 0x00000003,
    inherit         = 0x00000004,
};
pub const PresentMode = enum(u32) {
    fifo         = 0x00000000,
    fifo_relaxed = 0x00000001,
    immediate    = 0x00000002,
    mailbox      = 0x00000003,
};

pub const SurfaceConfiguration = extern struct {
    next_in_chain: *ChainedStruct,
    device: *Device,
    format: TextureFormat,
    usage: TextureUsageFlags,
    view_format_count: usize,
    view_formats: [*]const TextureFormat,
    alpha_mode: CompositeAlphaMode,
    width: u32,
    height: u32,
    present_mode: PresentMode,
};

pub const SurfaceCapabilitiesProcs = struct {
    pub const FreeMembers = *const fn(*SurfaceCapabilities) callconv(.C) void;
};
extern fn wgpuSurfaceCapabilitiesFreeMembers(capabilities: *SurfaceCapabilities) void;
pub const SurfaceCapabilities = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    format_count: usize,
    formats: [*]TextureFormat,
    present_mode_count: usize,
    present_modes: [*]PresentMode,
    alpha_mode_count: usize,
    alpha_modes: [*]CompositeAlphaMode,

    pub inline fn FreeMembers(self: *SurfaceCapabilities) void {
        wgpuSurfaceCapabilitiesFreeMembers(self);
    }
};

pub const GetCurrentTextureStatus = enum(u32) {
    success       = 0x00000000,
    timeout       = 0x00000001,
    outdated      = 0x00000002,
    lost          = 0x00000003,
    out_of_memory = 0x00000004,
    device_lost   = 0x00000005,
};

pub const SurfaceTexture = extern struct {
    texture: *Texture,
    suboptimal: WGPUBool,
    status: GetCurrentTextureStatus,
};

pub const SurfaceProcs = struct {
    pub const Configure = *const fn(*Surface, *const SurfaceConfiguration) callconv(.C) void;
    pub const GetCapabilities = *const fn(*Surface, *Adapter, *SurfaceCapabilities) callconv(.C) void;
    pub const GetCurrentTexture = *const fn(*Surface, *SurfaceTexture) callconv(.C) void;
    pub const GetPreferredFormat = *const fn(*Surface, *Adapter) callconv(.C) TextureFormat;
    pub const Present = *const fn(*Surface) callconv(.C) void;
    pub const Unconfigure = *const fn(*Surface) callconv(.C) void;
    pub const Reference = *const fn(*Surface) callconv(.C) void;
    pub const Release = *const fn(*Surface) callconv(.C) void;
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