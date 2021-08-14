const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const io = std.io;

const serde = @import("serde.zig");
const utils = @import("utils.zig");

pub const Tag = union(enum(u8)) {
    end: void,
    byte: struct { name: []const u8, payload: i8 },
    short: struct { name: []const u8, payload: i16 },
    int: struct { name: []const u8, payload: i32 },
    long: struct { name: []const u8, payload: i64 },
    float: struct { name: []const u8, payload: f32 },
    double: struct { name: []const u8, payload: f64 },
    byte_array: struct { name: []const u8, payload: []const u8 },
    string: struct { name: []const u8, payload: []const u8 },
    list: struct { name: []const u8, payload: []const Tag },
    compound: struct { name: []const u8, payload: []const Tag },
    int_array: struct { name: []const u8, payload: []i32 },
    long_array: struct { name: []const u8, payload: []i64 },
};

// deserialzie fn
// 1. switch on readByte for type
// 2. read tag name length
// 3. read tag name
// 4. read payload (dependent on type in 1.)
pub fn readTag(
    reader: anytype,
    alloc: *Allocator,
    payload_only: bool,
    tag_type: u8,
) anyerror!Tag {
    const tag_id = if (!payload_only) try reader.readByte() else tag_type;

    // check if it is .end tag
    if (tag_id == 0)
        return Tag.end;

    // grab name
    const tag_name: []const u8 = if (!payload_only) try utils.readByteArray(alloc, reader, try reader.readIntBig(u16)) else "";

    switch (tag_id) {
        1 => return Tag{ .byte = .{ .name = tag_name, .payload = @intCast(i8, try reader.readByte()) } },
        2 => return Tag{ .short = .{ .name = tag_name, .payload = try serde.primativeDeserialize(i16, reader) } },
        3 => return Tag{ .int = .{ .name = tag_name, .payload = try serde.primativeDeserialize(i32, reader) } },
        4 => return Tag{ .long = .{ .name = tag_name, .payload = try serde.primativeDeserialize(i64, reader) } },
        5 => return Tag{ .float = .{ .name = tag_name, .payload = try serde.primativeDeserialize(f32, reader) } },
        6 => return Tag{ .double = .{ .name = tag_name, .payload = try serde.primativeDeserialize(f64, reader) } },
        7 => return Tag{ .byte_array = .{ .name = tag_name, .payload = try utils.readByteArray(alloc, reader, try reader.readIntBig(i32)) } },
        8 => return Tag{ .string = .{ .name = tag_name, .payload = try utils.readByteArray(alloc, reader, try reader.readIntBig(u16)) } },
        9 => {
            const list_type = try reader.readByte();
            const list_len = @intCast(usize, try reader.readIntBig(i32));
            var list = try std.ArrayList(Tag).initCapacity(alloc, list_len);
            try list.resize(list_len);
            var outSlice = list.toOwnedSlice();
            for (outSlice) |v, i| {
                outSlice[i] = try readTag(reader, alloc, true, list_type); // need to handle payload-only case
            }
            return Tag{ .list = .{ .name = tag_name, .payload = outSlice } };
        },
        10 => {
            var list = std.ArrayList(Tag).init(alloc);
            while (true) {
                const compoundTag = try readTag(reader, alloc, false, 0);
                if (compoundTag == .end) break;
                try list.append(compoundTag);
            }
            return Tag{ .compound = .{ .name = tag_name, .payload = list.toOwnedSlice() } };
        },
        11 => {
            const list_len = @intCast(usize, try reader.readIntBig(i32));
            var list = try std.ArrayList(i32).initCapacity(alloc, list_len);
            try list.resize(list_len);
            var outSlice = list.toOwnedSlice();
            for (outSlice) |v, i| {
                outSlice[i] = try reader.readIntBig(i32);
            }
            return Tag{ .int_array = .{ .name = tag_name, .payload = outSlice } };
        },
        12 => {
            const list_len = @intCast(usize, try reader.readIntBig(i32));
            var list = try std.ArrayList(i64).initCapacity(alloc, list_len);
            try list.resize(list_len);
            var outSlice = list.toOwnedSlice();
            for (outSlice) |v, i| {
                outSlice[i] = try reader.readIntBig(i64);
            }
            return Tag{ .long_array = .{ .name = tag_name, .payload = outSlice } };
        },
        else => return .end,
    }
}

