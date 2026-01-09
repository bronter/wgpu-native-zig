const _chained_struct = @import("chained_struct.zig");
const SType = _chained_struct.SType;
const ChainedStruct = _chained_struct.ChainedStruct;
const ChainedStructOut = _chained_struct.ChainedStructOut;

const _adapter = @import("adapter.zig");
const Adapter = _adapter.Adapter;

const _texture = @import("texture.zig");
const Texture = _texture.Texture;
const TextureFormat = _texture.TextureFormat;
const TextureUsage = _texture.TextureUsage;
const TextureUsages = _texture.TextureUsages;

const _device = @import("device.zig");
const Device = _device.Device;

const _misc = @import("misc.zig");
const WGPUBool = _misc.WGPUBool;
const StringView = _misc.StringView;
const Status = _misc.Status;

// The root descriptor for the creation of an Surface with Instance.createSurface().
// It isn't sufficient by itself and must have one of the *SurfaceSource in its chain.
pub const SurfaceDescriptor = extern struct {
    next_in_chain: *const ChainedStruct,

    // Label used to refer to the object.
    label: StringView = StringView {},
};

// Chained in SurfaceDescriptor to make an Surface wrapping an Android [`ANativeWindow`](https://developer.android.com/ndk/reference/group/a-native-window).
pub const SurfaceSourceAndroidNativeWindow = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.surface_source_android_native_window,
    },

    // The pointer to the [`ANativeWindow`](https://developer.android.com/ndk/reference/group/a-native-window) that will be wrapped by the Surface.
    window: *anyopaque,
};
pub const MergedSurfaceDescriptorFromAndroidWindow = struct {
    label: []const u8 = "",
    window: *anyopaque,
};
pub inline fn surfaceDescriptorFromAndroidNativeWindow(descriptor: MergedSurfaceDescriptorFromAndroidWindow) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceSourceAndroidNativeWindow {
            .window = descriptor.window,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

// Chained in SurfaceDescriptor to make an Surface wrapping a [`CAMetalLayer`](https://developer.apple.com/documentation/quartzcore/cametallayer?language=objc).
pub const SurfaceSourceMetalLayer = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.surface_source_metal_layer,
    },

    // The pointer to the [`CAMetalLayer`](https://developer.apple.com/documentation/quartzcore/cametallayer?language=objc) that will be wrapped by the Surface.
    layer: *anyopaque,
};
pub const MergedSurfaceDescriptorFromMetalLayer = struct {
    label: []const u8 = "",
    layer: *anyopaque,
};
pub inline fn surfaceDescriptorFromMetalLayer(descriptor: MergedSurfaceDescriptorFromMetalLayer) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceSourceMetalLayer {
            .layer = descriptor.layer,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

// Chained in SurfaceDescriptor to make an Surface wrapping a [Wayland](https://wayland.freedesktop.org/) [`wl_surface`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_surface).
pub const SurfaceSourceWaylandSurface = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.surface_source_wayland_surface,
    },

    // A [`wl_display`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_display) for this Wayland instance.
    display: *anyopaque,

    // A [`wl_surface`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_surface) that will be wrapped by the Surface
    surface: *anyopaque,
};
pub const MergedSurfaceDescriptorFromWaylandSurface = struct {
    label: []const u8 = "",
    display: *anyopaque,
    surface: *anyopaque,
};
pub inline fn surfaceDescriptorFromWaylandSurface(descriptor: MergedSurfaceDescriptorFromWaylandSurface) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceSourceWaylandSurface {
            .display = descriptor.display,
            .surface = descriptor.surface,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

// Chained in SurfaceDescriptor to make an Surface wrapping a Windows [`HWND`](https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/retrieve-hwnd).
pub const SurfaceSourceWindowsHWND = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.surface_source_windows_hwnd,
    },

    // The [`HINSTANCE`](https://learn.microsoft.com/en-us/windows/win32/learnwin32/winmain--the-application-entry-point) for this application.
    // Most commonly `GetModuleHandle(nullptr)`.
    hinstance: *anyopaque,

    // The [`HWND`](https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/retrieve-hwnd) that will be wrapped by the Surface.
    hwnd: *anyopaque,
};
pub const MergedSurfaceDescriptorFromWindowsHWND = struct {
    label: []const u8 = "",
    hinstance: *anyopaque,
    hwnd: *anyopaque,
};
pub inline fn surfaceDescriptorFromWindowsHWND(descriptor: MergedSurfaceDescriptorFromWindowsHWND) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceSourceWindowsHWND {
            .hinstance = descriptor.hinstance,
            .hwnd = descriptor.hwnd,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

// Chained in SurfaceDescriptor to make an Surface wrapping an [XCB](https://xcb.freedesktop.org/) `xcb_window_t`.
pub const SurfaceSourceXCBWindow = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.surface_source_xcb_window,
    },

    // The `xcb_connection_t` for the connection to the X server.
    connection: *anyopaque,

    // The `xcb_window_t` for the window that will be wrapped by the Surface.
    window: u32,
};
pub const MergedSurfaceDescriptorFromXcbWindow = struct {
    label: []const u8 = "",
    connection: *anyopaque,
    window: u32,
};
pub inline fn surfaceDescriptorFromXcbWindow(descriptor: MergedSurfaceDescriptorFromXcbWindow) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceSourceXCBWindow {
            .connection = descriptor.connection,
            .window = descriptor.window,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

// Chained in SurfaceDescriptor to make an Surface wrapping an [Xlib](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html) `Window`.
pub const SurfaceSourceXlibWindow = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.surface_source_xlib_window,
    },

    // A pointer to the [`Display`](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Opening_the_Display) connected to the X server.
    display: *anyopaque,

    // The [`Window`](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Creating_Windows) that will be wrapped by the Surface.
    window: u64,
};
pub const MergedSurfaceDescriptorFromXlibWindow = struct {
    label: []const u8 = "",
    display: *anyopaque,
    window: u64,
};
pub inline fn surfaceDescriptorFromXlibWindow(descriptor: MergedSurfaceDescriptorFromXlibWindow) SurfaceDescriptor {
    return SurfaceDescriptor{
        .next_in_chain = @ptrCast(&SurfaceSourceXlibWindow {
            .display = descriptor.display,
            .window = descriptor.window,
        }),
        .label = StringView.fromSlice(descriptor.label),
    };
}

