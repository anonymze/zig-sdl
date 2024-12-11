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
        // tell the path for C compiler to find headers while compiling
        exe.addSystemIncludePath(b.path("libs/sdl2/macos"));
        // on macos you add a path where it will search for xxx.framework
        exe.addFrameworkPath(b.path("libs/sdl2/macos"));
        // (run path) add a dynamic path where it will search the framework while compiled
        exe.addRPath(b.path("libs/sdl2/macos"));
        // tell the name of the framework we will use
        exe.linkFramework("SDL2");
        // coreGraphics is already built-in on macos, so you can just link it, it will search in the system path (/System/Library/Frameworks/)
        exe.linkFramework("CoreGraphics");
        exe.linkFramework("CoreFoundation");
    } else if (target_os.tag == .windows) {} else {
        @panic("Unsupported OS");
    }

    b.installArtifact(exe);

    const run = b.step("run", "Run the demo");
    const run_cmd = b.addRunArtifact(exe);
    run.dependOn(&run_cmd.step);
}
