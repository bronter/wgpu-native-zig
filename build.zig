const std = @import("std");

fn link_windows_system_libraries(comptime T: type, mod: *T, is_gnu: bool) void {
    const linkSystemLibrary = switch (T) {
        std.Build.Module => std.Build.Module.linkSystemLibrary,
        std.Build.Step.Compile => std.Build.Step.Compile.linkSystemLibrary2,
        else => @compileError("Provided type must either be std.Build.Module or std.Build.Step.Compile"),
    };

    if (is_gnu) {
        // For gnu, the linker needs the d3dcompiler dll since it can't find a suitable static lib
        // (I'd guess it tries to search for something like "libd3dcompiler.a" instead of "d3dcompiler.lib").
        linkSystemLibrary(mod, "d3dcompiler_47", .{});

        // This seems to have something to do with the windows-result crate in wgpu-native's dependencies
        linkSystemLibrary(mod, "api-ms-win-core-winrt-error-l1-1-0", .{});
    } else {
        linkSystemLibrary(mod, "d3dcompiler", .{});

        // GetClientRect is unresolved unless we link this for msvc
        linkSystemLibrary(mod, "user32", .{});

        linkSystemLibrary(mod, "RuntimeObject", .{});
    }
    linkSystemLibrary(mod, "opengl32", .{});
    linkSystemLibrary(mod, "gdi32", .{});

    // COM-related
    linkSystemLibrary(mod, "OleAut32", .{});
    linkSystemLibrary(mod, "Ole32", .{});

    // Apparently these are needed because of rust stdlib
    linkSystemLibrary(mod, "ws2_32", .{});
    linkSystemLibrary(mod, "userenv", .{});

    // Needed by windows-rs (wgpu-native dependency)
    linkSystemLibrary(mod, "propsys", .{});
}

fn link_mac_frameworks(mod: *std.Build.Step.Compile) void {
    mod.linkFramework("Foundation");
    mod.linkFramework("QuartzCore");
    mod.linkFramework("Metal");
}