// Describes how frames are composited with other contents on the screen when `::wgpuSurfacePresent` is called
pub const CompositeAlphaMode = enum(u32) {
    // Lets the WebGPU implementation choose the best mode (supported, and with the best performance) between `@"opaque"` or `inherit`.
    auto            = 0x00000000,

    // The alpha component of the image is ignored and teated as if it is always 1.0.
    @"opaque"       = 0x00000001,

    // The alpha component is respected and non-alpha components are assumed to be already multiplied with the alpha component.
    // For example, (0.5, 0, 0, 0.5) is semi-transparent bright red.
    premultiplied   = 0x00000002,

    // The alpha component is respected and non-alpha components are assumed to NOT be already multiplied with the alpha component.
    // For example, (1.0, 0, 0, 0.5) is semi-transparent bright red.
    unpremultiplied = 0x00000003,

    // The handling of the alpha component is unknown to WebGPU and should be handled by the application using system-specific APIs.
    // This mode may be unavailable (for example on Wasm).
    inherit         = 0x00000004,
};

// Describes when and in which order frames are presented on the screen when `::wgpuSurfacePresent` is called.
pub const PresentMode = enum(u32) {
    // Present mode is not specified. Use the default.
    @"undefined" = 0x00000000,

    // The presentation of the image to the user waits for the next vertical blanking period to update in a first-in, first-out manner.
    // Tearing cannot be observed and frame-loop will be limited to the display's refresh rate.
    // This is the only mode that's always available.
    fifo         = 0x00000001,

    // The presentation of the image to the user tries to wait for the next vertical blanking period but may decide to not wait if a frame is presented late.
    // Tearing can sometimes be observed but late-frame don't produce a full-frame stutter in the presentation.
    // This is still a first-in, first-out mechanism so a frame-loop will be limited to the display's refresh rate.
    fifo_relaxed = 0x00000002,

    // The presentation of the image to the user is updated immediately without waiting for a vertical blank.
    // Tearing can be observed but latency is minimized.
    immediate    = 0x00000003,

    // The presentation of the image to the user waits for the next vertical blanking period to update to the latest provided image.
    // Tearing cannot be observed and a frame-loop is not limited to the display's refresh rate.
    mailbox      = 0x00000004,
};

