const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var groups = std.mem.split(@embedFile("../inputs/day06.txt"), "\n\n");
    var total: usize = 0;
    while (groups.next()) |g| {
        var all_yes: u26 = (1 << 26) - 1;
        var people = std.mem.split(g, "\n");
        while (people.next()) |p| {
            if (p.len == 0) break;
            var individual_answers: u26 = 0;
            for (p) |c| {
                switch (c) {
                    'a'...'z' => {
                        individual_answers |= @shlExact(@as(u26, 1), @intCast(u5, c - 'a'));
                    },
                    else => {},
                }
            }
            all_yes &= individual_answers;
        }
        total += @popCount(u26, all_yes);
    }
    print("total {}\n", .{total});
}