const WGPUBuildContext = struct {
    link_mode: std.builtin.LinkMode,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    is_windows: bool,
    is_mac: bool,
    wgpu_dep: *std.Build.Dependency,
    libwgpu_path: ?std.Build.LazyPath,
    install_lib_dir: []const u8,
    wgpu_mod: *std.Build.Module,
    wgpu_c_mod: *std.Build.Module,

    fn init(b: *std.Build) ?WGPUBuildContext {
        const link_mode = b.option(std.builtin.LinkMode, "link_mode", "Use static linking instead of dynamic linking.") orelse .static;
        // Standard target options allows the person running `zig build` to choose
        // what target to build for. Here we do not override the defaults, which
        // means any target is allowed, and the default is native. Other options
        // for restricting supported target set are available.
        const target = b.standardTargetOptions(.{});

        // Standard optimization options allow the person running `zig build` to select
        // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
        // set a preferred release mode, allowing the user to decide how to optimize.
        const optimize = b.standardOptimizeOption(.{});

        const target_res = target.result;
        const os_str = @tagName(target_res.os.tag);
        const arch_str = @tagName(target_res.cpu.arch);

        const mode_str = switch (optimize) {
            .Debug => "debug",
            else => "release",
        };
        const abi_str = switch (target_res.os.tag) {
            .ios => switch (target_res.abi) {
                .simulator => "_simulator",
                else => "",
            },
            .windows => switch (target_res.abi) {
                .msvc => "_msvc",
                else => "_gnu",
            },
            else => "",
        };
        const target_name_slices = [_][:0]const u8{ "wgpu_", os_str, "_", arch_str, abi_str, "_", mode_str };
        const maybe_target_name = std.mem.concatWithSentinel(b.allocator, u8, &target_name_slices, 0);
        const target_name = maybe_target_name catch |err| {
            std.debug.panic("Failed to format target name: {s}", .{@errorName(err)});
        };

        // Check if we have a dependency matching our selected target.
        for (b.available_deps) |dep| {
            const name, _ = dep;
            if (std.mem.eql(u8, name, target_name)) {
                break;
            }
        } else {
            std.debug.panic("Could not find dependency matching target {s}", .{target_name});
        }

        const wgpu_mod = b.addModule("wgpu", .{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        });

        const wgpu_dep = b.lazyDependency(target_name, .{}) orelse return null;

        const translate_step = b.addTranslateC(.{
            // wgpu.h imports webgpu.h, so we get the contents of both files, as well as a bunch of libc garbage.
            .root_source_file = wgpu_dep.path("include/webgpu/wgpu.h"),

            .target = target,
            .optimize = optimize,
        });

        const wgpu_c_mod = translate_step.addModule("wgpu-c");
        wgpu_c_mod.resolved_target = target;
        wgpu_c_mod.link_libcpp = true;

        var libwgpu_path: ?std.Build.LazyPath = null;
        var is_windows: bool = false;
        var is_mac: bool = target_res.os.tag == .macos or target_res.os.tag == .ios;

        // TODO: This seems like it could be made smaller, lots of repetitive code here.
        switch (target_res.os.tag) {
            .windows => {
                is_windows = true;
                if (target_res.abi == .msvc) {
                    // I feel like libcpp should work, but it definitely does not on msvc. Fortunately libc does.
                    wgpu_mod.link_libcpp = false;
                    wgpu_c_mod.link_libcpp = false;
                    wgpu_mod.link_libc = true;
                    wgpu_c_mod.link_libc = true;

                    if (link_mode == .static) {
                        libwgpu_path = wgpu_dep.path("lib/wgpu_native.lib");

                        link_windows_system_libraries(std.Build.Module, wgpu_mod, false);
                        link_windows_system_libraries(std.Build.Module, wgpu_c_mod, false);
                    } else {
                        libwgpu_path = wgpu_dep.path("lib/wgpu_native.dll.lib");

                        // Unfortunately, it seems only the local tests can access the dll this way.
                        // For dependees, it copies to the zig cache, which you can use for testing if you do some weird stuff with the install steps,
                        // but it never copies to the output folder. So not helpful if you need to distribute a binary with the dll alongside it.
                        const dll_install_file = b.addInstallLibFile(wgpu_dep.path("lib/wgpu_native.dll"), "wgpu_native.dll");
                        b.getInstallStep().dependOn(&dll_install_file.step);

                        // For dependees that need the dll file, this seems to be the only reliable way to propagate it through.
                        // In Zig 0.14 there seems to be some method for exposing LazyPaths to dependees, which might be a bit cleaner.
                        const writeFiles = b.addNamedWriteFiles("lib");
                        _ = writeFiles.addCopyFile(wgpu_dep.path("lib/wgpu_native.dll"), "wgpu_native.dll");
                    }
                } else {
                    if (link_mode == .static) {
                        libwgpu_path = wgpu_dep.path("lib/libwgpu_native.a");

                        link_windows_system_libraries(std.Build.Module, wgpu_mod, true);
                        link_windows_system_libraries(std.Build.Module, wgpu_c_mod, true);
                    } else {
                        libwgpu_path = wgpu_dep.path("lib/libwgpu_native.dll.a");

                        const dll_install_file = b.addInstallLibFile(wgpu_dep.path("lib/wgpu_native.dll"), "wgpu_native.dll");
                        b.getInstallStep().dependOn(&dll_install_file.step);

                        const writeFiles = b.addNamedWriteFiles("lib");
                        _ = writeFiles.addCopyFile(wgpu_dep.path("lib/wgpu_native.dll"), "wgpu_native.dll");
                    }
                }
            },

            // This only tries to account for linux/macos since we're using pre-compiled wgpu-native;
            // need to think harder about this if I get custom builds working.
            else => if (link_mode == .static) {
                libwgpu_path = wgpu_dep.path("lib/libwgpu_native.a");
            } else if (target_res.os.tag == .macos or target_res.os.tag == .ios) { // TODO: This is just guesswork, need to test it somehow, but I don't have a mac.
                is_mac = true;
                const dylib_install_file = b.addInstallLibFile(wgpu_dep.path("lib/libwgpu_native.dylib"), "libwgpu_native.dylib");
                b.getInstallStep().dependOn(&dylib_install_file.step);

                const writeFiles = b.addNamedWriteFiles("lib");
                _ = writeFiles.addCopyFile(wgpu_dep.path("lib/libwgpu_native.dylib"), "libwgpu_native.dylib");
            } else {
                const so_install_file = b.addInstallLibFile(wgpu_dep.path("lib/libwgpu_native.so"), "libwgpu_native.so");
                b.getInstallStep().dependOn(&so_install_file.step);

                const writeFiles = b.addNamedWriteFiles("lib");
                _ = writeFiles.addCopyFile(wgpu_dep.path("lib/libwgpu_native.so"), "libwgpu_native.so");
            },
        }

        if (libwgpu_path != null) {
            wgpu_mod.addObjectFile(libwgpu_path.?);
            wgpu_c_mod.addObjectFile(libwgpu_path.?);
        }

        return WGPUBuildContext{
            .link_mode = link_mode,
            .target = target,
            .optimize = optimize,
            .is_windows = is_windows,
            .is_mac = is_mac,
            .wgpu_dep = wgpu_dep,
            .libwgpu_path = libwgpu_path,
            .install_lib_dir = b.getInstallPath(.lib, ""),
            .wgpu_mod = wgpu_mod,
            .wgpu_c_mod = wgpu_c_mod,
        };
    }
};

