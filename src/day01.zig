const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

pub fn findNComplements(comptime N: u8, target: i32, rest: []i32) ?[N]i32 {
    // base case, we are just looking for a number in a slice
    if (N == 1) {
        return if (findNumber(target, rest)) [N]i32{target} else null;
    }
    for (rest) |x, i| {            
        if (findNComplements(N-1, target-x, rest[i+1..])) |comp| {
            var out: [N]i32 = undefined;
            out[0] = x;
            std.mem.copy(i32, out[1..], comp[0..]);
            return out;
        }
    }
    return null;
}

pub fn findNumber(target: i32, rest: []i32) bool {
    for (rest) |n| if (n == target) return true;
    return false;
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

    var numbers = std.ArrayList(i32).init(allocator);
    defer numbers.deinit();

    var buf: [1024]u8 = undefined;
    while (file.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parsed = std.fmt.parseInt(i32, std.mem.trimRight(u8, line, "\r\n"), 0) catch |err| {
            print("failed to parse integer from line '{}': {}\n", .{line, err});
            return;
        };
        try numbers.append(parsed);
    }
    for (findNComplements(3, 2020, numbers.items).?) |x| {
        print("wow: {}\n", .{x});
    }
}
