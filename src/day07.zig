const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const BagCount = struct {
    style: []const u8,
    n: usize,
};

fn containsCount(m: std.StringArrayHashMap(std.ArrayList(BagCount)), t: []const u8) usize {
    var sum: usize = 0;
    if (m.get(t)) |list| {
        for (list.items) |bag| {
            sum += bag.n + bag.n * containsCount(m, bag.style);
        }
    }
    return sum;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = &arena.allocator;
    var lines = std.mem.split(@embedFile("../inputs/day07.txt"), "\n");
    var m = std.StringArrayHashMap(std.ArrayList(BagCount)).init(alloc);
    defer m.deinit();
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var trimmed = std.mem.trim(u8, line, " .\r\n\t");
        var parts = std.mem.split(trimmed, " bags contain ");
        var key = parts.next().?;
        var value = parts.next().?;
        if (std.mem.eql(u8, value, "no other bags")) {
            continue;
        }
        var list = m.get(key) orelse std.ArrayList(BagCount).init(alloc);
        var contains = std.mem.split(value, ", ");
        while (contains.next()) |in| {
            var space_index = std.mem.indexOf(u8, in, " ").?;
            var count = try std.fmt.parseUnsigned(usize, in[0..space_index], 10);
            var in_type = in[space_index + 1 ..];
            if (std.mem.lastIndexOf(u8, in_type, " bag")) |i| in_type = in_type[0..i];
            try list.append(.{
                .style = try alloc.dupe(u8, in_type),
                .n = count,
            });
        }
        try m.put(key, list);
    }
    print("shiny gold bag contains: {} more bags\n", .{containsCount(m, "shiny gold")});
}