fn dynamic_link(context: *const WGPUBuildContext, c: *std.Build.Step.Compile, cmd: *std.Build.Step.Run) void {
    if (!context.is_windows) {
        c.addLibraryPath(context.wgpu_dep.path("lib"));
        c.linkSystemLibrary2("wgpu_native", .{});
    }
    cmd.addPathDir(context.install_lib_dir);
}

fn handle_rt(context: *const WGPUBuildContext, exe: *std.Build.Step.Compile) void {
    if (context.is_windows and context.target.result.abi == .msvc) {
        // We get duplicate symbol errors at link-time if we don't disable these;
        exe.bundle_compiler_rt = false;
        exe.bundle_ubsan_rt = false;
    }
}

fn triangle_example(b: *std.Build, context: *const WGPUBuildContext) void {
    const bmp_mod = b.createModule(.{
        .root_source_file = b.path("examples/bmp.zig"),
    });

    const triangle_example_exe_mod = b.createModule(.{
        .root_source_file = b.path("examples/triangle/triangle.zig"),
        .target = context.target,
        .optimize = context.optimize,
    });
    triangle_example_exe_mod.addImport("wgpu", context.wgpu_mod);
    triangle_example_exe_mod.addImport("bmp", bmp_mod);
    const triangle_example_exe = b.addExecutable(.{
        .name = "triangle-example",
        .root_module = triangle_example_exe_mod,
    });
    handle_rt(context, triangle_example_exe);

    const run_triangle_cmd = b.addRunArtifact(triangle_example_exe);

    const run_triangle_step = b.step("run-triangle-example", "Run the triangle example");
    run_triangle_step.dependOn(&run_triangle_cmd.step);

    if (context.link_mode == .dynamic) {
        dynamic_link(context, triangle_example_exe, run_triangle_cmd);

        run_triangle_cmd.step.dependOn(b.getInstallStep());
    }
}

fn unit_tests(b: *std.Build, context: *const WGPUBuildContext) void {
    const unit_test_step = b.step("unit-tests", "Run unit tests");
    if (context.is_windows) {
        unit_test_step.dependOn(b.getInstallStep());
    }

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = context.target,
        .optimize = context.optimize,
    });
    const t = b.addTest(.{
        .name = "root_unit",
        .root_module = test_mod,
    });
    handle_rt(context, t);
    if (context.libwgpu_path != null) {
        t.addObjectFile(context.libwgpu_path.?);
    }
    if (context.is_windows) {
        t.linkLibC();
    } else {
        t.linkLibCpp();
    }

    const run_test = b.addRunArtifact(t);

    if (context.is_mac) {
        link_mac_frameworks(t);
    }

    if (context.link_mode == .dynamic) {
        dynamic_link(context, t, run_test);
    } else if (context.is_windows) {
        if (context.target.result.abi == .gnu) {
            link_windows_system_libraries(std.Build.Step.Compile, t, true);

            // TODO: Find out why this is only required here; seems suspicious
            t.linkSystemLibrary2("unwind", .{});
        } else {
            link_windows_system_libraries(std.Build.Step.Compile, t, false);
        }
    }

    unit_test_step.dependOn(&run_test.step);
}

fn compute_tests(b: *std.Build, context: *const WGPUBuildContext) void {
    const compute_test_mod = b.createModule(.{
        .root_source_file = b.path("tests/compute.zig"),
        .target = context.target,
        .optimize = context.optimize,
    });
    compute_test_mod.addImport("wgpu", context.wgpu_mod);
    const compute_test = b.addTest(.{
        .name = "compute-test",
        .root_module = compute_test_mod,
    });
    handle_rt(context, compute_test);

    const run_compute_test = b.addRunArtifact(compute_test);

    const compute_test_c_mod = b.createModule(.{
        .root_source_file = b.path("tests/compute_c.zig"),
        .target = context.target,
        .optimize = context.optimize,
    });
    compute_test_c_mod.addImport("wgpu-c", context.wgpu_c_mod);
    const compute_test_c = b.addTest(.{
        .name = "compute-test-c",
        .root_module = compute_test_c_mod,
    });
    handle_rt(context, compute_test_c);

    const run_compute_test_c = b.addRunArtifact(compute_test_c);

    const compute_test_step = b.step("compute-tests", "Run compute shader tests");
    if (context.link_mode == .dynamic) {
        dynamic_link(context, compute_test, run_compute_test);
        dynamic_link(context, compute_test_c, run_compute_test_c);

        run_compute_test.step.dependOn(b.getInstallStep());
        run_compute_test_c.step.dependOn(b.getInstallStep());
    }

    if (context.is_mac) {
        link_mac_frameworks(compute_test);
        link_mac_frameworks(compute_test_c);
    }

    compute_test_step.dependOn(&run_compute_test.step);
    compute_test_step.dependOn(&run_compute_test_c.step);
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const context = WGPUBuildContext.init(b) orelse return;

    compute_tests(b, &context);
    unit_tests(b, &context);

    triangle_example(b, &context);
}
