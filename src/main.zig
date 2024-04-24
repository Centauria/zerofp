const zerofp = @import("root.zig");
const std = @import("std");

pub fn main() !void {
    var a: f32 = -0.0114514;
    var x = zerofp.convert_F_Q32(a, 3);
    std.debug.print("{} ==> 0x{X}\n", .{ a, x });
    a = -0.039615747;
    x = zerofp.convert_F_Q32_2(a, 0);
    std.debug.print("{} ==> {}\n", .{ a, x });
    const c = 0xC0580A90;
    const exp: i8 = @truncate((c & 0x7F800000) >> 23);
    std.debug.print("exp = 0x{X}\n", .{exp});
}
