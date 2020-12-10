const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const Adapter = struct {
    jolts: usize,
    possible_parents: []Adapter = &[_]Adapter{},
    cached_count: usize = 0,

    fn lessThan(context: void, lhs: @This(), rhs: @This()) bool {
        return lhs.jolts < rhs.jolts;
    }

    fn pathsTo(self: *@This()) usize {
        if (self.cached_count != 0) return self.cached_count;
        if (self.possible_parents.len == 0) return 1;
        var sum: usize = 0;
        for (self.possible_parents) |*p| sum += p.pathsTo();
        self.cached_count = sum;
        return sum;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = &arena.allocator;

    const input = @embedFile("../inputs/day10.txt");
    var adapters = std.ArrayList(Adapter).init(alloc);
    try adapters.append(.{ .jolts = 0 }); // the "wall"
    var lines = std.mem.split(input, "\n");
    while (lines.next()) |line| {
        var trimmed = std.mem.trim(u8, line, &std.ascii.spaces);
        if (trimmed.len == 0) break;
        try adapters.append(.{
            .jolts = try std.fmt.parseUnsigned(usize, trimmed, 10),
        });
    }
    std.sort.sort(Adapter, adapters.items, {}, Adapter.lessThan);
    try adapters.append(.{ .jolts = adapters.items[adapters.items.len - 1].jolts + 3 }); // the device
    for (adapters.items) |*n, i| {
        var parents = adapters.items[std.math.max(3, i) - 3 .. i];
        while (parents.len > 0 and n.jolts - parents[0].jolts > 3) parents = parents[1..];
        n.possible_parents = parents;
    }
    var device = adapters.items[adapters.items.len - 1];
    print("possible combinations {}\n", .{device.pathsTo()});
}
