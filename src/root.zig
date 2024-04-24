const std = @import("std");
const testing = std.testing;
const print = std.debug.print;

const i16_min = std.math.minInt(i16);
const i16_max = std.math.maxInt(i16);
const i32_min = std.math.minInt(i32);
const i32_max = std.math.maxInt(i32);

pub export fn convert_Q32(a: i32, q0: u8, f0: u8, q: u8, f: u8) i32 {
    _ = a;
    _ = q0;
    _ = f0;
    _ = q;
    _ = f;
    return 0;
}

pub export fn convert_F_Q32(a: f32, q: i8) i32 {
    const a_u32: u32 = @bitCast(a);
    var exp: i8 = @intCast((a_u32 & 0x7F800000) >> 23);
    exp -= 127;
    if (exp >= 0) {
        if (a < 0) {
            return i32_min;
        } else if (a > 0) {
            return i32_max;
        } else {
            return 0;
        }
    } else if (exp < -24) {
        return 0;
    }
    exp += 8 - q;
    var frac: u32 = (a_u32 & 0x7FFFFF) | 0x800000;
    var result: i32 = 0;
    if (exp < 0) {
        frac >>= @intCast(-exp - 1);
        frac = (frac >> 1) + (frac & 1);
        result = @intCast(frac);
    } else {
        result = @intCast(frac << @intCast(exp));
    }
    const sign: bool = (a_u32 & 0x80000000) != 0;
    if (sign) {
        result = -result;
    }
    return result;
}

pub export fn add_Q0f31_Q0f31(a: i32, b: i32) i32 {
    return a +| b;
}

pub export fn mul_Q0f31_Q0f31(a: i32, b: i32) i32 {
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

pub export fn mul_Q0f15_Q0f15(a: i16, b: i16) i16 {
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
    try testing.expect(add_Q0f31_Q0f31(3, 7) == 10);
}

test "multiply Q0f15" {
    try testing.expect(mul_Q0f15_Q0f15(1, 1) == 0);
    try testing.expect(mul_Q0f15_Q0f15(-0x4000, 0x4000) == -0x2000);
    try testing.expect(mul_Q0f15_Q0f15(0x2CE6, 0x6667) == 0x23EB);
    try testing.expect(mul_Q0f15_Q0f15(0, 0) == 0);
    try testing.expect(mul_Q0f15_Q0f15(-0x3333, 0x628F) == -(0x276C));
}

test "multiply Q0f31" {
    try testing.expect(mul_Q0f31_Q0f31(-0x3D0E5604, -0x4A3D70A4) == 0x2369984A);
    try testing.expect(mul_Q0f31_Q0f31(-0x374bc6a, 0x7eb851ec) == -0x36be37d);
}

test "conversion" {
    try testing.expect(convert_F_Q32(0.87, 0) == 0x6F5C2900);
    try testing.expect(convert_F_Q32(0.3387, 0) == 0x2B5A8580);
    try testing.expect(convert_F_Q32(-0.0114514, 0) == -0x1773D4E);
    try testing.expect(convert_F_Q32(-0.0114514, 3) == -0x2EE7AA);
    try testing.expect(convert_F_Q32(-0.0114514, 7) == -0x2EE7B);
}