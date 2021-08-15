const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const lib = @import("impl/lib.zig");

const zlm = @import("zlm").specializeOn(f64);

pub const VarIntError = error{
    VarIntTooLargeError,
    VarLongTooLargeError,
};

pub fn oreadVarInt(reader: anytype) !i32 {
    var result: u32 = 0;

    var num_read: u32 = 0;
    var read = try reader.readByte();

    while ((read & 0b10000000) != 0) {
        var value: u32 = (read & 0b01111111);
        result |= (value << @intCast(u5, 7 * num_read));

        num_read += 1;
        read = try reader.readByte();
    }
    var value: u32 = (read & 0b01111111);
    result |= (value << @intCast(u5, 7 * num_read));

    return @bitCast(i32, result);
}

pub fn readVarInt(reader: anytype) !i32 {
    return (try readVarIntCounter(reader))[0];
}

pub fn readVarIntCounter(reader: anytype) ![]i32 {
    var num_read: u32 = 0;
    var result: u32 = 0;
    var read: u8 = undefined;
    while (true) {
        read = try reader.readByte();
        var value: u32 = (read & 0b01111111);
        result |= (value << @intCast(u5, 7 * num_read));
        num_read += 1;
        if (num_read > 5) return VarIntError.VarIntTooLargeError;
        if ((read & 0b10000000) == 0) break;
    }
    return &[_]i32{ @bitCast(i32, result), @intCast(i32, num_read) };
}

pub fn readVarLong(reader: anytype) !i64 {
    return (try readVarLongCounter(reader))[0];
}

pub fn readVarLongCounter(reader: anytype) ![]i64 {
    var num_read: u32 = 0;
    var result: u64 = 0;
    var read: u8 = undefined;
    while (true) {
        read = try reader.readByte();
        var value: u64 = (read & 0b01111111);
        result |= (value << @intCast(u6, 7 * num_read));
        num_read += 1;
        if (num_read > 10) return VarIntError.VarLongTooLargeError;
        if ((read & 0b10000000) == 0) break;
    }

    return &[_]i64{ @bitCast(i64, result), @intCast(i64, num_read) };
}
pub fn readVarByteArray(alloc: *Allocator, reader: anytype) ![]u8 {
    return try readByteArray(alloc, reader, try readVarInt(reader));
}

pub fn readByteArray(alloc: *Allocator, reader: anytype, length: i32) ![]u8 {
    var buf = try alloc.alloc(u8, @intCast(usize, length));
    var strm = std.io.fixedBufferStream(buf);
    var wr = strm.writer();

    var i: usize = 0;
    while (i < length) : (i += 1) {
        try wr.writeByte(try reader.readByte());
    }

    return buf;
}

pub fn writeVarInt(writer: anytype, value: i32) !void {
    var tmp_value: u32 = @bitCast(u32, value);
    var tmp: u8 = @truncate(u8, tmp_value) & 0b01111111;
    while (true) {
        tmp = @truncate(u8, tmp_value) & 0b01111111;
        tmp_value >>= 7;

        if (tmp_value != 0) {
            tmp |= 0b10000000;
        }
        try writer.writeByte(tmp);
        if (tmp_value == 0) break;
    }
}

pub fn writeVarLong(writer: anytype, value: i64) !void {
    var tmp_value: u64 = @bitCast(u64, value);
    var tmp: u8 = @truncate(u8, tmp_value) & 0b01111111;
    while (true) {
        tmp = @truncate(u8, tmp_value) & 0b01111111;
        tmp_value >>= 7;

        if (tmp_value != 0) {
            tmp |= 0b10000000;
        }
        try writer.writeByte(tmp);
        if (tmp_value == 0) break;
    }
}

pub fn writeByteArray(writer: anytype, data: []const u8) !void {
    try writeVarInt(writer, @intCast(i32, data.len));
    try writer.writeAll(data);
}

