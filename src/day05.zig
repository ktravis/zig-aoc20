const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

fn doBinarySearch(s: []const u8, low: u8, hi: u8, count: usize) usize {
    var min: usize = 0;
    var max: usize = count - 1;
    for (s) |c| {
        const half = @floatToInt(usize, std.math.ceil(@intToFloat(f32, max-min)/2.0));
        if (c == hi) min += half
        else if (c == low) max -= half
        else unreachable;
    }
    assert(min == max);
    return min;
}

fn seatID(row: usize, col: usize) usize {
    return row * 8 + col;
}

pub fn main() !void {
    var max: usize = 0;
    const rows = 128;
    const cols = 8;

    var seats = [_]bool{false} ** (rows * cols);
    var lines = std.mem.split(@embedFile("../inputs/day05.txt"), "\n");
    while (lines.next()) |line| {
        const seat = std.mem.trim(u8, line, &std.ascii.spaces);
        if (seat.len == 0) break;
        const id = seatID(doBinarySearch(seat[0..7], 'F', 'B', rows), doBinarySearch(seat[7..], 'L', 'R', cols));
        if (id > max) max = id;
        seats[id] = true;
    }
    print("max {}\n", .{max});
    const my_seat = blk: for (seats) |s, i| {
        if (s) for (seats[i+1..]) |x, j| if (!x) break :blk i+1+j;
    } else unreachable;
    print("my seat: {}\n", .{my_seat});
}
