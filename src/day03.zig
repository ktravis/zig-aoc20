const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const input = \\..##.......
              \\#...#...#..
              \\.#....#..#.
              \\..#.#...#.#
              \\.#...##..#.
              \\..#.##.....
              \\.#.#.#....#
              \\.#........#
              \\#.##...#...
              \\#...##....#
              \\.#..#...#.#
;
// const input = @embedFile("../inputs/day03.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer _ = gpa.deinit();

    const W = comptime std.mem.indexOf(u8, input, "\n").?;

    var grid = std.ArrayList([W]bool).init(allocator);
    defer grid.deinit();
    var lines = std.mem.split(input, "\n");

    while (true) {
        const line = lines.next() orelse break;
        var row : [W]bool = undefined;
        for (line) |c, x| {
            row[x] = (c == '#');
        }
        try grid.append(row);
    }

    const slope = struct {
        dx: usize,
        dy: usize,
    };

    const slopes = [_]slope{
        .{.dx = 1, .dy = 1},
        .{.dx = 3, .dy = 1},
        .{.dx = 5, .dy = 1},
        .{.dx = 7, .dy = 1},
        .{.dx = 1, .dy = 2},
    };
    var counts = [_]usize{0} ** slopes.len;

    for (slopes) |s, i| {
        var x: usize = 0;
        var y: usize = 0;
        var count: usize = 0;
        while (y < grid.items.len) : ({ x += s.dx; y += s.dy; }) {
            if (grid.items[y][x%W]) count += 1;
        }
        counts[i] = count;
        print("slope: {} - {}\n", .{s, count});
    }
    var a: usize = 1;
    for (counts) |c| a *= c;
    print("multiplied: {}\n", .{a});
}