// serialize fn
pub fn writeTag(writer: anytype, tag: Tag, payload_only: bool) anyerror!void {
    switch (tag) {
        .end => try writer.writeByte(0),
        .byte => {
            if (!payload_only) {
                try writer.writeByte(1);
                try writer.writeIntBig(u16, @intCast(u16, tag.byte.name.len));
                try writer.writeAll(tag.byte.name);
            }
            try writer.writeByte(@bitCast(u8, tag.byte.payload));
        },
        .short => {
            if (!payload_only) {
                try writer.writeByte(2);
                try writer.writeIntBig(u16, @intCast(u16, tag.short.name.len));
                try writer.writeAll(tag.short.name);
            }
            try writer.writeIntBig(i16, tag.short.payload);
        },
        .int => {
            if (!payload_only) {
                try writer.writeByte(3);
                try writer.writeIntBig(u16, @intCast(u16, tag.int.name.len));
                try writer.writeAll(tag.int.name);
            }
            try writer.writeIntBig(i32, tag.int.payload);
        },
        .long => {
            if (!payload_only) {
                try writer.writeByte(4);
                try writer.writeIntBig(u16, @intCast(u16, tag.long.name.len));
                try writer.writeAll(tag.long.name);
            }
            try writer.writeIntBig(i64, tag.long.payload);
        },
        .float => {
            if (!payload_only) {
                try writer.writeByte(5);
                try writer.writeIntBig(u16, @intCast(u16, tag.float.name.len));
                try writer.writeAll(tag.float.name);
            }
            try writer.writeIntBig(u32, @bitCast(u32, tag.float.payload));
        },
        .double => {
            if (!payload_only) {
                try writer.writeByte(6);
                try writer.writeIntBig(u16, @intCast(u16, tag.double.name.len));
                try writer.writeAll(tag.double.name);
            }
            try writer.writeIntBig(u64, @bitCast(u64, tag.double.payload));
        },
        .byte_array => {
            if (!payload_only) {
                try writer.writeByte(7);
                try writer.writeIntBig(u16, @intCast(u16, tag.byte_array.name.len));
                try writer.writeAll(tag.byte_array.name);
            }
            try writer.writeIntBig(i32, @intCast(i32, tag.byte_array.payload.len));
            try writer.writeAll(tag.byte_array.payload);
        },
        .string => {
            if (!payload_only) {
                try writer.writeByte(8);
                try writer.writeIntBig(u16, @intCast(u16, tag.string.name.len));
                try writer.writeAll(tag.string.name);
            }
            try writer.writeIntBig(u16, @intCast(u16, tag.string.payload.len));
            try writer.writeAll(tag.string.payload);
        },
        .list => {
            if (!payload_only) {
                try writer.writeByte(9);
                try writer.writeIntBig(u16, @intCast(u16, tag.list.name.len));
                try writer.writeAll(tag.list.name);
            }
            if (tag.list.payload.len <= 0) {
                try writer.writeByte(0);
                try writer.writeIntBig(i32, @intCast(i32, tag.list.payload.len));
            } else {
                try writer.writeByte(@enumToInt(tag.list.payload[0]));
                try writer.writeIntBig(i32, @intCast(i32, tag.list.payload.len));
                for (tag.list.payload) |t| try writeTag(writer, t, true);
            }
        },
        .compound => {
            if (!payload_only) {
                try writer.writeByte(10);
                try writer.writeIntBig(u16, @intCast(u16, tag.compound.name.len));
                try writer.writeAll(tag.compound.name);
            }
            for (tag.compound.payload) |t| try writeTag(writer, t, false);
            try writer.writeByte(0);
        },
        .int_array => {
            if (!payload_only) {
                try writer.writeByte(11);
                try writer.writeIntBig(u16, @intCast(u16, tag.int_array.name.len));
                try writer.writeAll(tag.int_array.name);
            }
            try writer.writeIntBig(i32, @intCast(i32, tag.int_array.payload.len));
            for (tag.int_array.payload) |int| try writer.writeIntBig(i32, int);
        },
        .long_array => {
            if (!payload_only) {
                try writer.writeByte(12);
                try writer.writeIntBig(u16, @intCast(u16, tag.long_array.name.len));
                try writer.writeAll(tag.long_array.name);
            }
            try writer.writeIntBig(i32, @intCast(i32, tag.long_array.payload.len));
            for (tag.long_array.payload) |long| try writer.writeIntBig(i64, long);
        },
    }
}

