const std = @import("std");

fn setupRust(b: *std.Build, opt: std.builtin.OptimizeMode) !std.Build.LazyPath {
    const tool_run = b.addSystemCommand(&.{"cargo"});
    tool_run.setCwd(b.path("src/rust"));
    tool_run.addArgs(&.{
        "build",
    });

    var opt_path: []const u8 = undefined;
    switch (opt) {
        .ReleaseSafe,
        .ReleaseFast,
        .ReleaseSmall,
        => {
            tool_run.addArg("--release");
            opt_path = "release";
        },
        .Debug => {
            opt_path = "debug";
        },
    }

    const generated = try b.allocator.create(std.Build.GeneratedFile);
    generated.* = .{
        .step = &tool_run.step,
        .path = try b.build_root.join(b.allocator, &.{ "src/rust/target", opt_path, "libcalc.a" }),
    };

    const lib_path = std.Build.LazyPath{
        .generated = .{ .file = generated },
    };

    return lib_path;
}

fn linkSDL(b: *std.Build, exe: *std.Build.Step.Compile, target: std.Build.ResolvedTarget) void {
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_ttf");

    switch (b.host.result.os.tag) {
        .macos => {
            exe.linkFramework("IOKit");
            exe.linkFramework("Metal");
        },
        .windows => {
            const sdl_dep = b.dependency("SDL", .{
                .optimize = .ReleaseFast,
                .target = target,
            });
            exe.linkLibrary(sdl_dep.artifact("SDL2"));
        },
        .linux => {},
        else => @import("std").debug.panic("device runs on unsupported architecture!", .{}),
    }
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const opt = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "browser_cli",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = opt,
    });

    exe.linkLibC();
    const rust_lib = try setupRust(b, opt);
    exe.addLibraryPath(rust_lib.dirname());
    exe.linkSystemLibrary("calc");

    linkSDL(b, exe, target);

    b.installArtifact(exe);
}
