const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

pub fn validatePassword(char: u8, i: u32, j: u32, pass: []const u8) bool {
    assert(i <= pass.len);
    assert(j <= pass.len);
    return (pass[i-1] == char) != (pass[j-1] == char);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer _ = gpa.deinit();

    var args = std.process.argsAlloc(allocator) catch |err| {
        print("failed to allocate args slice: .{}\n", .{err});
        return;
    };
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        print("expected a file name as argument.", .{});
        return;
    }
    var filename = args[1];
    const file = std.fs.cwd().openFile(filename, .{ .read = true }) catch |err| {
        print("couldn't open file '{}': {}\n", .{filename, err});
        return;
    };
    defer file.close();

    var buf: [1024]u8 = undefined;
    var valid_count: u32 = 0;
    while (true) {
        var line = (file.reader().readUntilDelimiterOrEof(&buf, '\n') catch break) orelse break;
        var token_it = std.mem.split(line, "-");
        const low = try std.fmt.parseInt(u32, token_it.next().?, 0);
        token_it.delimiter = " ";
        const high = try std.fmt.parseInt(u32, token_it.next().?, 0);
        token_it.delimiter = ": ";
        const char = token_it.next().?[0];
        const pass = token_it.next().?;
        if (validatePassword(char, low, high, pass)) valid_count += 1;
    }
    print("valid count: {}\n", .{valid_count});
}