pub const SurfaceConfigurationExtras = extern struct {
    chain: ChainedStruct = ChainedStruct {
        .s_type = SType.surface_configuration_extras,
    },

    desired_maximum_frame_latency: u32,
};

// Options to Surface.configure() for defining how a Surface will be rendered to and presented to the user.
pub const SurfaceConfiguration = extern struct {
    next_in_chain: ?*const ChainedStruct = null,

    // The Device to use to render to surface's textures.
    device: *Device,

    // The TextureFormat of the surface's textures.
    format: TextureFormat,

    // The TextureUsage of the surface's textures.
    usage: TextureUsage = TextureUsages.render_attachment,

    // The width of the surface's textures
    width: u32,

    // The height of the surface's textures.
    height: u32,

    // The additional TextureFormat for TextureView format reinterpretation of the surface's textures.
    view_format_count: usize = 0,
    view_formats: [*]const TextureFormat = &[0]TextureFormat {},

    // How the surface's frames will be composited on the screen.
    alpha_mode: CompositeAlphaMode = CompositeAlphaMode.auto,

    // When and in which order the surface's frames will be shown on the screen.
    present_mode: PresentMode = PresentMode.fifo,

    pub inline fn withDesiredMaxFrameLatency(self: SurfaceConfiguration, desired_max_frame_latency: u32) SurfaceConfiguration {
        var sc = self;
        sc.next_in_chain = @ptrCast(&SurfaceConfigurationExtras {
            .desired_maximum_frame_latency = desired_max_frame_latency,
        });
        return sc;
    }
};

pub const SurfaceCapabilitiesProcs = struct {
    pub const FreeMembers = *const fn(SurfaceCapabilities) callconv(.c) void;
};

extern fn wgpuSurfaceCapabilitiesFreeMembers(surface_capabilities: SurfaceCapabilities) void;

// Filled by Surface.getCapabilities() with what's supported for Surface.configure() for a pair of Surface and Adapter.
pub const SurfaceCapabilities = extern struct {
    next_in_chain: ?*ChainedStructOut = null,

    // The bit set of supported TextureUsage bits.
    // Guaranteed to contain TextureUsage.render_attachment.
    usages: TextureUsage,

    // A list of supported TextureFormat values, in order of preference.
    format_count: usize,
    formats: [*]const TextureFormat,

    // A list of supported PresentMode values.
    // Guaranteed to contain PresentMode.fifo.
    present_mode_count: usize,
    present_modes: [*]const PresentMode,

    // A list of supported CompositeAlphaMode values.
    // CompositeAlphaMode.auto will be an alias for the first element and will never be present in this array.
    alpha_mode_count: usize,
    alpha_modes: [*]const CompositeAlphaMode,

    // Frees array members of SurfaceCapabilities which were allocated by the API.
    pub inline fn freeMembers(self: SurfaceCapabilities) void {
        wgpuSurfaceCapabilitiesFreeMembers(self);
    }
};

// The status enum for `::wgpuSurfaceGetCurrentTexture`.
pub const GetCurrentTextureStatus = enum(u32) {
    // Yay! Everything is good and we can render this frame.
    success_optimal    = 0x00000001,

    // Still OK - the surface can present the frame, but in a suboptimal way.
    // The surface may need reconfiguration.
    success_suboptimal = 0x00000002,

    // Some operation timed out while trying to acquire the frame.
    timeout            = 0x00000003,

    // The surface is too different to be used, compared to when it was originally created.
    outdated           = 0x00000004,

    // The connection to whatever owns the surface was lost.
    lost               = 0x00000005,

    // The system ran out of memory.
    out_of_memory      = 0x00000006,

    // The Device configured on the Surface was lost.
    device_lost        = 0x00000007,

    // The surface is not configured, or there was an OutStructChainError.
    @"error"           = 0x00000008,
};

