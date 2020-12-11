const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const input = @embedFile("../inputs/day11_sample.txt");
// const input = @embedFile("../inputs/day11.txt");

fn printGrid(grid: anytype) void {
    for (grid) |row, y| {
        for (row) |spot, x| {
            print("{c}", .{spot});
        }
    }
    print("\n", .{});
}

fn occupiedAdjacent(grid: anytype, x: usize, y: usize) usize {
    var sum: usize = 0;
    var y0: usize = std.math.max(1, y) - 1;
    while (y0 < std.math.min(grid.len, y + 2)) : (y0 += 1) {
        var x0: usize = std.math.max(1, x) - 1;
        while (x0 < std.math.min(grid[y].len, x + 2)) : (x0 += 1) {
            if (x == x0 and y == y0) continue;
            sum += @boolToInt(grid[y0][x0] == '#' or grid[y0][x0] == 'l');
        }
    }
    return sum;
}

const P = struct { x: usize = 0, y: usize = 0 };
const D = struct { x: i8, y: i8 };

fn inBounds(grid: anytype, p: P) bool {
    return p.x >= 0 and p.y >= 0 and p.x < grid[0].len - 1 and p.y < grid.len - 1;
}

fn advance(grid: anytype, pos: *P, dir: D) ?u8 {
    pos.x += dir.x;
    pos.y += dir.y;
    return if (inBounds(grid, pos.*)) grid[pos.y][pos.x] else null;
}

fn visibleOccupied(grid: anytype, p: P) usize {
    var sum: usize = 0;
    var dirs = [_]D{
        .{ .x = 1, .y = 0 },
        .{ .x = 1, .y = 1 },
        .{ .x = 0, .y = 1 },
        .{ .x = -1, .y = 1 },
        .{ .x = -1, .y = 0 },
        .{ .x = -1, .y = -1 },
        .{ .x = 0, .y = -1 },
        .{ .x = 1, .y = -1 },
    };
    for (dirs) |d| {
        var p0 = p;
        sum += while (advance(grid, &p0, d)) |c| {
            if (c == '#') break @as(usize, 1);
            if (c == 'L') break @as(usize, 0);
        } else 0;
    }
    return sum;
}

fn fillSeats(grid: anytype) void {
    var indexes: [grid.len * grid[0].len][2]usize = undefined;
    while (true) {
        var z: usize = 0;
        print("z\n", .{});
        for (grid) |row, y| {
            for (row) |spot, x| {
                switch (spot) {
                    // 'L' => {
                    //     if (occupiedAdjacent(grid, x, y) == 0) {
                    //         indexes[z] = .{ x, y };
                    //         z += 1;
                    //     }
                    // },
                    // '#' => {
                    //     if (occupiedAdjacent(grid, x, y) > 3) {
                    //         indexes[z] = .{ x, y };
                    //         z += 1;
                    //     }
                    // },
                    'L' => {
                        if (visibleOccupied(grid, .{ .x = x, .y = y }) == 0) {
                            indexes[z] = .{ x, y };
                            z += 1;
                        }
                    },
                    '#' => {
                        if (visibleOccupied(grid, .{ .x = x, .y = y }) > 4) {
                            indexes[z] = .{ x, y };
                            z += 1;
                        }
                    },
                    else => continue,
                }
            }
        }
        if (z == 0) return;
        for (indexes[0..z]) |i| {
            const c = &grid[i[1]][i[0]];
            c.* = switch (c.*) {
                '#' => 'L',
                'L' => '#',
                else => unreachable,
            };
        }
    }
}

pub fn main() !void {
    comptime const cols = std.mem.indexOfScalar(u8, input, '\n').?;
    comptime const rows = @floatToInt(usize, @ceil(@intToFloat(f32, input.len) / @intToFloat(f32, cols + 1)));
    var grid = @bitCast([rows][cols + 1]u8, @as([input.len]u8, input.*));

    fillSeats(&grid);
    const filled = std.mem.count(u8, &@bitCast([input.len]u8, grid), "#");

    printGrid(grid);
    print("filled: {}\n", .{filled});
}
