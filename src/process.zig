const std = @import("std");
const print = std.debug.print;

const INTERVAL_CHECK_PROCESS = 2;

const proc = @cImport({
    // no need to link libproc.h in build.zig
    @cInclude("libproc.h");
});

pub fn isDofusRunning() bool {
    var name_buf: [proc.PROC_PIDPATHINFO_MAXSIZE]u8 = undefined;
    const proc_count = proc.proc_listpids(proc.PROC_ALL_PIDS, 0, null, 0);

    const pids = std.heap.page_allocator.alloc(c_int, @intCast(proc_count)) catch return false;
    defer std.heap.page_allocator.free(pids);

    _ = proc.proc_listpids(proc.PROC_ALL_PIDS, 0, pids.ptr, proc_count * @sizeOf(c_int));

    for (pids) |pid| {
        if (pid == 0) continue;
        if (proc.proc_name(pid, &name_buf, proc.PROC_PIDPATHINFO_MAXSIZE) <= 0) continue;

        if (std.mem.eql(u8, name_buf[0..5], "Dofus")) {
            return true;
        }
    }
    return false;
}

pub fn watchDofus() !void {
    // first check if Dofus is running
    if (!isDofusRunning()) {
        @panic("Dofus process is not running!");
    }

    print("Dofus is running, we will watch the process and detect if it closes from now on...\n", .{});

    const thread = try std.Thread.spawn(.{}, struct {
        fn watch() void {
            while (true) {
                std.time.sleep(INTERVAL_CHECK_PROCESS * 1000000000); // Convert s to ns

                if (!isDofusRunning()) {
                    @panic("Dofus process is not running!");
                }
            }
        }
    }.watch, .{});
    thread.detach();
}

pub fn focusDofus() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{
            "osascript",
            "-e",
            "tell application \"Dofus\" to activate",
        },
    });

    if (result.term.Exited != 0) {
        print("Failed to focus Dofus: {s}\n", .{result.stderr});
        return error.FailedToFocusDofus;
    }

    print("Successfully focused Dofus!\n", .{});
}
