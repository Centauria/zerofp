const zerofp = @import("root.zig");
const std = @import("std");

pub fn main() !void {
    const a = -0.0114514;
    const x = zerofp.convert_F_Q32(a, 3);
    std.debug.print("{} ==> 0x{X}\n", .{ a, x });
}
