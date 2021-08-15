const fs = require("fs");

// TODO ztsd for internal packet compression (not to client).

const blacklisted_packets = new Set([
  "packet_declare_commands",
  "packet_declare_recipes",
  "packet_unlock_recipes",
  "packet_player_info",
  "packet_scoreboard_score",
  "packet_world_particles",
  "packet_crafting_book_data",
]);

const int_types = new Set(["u8", "i8", "varint"]);

const blacklisted_typedecls = new Set([]);
const blacklisted_versions = new Set(["1.7"]);

var typeMap = {};

// define the types we know we want to handle differently
//
const registerTypes = () => {
  typeMap.option = (impl, i, stack) => parseOption(impl, i, stack);
  typeMap.topBitSetTerminatedArray = (impl, i, stack) =>
    parseTopBitArray(impl, i, stack);
  typeMap.bitfield = (impl, i, stack) => parseBitField(impl, i, stack);
  typeMap.container = (impl, i, stack) => parseContainer(impl, i, stack);
  typeMap.switch = (impl, i, stack) => parseSwitch(impl, i, stack);
  typeMap.array = (impl, i, stack) => parseArray(impl, i, stack);
  typeMap.particleData = () => "particleData";
  typeMap.particle = () => "Particle";
  typeMap.buffer = () => "[]u8";
  typeMap.string = () => "[]u8";
  typeMap.pstring = () => "[]u8";
  typeMap.restBuffer = () => "[]u8";
  typeMap.varint = () => "vi";
  typeMap.optvarint = () => "?vi";
  typeMap.UUID = () => "UUID";
  typeMap.slot = () => "Slot";
  typeMap.particle = () => "Particle";
  typeMap.optionalNbt = () => "?NBT";
  typeMap.nbt = () => "NBT";
  typeMap.tags = () => "Tags";
  typeMap.entityMetadata = () => "EntityMetadata";
  typeMap.entityMetadataItem = () => "EntityMetadataItem";
};

var buffer = "";
var decl = false;
var switched = false;

const allVersions = () => {
  fs.readdir("./minecraft-data/data/pc", (err, files) => {
    files.map((v) => {
      if (!blacklisted_versions.has(v)) doVersion(v);
    });
  });
};

allVersions();

const parseTypeDecls = (data) => {
  decl = true;
  objectMap(data, (k, v) => {
    if (blacklisted_typedecls.has(k) || k in typeMap) return;
    if (v !== "native") {
      pprint(0, `pub const ${k} = ${parseType(v, 1, [])};`);
      pprint(0, "");
    }
    typeMap[k] = () => k;
  });
  decl = false;
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
          typeMap = {};
          registerTypes();
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
  if (containsSwitch(pkt[1])) switched = true;

  pprint(i, `pub const ${snake2Pascal(packetName.slice(7))} = struct {`);
  packetData.map((field) => {
    if (containsSwitch(field.type) && !switched) return;
    pprint(
      i + 1,
      `${filterDecl(field.name)}: ${parseType(field.type, i + 1, [
        packetData,
      ])},`
    );
  });
  pprint(i, `};\n`);
};

