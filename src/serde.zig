const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const utils = @import("utils.zig");

const SerializationError = error{
    NoAutoSerialized,
};

pub fn primativeSerialize(value: anytype, writer: anytype) anyerror!void {
    switch (@TypeOf(value)) {
        bool => try writer.writeByte(@boolToInt(value)),
        u8 => try writer.writeByte(value),
        i16, i32, i64, i128, u16, u32, u64, u128 => |t| try writer.writeIntBig(t, value),
        f32 => try writer.writeIntBig(i32, @floatToInt(i32, value)),
        f64 => try writer.writeIntBig(i64, @floatToInt(i64, value)),
        else => SerializationError.NoAutoSerialized,
    }
}

pub fn primativeDeserialize(comptime T: type, reader: anytype) anyerror!T {
    switch (T) {
        bool => return ((try reader.readByte()) == 1),
        u8 => return try reader.readByte(),
        i16, i32, i64, i128, u16, u32, u64, u128 => |t| return try reader.readIntBig(t),
        f32 => return @bitCast(f32, try reader.readIntBig(i32)),
        f64 => return @bitCast(f64, try reader.readIntBig(i64)),
        else => return SerializationError.NoAutoSerialized,
    }
}

// we want to have a two funcs:
// (ctx: Context, writer: anytype, alloc: *Allocator) anyerror!void
// (ctx: Context, reader: anytype, alloc: *Allocator) anyerror!void
pub fn Serde(comptime Context: type) type {
    return struct {
        pub fn ser(context: Context, writer: anytype, alloc: *Allocator) anyerror!void {
            try defaultSerialize(context, writer, alloc);
        }

        pub fn de(context: Context, reader: anytype, alloc: *Allocator) anyerror!void {
            context.* = try defaultDeserialize(@typeInfo(Context).Pointer.child, reader, alloc);
        }
    };
}

/// Takes an type value, an anytype implementing the io.Writer iface, and an allocator
/// reads the value into a (default stack) const using a default method or returns SerializationError
///
/// if a fn deserialize(reader: anytype, alloc: *Allocator) anyerror!Context exists
/// use that instead (only for struct and union types)
pub fn defaultDeserialize(comptime T: type, reader: anytype, alloc: *Allocator) anyerror!T {
    switch (@typeInfo(T)) {
        .Bool, .Int, .ComptimeInt, .Float, .ComptimeFloat => return try primativeDeserialize(T, reader),
        .Struct => |struct_info| {
            switch (@hasDecl(T, "deserialize")) {
                true => return try T.deserialize(reader, alloc),
                false => {
                    var value = std.mem.zeroes(T);
                    inline for (struct_info.fields) |field| {
                        @field(value, field.name) = try defaultDeserialize(field.field_type, reader, alloc);
                    }
                    return value;
                },
            }
        },
        .Union => |union_info| {
            switch (@hasDecl(T, "deserialize")) {
                true => return try T.deserialize(reader, alloc),
                false => {
                    // will attempt to read an enum (u8) tag to decide what to do next, else undecidable
                    if (union_info.tag_type) |UnionTag| {
                        const enumTag = try std.meta.intToEnum(UnionTag, try reader.readByte());
                        inline for (union_info.fields) |field| {
                            if (@field(UnionTag, field.name) == enumTag) {
                                return @unionInit(T, field.name, try defaultDeserialize(field.field_type, reader, alloc));
                            }
                        }
                    }
                    return SerializationError.NoAutoSerialized;
                },
            }
        },
        .Enum => |struct_info| {
            switch (@hasDecl(T, "deserialize")) {
                true => return try T.deserialize(reader, alloc),
                false => {
                    // only works with int types -- need to add assertion / check here
                    return @intToEnum(T, try defaultDeserialize(struct_info.tag_type, reader, alloc));
                },
            }
        },
        .Pointer => |ptr_info| {
            switch (ptr_info.size) {
                .Slice => {
                    switch (ptr_info.child) {
                        u8 => return try utils.readVarByteArray(alloc, reader),
                        else => |child_type| {
                            const len = try utils.readVarInt(reader);
                            var value = std.mem.zeroes([len]child_type);
                            inline for (value) |v, i| {
                                value[i] = try defaultDeserialize(child_type, reader, alloc);
                            }
                            return value;
                        },
                    }
                },
                .One => {
                    switch (@hasDecl(ptr_info.child, "deserialize")) {
                        true => return try T.deserialize(reader, alloc),
                        false => return try defaultDeserialize(ptr_info.child, reader, alloc),
                    }
                },
                else => return SerializationError.NoAutoSerialized,
            }
        },
        .Optional => |opt_info| {
            switch (try reader.readByte()) {
                0 => return null,
                1 => return try defaultDeserialize(opt_info.child, reader, alloc),
                else => return SerializationError.NoAutoSerialized,
            }
        },
        else => return SerializationError.NoAutoSerialized,
    }
}

/// Takes an anytype value, and an antype implementing the io.Writer iface
/// writes the value into the writer using a default method or returns SerializationError
pub fn defaultSerialize(value: anytype, writer: anytype, alloc: *Allocator) anyerror!void {
    switch (@typeInfo(@TypeOf(value))) {
        .Bool, .Int, .ComptimeInt, .Float, .ComptimeFloat => return try primativeSerialize(value, writer),
        .Struct => |struct_info| {
            switch (@hasDecl(@TypeOf(value), "serialize")) {
                true => try value.serialize(writer, alloc),
                false => inline for (struct_info.fields) |field| {
                    try defaultSerialize(@field(value, field.name), writer, alloc);
                },
            }
        },
        .Enum => |struct_info| {
            switch (@hasDecl(@TypeOf(value), "serialize")) {
                true => return try value.serialize(writer),
                false => {
                    // only works with int types -- need to add assertion / check here
                    try defaultSerialize(@enumToInt(value), writer, alloc);
                },
            }
        },
        .Union => |union_info| {
            switch (@hasDecl(@TypeOf(value), "serialize")) {
                true => try value.serialize(writer),
                false => {
                    const activeTag = std.meta.activeTag(value);
                    if (union_info.tag_type) |UnionTag| {
                        inline for (union_info.fields) |field| {
                            if (@field(UnionTag, field.name) == activeTag) {
                                return try defaultSerialize(@field(value, field.name), writer, alloc);
                            }
                        }
                    }
                },
            }
        },
        .Pointer => |ptr_info| {
            switch (ptr_info.size) {
                .Slice => {
                    switch (ptr_info.child) {
                        u8 => try utils.writeByteArray(writer, value),
                        else => {
                            try utils.writeVarInt(writer, std.mem.len(value));
                            inline for (values) |v| {
                                try defaultSerialize(v, writer, alloc);
                            }
                        },
                    }
                },
                .One => {
                    switch (@hasDecl(ptr_info.child, "serialize")) {
                        true => try value.serialize(writer),
                        false => try defaultSerialize(value.*, writer, alloc),
                    }
                },
                else => return SerializationError.NoAutoSerialized,
            }
        },
        .Optional => |opt_info| {
            if (value) |v| {
                try writer.writeByte(1);
                try defaultSerialize(v, writer, alloc);
            } else try writer.writeByte(0);
        },
        else => return SerializationError.NoAutoSerialized,
    }
}
