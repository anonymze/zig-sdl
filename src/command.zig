const std = @import("std");
const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
    @cInclude("CoreFoundation/CoreFoundation.h");
});

// define common keys
pub const Key = enum(u16) {
    space = 49,
    // 76 too
    enter = 36,
    comma = 46,
    slash = 75,
    minus = 24,
    esc = 53,
    t = 17,
    r = 15,
    a = 12,
    v = 9,
    e = 14,
    l = 37,
    n1 = 83,
    n2 = 84,
    n3 = 85,
    n4 = 86,
    n5 = 87,
    n6 = 88,
    n7 = 89,
    n8 = 91,
    n9 = 92,
    n0 = 82,
};

pub fn simulateKeyPress(key: Key) !void {
    // create event source
    const source = c.CGEventSourceCreate(c.kCGEventSourceStateHIDSystemState);
    if (source == null) return error.EventSourceCreationFailed;
    defer c.CFRelease(source);

    // create key down event
    const key_down = c.CGEventCreateKeyboardEvent(source, @intFromEnum(key), true);
    if (key_down == null) return error.KeyEventCreationFailed;
    defer c.CFRelease(key_down);

    // create key up event
    const key_up = c.CGEventCreateKeyboardEvent(source, @intFromEnum(key), false);
    if (key_up == null) return error.KeyEventCreationFailed;
    defer c.CFRelease(key_up);

    // random delay between 30ms and 80ms before keypress
    const pre_delay = (std.crypto.random.intRangeAtMost(u64, 50, 70)) * std.time.ns_per_ms;
    std.time.sleep(pre_delay);

    // post key down event
    c.CGEventPost(c.kCGHIDEventTap, key_down);

    // random delay between down and up
    const hold_delay = (std.crypto.random.intRangeAtMost(u64, 50, 70)) * std.time.ns_per_ms;
    std.time.sleep(hold_delay);

    // post key up event
    c.CGEventPost(c.kCGHIDEventTap, key_up);

    // random delay after keypress
    const post_delay = (std.crypto.random.intRangeAtMost(u64, 50, 70)) * std.time.ns_per_ms;
    std.time.sleep(post_delay);
}

pub fn simulateTypeString(text: []const u8) !void {
    for (text) |char| {
        const lower_char = std.ascii.toLower(char);

        const key = switch (lower_char) {
            'a' => Key.a,
            'e' => Key.e,
            'l' => Key.l,
            'r' => Key.r,
            't' => Key.t,
            'v' => Key.v,
            ' ' => Key.space,
            ',' => Key.comma,
            '/' => Key.slash,
            '\n' => Key.enter,
            '-' => Key.minus,
            '0' => Key.n0,
            '1' => Key.n1,
            '2' => Key.n2,
            '3' => Key.n3,
            '4' => Key.n4,
            '5' => Key.n5,
            '6' => Key.n6,
            '7' => Key.n7,
            '8' => Key.n8,
            '9' => Key.n9,
            '\x1b' => Key.esc,
            else => continue,
        };

        try simulateKeyPress(key);
    }
}