pub fn writeJSONStruct(value: anytype, writer: anytype, alloc: *Allocator) !void {
    var array_list = std.ArrayList(u8).init(alloc);
    defer array_list.deinit();

    try std.json.stringify(value, .{}, array_list.outStream());

    try writeByteArray(writer, array_list.toOwnedSlice());
}

pub fn readJSONStruct(comptime T: type, reader: anytype, alloc: *Allocator) !T {
    var byteArray = try readJSONHelper(reader, alloc);
    const ret = try std.json.parse(T, &std.json.TokenStream.init(byteArray), std.json.ParseOptions{});
    return ret;
}

// readJSONHelper read a byte at a time, stopping when the stack is complete
// or invalid
pub fn readJSONHelper(reader: anytype, alloc: *Allocator) ![]u8 {
    var byte: u8 = undefined;
    var array_list = std.ArrayList(u8).init(alloc);
    var curl_stack: i32 = @intCast(i32, 0);
    var sq_stack: i32 = @intCast(i32, 0);
    defer array_list.deinit();

    while (true) : (byte = try reader.readByte()) {
        switch (byte) {
            '{' => {
                curl_stack += 1;
            },
            '}' => {
                curl_stack -= 1;
            },
            '[' => {
                sq_stack += 1;
            },
            ']' => {
                sq_stack -= 1;
            },
            else => {},
        }
        if (curl_stack < 0 or sq_stack < 0) return InvalidJsonError.InvalidJson;
        try array_list.append(byte);
        if (curl_stack == 0 and sq_stack == 0) break;
    }
    return array_list.toOwnedSlice();
}

const InvalidJsonError = error{
    InvalidJson,
};

pub inline fn toPacketPosition(vec: zlm.Vec3) u64 {
    return (@as(u64, @bitCast(u32, @floatToInt(i32, vec.x) & 0x3FFFFFF)) << 38) | (@as(u64, @bitCast(u32, @floatToInt(i32, vec.z) & 0x3FFFFFF)) << 12) | (@as(u64, @bitCast(u32, @floatToInt(i32, vec.y))) & 0xFFF);
}

const testing = std.testing;

fn testWriteHelper(varInt: i32, expected: []u8) !void {
    var array_list = std.ArrayList(u8).init(testing.allocator);
    var writer = array_list.writer();
    try writeVarInt(writer, varInt);
    const slice = array_list.toOwnedSlice();
    defer testing.allocator.free(slice);
    try testing.expectEqualSlices(u8, expected, slice);
}

fn testReadHelper(expected: i32, varInt: []u8) !void {
    var buf = std.io.fixedBufferStream(varInt);
    const out: i32 = try readVarInt(buf.reader());
    try std.testing.expectEqual(expected, out);
}

test "test writeVarInt" {
    var test1 = [_]u8{0x00};
    var test2 = [_]u8{0x01};
    var test3 = [_]u8{0x02};
    var test4 = [_]u8{0x7f};
    var test5 = [_]u8{ 0x80, 0x01 };
    var test6 = [_]u8{ 0xff, 0x01 };
    var test7 = [_]u8{ 0xff, 0xff, 0x7f };
    var test8 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0x07 };
    var test9 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0x0f };
    var test10 = [_]u8{ 0x80, 0x80, 0x80, 0x80, 0x08 };

    try testWriteHelper(0, &test1);
    try testWriteHelper(1, &test2);
    try testWriteHelper(2, &test3);
    try testWriteHelper(127, &test4);
    try testWriteHelper(128, &test5);
    try testWriteHelper(255, &test6);
    try testWriteHelper(2097151, &test7);
    try testWriteHelper(2147483647, &test8);
    try testWriteHelper(-1, &test9);
    try testWriteHelper(-2147483648, &test10);
}

