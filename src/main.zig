const zerofp = @import("root.zig");
const std = @import("std");

pub fn main() !void {
    var a: f32 = -0.0114514;
    var x = zerofp.convert_F_Q32(a, 3);
    std.debug.print("{} ==> 0x{X}\n", .{ a, x });
    a = 2.0;
    x = zerofp.convert_F_Q32(a, 0);
    std.debug.print("{} ==> {}\n", .{ a, x });
    x = zerofp.mul_Q0f31_Q0f31(1006926165, -890238529);
    std.debug.print("x = {}\n", .{x});
    x = zerofp.mul_Q0f31_Q0f31(-268033373, 159496041);
    std.debug.print("x = {}\n", .{x});
    x = zerofp.mul_Q0f31_Q0f31(2139400768, -435302993);
    std.debug.print("x = {}\n", .{x});
    var y: i16 = zerofp.mul_Q0f15_Q0f15(11494, 26215);
    std.debug.print("y = {}\n", .{y});
    y = zerofp.mul_Q0f15_Q0f15(-26404, 28491);
    std.debug.print("y = {}\n", .{y});
    y = zerofp.mul_Q0f15_Q0f15(-24630, 25554);
    std.debug.print("y = {}\n", .{y});
}