// Queried each frame from a Surface to get a Texture to render to along with some metadata.
pub const SurfaceTexture = extern struct {
    next_in_chain: ?*ChainedStructOut,

    // The Texture representing the frame that will be shown on the surface.
    // It is ReturnedWithOwnership from Surface.getCurrentTexture().
    texture: ?*Texture,

    // Whether the call to Surface.getCurrentTexture() succeeded and a hint as to why it might not have.
    status: GetCurrentTextureStatus,
};

pub const SurfaceProcs = struct {
    pub const Configure = *const fn(*Surface, *const SurfaceConfiguration) callconv(.c) void;
    pub const GetCapabilities = *const fn(*Surface, *Adapter, *SurfaceCapabilities) callconv(.c) Status;
    pub const GetCurrentTexture = *const fn(*Surface, *SurfaceTexture) callconv(.c) void;
    pub const Present = *const fn(*Surface) callconv(.c) Status;
    pub const SetLabel = *const fn(*Surface, StringView) void;
    pub const Unconfigure = *const fn(*Surface) callconv(.c) void;
    pub const AddRef = *const fn(*Surface) callconv(.c) void;
    pub const Release = *const fn(*Surface) callconv(.c) void;
};

extern fn wgpuSurfaceConfigure(surface: *Surface, config: *const SurfaceConfiguration) void;
extern fn wgpuSurfaceGetCapabilities(surface: *Surface, adapter: *Adapter, capabilities: *SurfaceCapabilities) Status;
extern fn wgpuSurfaceGetCurrentTexture(surface: *Surface, surface_texture: *SurfaceTexture) void;
extern fn wgpuSurfacePresent(surface: *Surface) Status;
extern fn wgpuSurfaceSetLabel(surface: *Surface, label: StringView) void;
extern fn wgpuSurfaceUnconfigure(surface: *Surface) void;
extern fn wgpuSurfaceAddRef(surface: *Surface) void;
extern fn wgpuSurfaceRelease(surface: *Surface) void;

pub const Surface = opaque {
    pub inline fn configure(self: *Surface, config: *const SurfaceConfiguration) void {
        wgpuSurfaceConfigure(self, config);
    }

    // Provides information on how `adapter` is able to use `surface`.
    //
    // adapter
    // The Adapter to get capabilities for presenting to this Surface.
    //
    // capabilities
    // The structure to fill capabilities in.
    // It may contain memory allocations so `capabilities.freeMembers()` must be called to avoid memory leaks.
    //
    // Return value indicates if there was an OutStructChainError.
    //
    pub inline fn getCapabilities(self: *Surface, adapter: *Adapter, capabilities: *SurfaceCapabilities) Status {
        return wgpuSurfaceGetCapabilities(self, adapter, capabilities);
    }

    // Retrieves the Texture to render to `surface` this frame along with metadata on the frame.
    // Populates surface_texture with .texture = null and .status = GetCurrentTextureStatus.@"error" if the surface is not configured.
    //
    // surface_texture
    // The structure to fill the Texture and metadata in.
    //
    pub inline fn getCurrentTexture(self: *Surface, surface_texture: *SurfaceTexture) void {
        wgpuSurfaceGetCurrentTexture(self, surface_texture);
    }

    // Shows `surface`'s current texture to the user.
    //
    // Returns Status.@"error" if the surface doesn't have a current texture.
    //
    pub inline fn present(self: *Surface) Status {
        return wgpuSurfacePresent(self);
    }

    // Unimplemented as of wgpu-native v25.0.2.1,
    // see https://github.com/gfx-rs/wgpu-native/blob/d8238888998db26ceab41942f269da0fa32b890c/src/unimplemented.rs#L200
    // pub inline fn setLabel(self: *Surface, label: []const u8) void {
    //     wgpuSurfaceSetLabel(self, StringView.fromSlice(label));
    // }

    // Removes the configuration for `surface`.
    pub inline fn unconfigure(self: *Surface) void {
        wgpuSurfaceUnconfigure(self);
    }

    pub inline fn addRef(self: *Surface) void {
        wgpuSurfaceAddRef(self);
    }
    pub inline fn release(self: *Surface) void {
        wgpuSurfaceRelease(self);
    }
};