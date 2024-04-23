const std = @import("std");
const testing = std.testing;
const print = std.debug.print;

const i16_min = std.math.minInt(i16);
const i16_max = std.math.maxInt(i16);
const i32_min = std.math.minInt(i32);
const i32_max = std.math.maxInt(i32);

export fn add(a: i32, b: i32) i32 {
    return a +| b;
}

export fn mul_Q0f31_Q0f31(a: i32, b: i32) i32 {
    const sign: i32 = (a & i32_min) ^ (b & i32_min);
    const x = @abs(a);
    const y = @abs(b);
    const hx = x >> 15;
    const hy = y >> 15;
    const lx = x & 0x7FFF;
    const ly = y & 0x7FFF;
    const result: i32 = @intCast((hx * hy +| ((hy * lx + hx * ly) >> 15) +| (lx >> 14) + (ly >> 14)) >> 1);
    if (sign != 0) {
        return -result;
    }
    return result;
}

export fn mul_Q0f15_Q0f15(a: i16, b: i16) i16 {
    const sign: i16 = (a & i16_min) ^ (b & i16_min);
    const x = @abs(a);
    const y = @abs(b);
    const hx = x >> 7;
    const hy = y >> 7;
    const lx = x & 0x7F;
    const ly = y & 0x7F;
    const result: i16 = @intCast((hx * hy +| ((hy * lx + hx * ly) >> 7) +| (lx >> 7) + (ly >> 7)) >> 1);
    if (sign != 0) {
        return -result;
    }
    return result;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
    try testing.expect(mul_Q0f15_Q0f15(1, 1) == 0);
    try testing.expect(mul_Q0f15_Q0f15(-0x4000, 0x4000) == -0x2000);
    try testing.expect(mul_Q0f15_Q0f15(0x2CE6, 0x6667) == 0x23EB);
    try testing.expect(mul_Q0f15_Q0f15(0, 0) == 0);
    try testing.expect(mul_Q0f15_Q0f15(-0x3333, 0x628F) == -(0x276C));
    try testing.expect(mul_Q0f31_Q0f31(-0x3D0E5604, -0x4A3D70A4) == 0x2369984A);
    try testing.expect(mul_Q0f31_Q0f31(-0x374bc6a, 0x7eb851ec) == -0x36be37d);
}
