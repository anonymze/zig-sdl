const std = @import("std");
const target_os = @import("builtin").os;
const sdl = @import("sdl");
const print = std.debug.print;

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = .ReleaseSafe,
    });

    if (target_os.tag == .macos) {
        // on macos you add a path where it will search for xxx.framework
        exe.addFrameworkPath(b.path("libs/sdl2/macos"));
        // then link it based on that path
        exe.linkFramework("SDL2");
    } else if (target_os.tag == .windows) {} else {
        @panic("Unsupported OS");
    }

    b.installArtifact(exe);
}
