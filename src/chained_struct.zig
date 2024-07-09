const WGPUSType = enum(u32) {
    Invalid                                  = 0x00000000,
    SurfaceDescriptorFromMetalLayer          = 0x00000001,
    SurfaceDescriptorFromWindowsHWND         = 0x00000002,
    SurfaceDescriptorFromXlibWindow          = 0x00000003,
    SurfaceDescriptorFromCanvasHTMLSelector  = 0x00000004,
    ShaderModuleSPIRVDescriptor              = 0x00000005,
    ShaderModuleWGSLDescriptor               = 0x00000006,
    PrimitiveDepthClipControl                = 0x00000007,
    SurfaceDescriptorFromWaylandSurface      = 0x00000008,
    SurfaceDescriptorFromAndroidNativeWindow = 0x00000009,
    SurfaceDescriptorFromXcbWindow           = 0x0000000A,
    RenderPassDescriptorMaxDrawCount         = 0x0000000F,
};
pub const SType = WGPUSType;

const WGPUChainedStruct = extern struct {
    next: ?*const ChainedStruct,
    s_type: SType,
};
pub const ChainedStruct = WGPUChainedStruct;