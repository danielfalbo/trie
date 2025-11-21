// zig 0.16.0-dev.1399+
const std = @import("std");

pub fn main() !void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_impl.allocator();
    defer _ = gpa_impl.deinit();

    var threaded = std.Io.Threaded.init(gpa);
    defer threaded.deinit();

    const io = threaded.io();

    var out_buffer: [4096]u8 = undefined;
    var stdout_impl = std.fs.File.stdout().writer(&out_buffer);
    const stdout = &stdout_impl.interface;

    var in_buffer: [4096]u8 = undefined;
    var stdin_impl = std.fs.File.stdin().reader(io, &in_buffer);
    const stdin = &stdin_impl.interface;

    while (true) {
        try stdout.writeAll("> ");
        try stdout.flush();

        const line = try stdin.takeDelimiter('\n') orelse break;

        try stdout.print("you said: {s}\n", .{line});
        try stdout.flush();
    }
}
