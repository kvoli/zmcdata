const fs = require("fs");

const blacklisted_packets = new Set(["packet_declare_commands"]);

fs.readFile(
  "./minecraft-data/data/pc/1.17/protocol.json",
  "utf-8",
  (err, jsonString) => {
    const data = JSON.parse(jsonString);
    //whatever other code you may fanacy
    objectMap(data, (k, v) => {
      //console.log(k, v);
      parseState(k, v);
    });
  }
);

const _pprint = (i, s) => indent(i) + s + "\n";

const pprint = (i, s) => {
  process.stdout.write(_pprint(i, s));
};

const indent = (i) => {
  var out = "";
  for (; i > 0; i--) {
    out += "    ";
  }
  return out;
};

var statemap = {};

const parseState = (stateName, data) => {
  if (stateName == "types") {
    return;
  }
  pprint(0, `pub const ${stateName} = struct {`);
  parsePacketSet(data, 1);
  pprint(0, `};`);
};

const parsePacketSet = (packetSet, i) => {
  pprint(i, `pub const s2c = union(S2C) {`);
  Object.entries(packetSet.toClient.types).map((pkt) => {
    parsePacket(pkt, i + 1);
  });
  pprint(i, ``);
  pprint(i + 1, "pub const S2C = enum(u8) {");
  parseStateEnum(i + 2);
  pprint(i + 1, "};");
  pprint(i, `};\n`);

  pprint(i, `pub const c2s = union(C2S) {`);
  Object.entries(packetSet.toServer.types).map((pkt) => {
    parsePacket(pkt, i + 1);
  });
  pprint(i, ``);
  pprint(i + 1, "pub const C2S = enum(u8) {");
  parseStateEnum(i + 2);
  pprint(i + 1, "};");
  pprint(i, `};`);
};

const parseStateEnum = (i) => {
  objectMap(statemap, (k, v) => {
    pprint(i, `${v}: ${k},`);
  });
};

const parsePacket = (pkt, i) => {
  let packetName = pkt[0];
  let packetData = pkt[1][1];

  if (packetName === "packet") {
    parsePacketMap(packetData, i);
    return;
  }

  if (packetName.slice(0, 6) !== "packet") return;
  pprint(i, `pub const ${snake2Pascal(packetName.slice(7))} = struct {`);

  packetData.map((field) => {
    pprint(i + 1, `${field.name}: ${parseType(field.type, i + 1)},`);
  });

  pprint(i, `};\n`);
};

const parseType = (t, i) => {
  const isComplexType = Array.isArray(t);
  return isComplexType ? parseComplexType(t, i) : parseSimpleType(t);
};

const parsePacketMap = (pkt, i) => {
  let mapName = pkt[0];
  let mappings = mapName.type[1].mappings;

  statemap = mappings;

  var out = "";
  objectMap(mappings, (k, v) => pprint(i, `${v}: ${snake2Pascal(v)},`)).forEach(
    (e) => (out += e)
  );
  return out;
};

const parseComplexType = (t, i) => {
  const decl = t[0];
  const impl = t[1];
  switch (decl) {
    case "option":
      return parseOption(impl, i);
    case "entityMetadataLoop":
      return "EntityMetadata";
    case "topBitSetTerminatedArray":
      return parseTopBitArray(impl, i);
    case "bitfield":
      return parseBitField(impl, i);
    case "container":
      return parseContainer(impl, i);
    case "switch":
      return parseSwitch(impl, i);
    case "array":
      return parseArray(impl, i);
    case "nbt":
      return "NBT";
    case "optionalNbt":
      return "NBT?";
    case "buffer":
      return "[]u8";
    default:
      return `UNKNOWN_COMPLEX_TYPE(${decl})`;
  }
};

const parseSimpleType = (t) => {
  switch (t) {
    case "optvarint":
      return "varint?";
    case "varint":
      return "varint";
    case "pstring":
      return "[]u8";
    case "UUID":
      return "UUID";
    case "void":
      return "null";
    case "restBuffer":
      return "[]u8";
    case "string":
      return "[]u8";
    case "u16":
      return "u16";
    case "u8":
      return "u8";
    case "i64":
      return "i64";
    case "i32":
      return "i32";
    case "i8":
      return "i8";
    case "bool":
      return "bool";
    case "i16":
      return "i16";
    case "f32":
      return "f32";
    case "f64":
      return "f64";
    case "position":
      return "position";
    case "slot":
      return "slot";
    case "optionalNbt":
      return "?nbt";
    case "nbt":
      return "nbt";
    case "entityMetadata":
      return "EntityMetadata";
    case "tags":
      return "tags";
    default:
      return `UNKNOWN_SIMPLE_TYPE(${t})`;
  }
};

const parseOption = (t, i) => `?${parseType(t, i)}`;

const parseArray = (t, i) => {
  var out = `ArrayType(${t.countType}, `;
  return out + parseType(t.type, i + 1) + ")";
};

const parseTopBitArray = (t, i) => {
  var out = `TopBitArrayType(`;
  return out + parseType(t.type, i + 1) + ")";
};

const parseBitField = (t, i) => {
  var out = _pprint(0, "packed struct {");
  t.map(
    (item) =>
      (out += _pprint(
        i + 1,
        `${item.name}: ${item.signed ? "i" : "u"}${item.size},`
      ))
  );
  return out + indent(i) + "}";
};

const parseContainer = (t, i) => {
  var out = _pprint(0, "struct {");
  t.map(
    (field) =>
      (out += _pprint(i, `${field.name}: ${parseType(field.type, i + 1)},`))
  );
  return out + indent(i - 1) + "}";
};

const parseSwitch = (t, i) => {
  var out = _pprint(0, `SwitchType(${t.compareTo}, struct {`);
  objectMap(t.fields, (k, v) => {
    out += _pprint(i + 1, `x${k}: ${parseType(v, i)},`);
  });
  out += _pprint(i + 1, `default: ${t.default ? t.default : "void"},`);
  return out + indent(i) + "})";
};

function snake2Pascal(str) {
  str += "";
  str = str.split("_");

  function upper(str) {
    return str.slice(0, 1).toUpperCase() + str.slice(1, str.length);
  }

  for (var i = 0; i < str.length; i++) {
    var str2 = str[i].split("/");
    for (var j = 0; j < str2.length; j++) {
      str2[j] = upper(str2[j]);
    }
    str[i] = str2.join("");
  }
  return str.join("");
}

const objectMap = (obj, fn) =>
  Object.entries(obj).map(([k, v], i) => fn(k, v, i));
