const std = @import("std");
const print = std.debug.print;
const moveMouseHuman = @import("./bot/mouse.zig").moveMouseHuman;
const showResolution = @import("./screen/display.zig").showResolution;
const isDofusRunning = @import("./process.zig").isDofusRunning;
const watchDofus = @import("./process.zig").watchDofus;
const focusDofus = @import("./process.zig").focusDofus;
const takeScreenshot = @import("./screen/screenshot.zig").takeScreenshot;
const simulateKeyPress = @import("./command.zig").simulateKeyPress;
const simulateTypeString = @import("./command.zig").simulateTypeString;

const START_COUNT_DOWN = 0;

pub fn main() !void {
    print("========== Start TREASURE HUNTING! ==========\n", .{});
    print("Get ready the process will start to work.\n", .{});

    var i: usize = START_COUNT_DOWN;
    while (i > 0) : (i -= 1) {
        print("{d}\n", .{i});
        std.time.sleep(1000000000);
    }

    try watchDofus();
    try focusDofus();
    try showResolution();
    try takeScreenshot(null);
    try moveMouseHuman(500, 500);
    std.time.sleep(1000000000);

    // try simulateKeyPress(.t);
    // try simulateKeyPress(.r);

    // type a word
    try simulateKeyPress(.space);
    // try simulateKeyPress(.minus);
    try simulateTypeString("/travel 5,-7");
    try simulateKeyPress(.enter);
    try simulateKeyPress(.enter);

    // or even a sentence

    print("========== End TREASURE HUNTING! ==========\n", .{});
}
