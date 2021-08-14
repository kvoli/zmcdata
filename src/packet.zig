const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const io = std.io;

const zlib = std.compress.zlib;

const utils = @import("utils.zig");
const Serde = @import("serde.zig").Serde;
const types = @import("types.zig");

const vi32 = types.vi32;

/// generic packet
/// s2c packets do not own the data
/// c2s packets own the data
pub const Packet = struct {
    length: i32,
    id: u8,
    data: []u8,

    // false when reading, true when writing
    read_write: bool,
    raw_data: []u8,
    cthreshed: bool,

    pub fn init(alloc: *Allocator) !*Packet {
        const packet = try alloc.create(Packet);
        packet.* = .{
            .length = 0,
            .id = 0xFF,
            .data = undefined,

            .read_write = false,
            .raw_data = undefined,
            .cthreshed = false,
        };
        return packet;
    }

    pub fn encode(self: *Packet, alloc: *Allocator, wr: anytype, cthresh: i32) !void {
        if (cthresh >= 0) {
            // compression has been updated from default (-1)
            // use updated packet format and set compression to be 0
            try utils.writeVarInt(wr, self.length + 1);
            try wr.writeByte(0x00);
        } else {
            try utils.writeVarInt(wr, self.length);
        }
        try wr.writeByte(self.id);
        try wr.writeAll(self.data);
    }

    pub fn decode(alloc: *Allocator, rd: anytype, cthresh: i32) !*Packet {
        var packet_length = try utils.readVarInt(rd);
        if (cthresh >= 0) {
            // bug here on data_length - trying to read too much
            const data_length = try utils.readVarIntCounter(rd);
            const decompressed_size = data_length[0];
            const bytes_read = data_length[1];
            packet_length -= bytes_read;
            if (decompressed_size > 0) {
                return try compressedDecode(alloc, rd, decompressed_size, packet_length);
            }
        }
        const data = try utils.readByteArray(alloc, rd, packet_length);

        const packet = try alloc.create(Packet);
        packet.* = .{
            .length = packet_length,
            .id = data[0],
            .data = data[1..],

            .read_write = false,
            .raw_data = data,
            .cthreshed = (cthresh > 0),
        };
        return packet;
    }

    pub fn redecode(self: *Packet, alloc: *Allocator, cthresh: i32) !void {
        // we decoded assuming no thresh, but there was thresh
        if (cthresh >= 0 and !self.cthreshed) {
            const rd = std.io.fixedBufferStream(self.raw_data).reader();
            const data_length = try utils.readVarIntCounter(rd);
            var data: []u8 = undefined;

            if (data_length[0] > 0) {
                data = try utils.readByteArray(alloc, (try zlib.zlibStream(alloc, rd)).reader(), data_length[0]);
                self.length = data_length[0];
            } else {
                data = self.raw_data[1..];
            }
            self.data = data[1..];
            self.id = data[0];
        }
    }

    fn compressedDecode(alloc: *Allocator, rd: anytype, data_length: i32, packet_length: i32) !*Packet {
        const compressed_data = try utils.readByteArray(alloc, rd, packet_length);

        var zlibStream = try zlib.zlibStream(alloc, io.fixedBufferStream(compressed_data).reader());
        const data = try utils.readByteArray(alloc, zlibStream.reader(), data_length);

        const packet = try alloc.create(Packet);
        packet.* = .{
            .length = data_length,
            .id = data[0],
            .data = data[1..],

            .read_write = false,
            .raw_data = compressed_data,
            .cthreshed = true,
        };
        return packet;
    }

    pub fn deinit(self: *Packet, alloc: *Allocator) void {
        if (!self.read_write) {
            if (self.id != 0xFF) alloc.free(self.raw_data);
        } else {
            if (self.id != 0xFF) alloc.free(self.data);
        }
        alloc.destroy(self);
    }

    pub fn copy(self: *Packet, alloc: *Allocator) !*Packet {
        const data = if (self.read_write) try alloc.dupe(u8, self.data) else try alloc.dupe(u8, self.raw_data);

        const packet = try alloc.create(Packet);
        packet.* = .{
            .length = self.length,
            .id = self.id,
            .data = if (self.read_write) data else data[1..],

            .read_write = self.read_write,
            .raw_data = if (self.read_write) undefined else data,
            .cthreshed = self.cthreshed,
        };
        return packet;
    }

    pub fn toStream(self: *Packet) io.FixedBufferStream([]u8) {
        return io.fixedBufferStream(self.data);
    }

    pub fn format(self: *const Packet, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        try std.fmt.format(writer, "Packet{{{}, 0x{x}}}", .{ self.length, self.id });
    }
};

