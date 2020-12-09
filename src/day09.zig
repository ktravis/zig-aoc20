const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = &arena.allocator;

    // const preamble_len = 5;
    // const input = @embedFile("../inputs/day09_sample.txt");
    const preamble_len = 25;
    const input = @embedFile("../inputs/day09.txt");

    var numbers = std.ArrayList(usize).init(alloc);

    var lines = std.mem.split(input, "\n");
    while (lines.next()) |line| {
        var trimmed = std.mem.trim(u8, line, &std.ascii.spaces);
        if (trimmed.len == 0) break;
        try numbers.append(try std.fmt.parseUnsigned(usize, trimmed, 10));
    }

    // type inference breaks here, so declaring type of invalid explicitly
    const invalid: usize = for (numbers.items[preamble_len..]) |n, i| {
        const preamble = numbers.items[i .. i + preamble_len];
        for (preamble) |x, j| {
            if (x < n and std.mem.indexOfScalar(usize, preamble[j + 1 ..], n - x) != null) break;
        } else break n; // no match, found invalid number
    } else unreachable;

    print("Part 1: Invalid number is {}\n", .{invalid});

    var start: usize = 0;
    var sum: usize = 0;
    for (numbers.items) |n, i| {
        if (n == invalid) {
            start = i;
            continue;
        }
        sum += n;
        while (start < i and sum > invalid) {
            sum -= numbers.items[start];
            start += 1;
        }
        if (sum == invalid) {
            comptime var asc_usize = std.sort.asc(usize);
            var run = numbers.items[start .. i + 1];
            const min = std.sort.min(usize, run, {}, asc_usize).?;
            const max = std.sort.max(usize, run, {}, asc_usize).?;
            print("Part 2: min {} + max {} = {}\n", .{ min, max, min + max });
            break;
        }
    }
}
