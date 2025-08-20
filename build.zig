const std = @import("std");

pub fn link_windows_system_libraries(comptime T: type, mod: *T, is_gnu: bool) void {
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

    // needed for tests?
    linkSystemLibrary(mod, "unwind", .{});
}

pub fn link_mac_frameworks(mod: *std.Build.Module) void {
    mod.linkFramework("Foundation", .{});
    mod.linkFramework("QuartzCore", .{});
    mod.linkFramework("Metal", .{});
}

pub fn disable_rt_for_msvc(exe: *std.Build.Step.Compile) void {
    const target = exe.rootModuleTarget();
    if (target.os.tag == .windows and target.abi == .msvc) {
        // We get duplicate symbol errors at link-time if we don't disable these;
        exe.bundle_compiler_rt = false;
        exe.bundle_ubsan_rt = false;
    }
}
fn quick_link(t: *std.Build.Step.Compile, link_mode: std.builtin.LinkMode, lp: std.Build.LazyPath) void {
    if (link_mode == .dynamic) {
        // normally here you would add a build step to copy all your shared libraries to
        // a specific folder for distribution
        // you would tell the executable to where to find the executable the shared library with
        // exe.addRPath(...);

        // this is just quick and dirty to test the thing
        t.addObjectFile(lp);
        t.addRPath(lp.dirname());
    }
    // (nat3): cant test this since i am a mac user
    disable_rt_for_msvc(t);
}

fn triangle_example(b: *std.Build, wgpu_mod: *std.Build.Module, link_mode: std.builtin.LinkMode, lp: std.Build.LazyPath) *std.Build.Step {
    const bmp_mod = b.createModule(.{
        .root_source_file = b.path("examples/bmp.zig"),
    });
    const triangle_example_exe = b.addExecutable(.{
        .name = "triangle-example",
        .root_source_file = b.path("examples/triangle/triangle.zig"),
        .target = wgpu_mod.resolved_target,
        .optimize = wgpu_mod.optimize.?,
    });
    triangle_example_exe.root_module.addImport("wgpu", wgpu_mod);
    triangle_example_exe.root_module.addImport("bmp", bmp_mod);
    const run_triangle_cmd = b.addRunArtifact(triangle_example_exe);
    const run_triangle_step = b.step("run-triangle-example", "Run the triangle example");
    run_triangle_step.dependOn(&run_triangle_cmd.step);
    quick_link(triangle_example_exe, link_mode, lp);
    return run_triangle_step;
}

fn unit_tests(b: *std.Build, wgpu_mod: *std.Build.Module, link_mode: std.builtin.LinkMode, lp: std.Build.LazyPath) *std.Build.Step {
    const unit_test_step = b.step("test", "Run unit tests");
    const test_files = [_][:0]const u8{
        "src/instance.zig",
        "src/adapter.zig",
        "src/pipeline.zig",
    };
    comptime var test_names: [test_files.len][:0]const u8 = test_files;
    comptime for (test_files, 0..) |test_file, idx| {
        const test_name = test_file[4..(test_file.len - 4)] ++ "-test";
        test_names[idx] = test_name;
    };
    for (test_files, test_names) |test_file, test_name| {
        const t = b.addTest(.{
            .name = test_name,
            .root_source_file = b.path(test_file),
            .target = wgpu_mod.resolved_target,
            .optimize = wgpu_mod.optimize.?,
        });
        t.root_module.addImport("wgpu", wgpu_mod);
        // handle_rt(context, t);
        const run_test = b.addRunArtifact(t);
        unit_test_step.dependOn(&run_test.step);
        quick_link(t, link_mode, lp);
    }
    return unit_test_step;
}

