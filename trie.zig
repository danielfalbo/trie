// zig 0.16.0-dev.1399+
const std = @import("std");

const Trie = struct {
    is_word: bool = false,
    children: [26]?*Trie = .{null} ** 26,

    pub fn deinit(self: *Trie, allocator: std.mem.Allocator) void {
        for (self.children) |child_opt| {
            if (child_opt) |child| { child.deinit(allocator); }
        }
        allocator.destroy(self);
    }

    pub fn insert(self: *Trie, a: std.mem.Allocator, word: []const u8) !void {
        if (word.len == 0) {
            self.is_word = true;
            return;
        }

        const first = word[0];
        const rest = word[1..];
        const i = first - 'a';

        if (self.children[i] == null) {
            const new_node = try a.create(Trie);
            new_node.* = Trie{};
            self.children[i] = new_node;
        }

        try self.children[i].?.insert(a, rest);
    }

    pub fn prefix(self: *const Trie, prefix_str: []const u8) ?*const Trie {
        if (prefix_str.len == 0) return self;

        const i = prefix_str[0] - 'a';

        if (self.children[i]) |child| {
            return child.prefix(prefix_str[1..]);
        }

        return null;
    }

    pub fn find(self: *const Trie, word: []const u8) bool {
        if (self.prefix(word)) |node| {
            return node.is_word;
        }
        return false;
    }
};

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

    const root = try gpa.create(Trie);
    defer root.deinit(gpa);

    root.* = Trie{};

    try stdout.print("Available commands: EXIT, INSERT, PREFIX, FIND.\n", .{});
    try stdout.flush();

    while (true) {
        try stdout.writeAll("> ");
        try stdout.flush();

        const line = try stdin.takeDelimiter('\n') orelse break;

        const normalized = try std.ascii.allocLowerString(gpa,
            std.mem.trim(u8, line, &std.ascii.whitespace));
        defer gpa.free(normalized);

        if (std.mem.eql(u8, normalized, "exit")) {
            break;
        }

        var args_list = std.ArrayListUnmanaged([]const u8){};
        defer args_list.deinit(gpa);

        var iter = std.mem.tokenizeAny(u8, normalized, " ");

        while (iter.next()) |token| {
            try args_list.append(gpa, token);
        }

        const args = args_list.items;

        if (args.len != 2) {
            try stdout.print("Invalid format. Usage: COMMAND <arg>\n", .{});
            try stdout.flush();
            continue;
        }

        if (std.mem.eql(u8, args[0], "insert")) {
            try root.insert(gpa, args[1]);
        } else if (std.mem.eql(u8, args[0], "find")) {
            const found = root.find(args[1]);
            try stdout.print("{any}.\n", .{found});
            try stdout.flush();
        } else if (std.mem.eql(u8, args[0], "prefix")) {
            const exists = root.prefix(args[1]) != null;
            try stdout.print("{any}.\n", .{exists});
            try stdout.flush();
        } else {
            try stdout.print("Unknown command {s}.\n", .{args[0]});
            try stdout.flush();
        }
    }
}
