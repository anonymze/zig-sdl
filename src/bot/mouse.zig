const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

// Represents a 2D point
const Point = struct {
    x: f64,
    y: f64,
};

// Linear interpolation between two values
fn lerp(start: f64, end: f64, t: f64) f64 {
    return start + (end - start) * t;
}

// Bezier curve interpolation
fn bezierPoint(start: Point, control1: Point, control2: Point, end: Point, t: f64) Point {
    const x = std.math.pow(f64, (1 - t), 3) * start.x +
        3 * std.math.pow(f64, (1 - t), 2) * t * control1.x +
        3 * (1 - t) * std.math.pow(f64, t, 2) * control2.x +
        std.math.pow(f64, t, 3) * end.x;

    const y = std.math.pow(f64, (1 - t), 3) * start.y +
        3 * std.math.pow(f64, (1 - t), 2) * t * control1.y +
        3 * (1 - t) * std.math.pow(f64, t, 2) * control2.y +
        std.math.pow(f64, t, 3) * end.y;

    return Point{ .x = x, .y = y };
}

// Add some random variation to make movement more human-like
fn addNoise(value: f64, magnitude: f64) f64 {
    const random = std.crypto.random;
    return value + (random.float(f64) * 2 - 1) * magnitude;
}

pub fn moveMouseHuman(end_x: i32, end_y: i32) !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) < 0) {
        std.debug.print("SDL2 initialization failed: {s}\n", .{sdl.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    var start_x: i32 = undefined;
    var start_y: i32 = undefined;
    _ = sdl.SDL_GetGlobalMouseState(&start_x, &start_y);

    const start = Point{ .x = @floatFromInt(start_x), .y = @floatFromInt(start_y) };
    const end = Point{ .x = @floatFromInt(end_x), .y = @floatFromInt(end_y) };

    // Create control points for the Bezier curve
    // Add some randomness to make each movement unique
    const mid_x = (start.x + end.x) / 2;
    const mid_y = (start.y + end.y) / 2;
    const control1 = Point{
        .x = addNoise(mid_x, 100),
        .y = addNoise(mid_y, 100),
    };
    const control2 = Point{
        .x = addNoise(mid_x, 100),
        .y = addNoise(mid_y, 100),
    };

    // Reduce steps for shorter movements
    const distance = @sqrt(std.math.pow(f64, end.x - start.x, 2) +
        std.math.pow(f64, end.y - start.y, 2));
    const steps = @min(50, @max(10, @as(usize, @intFromFloat(distance / 10))));

    var i: usize = 0;
    while (i < steps) : (i += 1) {
        const t = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(steps));
        const pos = bezierPoint(start, control1, control2, end, t);
        _ = sdl.SDL_WarpMouseGlobal(@intFromFloat(pos.x), @intFromFloat(pos.y));

        // Reduce base delay and variation
        const base_delay = 2; // 2ms base delay
        const random_delay = addNoise(@as(f64, base_delay), 1);
        std.time.sleep(@intFromFloat(random_delay * 1000000));
    }
}