/// Given some type T, which should be a pointer to a packet type
/// return the default (de)serialization protocol wrapper
///
/// Tries to default serialize and deserialize all types using serde.default(De)Serialize()
/// Shouldn't be used when there are multiple user defined types without .serialize implemented
pub fn defaultProto(comptime T: type) @TypeOf(WireProto(T, Serde(T).ser, Serde(T).de)) {
    return WireProto(T, Serde(T).ser, Serde(T).de);
}

pub fn gen(comptime T: type, comptime R: type, declID: u8) type {
    return struct {
        pub fn ser(ctx: *T) R {
            return .{ .context = ctx, .packet_id = id };
        }

        pub fn de(base: *Packet) R {
            return .{ .base = base, .packet_id = id };
        }

        pub const id = declID;
    };
}

pub fn WireProto(
    comptime Context: type,
    comptime serializeFn: fn (context: Context, writer: anytype, alloc: *Allocator) anyerror!void,
    comptime deserializeFn: fn (context: Context, reader: anytype, alloc: *Allocator) anyerror!void,
) type {
    return struct {
        context: Context = undefined,
        base: *Packet = undefined,
        packet_id: u8,

        const Self = @This();

        pub fn encode(self: *Self, alloc: *Allocator) !*Packet {
            self.base = try Packet.init(alloc);
            self.base.id = self.packet_id;
            self.base.read_write = true;

            var array_list = std.ArrayList(u8).init(alloc);
            defer array_list.deinit();

            try serializeFn(self.context, array_list.writer(), alloc);

            self.base.data = array_list.toOwnedSlice();
            self.base.length = @intCast(i32, self.base.data.len) + 1;

            return self.base;
        }

        pub fn decode(self: *Self, alloc: *Allocator) !Context {
            const brd = self.base.toStream().reader();
            const base = try alloc.create(@typeInfo(Context).Pointer.child);

            try deserializeFn(base, brd, alloc);

            return base;
        }
    };
}

const testing = std.testing;
const a = testing.allocator;

test "does init" {
    _ = @import("utils.zig");
}

const TestDefaultPacket = struct {
    protocol_version: vi32,
    server_address: []const u8,
    server_port: u16,

    usingnamespace gen(@This(), defaultProto(*@This()), 0x00);

    pub fn deinit(self: *@This(), alloc: *Allocator) void {
        alloc.free(self.server_address);
        alloc.destroy(self);
    }
};

test "encode datastruct" {
    var handshakePacket = TestDefaultPacket{
        .protocol_version = .{ .int = 1 },
        .server_address = "127.0.0.1",
        .server_port = 25565,
    };

    var s = handshakePacket.serializer();
    var pkt = try s.encode(a);
    defer pkt.deinit(a);
    try testing.expectEqual(pkt.id, TestDefaultPacket.id);
}

test "decode packet to datastruct" {
    var pkt = try Packet.init(a);
    defer pkt.deinit(a);

    var array_list = std.ArrayList(u8).init(a);
    defer array_list.deinit();

    const writer = array_list.writer();

    try utils.writeVarInt(writer, @intCast(i32, 1));
    try utils.writeByteArray(writer, "127.0.0.1");
    try writer.writeIntBig(u16, @intCast(u16, 25565));

    pkt.read_write = true;
    pkt.id = 0x00;
    pkt.data = array_list.toOwnedSlice();
    pkt.length = @intCast(i32, pkt.data.len) + 1;

    // attempt to decode the packet
    var s = TestDefaultPacket.deserializer(pkt);
    var handshakePacket = try s.decode(a);
    defer handshakePacket.deinit(a);

    try testing.expectEqual(handshakePacket.protocol_version, .{ .int = 1 });
    try testing.expectEqualStrings(handshakePacket.server_address, "127.0.0.1");
    try testing.expectEqual(handshakePacket.server_port, 25565);
}
