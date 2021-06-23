const std = @import("std");
const json = std.json;

pub fn Native(comptime T: type) type {
    return struct {
        field: T,
    };
}

pub const vi32 = struct {};
pub const UUID = struct {};
pub const pstring = struct {};
pub const string = struct {};
pub const RestBuffer = struct {};
pub const EntityMetaDataLoop = struct {};
pub const Slot = struct {};
pub const Particle = struct {};
pub const ParticleData = struct {};
pub const Ingredient = struct {};
pub const EntityMetaDataItem = struct {};
pub const EntityMetaData = struct {};
pub const NBT = union(enum(u8)) {};
pub const PString = struct {};
pub const Void = struct {};
pub const Buffer = struct {};

pub fn Option(comptime T: type) type {
    return struct {
        inner: T,
    };
}
pub const BitField = struct { items: []struct {
    size: Native(bool),
    signed: Native(bool),
} };
pub const TopBitTerminatedArray = struct {};

pub const Container = struct {
    fields: []Field,

    pub fn parse(stream: std.json.TokenStream, json: []const u8, alloc: *std.mem.Allocator) !Container {
        var fields = std.ArrayList(Field).init(alloc);
        while (try stream.next()) |tok| {
            switch (tok) {
                .String => |t| {},
                .ObjectBegin => {},
                .ObjectEnd => {},
                else => {},
            }
        }

        var ret = try alloc.create(Container);
        ret.* = .{
            .fields = fields.toOwnedSlice(),
        };
        return ret;
    }
};

pub const Switch = struct {};
pub const Array = struct {
    items: []FieldType,
};

pub fn Native(comptime T: type) type {
    return struct {
        field: T,
    };
}

pub const FieldType = union(enum) {
    end: Void,
    varint: vi32,
    optvarint: Option(vi32),
    pstring: PString,
    ushort: Native(u16),
    ubytes: Native(u8),
    long: Native(i64),
    buffer: Buffer,
    int: Native(i32),
    byte: Native(i8),
    boolean: Native(bool),
    short: Native(i16),
    float: Native(f32),
    double: Native(f64),
    UUID: UUID,
    option: Option(void),
    entityMetadataLoop: EntityMetaDataLoop,
    topBitSetTerminatedArray: TopBitTerminatedArray,
    bitfield: BitField,
    container: Container,
    switched: Switch,
    array: Array,
    restBuffer: RestBuffer,
    nbt: NBT,
    optionalNbt: Option(NBT),
    slot: Slot,
    particle: Particle,
    ingredient: Ingredient,
    entityMetadata: EntityMetaData,
};

pub const AST = struct {
    types: struct {},
    handshaking: StateSet,
    status: StateSet,
    login: StateSet,
    play: StateSet,
};

pub const StateSet = struct {
    toClient: []PacketSet,
    toServer: []PacketSet,
};

pub const PacketSet = struct {
    types: []Packet,
};

pub const Packet = struct {
    name: []const u8,
    root: FieldType,
};

pub const Field = struct {
    name: []const u8,
    typeOf: FieldType,
};

var root = AST{ .types = undefined, .handshaking = undefined, .status = undefined, .login = undefined, .play = undefined };

const json = @embedFile("protocol.json");

const ParseError = error{
    UnexpectedToken,
    UnexpectedEndOfJson,
};

pub fn parse(stream: std.json.TokenStream, json: []const u8, alloc: *std.mem.Allocator) !void {
    var types: void;
    var login: StateSet;
    var handshaking: StateSet;
    var play: StateSet;

    while (try stream.next()) |tok| {
        switch (tok) {
            .String => |t| {
                switch (t.slice(json, stream.i - 1)) { // not sure if this slices it entirely
                    "types" => try skipObject(stream),
                    "login" => try parseStateSet(stream),
                    "handshaking" => try parseStateSet(stream),
                    "play" => try parseStateSet(stream),
                }
            },
            else => {},
            .Number => |t| {},
            .ObjectBegin => |t| {},
            .ObjectEnd => |t| {},
            .ArrayBegin => |t| {},
            .ArrayEnd => |t| {},
            .True => |t| {},
            .False => |t| {},
            .Null => |t| {},
        }
    }
}

pub fn skipObject(stream: std.json.TokenStream) !void {
    var stack: u16 = @intCast(u16, 0);
    while (try stream.next()) |tok| {
        switch (tok) {
            .ObjectBegin => |t| {
                stack += 1;
            },
            .ObjectEnd => |t| {
                stack -= 1;
                if (stack == 0) return;
            },
            else => {},
        }
    }
}

