const fs = require("fs");

// TODO ztsd for internal packet compression (not to client).

const blacklisted_packets = new Set([
  "packet_declare_commands",
  "packet_declare_recipes",
]);

const blacklisted_typedecls = new Set([]);

const typeMap = {};

typeMap.option = (impl, i, obj) => parseOption(impl, i);
typeMap.entityMetadataLoop = (impl, i, obj) => "EntityMetadata";
typeMap.topBitSetTerminatedArray = (impl, i, obj) => parseTopBitArray(impl, i);
typeMap.bitfield = (impl, i, obj) => parseBitField(impl, i);
typeMap.container = (impl, i, obj) => parseContainer(impl, i);
typeMap.switch = (impl, i, obj) => parseSwitch(impl, i);
typeMap.array = (impl, i, obj) => parseArray(impl, i);
typeMap.buffer = (impl, i, obj) => "[]u8";
typeMap.string = (impl, i, obj) => "[]u8";
typeMap.optvarint = (impl, i, obj) => "?varint";
typeMap.varint = (impl, i, obj) => "varint";
typeMap.pstring = (impl, i, obj) => "[]u8";
typeMap.UUID = (impl, i, obj) => "UUID";
typeMap.restBuffer = (impl, i, obj) => "[]u8";
typeMap.slot = (impl, i, obj) => "?Slot";
typeMap.optionalNbt = (impl, i, obj) => "?NBT";
typeMap.entityMetadata = (impl, i, obj) => "EntityMetadata";

var buffer = "";
var decl = false;

const allVersions = () => {
  fs.readdir("./minecraft-data/data/pc", (err, files) => {
    files.map((v) => {
      doVersion(v);
    });
  });
};

allVersions();

const parseTypeDecls = (data) => {
  decl = true;
  objectMap(data, (k, v) => {
    if (blacklisted_typedecls.has(k) || k in typeMap) return;
    if (v !== "native") {
      pprint(0, `pub const ${k} = ${parseType(v, 1)};`);
      pprint(0, "");
    }
    typeMap[k] = (impl, i, obj) => k;
  });
  decl = false;
  console.log(JSON.stringify(Object.entries(typeMap)));
};

const doVersion = (v) => {
  fs.readFile(
    `./minecraft-data/data/pc/${v}/protocol.json`,
    "utf-8",
    (err, jsonString) => {
      if (jsonString != undefined) {
        try {
          console.log("parsing ", v);
          const data = JSON.parse(jsonString);
          objectMap(data, (k, v) => {
            parseState(k, v);
          });
          if (!fs.readdirSync(`./impl`).some((x) => x === `${v}`)) {
            fs.mkdirSync(`./impl/${v}`);
          }
          fs.writeFileSync(`./impl/${v}/protocol.zig`, buffer);
        } catch (e) {
          console.log("error parsing proto ", e);
        }
        buffer = "";
      }
    }
  );
};

const _pprint = (i, s) => indent(i) + s + "\n";

const pprint = (i, s) => {
  buffer += _pprint(i, s);
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
    parseTypeDecls(data);
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

  if (blacklisted_packets.has(packetName)) {
    return;
  }

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
  const decl = isComplexType ? t[0] : t;
  if (typeMap[decl] === undefined) {
    console.log("UNDEFINED", decl);
    return "";
  }
  return isComplexType ? typeMap[decl](t[1], i) : typeMap[decl]();
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
  t.map((field) => {
    if (field.anon !== undefined && field.anon) {
      //console.log("ANON ALERT,", field);
      out += _pprint(`${parseType(field.type, i + 1)},`);
    } else {
      // non anon
      out += _pprint(i, `${field.name}: ${parseType(field.type, i + 1)},`);
    }
  });
  return out + indent(i - 1) + "}";
};

// if we have a switch on the same field in the same scope, then we should combine the output
const parseSwitch = (t, i) => {
  if (decl) {
    var out = _pprint(0, `union(enum(u8)) {`);
    objectMap(t.fields, (k, v) => {
      out += _pprint(i + 1, `x${k}: ${parseType(v, i)},`);
    });
    out += _pprint(
      i + 1,
      `default: ${t.default ? parseType(t.default) : "void"},`
    );
    return out + indent(i) + "}";
  } else {
    var out = _pprint(
      0,
      `SwitchType(${t.compareTo.split("/").pop()}, struct {`
    );
    objectMap(t.fields, (k, v) => {
      out += _pprint(i + 1, `x${k}: ${parseType(v, i)},`);
    });
    out += _pprint(
      i + 1,
      `default: ${t.default ? parseType(t.default) : "void"},`
    );
    return out + indent(i) + "})";
  }
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
