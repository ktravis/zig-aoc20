const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const FieldName = enum(usize) {
    byr,
    iyr,
    eyr,
    hgt,
    hcl,
    ecl,
    pid,
    cid,
};

fn year_in_range(y: ?usize, min: usize, max: usize) bool {
    return y != null and y.? >= min and y.? <= max;
}

fn height_valid(hgt: []const u8) !bool {
    const n = std.fmt.parseUnsigned(usize, hgt[0..hgt.len-2], 10) catch return false;
    const unit = hgt[hgt.len-2..];
    return if (std.mem.eql(u8, unit, "cm"))
        n >= 150 and n <= 193
    else if (std.mem.eql(u8, unit, "in"))
        n >= 59 and n <= 76
    else error.OhNoDude;
}

const EyeColor = enum {
    amb,
    blu,
    brn,
    gry,
    grn,
    hzl,
    oth,
};

pub fn main() !void {
    var lines = std.mem.split(@embedFile("../inputs/day04.txt"), "\n\n");

    var count: usize = 0;
    outer: while (lines.next()) |line| {
        var found = [_]bool{false} ** std.meta.fields(FieldName).len;
        var fields = std.mem.tokenize(line, " \r\n");
        while (fields.next()) |f| {
            const colon = std.mem.indexOf(u8, f, ":").?;
            const val = std.mem.trim(u8, f[colon+1..], &std.ascii.spaces);
            const fieldName = std.meta.stringToEnum(FieldName, f[0..colon]).?;
            const fieldValid = switch (fieldName) {
                .byr =>
                    val.len == 4 and year_in_range(try std.fmt.parseUnsigned(usize, val, 10), 1920, 2002),
                .iyr =>
                    val.len == 4 and year_in_range(try std.fmt.parseUnsigned(usize, val, 10), 2010, 2020),
                .eyr =>
                    val.len == 4 and year_in_range(try std.fmt.parseUnsigned(usize, val, 10), 2020, 2030),
                .hgt => try height_valid(val),
                .hcl =>
                    val.len == 7 and val[0] == '#' and blk: for (val[1..]) |c| {
                        if (!((c >= '0' and c <= '9') or (c >= 'a' and c <= 'f'))) break :blk false;
                    } else true,
                .ecl => std.meta.stringToEnum(EyeColor, val) != null,
                .pid =>
                    val.len == 9 and blk: for (val[1..]) |c| {
                        if (c < '0' or c > '9') break :blk false;
                    } else true,
                .cid => true,
            };
            found[@enumToInt(fieldName)] = true;
            if (!fieldValid) continue :outer;
        }
        const valid = blk: for (found[0..found.len-1]) |b| {
            if (!b) break :blk false;
        } else true;
        if (valid) count += 1;
    }
    print("valid count: {}\n", .{count});
}
