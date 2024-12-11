const std = @import("std");
const print = std.debug.print;

const cg = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
});

pub fn takeScreenshot(display_id: ?u32) !void {
    const actual_display_id = display_id orelse cg.CGMainDisplayID();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // format the display argument
    const display_arg = try std.fmt.allocPrint(allocator, "-D{d}", .{actual_display_id});

    var child = std.process.Child.init(&[_][]const u8{
        "screencapture",
        "-x", // silent capture (no sound)
        display_arg, // specify which display
        "screenshots/scr.png",
    }, allocator);

    const term = try child.spawnAndWait();

    switch (term) {
        .Exited => |code| {
            if (code == 0) {
                print("Screenshot of display {d} saved as 'screenshot.png'\n", .{actual_display_id});
            } else {
                return error.ScreenshotFailed;
            }
        },
        else => return error.ScreenshotFailed,
    }
}