fn compute_tests(b: *std.Build, wgpu_mod: *std.Build.Module, wgpu_c_mod: *std.Build.Module, link_mode: std.builtin.LinkMode, lp: std.Build.LazyPath) *std.Build.Step {
    const compute_test_step = b.step("compute-tests", "Run compute shader tests");

    const compute_test = b.addTest(.{
        .name = "compute-test",
        .root_source_file = b.path("tests/compute.zig"),
        .target = wgpu_mod.resolved_target,
        .optimize = wgpu_mod.optimize.?,
    });
    compute_test.root_module.addImport("wgpu", wgpu_mod);
    // handle_rt(context, compute_test);
    const run_compute_test = b.addRunArtifact(compute_test);
    compute_test_step.dependOn(&run_compute_test.step);

    const compute_test_c = b.addTest(.{
        .name = "compute-test-c",
        .root_source_file = b.path("tests/compute_c.zig"),
        .target = wgpu_mod.resolved_target,
        .optimize = wgpu_mod.optimize.?,
    });
    compute_test_c.root_module.addImport("wgpu-c", wgpu_c_mod);
    // handle_rt(context, compute_test_c);
    const run_compute_test_c = b.addRunArtifact(compute_test_c);
    compute_test_step.dependOn(&run_compute_test_c.step);

    quick_link(compute_test, link_mode, lp);
    quick_link(compute_test_c, link_mode, lp);
    return compute_test_step;
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
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

    const wgpu_dep = get_wgpu_dep(b, target, optimize);
    const translate_step = b.addTranslateC(.{
        // wgpu.h imports webgpu.h, so we get the contents of both files, as well as a bunch of libc garbage.
        .root_source_file = wgpu_dep.path("include/webgpu/wgpu.h"),
        .target = target,
        .optimize = optimize,
    });
    const wgpu_c_mod = translate_step.addModule("wgpu-c");

    const wgpu_mod = b.addModule("wgpu", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (target.result.abi != .msvc) {
        wgpu_c_mod.link_libcpp = true;
        wgpu_mod.link_libcpp = true;
    }
    switch (target.result.os.tag) {
        .windows => {
            link_windows_system_libraries(std.Build.Module, wgpu_mod, true);
            link_windows_system_libraries(std.Build.Module, wgpu_c_mod, true);
        },
        .macos, .ios => {
            link_mac_frameworks(wgpu_mod);
            link_mac_frameworks(wgpu_c_mod);
        },
        else => {},
    }
    // this is the lazy path to the .dll / .dylib / .so
    // its added for users of this module dependency under the name "lib"
    // you can get it with `.namedLazyPath("libwgpu_native")`

    const extension: []const u8 =
        if (link_mode == .static)
            switch (target.result.os.tag) {
                .windows => "lib",
                else => "a",
            }
        else switch (target.result.os.tag) {
            .windows => "dll",
            .macos, .ios => "dylib",
            else => "so",
        };
    // NOTE: on windows the objects from rust dont have the "lib" prefix!
    const prefix = switch (target.result.os.tag) {
        .windows => "",
        else => "lib",
    };
    const lib_name = b.fmt("lib/{s}wgpu_native.{s}", .{ prefix, extension });

    const wgpu_native_lib = wgpu_dep.path(lib_name);

    if (link_mode == .static) {
        wgpu_mod.addObjectFile(wgpu_native_lib);
        wgpu_c_mod.addObjectFile(wgpu_native_lib);
    } else {
        b.addNamedLazyPath("libwgpu_native", wgpu_native_lib);
    }
    const compute_tests_step = compute_tests(b, wgpu_mod, wgpu_c_mod, link_mode, wgpu_native_lib);
    const unit_tests_step = unit_tests(b, wgpu_mod, link_mode, wgpu_native_lib);
    const triangle_example_step = triangle_example(b, wgpu_mod, link_mode, wgpu_native_lib);

    const step_all = b.step("all", "run everything");
    step_all.dependOn(compute_tests_step);
    step_all.dependOn(unit_tests_step);
    step_all.dependOn(triangle_example_step);
}

pub fn get_wgpu_dep(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Dependency {
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
    return b.lazyDependency(target_name, .{}) orelse unreachable;
}
