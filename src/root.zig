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
    var exp: i16 = @intCast((a_u32 & 0x7F800000) >> 23);
    exp -= 127;
    exp -= q;
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
    exp += 8;
    var frac: u32 = (a_u32 & 0x7FFFFF) | 0x800000;
    var result: i32 = 0;
    if (exp < 0) {
        frac >>= @intCast(-exp - 1);
        frac = (frac >> 1) + (frac & 1);
        result = @intCast(frac);
    } else {
        result = @intCast(frac << @intCast(exp));
    }
    const sign: bool = a < 0;
    if (sign) {
        result = -result;
    }
    return result;
}

pub export fn convert_F_Q32_2(a: f32, q: i8) i32 {
    var a_f32 = a;
    for (0..@intCast(31 - q)) |_| {
        a_f32 += a_f32;
    }
    if (a > 0) {
        a_f32 += 0.5;
    } else if (a < 0) {
        a_f32 -= 0.5;
    }
    return @as(i32, @intFromFloat(a_f32));
}

pub export fn add_limit(a: i32, b: i32) i32 {
    return a +| b;
}

pub export fn sub_limit(a: i32, b: i32) i32 {
    return a -| b;
}

pub export fn mul_limit(a: i32, b: i32) i32 {
    return a *| b;
}

pub export fn mul_Q0f31_Q0f31(a: i32, b: i32) i32 {
    const sign: i32 = (a & i32_min) ^ (b & i32_min);
    const x = @abs(a);
    const y = @abs(b);
    const hx = x >> 15;
    const hy = y >> 15;
    const lx = x & 0x7FFF;
    const ly = y & 0x7FFF;
    var r: u32 = hx * hy;
    var s: u32 = hy * lx + hx * ly + ((lx * ly) >> 16);
    s >>= 15;
    r += s;
    const rem = r & 1;
    r >>= 1;
    r += rem;
    var result: i32 = @intCast(r);
    if (sign != 0) {
        result = -result;
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
    var r: u16 = hx * hy;
    var s: u16 = hy * lx + hx * ly + ((lx * ly) >> 8);
    s >>= 7;
    r += s;
    const rem = r & 1;
    r >>= 1;
    r += rem;
    var result: i16 = @intCast(r);
    if (sign != 0) {
        result = -result;
    }
    return result;
}

test "basic add functionality" {
    try testing.expect(add_limit(3, 7) == 10);
    try testing.expect(add_limit(-2147483648, 7) == -2147483641);
    try testing.expect(add_limit(-2147483648, 0) == -2147483648);
    try testing.expect(add_limit(-455097958, -969180166) == -1424278124);
    try testing.expect(add_limit(1514432915, -1662737055) == -148304140);
    try testing.expect(add_limit(-1914173523, 1713635963) == -200537560);
    try testing.expect(add_limit(2041722576, -433296828) == 1608425748);
    try testing.expect(add_limit(1855740775, 1211581484) == 2147483647);
    try testing.expect(add_limit(-1796826983, 552354270) == -1244472713);
    try testing.expect(add_limit(-358680292, -95966905) == -454647197);
    try testing.expect(add_limit(1256111109, 1539035832) == 2147483647);
    try testing.expect(add_limit(-2021743425, -448636700) == -2147483648);
    try testing.expect(add_limit(-1875700498, -588188608) == -2147483648);
    try testing.expect(add_limit(2029434865, 1125449905) == 2147483647);
    try testing.expect(add_limit(898261784, 1194547110) == 2092808894);
    try testing.expect(add_limit(-669177291, -722306058) == -1391483349);
    try testing.expect(add_limit(878753559, -259098850) == 619654709);
    try testing.expect(add_limit(1111462036, -1354753620) == -243291584);
    try testing.expect(add_limit(-31810020, 764323027) == 732513007);
    try testing.expect(add_limit(-1636461629, 796746603) == -839715026);
    try testing.expect(add_limit(-436920629, -48496960) == -485417589);
    try testing.expect(add_limit(1775676277, -785024321) == 990651956);
    try testing.expect(add_limit(-1934404114, -1138555678) == -2147483648);
    try testing.expect(add_limit(1201907042, 489505879) == 1691412921);
    try testing.expect(add_limit(-814932486, -117791957) == -932724443);
    try testing.expect(add_limit(1227586588, 2123881080) == 2147483647);
    try testing.expect(add_limit(547289755, 212507279) == 759797034);
    try testing.expect(add_limit(109198334, -1900432070) == -1791233736);
    try testing.expect(add_limit(1926731960, 997348573) == 2147483647);
    try testing.expect(add_limit(712536187, -549039268) == 163496919);
    try testing.expect(add_limit(1820650872, -1058287363) == 762363509);
    try testing.expect(add_limit(271244056, 1392758178) == 1664002234);
    try testing.expect(add_limit(1072517328, 1100443446) == 2147483647);
    try testing.expect(add_limit(1476341355, 2114925732) == 2147483647);
    try testing.expect(add_limit(-1010713499, -638416526) == -1649130025);
    try testing.expect(add_limit(-367051278, 59450739) == -307600539);
    try testing.expect(add_limit(-1321723900, 960843345) == -360880555);
    try testing.expect(add_limit(333750603, -71354916) == 262395687);
    try testing.expect(add_limit(1018705994, 1475515670) == 2147483647);
    try testing.expect(add_limit(-619428030, 1636778256) == 1017350226);
    try testing.expect(add_limit(1295180856, 696701797) == 1991882653);
    try testing.expect(add_limit(1219646733, -355537169) == 864109564);
    try testing.expect(add_limit(-1209550030, -1399291694) == -2147483648);
    try testing.expect(add_limit(181849562, -1545071459) == -1363221897);
    try testing.expect(add_limit(255114900, -2142142439) == -1887027539);
    try testing.expect(add_limit(194716655, -171758947) == 22957708);
    try testing.expect(add_limit(-1606836369, 1774706902) == 167870533);
    try testing.expect(add_limit(1229302677, -1313663089) == -84360412);
    try testing.expect(add_limit(-873645378, 407561633) == -466083745);
    try testing.expect(add_limit(1039785982, -1207067526) == -167281544);
    try testing.expect(add_limit(-811657865, 404976376) == -406681489);
    try testing.expect(add_limit(832284473, -533928885) == 298355588);
    try testing.expect(add_limit(-576026712, 1562178880) == 986152168);
}

test "subtract" {
    try testing.expect(sub_limit(-2147483648, -2147483648) == 0);
    try testing.expect(sub_limit(0, -2147483648) == 2147483647);
    try testing.expect(sub_limit(-2147483648, -2147483600) == -48);
    try testing.expect(sub_limit(-1073327226, -825140187) == -248187039);
    try testing.expect(sub_limit(-1011216278, 1304877587) == -2147483648);
    try testing.expect(sub_limit(623697224, 1633751330) == -1010054106);
    try testing.expect(sub_limit(1323456925, 1414745800) == -91288875);
    try testing.expect(sub_limit(-1970623658, -343005632) == -1627618026);
    try testing.expect(sub_limit(-2024974575, -849462305) == -1175512270);
    try testing.expect(sub_limit(-1477302965, -1099406504) == -377896461);
    try testing.expect(sub_limit(-1350865645, 2032062192) == -2147483648);
    try testing.expect(sub_limit(-749481172, 2094907806) == -2147483648);
    try testing.expect(sub_limit(-1094145654, -1121964257) == 27818603);
}

test "multiply Q0f15" {
    try testing.expect(mul_Q0f15_Q0f15(1, 1) == 0);
    try testing.expect(mul_Q0f15_Q0f15(-0x4000, 0x4000) == -0x2000);
    try testing.expect(mul_Q0f15_Q0f15(0x2CE6, 0x6667) == 0x23EB);
    try testing.expect(mul_Q0f15_Q0f15(0, 0) == 0);
    try testing.expect(mul_Q0f15_Q0f15(-0x3333, 0x628F) == -(0x276C));
    try testing.expect(mul_Q0f15_Q0f15(25934, 14366) == 11370);
    try testing.expect(mul_Q0f15_Q0f15(17517, -22948) == -12267);
    try testing.expect(mul_Q0f15_Q0f15(21808, 25760) == 17144);
    try testing.expect(mul_Q0f15_Q0f15(26767, 15173) == 12394);
    try testing.expect(mul_Q0f15_Q0f15(-26404, 28491) == -22958);
    try testing.expect(mul_Q0f15_Q0f15(-1567, 10624) == -508);
    try testing.expect(mul_Q0f15_Q0f15(21081, 25581) == 16457);
    try testing.expect(mul_Q0f15_Q0f15(-22940, 9379) == -6566);
    try testing.expect(mul_Q0f15_Q0f15(-10138, -11104) == 3435);
    try testing.expect(mul_Q0f15_Q0f15(-24630, 25554) == -19208);
    try testing.expect(mul_Q0f15_Q0f15(2442, -3143) == -234);
    try testing.expect(mul_Q0f15_Q0f15(-345, -27336) == 288);
    try testing.expect(mul_Q0f15_Q0f15(30952, 32715) == 30902);
    try testing.expect(mul_Q0f15_Q0f15(-299, -24401) == 223);
    try testing.expect(mul_Q0f15_Q0f15(12831, -15211) == -5956);
    try testing.expect(mul_Q0f15_Q0f15(27125, 20522) == 16988);
    try testing.expect(mul_Q0f15_Q0f15(11962, 30627) == 11180);
    try testing.expect(mul_Q0f15_Q0f15(-552, 27371) == -461);
    try testing.expect(mul_Q0f15_Q0f15(11949, 21142) == 7710);
    try testing.expect(mul_Q0f15_Q0f15(11193, -26266) == -8972);
}

test "multiply Q0f31" {
    try testing.expect(mul_Q0f31_Q0f31(0, 477133664) == 0);
    try testing.expect(mul_Q0f31_Q0f31(0, -2147483648) == 0);
    try testing.expect(mul_Q0f31_Q0f31(0, 2147483647) == 0);
    try testing.expect(mul_Q0f31_Q0f31(-2147483648, 0) == 0);
    try testing.expect(mul_Q0f31_Q0f31(2147483647, 0) == 0);
    try testing.expect(mul_Q0f31_Q0f31(-268033373, 159496041) == -19907142);
    try testing.expect(mul_Q0f31_Q0f31(1006926165, -890238529) == -417420858);
    try testing.expect(mul_Q0f31_Q0f31(822770611, 941782343) == 360827350);
    try testing.expect(mul_Q0f31_Q0f31(1845688516, 1528251202) == 1313479474);
    try testing.expect(mul_Q0f31_Q0f31(-1764283736, -163919054) == 134669114);
    try testing.expect(mul_Q0f31_Q0f31(1399341682, -933588179) == -608344028);
    try testing.expect(mul_Q0f31_Q0f31(2089991838, -607293917) == -591035620);
    try testing.expect(mul_Q0f31_Q0f31(2139400768, -435302993) == -433664563);
    try testing.expect(mul_Q0f31_Q0f31(-1620284073, -1385854610) == 1045632247);
    try testing.expect(mul_Q0f31_Q0f31(-1808676534, -705973082) == 594592163);
    try testing.expect(mul_Q0f31_Q0f31(-1398230282, 113356149) == -73806383);
    try testing.expect(mul_Q0f31_Q0f31(1341641082, 309504604) == 193363098);
    try testing.expect(mul_Q0f31_Q0f31(241222531, -1026453521) == -115299465);
    try testing.expect(mul_Q0f31_Q0f31(-2016208064, 23641946) == -22196715);
    try testing.expect(mul_Q0f31_Q0f31(-833752033, -188442154) == 73161921);
    try testing.expect(mul_Q0f31_Q0f31(-792930459, 316918011) == -117017861);
    try testing.expect(mul_Q0f31_Q0f31(-1743205570, 920641847) == -747324897);
    try testing.expect(mul_Q0f31_Q0f31(1483610577, 1362362832) == 941202001);
    try testing.expect(mul_Q0f31_Q0f31(571370113, 701463126) == 186634746);
    try testing.expect(mul_Q0f31_Q0f31(-1489832097, 1895981144) == -1315350441);
}

test "conversion" {
    try testing.expect(convert_F_Q32(0.0, 0) == 0);
    try testing.expect(convert_F_Q32(-1.0, 0) == -2147483648);
    try testing.expect(convert_F_Q32(1.0, 0) == 2147483647);
    try testing.expect(convert_F_Q32(0.87, 0) == 0x6F5C2900);
    try testing.expect(convert_F_Q32(0.3387, 0) == 0x2B5A8580);
    try testing.expect(convert_F_Q32(-0.0114514, 0) == -0x1773D4E);
    try testing.expect(convert_F_Q32(-0.0114514, 3) == -0x2EE7AA);
    try testing.expect(convert_F_Q32(-0.0114514, 7) == -0x2EE7B);
    try testing.expect(convert_F_Q32_2(0.45632085, 0) == 979941568);
    try testing.expect(convert_F_Q32_2(-0.32180685, 0) == -691074944);
    try testing.expect(convert_F_Q32_2(0.34497935, 0) == 740837504);
    try testing.expect(convert_F_Q32_2(-0.8152496, 0) == -1750735232);
    try testing.expect(convert_F_Q32_2(-0.55224866, 0) == -1185944960);
    try testing.expect(convert_F_Q32_2(0.6515265, 0) == 1399142528);
    try testing.expect(convert_F_Q32_2(0.5843118, 0) == 1254800000);
    try testing.expect(convert_F_Q32_2(0.95483315, 0) == 2050488576);
    try testing.expect(convert_F_Q32_2(0.94275165, 0) == 2024543744);
    try testing.expect(convert_F_Q32_2(-0.47135544, 0) == -1012228096);
    try testing.expect(convert_F_Q32_2(-0.6846749, 0) == -1470328192);
    try testing.expect(convert_F_Q32_2(-0.27409053, 0) == -588604928);
    try testing.expect(convert_F_Q32_2(-0.59801614, 0) == -1284229888);
    try testing.expect(convert_F_Q32_2(-0.43219256, 0) == -928126464);
    try testing.expect(convert_F_Q32_2(-0.9702454, 0) == -2083586176);
    try testing.expect(convert_F_Q32_2(-0.057551146, 0) == -123590144);
    try testing.expect(convert_F_Q32_2(-0.10066668, 0) == -216180048);
    try testing.expect(convert_F_Q32_2(0.19495839, 0) == 418669952);
    try testing.expect(convert_F_Q32_2(0.5844674, 0) == 1255134208);
    try testing.expect(convert_F_Q32_2(-0.06361356, 0) == -136609072);
    try testing.expect(convert_F_Q32_2(-0.79516655, 0) == -1707607168);
    try testing.expect(convert_F_Q32_2(0.9242334, 0) == 1984776064);
    try testing.expect(convert_F_Q32_2(0.0012494724, 0) == 2683222);
    try testing.expect(convert_F_Q32_2(0.16639134, 0) == 357322688);
    try testing.expect(convert_F_Q32_2(0.5552961, 0) == 1192489344);
    try testing.expect(convert_F_Q32_2(0.9216287, 0) == 1979182592);
    try testing.expect(convert_F_Q32_2(-0.9625149, 0) == -2066984960);
    try testing.expect(convert_F_Q32_2(0.44007212, 0) == 945047680);
    try testing.expect(convert_F_Q32_2(0.57044685, 0) == 1225025280);
    try testing.expect(convert_F_Q32_2(0.24587236, 0) == 528006880);
    try testing.expect(convert_F_Q32_2(-0.07117124, 0) == -152839072);
    try testing.expect(convert_F_Q32_2(-0.10964765, 0) == -235466528);
    try testing.expect(convert_F_Q32_2(0.93987375, 0) == 2018363520);
    try testing.expect(convert_F_Q32_2(0.5676458, 0) == 1219010048);
    try testing.expect(convert_F_Q32_2(0.38364905, 0) == 823880064);
    try testing.expect(convert_F_Q32_2(-0.092354126, 0) == -198328976);
    try testing.expect(convert_F_Q32_2(-0.10529915, 0) == -226128208);
    try testing.expect(convert_F_Q32_2(0.9392326, 0) == 2016986624);
    try testing.expect(convert_F_Q32_2(-0.9988904, 0) == -2145100800);
    try testing.expect(convert_F_Q32_2(-0.3936751, 0) == -845410816);
    try testing.expect(convert_F_Q32_2(0.8981523, 0) == 1928767360);
    try testing.expect(convert_F_Q32_2(-0.60418576, 0) == -1297479040);
    try testing.expect(convert_F_Q32_2(0.004433403, 0) == 9520660);
    try testing.expect(convert_F_Q32_2(0.6365997, 0) == 1367087488);
    try testing.expect(convert_F_Q32_2(-0.38519514, 0) == -827200256);
    try testing.expect(convert_F_Q32_2(-0.9710457, 0) == -2085304704);
    try testing.expect(convert_F_Q32_2(-0.25420606, 0) == -545903360);
    try testing.expect(convert_F_Q32_2(-0.39699823, 0) == -852547200);
    try testing.expect(convert_F_Q32_2(-0.34651327, 0) == -744131584);
    try testing.expect(convert_F_Q32_2(0.29999074, 0) == 644225216);
    try testing.expect(convert_F_Q32(0.7437467, 0) == 1597183872);
    try testing.expect(convert_F_Q32(0.52611154, 0) == 1129815936);
    try testing.expect(convert_F_Q32(-0.59921044, 0) == -1286794624);
    try testing.expect(convert_F_Q32(-0.21042056, 0) == -451874720);
    try testing.expect(convert_F_Q32(-0.9933924, 0) == -2133293952);
    try testing.expect(convert_F_Q32(-0.49070224, 0) == -1053775040);
    try testing.expect(convert_F_Q32(0.18255228, 0) == 392028032);
    try testing.expect(convert_F_Q32(-0.54664165, 0) == -1173904000);
    try testing.expect(convert_F_Q32(-0.9944864, 0) == -2135643264);
    try testing.expect(convert_F_Q32(0.96330625, 0) == 2068684416);
    try testing.expect(convert_F_Q32(-0.4388183, 0) == -942355136);
    try testing.expect(convert_F_Q32(-0.3819623, 0) == -820257792);
    try testing.expect(convert_F_Q32(-0.49016908, 0) == -1052630080);
    try testing.expect(convert_F_Q32(-0.98009866, 0) == -2104745856);
    try testing.expect(convert_F_Q32(-0.93963003, 0) == -2017840128);
    try testing.expect(convert_F_Q32(-0.017581943, 0) == -37756936);
    try testing.expect(convert_F_Q32(0.081619054, 0) == 175275584);
    try testing.expect(convert_F_Q32(0.4341563, 0) == 932343552);
    try testing.expect(convert_F_Q32(-0.713761, 0) == -1532790016);
    try testing.expect(convert_F_Q32(0.22603942, 0) == 485415968);
    try testing.expect(convert_F_Q32(-0.8451397, 0) == -1814923648);
    try testing.expect(convert_F_Q32(0.9764979, 0) == 2097013248);
    try testing.expect(convert_F_Q32(-0.06678199, 0) == -143413232);
    try testing.expect(convert_F_Q32(0.67027235, 0) == 1439398912);
    try testing.expect(convert_F_Q32(0.90772074, 0) == 1949315456);
    try testing.expect(convert_F_Q32(0.008032838, 0) == 17250388);
    try testing.expect(convert_F_Q32(0.9313674, 0) == 2000096256);
    try testing.expect(convert_F_Q32(0.69736385, 0) == 1497577472);
    try testing.expect(convert_F_Q32(-0.35071784, 0) == -753160832);
    try testing.expect(convert_F_Q32(0.1858924, 0) == 399200896);
    try testing.expect(convert_F_Q32(0.17711775, 0) == 380357472);
    try testing.expect(convert_F_Q32(-0.30067772, 0) == -645700480);
    try testing.expect(convert_F_Q32(0.07276343, 0) == 156258272);
    try testing.expect(convert_F_Q32(0.8777215, 0) == 1884892544);
    try testing.expect(convert_F_Q32(0.52147174, 0) == 1119852032);
    try testing.expect(convert_F_Q32(0.14213938, 0) == 305241984);
    try testing.expect(convert_F_Q32(-0.0051099737, 0) == -10973585);
    try testing.expect(convert_F_Q32(0.42271224, 0) == 907767616);
    try testing.expect(convert_F_Q32(0.1296886, 0) == 278504160);
    try testing.expect(convert_F_Q32(0.2790183, 0) == 599187264);
    try testing.expect(convert_F_Q32(-0.6933456, 0) == -1488948352);
    try testing.expect(convert_F_Q32(-0.8817617, 0) == -1893568896);
    try testing.expect(convert_F_Q32(-0.9421486, 0) == -2023248768);
    try testing.expect(convert_F_Q32(0.9558219, 0) == 2052611840);
    try testing.expect(convert_F_Q32(-0.7563273, 0) == -1624200448);
    try testing.expect(convert_F_Q32(0.7586815, 0) == 1629256064);
    try testing.expect(convert_F_Q32(0.29112777, 0) == 625192128);
    try testing.expect(convert_F_Q32(-0.15813449, 0) == -339591232);
    try testing.expect(convert_F_Q32(-0.13264225, 0) == -284847072);
    try testing.expect(convert_F_Q32(-0.3227631, 0) == -693128448);
    try testing.expect(convert_F_Q32_2(-1.8846453, 3) == -505905632);
    try testing.expect(convert_F_Q32_2(-3.791003, 3) == -1017639616);
    try testing.expect(convert_F_Q32_2(-2.2637496, 3) == -607670656);
    try testing.expect(convert_F_Q32_2(2.308742, 3) == 619748224);
    try testing.expect(convert_F_Q32_2(-2.7334545, 3) == -733756096);
    try testing.expect(convert_F_Q32_2(-0.72423536, 3) == -194410448);
    try testing.expect(convert_F_Q32_2(3.8950958, 3) == 1045581824);
    try testing.expect(convert_F_Q32_2(1.2604986, 3) == 338362528);
    try testing.expect(convert_F_Q32_2(-1.4665757, 3) == -393680928);
    try testing.expect(convert_F_Q32_2(3.821078, 3) == 1025712832);
    try testing.expect(convert_F_Q32_2(-2.4257836, 3) == -651166336);
    try testing.expect(convert_F_Q32_2(0.47310066, 3) == 126996992);
    try testing.expect(convert_F_Q32_2(2.639231, 3) == 708463168);
    try testing.expect(convert_F_Q32_2(1.5947556, 3) == 428088960);
    try testing.expect(convert_F_Q32_2(3.6900804, 3) == 990548416);
    try testing.expect(convert_F_Q32_2(-1.7260778, 3) == -463340480);
    try testing.expect(convert_F_Q32_2(0.9671041, 3) == 259605024);
    try testing.expect(convert_F_Q32_2(1.7166456, 3) == 460808544);
    try testing.expect(convert_F_Q32_2(1.7139345, 3) == 460080800);
    try testing.expect(convert_F_Q32_2(-2.1570966, 3) == -579041216);
    try testing.expect(convert_F_Q32_2(-1.9358821, 3) == -519659392);
    try testing.expect(convert_F_Q32_2(0.13873823, 3) == 37242260);
    try testing.expect(convert_F_Q32_2(-1.712225, 3) == -459621888);
    try testing.expect(convert_F_Q32_2(0.8454686, 3) == 226953744);
    try testing.expect(convert_F_Q32_2(-2.7512484, 3) == -738532608);
    try testing.expect(convert_F_Q32_2(0.5816767, 3) == 156142656);
    try testing.expect(convert_F_Q32_2(-3.7330403, 3) == -1002080384);
    try testing.expect(convert_F_Q32_2(-1.1305703, 3) == -303485152);
    try testing.expect(convert_F_Q32_2(-3.2466438, 3) == -871514304);
    try testing.expect(convert_F_Q32_2(3.9427764, 3) == 1058380992);
    try testing.expect(convert_F_Q32_2(-2.1562626, 3) == -578817344);
    try testing.expect(convert_F_Q32_2(-3.9813519, 3) == -1068736000);
    try testing.expect(convert_F_Q32_2(-3.3860168, 3) == -908926976);
    try testing.expect(convert_F_Q32_2(0.68905646, 3) == 184967184);
    try testing.expect(convert_F_Q32_2(2.3201132, 3) == 622800640);
    try testing.expect(convert_F_Q32_2(0.6157933, 3) == 165300752);
    try testing.expect(convert_F_Q32_2(-2.5686486, 3) == -689516352);
    try testing.expect(convert_F_Q32_2(1.1599922, 3) == 311383040);
    try testing.expect(convert_F_Q32_2(2.0440924, 3) == 548706880);
    try testing.expect(convert_F_Q32_2(-3.6783555, 3) == -987401024);
    try testing.expect(convert_F_Q32_2(1.0551721, 3) == 283245600);
    try testing.expect(convert_F_Q32_2(-0.9193998, 3) == -246799504);
    try testing.expect(convert_F_Q32_2(-3.019402, 3) == -810514560);
    try testing.expect(convert_F_Q32_2(-0.9351924, 3) == -251038800);
    try testing.expect(convert_F_Q32_2(-1.6397434, 3) == -440165280);
    try testing.expect(convert_F_Q32_2(-1.8909724, 3) == -507604032);
    try testing.expect(convert_F_Q32_2(-0.0627031, 3) == -16831736);
    try testing.expect(convert_F_Q32_2(0.010759495, 3) == 2888230);
    try testing.expect(convert_F_Q32_2(0.291187, 3) == 78164912);
    try testing.expect(convert_F_Q32_2(1.3500396, 3) == 362398496);
    try testing.expect(convert_F_Q32(-0.7118685, 3) == -191090752);
    try testing.expect(convert_F_Q32(-3.3756447, 3) == -906142720);
    try testing.expect(convert_F_Q32(-3.7548559, 3) == -1007936448);
    try testing.expect(convert_F_Q32(2.3447165, 3) == 629405056);
    try testing.expect(convert_F_Q32(2.401967, 3) == 644773120);
    try testing.expect(convert_F_Q32(-2.158728, 3) == -579479104);
    try testing.expect(convert_F_Q32(0.62533975, 3) == 167863360);
    try testing.expect(convert_F_Q32(-3.651312, 3) == -980141632);
    try testing.expect(convert_F_Q32(0.60114956, 3) == 161369856);
    try testing.expect(convert_F_Q32(0.74771756, 3) == 200713904);
    try testing.expect(convert_F_Q32(1.410227, 3) == 378554912);
    try testing.expect(convert_F_Q32(-3.6551979, 3) == -981184704);
    try testing.expect(convert_F_Q32(-0.8994565, 3) == -241446016);
    try testing.expect(convert_F_Q32(3.6177833, 3) == 971141312);
    try testing.expect(convert_F_Q32(-2.0801136, 3) == -558376256);
    try testing.expect(convert_F_Q32(-2.3585691, 3) == -633123584);
    try testing.expect(convert_F_Q32(-0.039991353, 3) == -10735097);
    try testing.expect(convert_F_Q32(-0.7333596, 3) == -196859712);
    try testing.expect(convert_F_Q32(0.3115205, 3) == 83623144);
    try testing.expect(convert_F_Q32(-2.1202705, 3) == -569155776);
    try testing.expect(convert_F_Q32(-0.24573915, 3) == -65965100);
    try testing.expect(convert_F_Q32(-1.7911816, 3) == -480816640);
    try testing.expect(convert_F_Q32(-1.7493412, 3) == -469585216);
    try testing.expect(convert_F_Q32(3.0705843, 3) == 824253696);
    try testing.expect(convert_F_Q32(-0.12675415, 3) == -34025308);
    try testing.expect(convert_F_Q32(-0.005593513, 3) == -1501497);
    try testing.expect(convert_F_Q32(-2.2054403, 3) == -592018368);
    try testing.expect(convert_F_Q32(-2.968719, 3) == -796909440);
    try testing.expect(convert_F_Q32(-1.9763528, 3) == -530523168);
    try testing.expect(convert_F_Q32(-1.4407995, 3) == -386761664);
    try testing.expect(convert_F_Q32(-0.0080990745, 3) == -2174079);
    try testing.expect(convert_F_Q32(-1.2761717, 3) == -342569728);
    try testing.expect(convert_F_Q32(2.2798567, 3) == 611994368);
    try testing.expect(convert_F_Q32(-1.9948186, 3) == -535480032);
    try testing.expect(convert_F_Q32(-3.466895, 3) == -930637568);
    try testing.expect(convert_F_Q32(3.6041934, 3) == 967493312);
    try testing.expect(convert_F_Q32(0.63938946, 3) == 171634800);
    try testing.expect(convert_F_Q32(2.394917, 3) == 642880640);
    try testing.expect(convert_F_Q32(-3.6735196, 3) == -986102912);
    try testing.expect(convert_F_Q32(-2.9009118, 3) == -778707584);
    try testing.expect(convert_F_Q32(-1.9882696, 3) == -533722048);
    try testing.expect(convert_F_Q32(-0.21414109, 3) == -57483060);
    try testing.expect(convert_F_Q32(-1.5963084, 3) == -428505760);
    try testing.expect(convert_F_Q32(-0.036144357, 3) == -9702427);
    try testing.expect(convert_F_Q32(1.3009489, 3) == 349220800);
    try testing.expect(convert_F_Q32(-0.9419455, 3) == -252851568);
    try testing.expect(convert_F_Q32(-1.1617999, 3) == -311868288);
    try testing.expect(convert_F_Q32(-1.8831642, 3) == -505508032);
    try testing.expect(convert_F_Q32(3.1717722, 3) == 851416128);
    try testing.expect(convert_F_Q32(3.715574, 3) == 997391808);
}