pub fn printIndent(writer: anytype, indent: u8) anyerror!void {
    var i = @intCast(u8, 0);
    while (i < indent) : (i += 1) {
        try writer.print("\t", .{});
    }
}

pub fn printTag(tag: Tag, writer: anytype, payload_only: bool, indent: u8) anyerror!void {
    try printIndent(writer, indent);
    switch (tag) {
        .end => return,
        .byte => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{}\n", .{tag_type.payload});
        },
        .short => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{}\n", .{tag_type.payload});
        },
        .int => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{}\n", .{tag_type.payload});
        },
        .long => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{}\n", .{tag_type.payload});
        },
        .float => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{}\n", .{tag_type.payload});
        },
        .double => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{}\n", .{tag_type.payload});
        },
        .byte_array => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("[{} bytes]\n", .{tag_type.payload.len});
        },
        .string => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{s}\n", .{tag_type.payload});
        },
        .list => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            if (tag_type.payload.len <= 0) {
                return;
            } else {
                try writer.print("{} entries of type TAG_{s}:\n", .{ tag_type.payload.len, std.meta.tagName(std.meta.activeTag(tag_type.payload[0])) });
                try printIndent(writer, indent);
                try writer.print("{s}\n", .{"{"});
                for (tag_type.payload) |t| try printTag(t, writer, true, indent + 1);
                try printIndent(writer, indent);
                try writer.print("{s}\n", .{"}"});
            }
        },
        .compound => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("{} entries\n", .{tag_type.payload.len});
            try printIndent(writer, indent);
            try writer.print("{s}\n", .{"{"});
            for (tag_type.payload) |t| try printTag(t, writer, false, indent + 1);
            try printIndent(writer, indent);
            try writer.print("{s}\n", .{"}"});
        },
        .int_array => |tag_type| {
            try writer.print("TAG_{s} ", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("[{}] {any}\n", .{ tag_type.payload.len, tag_type.payload });
        },
        .long_array => |tag_type| {
            try writer.print("TAG_{s}", .{std.meta.tagName(std.meta.activeTag(tag))});
            if (!payload_only) {
                try writer.print("('{s}'): ", .{tag_type.name});
            }
            try writer.print("[{}] {any}\n", .{ tag_type.payload.len, tag_type.payload });
        },
    }
}
const testing = std.testing;

test "deserialize big test" {
    var in = gzipBigTest;

    var a = testing.allocator;
    var aa = std.heap.ArenaAllocator.init(a);
    var fixedBuf = io.FixedBufferStream([]const u8){ .buffer = in, .pos = 0 };
    var reader = fixedBuf.reader();
    var inflated = try std.compress.gzip.gzipStream(&aa.allocator, reader);
    const inf_reader = inflated.reader();

    const tag = try readTag(inf_reader, &aa.allocator, false, 0);
    var list = std.ArrayList(u8).init(&aa.allocator);

    try printTag(tag, list.writer(), false, 0);

    const v = list.toOwnedSlice();
    std.log.warn("\n{s}", .{v});

    try testing.expectEqualStrings(tag.compound.name, "Level");
    aa.deinit();
}

test "serialize big test" {
    var a = testing.allocator;
    var aa = std.heap.ArenaAllocator.init(a);

    var list = std.ArrayList(u8).init(&aa.allocator);
    try writeTag(list.writer(), bigNBT, false);
    try testing.expect(true);
    aa.deinit();
}

