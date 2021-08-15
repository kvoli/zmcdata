const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const utils = @import("utils.zig");
const zlm = @import("zlm");

pub fn Array(comptime countType: type, comptime fieldType: type) type {
    return struct {
        count_type: type,
        fields: []fieldType,
    };
}

// for types where the match is not necessarily directly above
pub fn Match(match: []const u8, comptime T: type) type {
    return struct {
        fields: T,

        pub fn serialize(self: Self, writer: anytype, alloc: *Allocator) anyerror!void {
            try utils.writeVarInt(writer, in(self.int));
        }

        pub fn deserialize(reader: anytype, alloc: *Allocator) anyerror!Self {
            return @This(){ .int = out(try utils.readVarInt(reader)) };
        }
    };
}

/// switch packets that need to be handled
/// =============================
///
/// packet_advancements
/// -----------------------------
///
///     switchType: bitfield
///     directlyAbove: true
///
/// packet_declare_commands
/// -----------------------------
///
///     switchType: bitfield
///     directlyAbove: false **
///
/// packet_boss_bar
/// -----------------------------
///
///     switchType: varint
///     directlyAbove: true
///
/// packet_face_player
/// -----------------------------
///
///     switchType: bool
///     directlyAbove: true
///
/// packet_map
/// -----------------------------
///
///     switchType: u8
///     directlyAbove: true
///
/// packet_player_info
/// -----------------------------
///
///     switchType: varint
///     directlyAbove: false - nested scope above  **
///
/// packet_unlock_recipes
/// -----------------------------
///
///     switchType: varint
///     directlyAbove: false **
///
/// packet_scoreboard_objective
/// -----------------------------
///
///     switchType: i8
///     directlyAbove: true
///
/// packet_teams
/// -----------------------------
///
///     switchType: i8
///     directlyAbove: true
///
/// packet_scoreboard_score
/// -----------------------------
///
///     switchType: i8
///     directlyAbove: true
///
/// packet_stop_sound
/// -----------------------------
///
///     switchType: i8
///     directlyAbove: true
///
/// packet_declare_recipes
/// -----------------------------
///
///     switchType: string
///     directlyAbove: true
///
/// packet_sculk_vibration_signal
/// -----------------------------
///
///     switchType: string
///     directlyAbove: true
///
/// string -> union(enum) {  }
/// i8/varint/u8 -> union(enum(u8)) {  }
/// bitfield -> SwitchType makes sense here.
pub fn SwitchType(comptime compareType: type, comptime fields: type) type {
    return struct {};
}

pub fn VarInt(comptime T: type, in: fn (v: T) i32, out: fn (v: i32) T) type {
    return struct {
        int: T,

        const Self = @This();

        pub fn serialize(self: Self, writer: anytype, alloc: *Allocator) anyerror!void {
            try utils.writeVarInt(writer, in(self.int));
        }

        pub fn deserialize(reader: anytype, alloc: *Allocator) anyerror!Self {
            return @This(){ .int = out(try utils.readVarInt(reader)) };
        }
    };
}

// providing default implementations for primative number types
//
// user specific types can be defined above with VarInt(), passing
// an in, out and type func in
pub const vu8 = VarInt(u8, VarI(u8).in, VarI(u8).out);
pub const vu16 = VarInt(u16, VarI(u16).in, VarI(u16).out);
pub const vu32 = VarInt(u32, VarI(u32).in, VarI(u32).out);
pub const vu64 = VarInt(u64, VarI(u64).in, VarI(u64).out);
pub const vusize = VarInt(usize, VarI(usize).in, VarI(usize).out);
pub const vu128 = VarInt(u128, VarI(u128).in, VarI(u128).out);

pub const vi8 = VarInt(i8, VarI(i8).in, VarI(i8).out);
pub const vi16 = VarInt(i16, VarI(i16).in, VarI(i16).out);
pub const vi32 = VarInt(i32, VarI(i32).in, VarI(i32).out);
pub const vi64 = VarInt(i64, VarI(i64).in, VarI(i64).out);
pub const visize = VarInt(isize, VarI(isize).in, VarI(isize).out);
pub const vi128 = VarInt(i128, VarI(i128).in, VarI(i128).out);
pub const vf32 = VarInt(f32, fn (v: f32) i32{return @bitCast(i32, v)}, fn (v: i32) f32{return @bitCast(f32, v)});

fn VarI(comptime T: type) type {
    return struct {
        pub fn in(v: T) i32 {
            return @intCast(i32, v);
        }
        pub fn out(v: i32) T {
            return @intCast(T, v);
        }
    };
}

const testing = std.testing;
const a = testing.allocator;

test "i32 varint Test" {
    var array_list = std.ArrayList(u8).init(a);
    defer array_list.deinit();
    const writer = array_list.writer();

    const start = vi32{ .int = 1 };

    try start.serialize(writer);

    const data = array_list.toOwnedSlice();
    defer a.free(data);

    const reader = std.io.fixedBufferStream(data).reader();

    const end = try vi32.deserialize(reader, a);

    try testing.expectEqual(end.int, start.int);
}
