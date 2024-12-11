const std = @import("std");
const print = std.debug.print;

const cg = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
});

pub fn showResolution() !void {
    var display_count: u32 = 0;

    // first get the number of displays
    if (cg.CGGetActiveDisplayList(0, null, &display_count) != cg.kCGErrorSuccess) {
        return error.NoDisplayFound;
    }

    // allocate memory for the display list
    const displays = try std.heap.page_allocator.alloc(cg.CGDirectDisplayID, display_count);
    defer std.heap.page_allocator.free(displays);

    // get the actual display list
    if (cg.CGGetActiveDisplayList(display_count, displays.ptr, &display_count) != cg.kCGErrorSuccess) {
        return error.NoDisplayFound;
    }

    // iterate through displays and get their info
    for (displays, 0..) |display, i| {
        const bounds = cg.CGDisplayBounds(display);
        print("Display {d}:\n", .{i + 1});
        print("  Position: x={d}, y={d}\n", .{ bounds.origin.x, bounds.origin.y });
        print("  Resolution: {d}x{d}\n", .{ bounds.size.width, bounds.size.height });
    }
}