// zig fmt: off
const bigNBT = Tag{
    .compound = .{
        .name = "Level",
        .payload = &[_]Tag{
            .{
                .long = .{
                    .name = "longTest",
                    .payload = @intCast(i64, 9223372036854775807)
                },
                },
            .{
                .float = .{
                    .name = "floatTest",
                    .payload = @as(f32, 0.49823147058486938)
                },
                },
            .{
                .double = .{
                    .name = "doubleTest",
                    .payload = @as(f64, 0.49312871321823148)
                },
                },
            .{
                .byte = .{
                    .name = "byteTest",
                    .payload = @intCast(i8, 127)
                },
                },
            .{
                .int = .{
                    .name = "intTest",
                    .payload = @intCast(i32, 2147483647)
                },
                },
            .{
                .short = .{
                    .name = "shortTest",
                    .payload = @intCast(i16, 32767)
                },
                },
            .{
                .list = .{
                    .name = "listTest (long)",
                    .payload = &[_]Tag{
                        .{.long = .{ .name = "", .payload = @intCast(i64, 11) }},
                        .{.long = .{ .name = "", .payload = @intCast(i64, 12) }},
                        .{.long = .{ .name = "", .payload = @intCast(i64, 13) }},
                        .{.long = .{ .name = "", .payload = @intCast(i64, 14) }},
                        .{.long = .{ .name = "", .payload = @intCast(i64, 15) }},
                    }
                },
                },
            .{
                .compound = .{
                    .name = "nested compound test",
                    .payload = &[_]Tag{
                        .{
                            .compound = .{
                                .name = "egg",
                                .payload = &[_]Tag{
                                    .{
                                        .string = .{
                                            .name = "name",
                                            .payload = "Eggbert"
                                        },
                                        },
                                    .{
                                        .float = .{
                                            .name = "floatTest",
                                            .payload = @as(f32, 0.5)
                                        }

                                    },
                                }
                            },
                            },
                        .{
                            .compound = .{
                                .name = "ham",
                                .payload = &[_]Tag{
                                    .{
                                        .string = .{
                                            .name = "name",
                                            .payload = "Hampus"
                                        },
                                        },
                                    .{
                                        .float = .{
                                            .name = "floatTest",
                                            .payload = @as(f32, 0.75)
                                        },
                                        },
                                    }
                                },
                            }
                        },
                        },
                    },
                    .{
                        .list = .{
                            .name = "listTest (compound)",
                            .payload = &[_]Tag{
                                .{
                                    .compound = .{
                                        .name = "",
                                        .payload = &[_]Tag{
                                            .{
                                                .long = .{
                                                    .name = "created-on",
                                                    .payload = @intCast(i64, 1264099775885)
                                                }
                                            },
                                            .{
                                                .string= .{
                                                    .name = "name",
                                                    .payload = "Compound tag #0"
                                                },

                                                },
                                            }
                                    }
                                },
                                .{
                                    .compound = .{
                                        .name = "",
                                        .payload = &[_]Tag{
                                            .{
                                                .long = .{
                                                    .name = "created-on",
                                                    .payload = @intCast(i64, 1264099775885)
                                                }
                                            },
                                            .{
                                                .string= .{
                                                    .name = "name",
                                                    .payload = "Compound tag #1"
                                                },

                                                },
                                            }
                                    }
                                },
                            }
                        }
                    },
                    .{
                        .byte_array = .{
                            .name = "byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))",
                            .payload = firstThousandBytes
                        }
                    },
                }
    }
};
// zig fmt: on

