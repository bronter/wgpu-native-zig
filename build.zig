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
    mod.addObjectFile(wgpu_dep.path("libwgpu_native.a"));

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
}