const parseType = (t, i, stack) => {
  const isComplexType = Array.isArray(t);
  const decl = isComplexType ? t[0] : t;
  if (typeMap[decl] === undefined) {
    console.log("UNDEFINED", decl);
    return "";
  }
  return isComplexType ? typeMap[decl](t[1], i, [...stack]) : typeMap[decl]();
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

const parseOption = (t, i, stack) => `?${parseType(t, i, stack)}`;

const parseArray = (t, i, stack) => {
  var out = `[]`;
  return out + parseType(t.type, i + 1, [...stack, t]);
};

const parseTopBitArray = (t, i, stack) => {
  var out = `TopBitArrayType(`;
  return out + parseType(t.type, i + 1, [...stack, t]) + ")";
};

const parseBitField = (t, i) => {
  var out = _pprint(0, "packed struct {");
  t.map(
    (item) =>
      (out += _pprint(
        i,
        `${filterDecl(item.name)}: ${item.signed ? "i" : "u"}${item.size},`
      ))
  );
  return out + indent(i - 1) + "}";
};

const parseContainer = (t, i, stack) => {
  var out = _pprint(0, "struct {");
  t.map((field) => {
    if (field["anon"] !== undefined && field.anon) {
      console.log("FOUND ANNON", field);
      out += _pprint(`${parseType(field.type, i + 1, [...stack, t])},`);
    } else {
      if (containsSwitch(field.type) && !switched && !decl) return;
      out += _pprint(
        i,
        `${filterDecl(field.name)}: ${parseType(field.type, i + 1, [
          ...stack,
          t,
        ])},`
      );
    }
  });
  return out + indent(i - 1) + "}";
};

// if we have a switch on the same field in the same scope, then we should combine the output
const parseSwitch = (t, i, stack) => {
  if (stack.length == 0 || !switched) return "";
  switched = false;
  const fields = remapSwitch(stack[stack.length - 1]);

  var out = _pprint(0, `union(enum(u8)) {`);
  objectMap(fields, (k, v) => {
    let val = getSwitchedStruct(i + 1, v);
    if (val !== "") {
      out += _pprint(i + 1, `@"${k}": ${val}`);
    }
  });

  return out + indent(i - 1) + "}";
};

const getSwitchedStruct = (i, data) => {
  var voided = true;
  var out = _pprint(0, "struct {");
  data.map((e) => {
    if (e[1] !== "void") {
      voided = false;
      out += _pprint(
        i + 1,
        `${filterDecl(e[0])}: ${parseType(e[1], i + 1, [])},`
      );
    }
  });
  if (voided) return "";
  return out + indent(i) + "},";
};

const remapSwitch = (scope) => {
  const fields = {};
  scope.map((e) => {
    if (Array.isArray(e.type) && e.type[0] == "switch") {
      objectMap(e.type[1].fields, (k, v, i) => {
        if (fields[k] === undefined) fields[k] = [[e.name, v]];
        else fields[k] = [...fields[k], [e.name, v]];
      });
      if (e.type[1].default !== undefined) {
        if (fields[`default`] === undefined)
          fields[`default`] = [[e.name, e.type[1].default]];
        else
          fields[`default`] = [
            ...fields[`default`],
            [e.name, e.type[1].default],
          ];
      }
    }
  });
  return fields;
};

const getSwitchType = (t, stack) => {
  const upperScope = stack[stack.length - 1];
  const out = upperScope.filter((e) => e.name === t.compareTo).shift();
  return out === undefined
    ? getSwitchType(t, stack.slice(0, stack.length - 1))
    : out.type;
};
//
// if its directly above
//  -> int type then go implict w/ union
//  ddddddddddddddddddddddddddddddddddddddddddd
//  -> string type, then explicit type w/ union
//  -> bitfield type, then encapsulate
//

const containsSwitch = (t) => {
  const complexType = Array.isArray(t);
  if (complexType) {
    switch (t[0]) {
      case "array":
        return containsSwitch(t[1].type);
      case "container":
        return t[1].some((e) => containsSwitch(e.type));
      case "switch":
        return true;
      case "option":
        return containsSwitch(t[1]);
      case "topBitSetTerminatedArray":
        return containsSwitch(t[1].type);
      default:
        false;
    }
  }
  return false;
};

const filterDecl = (decl) => {
  var out = "";
  if (decl === "type") {
    return `@"type"`;
  } else if (decl === "default") {
    out = `default`;
  } else {
    out = decl;
  }

  return snake_case_string(out);
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
function snake_case_string(str) {
  return (
    str &&
    str
      .match(
        /[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+/g
      )
      .map((s) => s.toLowerCase())
      .join("_")
  );
}

const objectMap = (obj, fn) =>
  Object.entries(obj).map(([k, v], i) => fn(k, v, i));