const gzipBigTest = &[_]u8{ 0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xed, 0x54, 0xcf, 0x4f, 0x1a, 0x41, 0x14, 0x7e, 0xc2, 0x02, 0xcb, 0x96, 0x82, 0xb1, 0xc4, 0x10, 0x63, 0xcc, 0xab, 0xb5, 0x84, 0xa5, 0xdb, 0xcd, 0x42, 0x11, 0x89, 0xb1, 0x88, 0x16, 0x2c, 0x9a, 0x0d, 0x1a, 0xd8, 0xa8, 0x31, 0x86, 0xb8, 0x2b, 0xc3, 0x82, 0x2e, 0xbb, 0x66, 0x77, 0xb0, 0xf1, 0xd4, 0x4b, 0x7b, 0x6c, 0x7a, 0xeb, 0x3f, 0xd3, 0x23, 0x7f, 0x43, 0xcf, 0xbd, 0xf6, 0xbf, 0xa0, 0xc3, 0x2f, 0x7b, 0x69, 0xcf, 0xbd, 0xf0, 0x32, 0xc9, 0xf7, 0xe6, 0xbd, 0x6f, 0xe6, 0x7b, 0x6f, 0x26, 0x79, 0x02, 0x04, 0x54, 0x72, 0x4f, 0x2c, 0x0e, 0x78, 0xcb, 0xb1, 0x4d, 0x8d, 0x78, 0xf4, 0xe3, 0x70, 0x62, 0x3e, 0x08, 0x7b, 0x1d, 0xc7, 0xa5, 0x93, 0x18, 0x0f, 0x82, 0x47, 0xdd, 0xee, 0x84, 0x02, 0x62, 0xb5, 0xa2, 0xaa, 0xc7, 0x78, 0x76, 0x5c, 0x57, 0xcb, 0xa8, 0x55, 0x0f, 0x1b, 0xc8, 0xd6, 0x1e, 0x6a, 0x95, 0x86, 0x86, 0x0d, 0xad, 0x7e, 0x58, 0x7b, 0x8f, 0x83, 0xcf, 0x83, 0x4f, 0x83, 0x6f, 0xcf, 0x03, 0x10, 0x6e, 0x5b, 0x8e, 0x3e, 0xbe, 0xa5, 0x38, 0x4c, 0x64, 0xfd, 0x10, 0xea, 0xda, 0x74, 0xa6, 0x23, 0x40, 0xdc, 0x66, 0x2e, 0x69, 0xe1, 0xb5, 0xd3, 0xbb, 0x73, 0xfa, 0x76, 0x0b, 0x29, 0xdb, 0x0b, 0xe0, 0xef, 0xe8, 0x3d, 0x1e, 0x38, 0x5b, 0xef, 0x11, 0x08, 0x56, 0xf5, 0xde, 0x5d, 0xdf, 0x0b, 0x40, 0xe0, 0x5e, 0xb7, 0xfa, 0x64, 0xb7, 0x04, 0x00, 0x8c, 0x41, 0x4c, 0x73, 0xc6, 0x08, 0x55, 0x4c, 0xd3, 0x20, 0x2e, 0x7d, 0xa4, 0xc0, 0xc8, 0xc2, 0x10, 0xb3, 0xba, 0xde, 0x58, 0x0b, 0x53, 0xa3, 0xee, 0x44, 0x8e, 0x45, 0x03, 0x30, 0xb1, 0x27, 0x53, 0x8c, 0x4c, 0xf1, 0xe9, 0x14, 0xa3, 0x53, 0x8c, 0x85, 0xe1, 0xd9, 0x9f, 0xe3, 0xb3, 0xf2, 0x44, 0x81, 0xa5, 0x7c, 0x33, 0xdd, 0xd8, 0xbb, 0xc7, 0xaa, 0x75, 0x13, 0x5f, 0x28, 0x1c, 0x08, 0xd7, 0x2e, 0xd1, 0x59, 0x3f, 0xaf, 0x1d, 0x1b, 0x60, 0x21, 0x59, 0xdf, 0xfa, 0xf1, 0x05, 0xfe, 0xc1, 0xce, 0xfc, 0x9d, 0xbd, 0x00, 0xbc, 0xf1, 0x40, 0xc9, 0xf8, 0x85, 0x42, 0x40, 0x46, 0xfe, 0x9e, 0xeb, 0xea, 0x0f, 0x93, 0x3a, 0x68, 0x87, 0x60, 0xbb, 0xeb, 0x32, 0x37, 0xa3, 0x28, 0x0a, 0x8e, 0xbb, 0xf5, 0xd0, 0x69, 0x63, 0xca, 0x4e, 0xdb, 0xe9, 0xec, 0xe6, 0xe6, 0x2b, 0x3b, 0xbd, 0x25, 0xbe, 0x64, 0x49, 0x09, 0x3d, 0xaa, 0xbb, 0x94, 0xfd, 0x18, 0x7e, 0xe8, 0xd2, 0x0e, 0xda, 0x6f, 0x15, 0x4c, 0xb1, 0x68, 0x3e, 0x2b, 0xe1, 0x9b, 0x9c, 0x84, 0x99, 0xbc, 0x84, 0x05, 0x09, 0x65, 0x59, 0x16, 0x45, 0x00, 0xff, 0x2f, 0x28, 0xae, 0x2f, 0xf2, 0xc2, 0xb2, 0xa4, 0x2e, 0x1d, 0x20, 0x77, 0x5a, 0x3b, 0xb9, 0x8c, 0xca, 0xe7, 0x29, 0xdf, 0x51, 0x41, 0xc9, 0x16, 0xb5, 0xc5, 0x6d, 0xa1, 0x2a, 0xad, 0x2c, 0xc5, 0x31, 0x7f, 0xba, 0x7a, 0x92, 0x8e, 0x5e, 0x9d, 0x5f, 0xf8, 0x12, 0x05, 0x23, 0x1b, 0xd1, 0xf6, 0xb7, 0x77, 0xaa, 0xcd, 0x95, 0x72, 0xbc, 0x9e, 0xdf, 0x58, 0x5d, 0x4b, 0x97, 0xae, 0x92, 0x17, 0xb9, 0x44, 0xd0, 0x80, 0xc8, 0xfa, 0x3e, 0xbf, 0xb3, 0xdc, 0x54, 0xcb, 0x07, 0x75, 0x6e, 0xa3, 0xb6, 0x76, 0x59, 0x92, 0x93, 0xa9, 0xdc, 0x51, 0x50, 0x99, 0x6b, 0xcc, 0x35, 0xe6, 0x1a, 0xff, 0x57, 0x23, 0x08, 0x42, 0xcb, 0xe9, 0x1b, 0xd6, 0x78, 0xc2, 0xec, 0xfe, 0xfc, 0x7a, 0xfb, 0x7d, 0x78, 0xd3, 0x84, 0xdf, 0xd4, 0xf2, 0xa4, 0xfb, 0x08, 0x06, 0x00, 0x00 };