test "test readVarInt" {
    var test1 = [_]u8{0x00};
    var test2 = [_]u8{0x01};
    var test3 = [_]u8{0x02};
    var test4 = [_]u8{0x7f};
    var test5 = [_]u8{ 0x80, 0x01 };
    var test6 = [_]u8{ 0xff, 0x01 };
    var test7 = [_]u8{ 0xff, 0xff, 0x7f };
    var test8 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0x07 };
    var test9 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0x0f };
    var test10 = [_]u8{ 0x80, 0x80, 0x80, 0x80, 0x08 };

    try testReadHelper(0, &test1);
    try testReadHelper(1, &test2);
    try testReadHelper(2, &test3);
    try testReadHelper(127, &test4);
    try testReadHelper(128, &test5);
    try testReadHelper(255, &test6);
    try testReadHelper(2097151, &test7);
    try testReadHelper(2147483647, &test8);
    try testReadHelper(-1, &test9);
    try testReadHelper(-2147483648, &test10);
}

fn testLongWriteHelper(varLong: i64, expected: []u8) !void {
    var array_list = std.ArrayList(u8).init(testing.allocator);
    var writer = array_list.writer();
    try writeVarLong(writer, varLong);
    const slice = array_list.toOwnedSlice();
    defer testing.allocator.free(slice);
    try testing.expectEqualSlices(u8, expected, slice);
}

fn testLongReadHelper(expected: i64, varLong: []u8) !void {
    var buf = std.io.fixedBufferStream(varLong);
    const out: i64 = try readVarLong(buf.reader());
    try std.testing.expectEqual(expected, out);
}

test "test writeVarLong" {
    var test1 = [_]u8{0x00};
    var test2 = [_]u8{0x01};
    var test3 = [_]u8{0x02};
    var test4 = [_]u8{0x7f};
    var test5 = [_]u8{ 0x80, 0x01 };
    var test6 = [_]u8{ 0xff, 0x01 };
    var test7 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0x07 };
    var test8 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f };
    var test9 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01 };
    var test10 = [_]u8{ 0x80, 0x80, 0x80, 0x80, 0xf8, 0xff, 0xff, 0xff, 0xff, 0x01 };
    var test11 = [_]u8{ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01 };

    try testLongWriteHelper(0, &test1);
    try testLongWriteHelper(1, &test2);
    try testLongWriteHelper(2, &test3);
    try testLongWriteHelper(127, &test4);
    try testLongWriteHelper(128, &test5);
    try testLongWriteHelper(255, &test6);
    try testLongWriteHelper(2147483647, &test7);
    try testLongWriteHelper(9223372036854775807, &test8);
    try testLongWriteHelper(-1, &test9);
    try testLongWriteHelper(-2147483648, &test10);
    try testLongWriteHelper(-9223372036854775808, &test11);
}

test "test readVarLong" {
    var test1 = [_]u8{0x00};
    var test2 = [_]u8{0x01};
    var test3 = [_]u8{0x02};
    var test4 = [_]u8{0x7f};
    var test5 = [_]u8{ 0x80, 0x01 };
    var test6 = [_]u8{ 0xff, 0x01 };
    var test7 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0x07 };
    var test8 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x7f };
    var test9 = [_]u8{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01 };
    var test10 = [_]u8{ 0x80, 0x80, 0x80, 0x80, 0xf8, 0xff, 0xff, 0xff, 0xff, 0x01 };
    var test11 = [_]u8{ 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01 };

    try testLongReadHelper(0, &test1);
    try testLongReadHelper(1, &test2);
    try testLongReadHelper(2, &test3);
    try testLongReadHelper(127, &test4);
    try testLongReadHelper(128, &test5);
    try testLongReadHelper(255, &test6);
    try testLongReadHelper(2147483647, &test7);
    try testLongReadHelper(9223372036854775807, &test8);
    try testLongReadHelper(-1, &test9);
    try testLongReadHelper(-2147483648, &test10);
    try testLongReadHelper(-9223372036854775808, &test11);
}