//  {
//      "toClient": {
//          "types": PacketSet,
//      },
//      "toServer": {
//          "types": PacketSet,
//      },
//  }
//
pub fn parseStateSet(stream: std.json.TokenStream, json: []const u8, alloc: *std.mem.Allocator) !StateSet {
    var state: u8 = 0;
    var toClient: PacketSet = undefined;
    var toServer: PacketSet = undefined;
    while (try stream.next()) |tok| {
        switch (tok) {
            .String => |t| {
                switch (t.slice(json, stream.i - 1)) {
                    "toClient" => toClient = try parsePacketSet(stream, json, alloc),
                    "toServer" => toServer = try parsePacketSet(stream, json, alloc),
                    else => return ParseError.UnexpectedToken,
                }
            },
            .ObjectBegin => {
                state = 1;
            },
            .ObjectEnd => {
                if (state != 1) return ParseError.UnexpectedToken;
                return StateSet{ .toServer = toServer, .toClient = .toClient };
            },
            else => return ParseError.UnexpectedToken,
        }
    }
    return ParseError.UnexpectedEndOfJson;
}

//  {
//      "types": {
//          "packet1": Packet,
//          "packet2": Packet,
//          "...": ...,
//          "packetN": Packet,
//      },
//  }
//
//  ObjectBegin, String, ObjectBegin, ... (check end) ... ObjectEnd, ObjectEnd
pub fn parsePacketSet(stream: std.json.TokenStream, json: []const u8, alloc: *std.mem.Allocator) !PacketSet {
    var state: u8 = @intCast(u8, 0);
    var packets = std.ArrayList(Packet).init(alloc);
    while (try stream.next()) |tok| {
        switch (tok) {
            .String => |t| {
                switch (t.slice(json, stream.i - 1)) {
                    "types" => state = 2,
                    else => {
                        if (state == 3) {
                            try packets.append(Packet{ .name = t.slice(json, stream.i - 1), .root = try parseFieldType(stream, json, alloc) });
                        } else {
                            return ParseError.UnexpectedToken;
                        }
                    },
                }
            },
            .ObjectBegin => {
                if (state == 0) {
                    state = 1;
                } else if (state == 2) {
                    state = 3;
                } else {
                    return ParseError.UnexpectedToken;
                }
            },
            .ObjectEnd => {
                if (state == 3) {
                    state = 1;
                } else if (state == 1) {
                    state = 0;
                    break;
                } else {
                    return ParseError.UnexpectedToken;
                }
            },
            else => return ParseError.UnexpectedToken,
        }
    }
    return ParseError.UnexpectedEndOfJson;
}

// {
//      "name": "name",
//      "type": FieldType,
// }
pub fn parseField(stream: std.json.TokenStream, json: []const u8, alloc: *std.mem.Allocator) !Field {
    var state: u8 = 0;
    var name: []const u8 = undefined;
    var typeOf: FieldType = undefined;
    while (try stream.next()) |tok| {
        switch (tok) {
            .String => |t| {
                if (state == 2) {
                    name = t.slice(json, stream.i - 1);
                    state = 1;
                    continue;
                }
                switch (t.slice(json, stream.i - 1)) {
                    "name" => state = 2,
                    "type" => typeOf = try parseFieldType(stream, json, alloc),
                    else => return ParseError.UnexpectedToken,
                }
            },
            .ObjectBegin => {
                if (state != 0) return ParseError.UnexpectedToken;
                state = 1;
            },
            .ObjectEnd => {
                if (state != 1) return ParseError.UnexpectedToken;
                return Field{ .name = name, .typeOf = typeOf };
            },
            else => return ParseError.UnexpectedToken,
        }
    }
    return ParseError.UnexpectedEndOfJson;
}

// multiple possibilities here:
//
// "composite types"
//
// Container
// [ "container", [
//          Field,
//          ...,
//          Field,
//      ]
// ]
//
// Array
// [ "array", {
//          "countType": "integer type or varint"
//          "type": FieldType,
//      }
// ]
//
// Switch
// [ "switch", {
//          "compareTo": ,TODO figure out what to do here
//          "fields": {
//
//          },
//          "default": FieldType,
//      }
// ]
//
// Option
// [ "option", FieldType ]
//
// BitField
// [ "bitField", [
//          { "name": "name", "size": integer, "signed": boolean },
//          ....
//      ]
// ]
//
// TopBitTerminatedArray
// [ "topBitSetTerminatedArray", {
//      "type":  FieldType TODO double check this
//      }
// ]
//
// "scalar types"
//
// the rest of them...
//
//
pub fn parseFieldType(stream: std.json.TokenStream, json: []const u8, alloc: *std.mem.Allocator) !FieldType {
    var state: u8 = @intCast(u8, 0);

    var field_type: FieldType = undefined;
    while (try stream.next()) |tok| {
        switch (tok) {
            .String => |t| {
                switch (state) {
                    0 => return std.meta.stringToEnum(std.meta.Tag(FieldType), t.slice(json, stream.i - 1)), // scalar type
                    1 => {
                        const tag = t.slice(json, stream.i - 1);
                        switch (tag) {
                            "container" => {},
                            "array" => {},
                            "option" => {},
                            "topBitSetTerminatedArray" => {},
                            "bitField" => {},
                            "switch" => {},
                            "option" => {},
                        }
                    }, // composite type
                }
            },
            .ArrayBegin => state = 1,
            .ArrayEnd => return field_type,
            else => return ParseError.UnexpectedToken,
        }
    }
    return ParseError.UnexpectedEndOfJson;
}