const firstThousandBytes = &[_]u8{ 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30, 0x0, 0x3e, 0x22, 0x10, 0x8, 0xa, 0x16, 0x2c, 0x4c, 0x12, 0x46, 0x20, 0x4, 0x56, 0x4e, 0x50, 0x5c, 0xe, 0x2e, 0x58, 0x28, 0x2, 0x4a, 0x38, 0x30, 0x32, 0x3e, 0x54, 0x10, 0x3a, 0xa, 0x48, 0x2c, 0x1a, 0x12, 0x14, 0x20, 0x36, 0x56, 0x1c, 0x50, 0x2a, 0xe, 0x60, 0x58, 0x5a, 0x2, 0x18, 0x38, 0x62, 0x32, 0xc, 0x54, 0x42, 0x3a, 0x3c, 0x48, 0x5e, 0x1a, 0x44, 0x14, 0x52, 0x36, 0x24, 0x1c, 0x1e, 0x2a, 0x40, 0x60, 0x26, 0x5a, 0x34, 0x18, 0x6, 0x62, 0x0, 0xc, 0x22, 0x42, 0x8, 0x3c, 0x16, 0x5e, 0x4c, 0x44, 0x46, 0x52, 0x4, 0x24, 0x4e, 0x1e, 0x5c, 0x40, 0x2e, 0x26, 0x28, 0x34, 0x4a, 0x6, 0x30 };
