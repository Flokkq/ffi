const std = @import("std");

pub fn build(b: *std.Build) void {
    const rust_lib = b.addSystemCommand(&.{ "cargo", "build", "--release", "--manifest-path", "src/rust/Cargo.toml" });

    const rust_lib_path = b.path("src/rust/target/release");

    const exe = b.addExecutable(.{
        .name = "browser_cli",
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = .Debug,
    });

    exe.linkLibC();
    exe.addLibraryPath(rust_lib_path);
    exe.linkSystemLibrary("calc");

    exe.step.dependOn(&rust_lib.step);

    b.installArtifact(exe);
}
