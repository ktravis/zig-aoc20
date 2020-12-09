const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const OpType = enum {
    nop,
    acc,
    jmp,
};

const Op = struct {
    t: OpType,
    value: i32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var alloc = &arena.allocator;
    var instructions = std.ArrayList(Op).init(alloc);
    // var lines = std.mem.split(@embedFile("../inputs/day08_sample.txt"), "\n");
    var lines = std.mem.split(@embedFile("../inputs/day08.txt"), "\n");
    while (lines.next()) |line| {
        var trimmed = std.mem.trim(u8, line, &std.ascii.spaces);
        if (trimmed.len == 0) break;
        var parts = std.mem.tokenize(trimmed, " ");
        try instructions.append(.{
            .t = std.meta.stringToEnum(OpType, parts.next().?).?,
            .value = try std.fmt.parseInt(i32, parts.next().?, 10),
        });
    }
    var seen = std.ArrayList(bool).init(alloc);
    try seen.resize(instructions.items.len);
    var tries: usize = 0;
    for (instructions.items) |*x| {
        const og_type = x.t;
        x.t = switch (og_type) {
            .nop => .jmp,
            .jmp => .nop,
            else => continue,
        };
        defer x.t = og_type;
        var acc: i32 = 0;
        var pc: i32 = 0;
        tries += 1;
        var looped = while (pc < instructions.items.len) {
            var i = @intCast(usize, pc);
            var op = &instructions.items[i];
            if (seen.items[i]) {
                break true;
            }
            seen.items[i] = true;
            switch (op.t) {
                .nop => pc += 1,
                .acc => {
                    acc += op.value;
                    pc += 1;
                },
                .jmp => pc += op.value,
            }
        } else false;
        if (!looped) {
            print("solution after {} tries: acc={}\n", .{ tries, acc });
            break;
        }
        std.mem.set(bool, seen.items, false);
    }
}
