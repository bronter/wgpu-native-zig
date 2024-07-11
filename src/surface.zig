const chained_struct = @import("chained_struct.zig");
const ChainedStruct = chained_struct.ChainedStruct;
const SType = chained_struct.SType;

const texture = @import("texture.zig");

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

// // CompositeAlphaMode and PresentMode only seem to be used by surface-related things, so I'm putting them here.
// pub const CompositeAlphaMode = enum(u32) {
//     Auto            = 0x00000000,
//     Opaque          = 0x00000001,
//     Premultiplied   = 0x00000002,
//     Unpremultiplied = 0x00000003,
//     Inherit         = 0x00000004,
// };
// pub const PresentMode = enum(u32) {
//     Fifo        = 0x00000000,
//     FifoRelaxed = 0x00000001,
//     Immediate   = 0x00000002,
//     Mailbox     = 0x00000003,
// };

// pub const SurfaceConfiguration = extern struct {
//     next_in_chain: *ChainedStruct,
//     device: *Device,
//     format: texture.TextureFormat,
//     usage: texture.TextureUsageFlags,
//     view_format_count: usize,
//     view_formats: [*c]const texture.TextureFormat,
//     alpha_mode: CompositeAlphaMode,
//     width: u32,
//     height: u32,
//     present_mode:
// };

// pub const SurfaceProcs = struct {
//     const Configure = *const fn(*Surface, *const SurfaceConfiguration)
// };

pub const Surface = opaque {
    // TODO: fill in methods
};