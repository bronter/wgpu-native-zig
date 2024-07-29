const std = @import("std");

const TargetQuery = std.Target.Query;

// All the targets for which a pre-compiled build of wgpu-native is currently (as of July 9, 2024) available
const target_whitelist = [_] TargetQuery {
    TargetQuery {
        .cpu_arch = .aarch64,
        .os_tag = .linux
    },
    TargetQuery {
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
    TargetQuery {
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    TargetQuery {
        .cpu_arch = .x86_64,
        .os_tag = .macos,
    },
    TargetQuery {
        .cpu_arch = .x86,
        .os_tag = .windows,
    },
    TargetQuery {
        .cpu_arch = .x86_64,
        .os_tag = .windows,
    },
};

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{
        .whitelist = &target_whitelist,
    });

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const target_res = target.result;
    const os_str = @tagName(target_res.os.tag);
    const arch_str = @tagName(target_res.cpu.arch);
    const mode_str = @tagName(optimize);
    const target_name_slices = [_] [:0]const u8 {"wgpu_", os_str, "_", arch_str, "_", mode_str};
    const maybe_target_name = std.mem.concatWithSentinel(b.allocator, u8, &target_name_slices, 0);
    const target_name = maybe_target_name catch "wgpu_linux_x86_64_Debug";

    const mod = b.addModule("wgpu", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    const wgpu_dep = b.lazyDependency(target_name, .{}).?;

    const lib_name = switch (target_res.os.tag) {
        // There's also some sorf of .pdb file available, which I think is a database of debugging symbols.
        // I don't even have a Windows machine though,
        // so I'll let somebody who does tell me what it is and if I need it.
        .windows => "wgpu_native.lib",

        // This only tries to account for linux/macos since we're using pre-compiled wgpu-native;
        // need to think harder about this if I get custom builds working.
        else => "libwgpu_native.a",
    }; // Also these don't even try to account for dynamic linking; that's a problem for future me.
    const libwgpu_path = wgpu_dep.path(lib_name);
    mod.addObjectFile(libwgpu_path);

    const translate_step = b.addTranslateC(.{
        // wgpu.h imports webgpu.h, so we get the contents of both files, as well as a bunch of libc garbage.
        .root_source_file = wgpu_dep.path("wgpu.h"),

        .target = target,
        .optimize = optimize,
    });
    const wgpu_c_mod = translate_step.addModule("wgpu-c");
    wgpu_c_mod.addObjectFile(libwgpu_path);
    wgpu_c_mod.link_libcpp = true;

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const compute_test = b.addTest(.{
        .name = "compute-test",
        .root_source_file = b.path("tests/compute.zig"),
        .target = target,
        .optimize = optimize,
    });
    compute_test.root_module.addImport("wgpu", mod);

    const run_compute_test = b.addRunArtifact(compute_test);

    const compute_test_c = b.addTest(.{
        .name = "compute-test-c",
        .root_source_file = b.path("tests/compute_c.zig"),
        .target = target,
        .optimize = optimize,
    });
    compute_test_c.root_module.addImport("wgpu-c", wgpu_c_mod);

    const run_compute_test_c = b.addRunArtifact(compute_test_c);

    const triangle_example_exe = b.addExecutable(.{
        .name = "triangle-example",
        .root_source_file = b.path("examples/triangle/triangle.zig"),
        .target = target,
        .optimize = optimize,
    });
    triangle_example_exe.root_module.addImport("wgpu", mod);
    const bmp_mod = b.createModule(.{
        .root_source_file = b.path("examples/bmp.zig"),
    });
    triangle_example_exe.root_module.addImport("bmp", bmp_mod);
    const run_triangle_cmd = b.addRunArtifact(triangle_example_exe);
    const run_triangle_step = b.step("run-triangle-example", "Run the triangle example");
    run_triangle_step.dependOn(&run_triangle_cmd.step);

    // This exposes a `test` step to the `zig build --help` menu,
    // providing a way for the user to request running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_compute_test.step);
    test_step.dependOn(&run_compute_test_c.step);

    const test_files = [_] [:0]const u8 {
        "src/instance.zig",
        "src/adapter.zig",
        "src/pipeline.zig",
    };
    comptime var test_names: [test_files.len] [:0]const u8 = test_files;
    comptime for (test_files, 0..) |test_file, idx| {
        const test_name = test_file[4..(test_file.len - 4)] ++ "-test";
        test_names[idx] = test_name;
    };

    for (test_files, test_names) |test_file, test_name| {
        const t = b.addTest(.{
            .name = test_name,
            .root_source_file = b.path(test_file),
            .target = target,
            .optimize = optimize,
        });
        t.addObjectFile(libwgpu_path);
        t.linkLibCpp();

        const run_test = b.addRunArtifact(t);
        test_step.dependOn(&run_test.step);
    }
}
