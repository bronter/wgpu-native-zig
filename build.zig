const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("wgpu", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    const wgpu_dep = b.dependency("wgpu_linux", .{});

    mod.addIncludePath(wgpu_dep.path(""));
    const libwgpu_path = wgpu_dep.path("libwgpu_native.a");
    mod.addObjectFile(libwgpu_path);

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

    // This exposes a `test` step to the `zig build --help` menu,
    // providing a way for the user to request running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_compute_test.step);

    const test_files = [_] [:0]const u8 {"src/instance.zig"};
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
