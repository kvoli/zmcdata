pub const handshaking = struct {
    pub const s2c = union(S2C) {
    };

    pub const c2s = union(C2S) {
        pub const SetProtocol = struct {
            protocolVersion: varint,
            serverHost: []u8,
            serverPort: u16,
            nextState: varint,
        };

        pub const LegacyServerListPing = struct {
            payload: u8,
        };

        set_protocol: SetProtocol,
        legacy_server_list_ping: LegacyServerListPing,
    };
};
pub const status = struct {
    pub const s2c = union(S2C) {
        pub const ServerInfo = struct {
            response: []u8,
        };

        pub const Ping = struct {
            time: i64,
        };

        server_info: ServerInfo,
        ping: Ping,
    };

    pub const c2s = union(C2S) {
        pub const PingStart = struct {
        };

        pub const Ping = struct {
            time: i64,
        };

        ping_start: PingStart,
        ping: Ping,
    };
};
pub const login = struct {
    pub const s2c = union(S2C) {
        pub const Disconnect = struct {
            reason: []u8,
        };

        pub const EncryptionBegin = struct {
            serverId: []u8,
            publicKey: []u8,
            verifyToken: []u8,
        };

        pub const Success = struct {
            uuid: UUID,
            username: []u8,
        };

        pub const Compress = struct {
            threshold: varint,
        };

        pub const LoginPluginRequest = struct {
            messageId: varint,
            channel: []u8,
            data: []u8,
        };

        disconnect: Disconnect,
        encryption_begin: EncryptionBegin,
        success: Success,
        compress: Compress,
        login_plugin_request: LoginPluginRequest,
    };

    pub const c2s = union(C2S) {
        pub const LoginStart = struct {
            username: []u8,
        };

        pub const EncryptionBegin = struct {
            sharedSecret: []u8,
            verifyToken: []u8,
        };

        pub const LoginPluginResponse = struct {
            messageId: varint,
            data: ?[]u8,
        };

        login_start: LoginStart,
        encryption_begin: EncryptionBegin,
        login_plugin_response: LoginPluginResponse,
    };
};
pub const play = struct {
    pub const s2c = union(S2C) {
        pub const SpawnEntity = struct {
            entityId: varint,
            objectUUID: UUID,
            type: varint,
            x: f64,
            y: f64,
            z: f64,
            pitch: i8,
            yaw: i8,
            objectData: i32,
            velocityX: i16,
            velocityY: i16,
            velocityZ: i16,
        };

        pub const SpawnEntityExperienceOrb = struct {
            entityId: varint,
            x: f64,
            y: f64,
            z: f64,
            count: i16,
        };

        pub const SpawnEntityLiving = struct {
            entityId: varint,
            entityUUID: UUID,
            type: varint,
            x: f64,
            y: f64,
            z: f64,
            yaw: i8,
            pitch: i8,
            headPitch: i8,
            velocityX: i16,
            velocityY: i16,
            velocityZ: i16,
        };

        pub const SpawnEntityPainting = struct {
            entityId: varint,
            entityUUID: UUID,
            title: varint,
            location: position,
            direction: u8,
        };

        pub const NamedEntitySpawn = struct {
            entityId: varint,
            playerUUID: UUID,
            x: f64,
            y: f64,
            z: f64,
            yaw: i8,
            pitch: i8,
        };

        pub const Animation = struct {
            entityId: varint,
            animation: u8,
        };

        pub const Statistics = struct {
            entries: ArrayType(varint, struct {
                categoryId: varint,
                statisticId: varint,
                value: varint,
            }),
        };

        pub const Advancements = struct {
            reset: bool,
            advancementMapping: ArrayType(varint, struct {
                key: []u8,
                value: struct {
                    parentId: ?[]u8,
                    displayData: ?struct {
                        title: []u8,
                        description: []u8,
                        icon: slot,
                        frameType: varint,
                        flags: packed struct {
                                _unused: u29,
                                hidden: u1,
                                show_toast: u1,
                                has_background_texture: u1,
                            },
                        backgroundTexture: SwitchType(flags/has_background_texture, struct {
                                x1: []u8,
                                default: void,
                            }),
                        xCord: f32,
                        yCord: f32,
                    },
                    criteria: ArrayType(varint, struct {
                            key: []u8,
                            value: null,
                        }),
                    requirements: ArrayType(varint, ArrayType(varint, []u8)),
                },
            }),
            identifiers: ArrayType(varint, []u8),
            progressMapping: ArrayType(varint, struct {
                key: []u8,
                value: ArrayType(varint, struct {
                        criterionIdentifier: []u8,
                        criterionProgress: ?i64,
                    }),
            }),
        };

        pub const BlockBreakAnimation = struct {
            entityId: varint,
            location: position,
            destroyStage: i8,
        };

        pub const TileEntityData = struct {
            location: position,
            action: u8,
            nbtData: ?nbt,
        };

        pub const BlockAction = struct {
            location: position,
            byte1: u8,
            byte2: u8,
            blockId: varint,
        };

        pub const BlockChange = struct {
            location: position,
            type: varint,
        };

        pub const BossBar = struct {
            entityUUID: UUID,
            action: varint,
            title: SwitchType(action, struct {
                x0: []u8,
                x3: []u8,
                default: void,
            }),
            health: SwitchType(action, struct {
                x0: f32,
                x2: f32,
                default: void,
            }),
            color: SwitchType(action, struct {
                x0: varint,
                x4: varint,
                default: void,
            }),
            dividers: SwitchType(action, struct {
                x0: varint,
                x4: varint,
                default: void,
            }),
            flags: SwitchType(action, struct {
                x0: u8,
                x5: u8,
                default: void,
            }),
        };

        pub const Difficulty = struct {
            difficulty: u8,
            difficultyLocked: bool,
        };

        pub const TabComplete = struct {
            transactionId: varint,
            start: varint,
            length: varint,
            matches: ArrayType(varint, struct {
                match: []u8,
                tooltip: ?[]u8,
            }),
        };

        pub const DeclareCommands = struct {
            nodes: ArrayType(varint, struct {
                flags: packed struct {
                        unused: u3,
                        has_custom_suggestions: u1,
                        has_redirect_node: u1,
                        has_command: u1,
                        command_node_type: u2,
                    },
                children: ArrayType(varint, varint),
                redirectNode: SwitchType(flags/has_redirect_node, struct {
                        x1: varint,
                        default: void,
                    }),
                extraNodeData: SwitchType(flags/command_node_type, struct {
                        x0: null,
                        x1: []u8,
                        x2: struct {
                    name: []u8,
                    parser: []u8,
                    properties: SwitchType(parser, struct {
                            xbrigadier:double: struct {
                        flags: packed struct {
                                unused: u6,
                                max_present: u1,
                                min_present: u1,
                            },
                        min: SwitchType(flags/min_present, struct {
                                x1: f64,
                                default: void,
                            }),
                        max: SwitchType(flags/max_present, struct {
                                x1: f64,
                                default: void,
                            }),
                    },
                            xbrigadier:float: struct {
                        flags: packed struct {
                                unused: u6,
                                max_present: u1,
                                min_present: u1,
                            },
                        min: SwitchType(flags/min_present, struct {
                                x1: f32,
                                default: void,
                            }),
                        max: SwitchType(flags/max_present, struct {
                                x1: f32,
                                default: void,
                            }),
                    },
                            xbrigadier:integer: struct {
                        flags: packed struct {
                                unused: u6,
                                max_present: u1,
                                min_present: u1,
                            },
                        min: SwitchType(flags/min_present, struct {
                                x1: i32,
                                default: void,
                            }),
                        max: SwitchType(flags/max_present, struct {
                                x1: i32,
                                default: void,
                            }),
                    },
                            xbrigadier:long: struct {
                        flags: packed struct {
                                unused: u6,
                                max_present: u1,
                                min_present: u1,
                            },
                        min: SwitchType(flags/min_present, struct {
                                x1: i64,
                                default: void,
                            }),
                        max: SwitchType(flags/max_present, struct {
                                x1: i64,
                                default: void,
                            }),
                    },
                            xbrigadier:string: varint,
                            xminecraft:entity: i8,
                            xminecraft:score_holder: i8,
                            xminecraft:range: bool,
                            default: void,
                        }),
                    suggests: SwitchType(../flags/has_custom_suggestions, struct {
                            x1: []u8,
                            default: void,
                        }),
                },
                        default: void,
                    }),
            }),
            rootIndex: varint,
        };

        pub const FacePlayer = struct {
            feet_eyes: varint,
            x: f64,
            y: f64,
            z: f64,
            isEntity: bool,
            entityId: SwitchType(isEntity, struct {
                xtrue: varint,
                default: void,
            }),
            entity_feet_eyes: SwitchType(isEntity, struct {
                xtrue: []u8,
                default: void,
            }),
        };

        pub const NbtQueryResponse = struct {
            transactionId: varint,
            nbt: nbt,
        };

        pub const Chat = struct {
            message: []u8,
            position: i8,
            sender: UUID,
        };

        pub const MultiBlockChange = struct {
            chunkCoordinates: packed struct {
                x: i22,
                z: i22,
                y: u20,
            },
            notTrustEdges: bool,
            records: ArrayType(varint, varint),
        };

        pub const CloseWindow = struct {
            windowId: u8,
        };

        pub const OpenWindow = struct {
            windowId: varint,
            inventoryType: varint,
            windowTitle: []u8,
        };

        pub const WindowItems = struct {
            windowId: u8,
            items: ArrayType(i16, slot),
        };

        pub const CraftProgressBar = struct {
            windowId: u8,
            property: i16,
            value: i16,
        };

        pub const SetSlot = struct {
            windowId: i8,
            slot: i16,
            item: slot,
        };

        pub const SetCooldown = struct {
            itemID: varint,
            cooldownTicks: varint,
        };

        pub const CustomPayload = struct {
            channel: []u8,
            data: []u8,
        };

        pub const NamedSoundEffect = struct {
            soundName: []u8,
            soundCategory: varint,
            x: i32,
            y: i32,
            z: i32,
            volume: f32,
            pitch: f32,
        };

        pub const KickDisconnect = struct {
            reason: []u8,
        };

        pub const EntityStatus = struct {
            entityId: i32,
            entityStatus: i8,
        };

        pub const Explosion = struct {
            x: f32,
            y: f32,
            z: f32,
            radius: f32,
            affectedBlockOffsets: ArrayType(varint, struct {
                x: i8,
                y: i8,
                z: i8,
            }),
            playerMotionX: f32,
            playerMotionY: f32,
            playerMotionZ: f32,
        };

        pub const UnloadChunk = struct {
            chunkX: i32,
            chunkZ: i32,
        };

        pub const GameStateChange = struct {
            reason: u8,
            gameMode: f32,
        };

        pub const OpenHorseWindow = struct {
            windowId: u8,
            nbSlots: varint,
            entityId: i32,
        };

        pub const KeepAlive = struct {
            keepAliveId: i64,
        };

        pub const MapChunk = struct {
            x: i32,
            z: i32,
            primaryBitMask: ArrayType(varint, i64),
            heightmaps: nbt,
            biomes: ArrayType(varint, varint),
            chunkData: []u8,
            blockEntities: ArrayType(varint, nbt),
        };

        pub const WorldEvent = struct {
            effectId: i32,
            location: position,
            data: i32,
            global: bool,
        };

        pub const WorldParticles = struct {
            particleId: i32,
            longDistance: bool,
            x: f64,
            y: f64,
            z: f64,
            offsetX: f32,
            offsetY: f32,
            offsetZ: f32,
            particleData: f32,
            particles: i32,
            data: UNKNOWN_COMPLEX_TYPE(particleData),
        };

        pub const UpdateLight = struct {
            chunkX: varint,
            chunkZ: varint,
            trustEdges: bool,
            skyLightMask: ArrayType(varint, i64),
            blockLightMask: ArrayType(varint, i64),
            emptySkyLightMask: ArrayType(varint, i64),
            emptyBlockLightMask: ArrayType(varint, i64),
            skyLight: ArrayType(varint, ArrayType(varint, u8)),
            blockLight: ArrayType(varint, ArrayType(varint, u8)),
        };

        pub const Login = struct {
            entityId: i32,
            isHardcore: bool,
            gameMode: u8,
            previousGameMode: i8,
            worldNames: ArrayType(varint, []u8),
            dimensionCodec: nbt,
            dimension: nbt,
            worldName: []u8,
            hashedSeed: i64,
            maxPlayers: varint,
            viewDistance: varint,
            reducedDebugInfo: bool,
            enableRespawnScreen: bool,
            isDebug: bool,
            isFlat: bool,
        };

        pub const Map = struct {
            itemDamage: varint,
            scale: i8,
            locked: bool,
            icons: ?ArrayType(varint, struct {
                type: varint,
                x: i8,
                y: i8,
                direction: u8,
                displayName: ?[]u8,
            }),
            columns: u8,
            rows: SwitchType(columns, struct {
                x0: null,
                default: u8,
            }),
            x: SwitchType(columns, struct {
                x0: null,
                default: u8,
            }),
            y: SwitchType(columns, struct {
                x0: null,
                default: u8,
            }),
            data: SwitchType(columns, struct {
                x0: null,
                default: buffer,[object Object],
            }),
        };

        pub const TradeList = struct {
            windowId: varint,
            trades: ArrayType(u8, struct {
                inputItem1: slot,
                outputItem: slot,
                inputItem2: ?slot,
                tradeDisabled: bool,
                nbTradeUses: i32,
                maximumNbTradeUses: i32,
                xp: i32,
                specialPrice: i32,
                priceMultiplier: f32,
                demand: i32,
            }),
            villagerLevel: varint,
            experience: varint,
            isRegularVillager: bool,
            canRestock: bool,
        };

        pub const RelEntityMove = struct {
            entityId: varint,
            dX: i16,
            dY: i16,
            dZ: i16,
            onGround: bool,
        };

        pub const EntityMoveLook = struct {
            entityId: varint,
            dX: i16,
            dY: i16,
            dZ: i16,
            yaw: i8,
            pitch: i8,
            onGround: bool,
        };

        pub const EntityLook = struct {
            entityId: varint,
            yaw: i8,
            pitch: i8,
            onGround: bool,
        };

        pub const VehicleMove = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
        };

        pub const OpenBook = struct {
            hand: varint,
        };

        pub const OpenSignEntity = struct {
            location: position,
        };

        pub const CraftRecipeResponse = struct {
            windowId: i8,
            recipe: []u8,
        };

        pub const Abilities = struct {
            flags: i8,
            flyingSpeed: f32,
            walkingSpeed: f32,
        };

        pub const EndCombatEvent = struct {
            duration: varint,
            entityId: i32,
        };

        pub const EnterCombatEvent = struct {
        };

        pub const DeathCombatEvent = struct {
            playerId: varint,
            entityId: i32,
            message: []u8,
        };

        pub const PlayerInfo = struct {
            action: varint,
            data: ArrayType(varint, struct {
                UUID: UUID,
                name: SwitchType(../action, struct {
                        x0: []u8,
                        default: void,
                    }),
                properties: SwitchType(../action, struct {
                        x0: ArrayType(varint, struct {
                        name: []u8,
                        value: []u8,
                        signature: ?[]u8,
                    }),
                        default: void,
                    }),
                gamemode: SwitchType(../action, struct {
                        x0: varint,
                        x1: varint,
                        default: void,
                    }),
                ping: SwitchType(../action, struct {
                        x0: varint,
                        x2: varint,
                        default: void,
                    }),
                displayName: SwitchType(../action, struct {
                        x0: ?[]u8,
                        x3: ?[]u8,
                        default: void,
                    }),
            }),
        };

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
            flags: i8,
            teleportId: varint,
            dismountVehicle: bool,
        };

        pub const UnlockRecipes = struct {
            action: varint,
            craftingBookOpen: bool,
            filteringCraftable: bool,
            smeltingBookOpen: bool,
            filteringSmeltable: bool,
            blastFurnaceOpen: bool,
            filteringBlastFurnace: bool,
            smokerBookOpen: bool,
            filteringSmoker: bool,
            recipes1: ArrayType(varint, []u8),
            recipes2: SwitchType(action, struct {
                x0: ArrayType(varint, []u8),
                default: void,
            }),
        };

        pub const DestroyEntity = struct {
            entityIds: varint,
        };

        pub const RemoveEntityEffect = struct {
            entityId: varint,
            effectId: i8,
        };

        pub const ResourcePackSend = struct {
            url: []u8,
            hash: []u8,
            forced: bool,
        };

        pub const Respawn = struct {
            dimension: nbt,
            worldName: []u8,
            hashedSeed: i64,
            gamemode: u8,
            previousGamemode: u8,
            isDebug: bool,
            isFlat: bool,
            copyMetadata: bool,
        };

        pub const EntityHeadRotation = struct {
            entityId: varint,
            headYaw: i8,
        };

        pub const Camera = struct {
            cameraId: varint,
        };

        pub const HeldItemSlot = struct {
            slot: i8,
        };

        pub const UpdateViewPosition = struct {
            chunkX: varint,
            chunkZ: varint,
        };

        pub const UpdateViewDistance = struct {
            viewDistance: varint,
        };

        pub const ScoreboardDisplayObjective = struct {
            position: i8,
            name: []u8,
        };

        pub const EntityMetadata = struct {
            entityId: varint,
            metadata: EntityMetadata,
        };

        pub const AttachEntity = struct {
            entityId: i32,
            vehicleId: i32,
        };

        pub const EntityVelocity = struct {
            entityId: varint,
            velocityX: i16,
            velocityY: i16,
            velocityZ: i16,
        };

        pub const EntityEquipment = struct {
            entityId: varint,
            equipments: TopBitArrayType(struct {
                slot: i8,
                item: slot,
            }),
        };

        pub const Experience = struct {
            experienceBar: f32,
            level: varint,
            totalExperience: varint,
        };

        pub const UpdateHealth = struct {
            health: f32,
            food: varint,
            foodSaturation: f32,
        };

        pub const ScoreboardObjective = struct {
            name: []u8,
            action: i8,
            displayText: SwitchType(action, struct {
                x0: []u8,
                x2: []u8,
                default: void,
            }),
            type: SwitchType(action, struct {
                x0: varint,
                x2: varint,
                default: void,
            }),
        };

        pub const SetPassengers = struct {
            entityId: varint,
            passengers: ArrayType(varint, varint),
        };

        pub const Teams = struct {
            team: []u8,
            mode: i8,
            name: SwitchType(mode, struct {
                x0: []u8,
                x2: []u8,
                default: void,
            }),
            friendlyFire: SwitchType(mode, struct {
                x0: i8,
                x2: i8,
                default: void,
            }),
            nameTagVisibility: SwitchType(mode, struct {
                x0: []u8,
                x2: []u8,
                default: void,
            }),
            collisionRule: SwitchType(mode, struct {
                x0: []u8,
                x2: []u8,
                default: void,
            }),
            formatting: SwitchType(mode, struct {
                x0: varint,
                x2: varint,
                default: void,
            }),
            prefix: SwitchType(mode, struct {
                x0: []u8,
                x2: []u8,
                default: void,
            }),
            suffix: SwitchType(mode, struct {
                x0: []u8,
                x2: []u8,
                default: void,
            }),
            players: SwitchType(mode, struct {
                x0: ArrayType(varint, []u8),
                x3: ArrayType(varint, []u8),
                x4: ArrayType(varint, []u8),
                default: void,
            }),
        };

        pub const ScoreboardScore = struct {
            itemName: []u8,
            action: i8,
            scoreName: []u8,
            value: SwitchType(action, struct {
                x1: null,
                default: varint,
            }),
        };

        pub const SpawnPosition = struct {
            location: position,
            angle: f32,
        };

        pub const UpdateTime = struct {
            age: i64,
            time: i64,
        };

        pub const EntitySoundEffect = struct {
            soundId: varint,
            soundCategory: varint,
            entityId: varint,
            volume: f32,
            pitch: f32,
        };

        pub const StopSound = struct {
            flags: i8,
            source: SwitchType(flags, struct {
                x1: varint,
                x3: varint,
                default: void,
            }),
            sound: SwitchType(flags, struct {
                x2: []u8,
                x3: []u8,
                default: void,
            }),
        };

        pub const SoundEffect = struct {
            soundId: varint,
            soundCategory: varint,
            x: i32,
            y: i32,
            z: i32,
            volume: f32,
            pitch: f32,
        };

        pub const PlayerlistHeader = struct {
            header: []u8,
            footer: []u8,
        };

        pub const Collect = struct {
            collectedEntityId: varint,
            collectorEntityId: varint,
            pickupItemCount: varint,
        };

        pub const EntityTeleport = struct {
            entityId: varint,
            x: f64,
            y: f64,
            z: f64,
            yaw: i8,
            pitch: i8,
            onGround: bool,
        };

        pub const EntityUpdateAttributes = struct {
            entityId: varint,
            properties: ArrayType(varint, struct {
                key: []u8,
                value: f64,
                modifiers: ArrayType(varint, struct {
                        uuid: UUID,
                        amount: f64,
                        operation: i8,
                    }),
            }),
        };

        pub const EntityEffect = struct {
            entityId: varint,
            effectId: i8,
            amplifier: i8,
            duration: varint,
            hideParticles: i8,
        };

        pub const SelectAdvancementTab = struct {
            id: ?[]u8,
        };

        pub const DeclareRecipes = struct {
            recipes: ArrayType(varint, struct {
                type: []u8,
                recipeId: []u8,
                data: SwitchType(type, struct {
                        xminecraft:crafting_shapeless: struct {
                    group: []u8,
                    ingredients: ArrayType(varint, UNKNOWN_SIMPLE_TYPE(ingredient)),
                    result: slot,
                },
                        xminecraft:crafting_shaped: struct {
                    width: varint,
                    height: varint,
                    group: []u8,
                    ingredients: ArrayType(undefined, ArrayType(undefined, UNKNOWN_SIMPLE_TYPE(ingredient))),
                    result: slot,
                },
                        xminecraft:crafting_special_armordye: null,
                        xminecraft:crafting_special_bookcloning: null,
                        xminecraft:crafting_special_mapcloning: null,
                        xminecraft:crafting_special_mapextending: null,
                        xminecraft:crafting_special_firework_rocket: null,
                        xminecraft:crafting_special_firework_star: null,
                        xminecraft:crafting_special_firework_star_fade: null,
                        xminecraft:crafting_special_repairitem: null,
                        xminecraft:crafting_special_tippedarrow: null,
                        xminecraft:crafting_special_bannerduplicate: null,
                        xminecraft:crafting_special_banneraddpattern: null,
                        xminecraft:crafting_special_shielddecoration: null,
                        xminecraft:crafting_special_shulkerboxcoloring: null,
                        xminecraft:crafting_special_suspiciousstew: null,
                        xminecraft:smelting: UNKNOWN_SIMPLE_TYPE(minecraft_smelting_format),
                        xminecraft:blasting: UNKNOWN_SIMPLE_TYPE(minecraft_smelting_format),
                        xminecraft:smoking: UNKNOWN_SIMPLE_TYPE(minecraft_smelting_format),
                        xminecraft:campfire_cooking: UNKNOWN_SIMPLE_TYPE(minecraft_smelting_format),
                        xminecraft:stonecutting: struct {
                    group: []u8,
                    ingredient: UNKNOWN_SIMPLE_TYPE(ingredient),
                    result: slot,
                },
                        xminecraft:smithing: struct {
                    base: UNKNOWN_SIMPLE_TYPE(ingredient),
                    addition: UNKNOWN_SIMPLE_TYPE(ingredient),
                    result: slot,
                },
                        default: void,
                    }),
            }),
        };

        pub const Tags = struct {
            tags: ArrayType(varint, struct {
                tagType: []u8,
                tags: tags,
            }),
        };

        pub const AcknowledgePlayerDigging = struct {
            location: position,
            block: varint,
            status: varint,
            successful: bool,
        };

        pub const SculkVibrationSignal = struct {
            sourcePosition: position,
            destinationIdentifier: []u8,
            destination: SwitchType(destinationIdentifier, struct {
                xblock: position,
                xentityId: varint,
                default: void,
            }),
            arrivalTicks: varint,
        };

        pub const ClearTitles = struct {
            reset: bool,
        };

        pub const InitializeWorldBorder = struct {
            x: f64,
            z: f64,
            oldDiameter: f64,
            newDiameter: f64,
            speed: varint,
            portalTeleportBoundary: varint,
            warningBlocks: varint,
            warningTime: varint,
        };

        pub const ActionBar = struct {
            text: []u8,
        };

        pub const WorldBorderCenter = struct {
            x: f64,
            z: f64,
        };

        pub const WorldBorderLerpSize = struct {
            oldDiameter: f64,
            newDiameter: f64,
            speed: varint,
        };

        pub const WorldBorderSize = struct {
            diameter: f64,
        };

        pub const WorldBorderWarningDelay = struct {
            warningTime: varint,
        };

        pub const WorldBorderWarningReach = struct {
            warningBlocks: varint,
        };

        pub const Ping = struct {
            id: i32,
        };

        pub const SetTitleSubtitle = struct {
            text: []u8,
        };

        pub const SetTitleText = struct {
            text: []u8,
        };

        pub const SetTitleTime = struct {
            fadeIn: i32,
            stay: i32,
            fadeOut: i32,
        };

        spawn_entity: SpawnEntity,
        spawn_entity_experience_orb: SpawnEntityExperienceOrb,
        spawn_entity_living: SpawnEntityLiving,
        spawn_entity_painting: SpawnEntityPainting,
        named_entity_spawn: NamedEntitySpawn,
        sculk_vibration_signal: SculkVibrationSignal,
        animation: Animation,
        statistics: Statistics,
        acknowledge_player_digging: AcknowledgePlayerDigging,
        block_break_animation: BlockBreakAnimation,
        tile_entity_data: TileEntityData,
        block_action: BlockAction,
        block_change: BlockChange,
        boss_bar: BossBar,
        difficulty: Difficulty,
        chat: Chat,
        clear_titles: ClearTitles,
        tab_complete: TabComplete,
        declare_commands: DeclareCommands,
        close_window: CloseWindow,
        window_items: WindowItems,
        craft_progress_bar: CraftProgressBar,
        set_slot: SetSlot,
        set_cooldown: SetCooldown,
        custom_payload: CustomPayload,
        named_sound_effect: NamedSoundEffect,
        kick_disconnect: KickDisconnect,
        entity_status: EntityStatus,
        explosion: Explosion,
        unload_chunk: UnloadChunk,
        game_state_change: GameStateChange,
        open_horse_window: OpenHorseWindow,
        initialize_world_border: InitializeWorldBorder,
        keep_alive: KeepAlive,
        map_chunk: MapChunk,
        world_event: WorldEvent,
        world_particles: WorldParticles,
        update_light: UpdateLight,
        login: Login,
        map: Map,
        trade_list: TradeList,
        rel_entity_move: RelEntityMove,
        entity_move_look: EntityMoveLook,
        entity_look: EntityLook,
        vehicle_move: VehicleMove,
        open_book: OpenBook,
        open_window: OpenWindow,
        open_sign_entity: OpenSignEntity,
        ping: Ping,
        craft_recipe_response: CraftRecipeResponse,
        abilities: Abilities,
        end_combat_event: EndCombatEvent,
        enter_combat_event: EnterCombatEvent,
        death_combat_event: DeathCombatEvent,
        player_info: PlayerInfo,
        face_player: FacePlayer,
        position: Position,
        unlock_recipes: UnlockRecipes,
        destroy_entity: DestroyEntity,
        remove_entity_effect: RemoveEntityEffect,
        resource_pack_send: ResourcePackSend,
        respawn: Respawn,
        entity_head_rotation: EntityHeadRotation,
        multi_block_change: MultiBlockChange,
        select_advancement_tab: SelectAdvancementTab,
        action_bar: ActionBar,
        world_border_center: WorldBorderCenter,
        world_border_lerp_size: WorldBorderLerpSize,
        world_border_size: WorldBorderSize,
        world_border_warning_delay: WorldBorderWarningDelay,
        world_border_warning_reach: WorldBorderWarningReach,
        camera: Camera,
        held_item_slot: HeldItemSlot,
        update_view_position: UpdateViewPosition,
        update_view_distance: UpdateViewDistance,
        spawn_position: SpawnPosition,
        scoreboard_display_objective: ScoreboardDisplayObjective,
        entity_metadata: EntityMetadata,
        attach_entity: AttachEntity,
        entity_velocity: EntityVelocity,
        entity_equipment: EntityEquipment,
        experience: Experience,
        update_health: UpdateHealth,
        scoreboard_objective: ScoreboardObjective,
        set_passengers: SetPassengers,
        teams: Teams,
        scoreboard_score: ScoreboardScore,
        set_title_subtitle: SetTitleSubtitle,
        update_time: UpdateTime,
        set_title_text: SetTitleText,
        set_title_time: SetTitleTime,
        entity_sound_effect: EntitySoundEffect,
        sound_effect: SoundEffect,
        stop_sound: StopSound,
        playerlist_header: PlayerlistHeader,
        nbt_query_response: NbtQueryResponse,
        collect: Collect,
        entity_teleport: EntityTeleport,
        advancements: Advancements,
        entity_update_attributes: EntityUpdateAttributes,
        entity_effect: EntityEffect,
        declare_recipes: DeclareRecipes,
        tags: Tags,
    };

    pub const c2s = union(C2S) {
        pub const TeleportConfirm = struct {
            teleportId: varint,
        };

        pub const QueryBlockNbt = struct {
            transactionId: varint,
            location: position,
        };

        pub const SetDifficulty = struct {
            newDifficulty: u8,
        };

        pub const EditBook = struct {
            new_book: slot,
            signing: bool,
            hand: varint,
        };

        pub const QueryEntityNbt = struct {
            transactionId: varint,
            entityId: varint,
        };

        pub const PickItem = struct {
            slot: varint,
        };

        pub const NameItem = struct {
            name: []u8,
        };

        pub const SelectTrade = struct {
            slot: varint,
        };

        pub const SetBeaconEffect = struct {
            primary_effect: varint,
            secondary_effect: varint,
        };

        pub const UpdateCommandBlock = struct {
            location: position,
            command: []u8,
            mode: varint,
            flags: u8,
        };

        pub const UpdateCommandBlockMinecart = struct {
            entityId: varint,
            command: []u8,
            track_output: bool,
        };

        pub const UpdateStructureBlock = struct {
            location: position,
            action: varint,
            mode: varint,
            name: []u8,
            offset_x: u8,
            offset_y: u8,
            offset_z: u8,
            size_x: u8,
            size_y: u8,
            size_z: u8,
            mirror: varint,
            rotation: varint,
            metadata: []u8,
            integrity: f32,
            seed: varint,
            flags: u8,
        };

        pub const TabComplete = struct {
            transactionId: varint,
            text: []u8,
        };

        pub const Chat = struct {
            message: []u8,
        };

        pub const ClientCommand = struct {
            actionId: varint,
        };

        pub const Settings = struct {
            locale: []u8,
            viewDistance: i8,
            chatFlags: varint,
            chatColors: bool,
            skinParts: u8,
            mainHand: varint,
            disableTextFiltering: bool,
        };

        pub const EnchantItem = struct {
            windowId: i8,
            enchantment: i8,
        };

        pub const WindowClick = struct {
            windowId: u8,
            slot: i16,
            mouseButton: i8,
            mode: i8,
            changedSlots: ArrayType(varint, struct {
                location: i16,
                item: slot,
            }),
            clicked_item: slot,
        };

        pub const CloseWindow = struct {
            windowId: u8,
        };

        pub const CustomPayload = struct {
            channel: []u8,
            data: []u8,
        };

        pub const UseEntity = struct {
            target: varint,
            mouse: varint,
            x: SwitchType(mouse, struct {
                x2: f32,
                default: void,
            }),
            y: SwitchType(mouse, struct {
                x2: f32,
                default: void,
            }),
            z: SwitchType(mouse, struct {
                x2: f32,
                default: void,
            }),
            hand: SwitchType(mouse, struct {
                x0: varint,
                x2: varint,
                default: void,
            }),
            sneaking: bool,
        };

        pub const GenerateStructure = struct {
            location: position,
            levels: varint,
            keepJigsaws: bool,
        };

        pub const KeepAlive = struct {
            keepAliveId: i64,
        };

        pub const LockDifficulty = struct {
            locked: bool,
        };

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
            onGround: bool,
        };

        pub const PositionLook = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
            onGround: bool,
        };

        pub const Look = struct {
            yaw: f32,
            pitch: f32,
            onGround: bool,
        };

        pub const Flying = struct {
            onGround: bool,
        };

        pub const VehicleMove = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
        };

        pub const SteerBoat = struct {
            leftPaddle: bool,
            rightPaddle: bool,
        };

        pub const CraftRecipeRequest = struct {
            windowId: i8,
            recipe: []u8,
            makeAll: bool,
        };

        pub const Abilities = struct {
            flags: i8,
        };

        pub const BlockDig = struct {
            status: i8,
            location: position,
            face: i8,
        };

        pub const EntityAction = struct {
            entityId: varint,
            actionId: varint,
            jumpBoost: varint,
        };

        pub const SteerVehicle = struct {
            sideways: f32,
            forward: f32,
            jump: u8,
        };

        pub const DisplayedRecipe = struct {
            recipeId: []u8,
        };

        pub const RecipeBook = struct {
            bookId: varint,
            bookOpen: bool,
            filterActive: bool,
        };

        pub const ResourcePackReceive = struct {
            result: varint,
        };

        pub const HeldItemSlot = struct {
            slotId: i16,
        };

        pub const SetCreativeSlot = struct {
            slot: i16,
            item: slot,
        };

        pub const UpdateJigsawBlock = struct {
            location: position,
            name: []u8,
            target: []u8,
            pool: []u8,
            finalState: []u8,
            jointType: []u8,
        };

        pub const UpdateSign = struct {
            location: position,
            text1: []u8,
            text2: []u8,
            text3: []u8,
            text4: []u8,
        };

        pub const ArmAnimation = struct {
            hand: varint,
        };

        pub const Spectate = struct {
            target: UUID,
        };

        pub const BlockPlace = struct {
            hand: varint,
            location: position,
            direction: varint,
            cursorX: f32,
            cursorY: f32,
            cursorZ: f32,
            insideBlock: bool,
        };

        pub const UseItem = struct {
            hand: varint,
        };

        pub const AdvancementTab = struct {
            action: varint,
            tabId: SwitchType(action, struct {
                x0: []u8,
                x1: null,
                default: void,
            }),
        };

        pub const Pong = struct {
            id: i32,
        };

        teleport_confirm: TeleportConfirm,
        query_block_nbt: QueryBlockNbt,
        set_difficulty: SetDifficulty,
        chat: Chat,
        client_command: ClientCommand,
        settings: Settings,
        tab_complete: TabComplete,
        enchant_item: EnchantItem,
        window_click: WindowClick,
        close_window: CloseWindow,
        custom_payload: CustomPayload,
        edit_book: EditBook,
        query_entity_nbt: QueryEntityNbt,
        use_entity: UseEntity,
        generate_structure: GenerateStructure,
        keep_alive: KeepAlive,
        lock_difficulty: LockDifficulty,
        position: Position,
        position_look: PositionLook,
        look: Look,
        flying: Flying,
        vehicle_move: VehicleMove,
        steer_boat: SteerBoat,
        pick_item: PickItem,
        craft_recipe_request: CraftRecipeRequest,
        abilities: Abilities,
        block_dig: BlockDig,
        entity_action: EntityAction,
        steer_vehicle: SteerVehicle,
        pong: Pong,
        displayed_recipe: DisplayedRecipe,
        recipe_book: RecipeBook,
        name_item: NameItem,
        resource_pack_receive: ResourcePackReceive,
        advancement_tab: AdvancementTab,
        select_trade: SelectTrade,
        set_beacon_effect: SetBeaconEffect,
        held_item_slot: HeldItemSlot,
        update_command_block: UpdateCommandBlock,
        update_command_block_minecart: UpdateCommandBlockMinecart,
        set_creative_slot: SetCreativeSlot,
        update_jigsaw_block: UpdateJigsawBlock,
        update_structure_block: UpdateStructureBlock,
        update_sign: UpdateSign,
        arm_animation: ArmAnimation,
        spectate: Spectate,
        block_place: BlockPlace,
        use_item: UseItem,
    };
};
