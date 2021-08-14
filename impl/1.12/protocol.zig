pub const string = []u8,

pub const slot = struct {
    blockId: i16,
undefined
},

pub const position = packed struct {
        x: i26,
        y: i12,
        z: i26,
    },

pub const entityMetadataItem = SwitchType($compareTo, struct {
        x0: i8,
        x1: varint,
        x2: f32,
        x3: []u8,
        x4: []u8,
        x5: slot,
        x6: bool,
        x7: struct {
    pitch: f32,
    yaw: f32,
    roll: f32,
},
        x8: position,
        x9: ?position,
        x10: varint,
        x11: ?UUID,
        x12: varint,
        x13: nbt,
        default: void,
    }),

pub const entityMetadata = EntityMetadata,

pub const handshaking = struct {
    pub const s2c = union(S2C) {
    
        pub const S2C = enum(u8) {
        };
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
    
        pub const C2S = enum(u8) {
            set_protocol: 0x00,
            legacy_server_list_ping: 0xfe,
        };
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
    
        pub const S2C = enum(u8) {
            server_info: 0x00,
            ping: 0x01,
        };
    };

    pub const c2s = union(C2S) {
        pub const PingStart = struct {
        };

        pub const Ping = struct {
            time: i64,
        };

        ping_start: PingStart,
        ping: Ping,
    
        pub const C2S = enum(u8) {
            ping_start: 0x00,
            ping: 0x01,
        };
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
            uuid: []u8,
            username: []u8,
        };

        pub const Compress = struct {
            threshold: varint,
        };

        disconnect: Disconnect,
        encryption_begin: EncryptionBegin,
        success: Success,
        compress: Compress,
    
        pub const S2C = enum(u8) {
            disconnect: 0x00,
            encryption_begin: 0x01,
            success: 0x02,
            compress: 0x03,
        };
    };

    pub const c2s = union(C2S) {
        pub const LoginStart = struct {
            username: []u8,
        };

        pub const EncryptionBegin = struct {
            sharedSecret: []u8,
            verifyToken: []u8,
        };

        login_start: LoginStart,
        encryption_begin: EncryptionBegin,
    
        pub const C2S = enum(u8) {
            login_start: 0x00,
            encryption_begin: 0x01,
        };
    };
};
pub const play = struct {
    pub const s2c = union(S2C) {
        pub const SpawnEntity = struct {
            entityId: varint,
            objectUUID: UUID,
            type: i8,
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

        pub const SpawnEntityWeather = struct {
            entityId: varint,
            type: i8,
            x: f64,
            y: f64,
            z: f64,
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
            metadata: EntityMetadata,
        };

        pub const SpawnEntityPainting = struct {
            entityId: varint,
            entityUUID: UUID,
            title: []u8,
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
            metadata: EntityMetadata,
        };

        pub const Animation = struct {
            entityId: varint,
            animation: u8,
        };

        pub const Statistics = struct {
            entries: ArrayType(varint, struct {
                name: []u8,
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
                        backgroundTexture: SwitchType(has_background_texture, struct {
                                x1: []u8,
                                default: void,
                            }),
                        xCord: f32,
                        yCord: f32,
                    },
                    criteria: ArrayType(varint, struct {
                            key: []u8,
                            value: void,
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
        };

        pub const TabComplete = struct {
            matches: ArrayType(varint, []u8),
        };

        pub const Chat = struct {
            message: []u8,
            position: i8,
        };

        pub const MultiBlockChange = struct {
            chunkX: i32,
            chunkZ: i32,
            records: ArrayType(varint, struct {
                horizontalPos: u8,
                y: u8,
                blockId: varint,
            }),
        };

        pub const Transaction = struct {
            windowId: i8,
            action: i16,
            accepted: bool,
        };

        pub const CloseWindow = struct {
            windowId: u8,
        };

        pub const OpenWindow = struct {
            windowId: u8,
            inventoryType: []u8,
            windowTitle: []u8,
            slotCount: u8,
            entityId: SwitchType(inventoryType, struct {
                xEntityHorse: i32,
                default: void,
            }),
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
            affectedBlockOffsets: ArrayType(i32, struct {
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

        pub const KeepAlive = struct {
            keepAliveId: varint,
        };

        pub const MapChunk = struct {
            x: i32,
            z: i32,
            groundUp: bool,
            bitMap: varint,
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
            x: f32,
            y: f32,
            z: f32,
            offsetX: f32,
            offsetY: f32,
            offsetZ: f32,
            particleData: f32,
            particles: i32,
            data: SwitchType(particleId, struct {
                x36: ArrayType(undefined, varint),
                x37: ArrayType(undefined, varint),
                x38: ArrayType(undefined, varint),
                default: void,
            }),
        };

        pub const Login = struct {
            entityId: i32,
            gameMode: u8,
            dimension: i32,
            difficulty: u8,
            maxPlayers: u8,
            levelType: []u8,
            reducedDebugInfo: bool,
        };

        pub const Map = struct {
            itemDamage: varint,
            scale: i8,
            trackingPosition: bool,
            icons: ArrayType(varint, struct {
                directionAndType: i8,
                x: i8,
                y: i8,
            }),
            columns: i8,
            rows: SwitchType(columns, struct {
                x0: void,
                default: i8,
            }),
            x: SwitchType(columns, struct {
                x0: void,
                default: i8,
            }),
            y: SwitchType(columns, struct {
                x0: void,
                default: i8,
            }),
            data: SwitchType(columns, struct {
                x0: void,
                default: []u8,
            }),
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

        pub const Entity = struct {
            entityId: varint,
        };

        pub const VehicleMove = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
        };

        pub const OpenSignEntity = struct {
            location: position,
        };

        pub const Abilities = struct {
            flags: i8,
            flyingSpeed: f32,
            walkingSpeed: f32,
        };

        pub const CombatEvent = struct {
            event: varint,
            duration: SwitchType(event, struct {
                x1: varint,
                default: void,
            }),
            playerId: SwitchType(event, struct {
                x2: varint,
                default: void,
            }),
            entityId: SwitchType(event, struct {
                x1: i32,
                x2: i32,
                default: void,
            }),
            message: SwitchType(event, struct {
                x2: []u8,
                default: void,
            }),
        };

        pub const PlayerInfo = struct {
            action: varint,
            data: ArrayType(varint, struct {
                UUID: UUID,
                name: SwitchType(action, struct {
                        x0: []u8,
                        default: void,
                    }),
                properties: SwitchType(action, struct {
                        x0: ArrayType(varint, struct {
                        name: []u8,
                        value: []u8,
                        signature: ?[]u8,
                    }),
                        default: void,
                    }),
                gamemode: SwitchType(action, struct {
                        x0: varint,
                        x1: varint,
                        default: void,
                    }),
                ping: SwitchType(action, struct {
                        x0: varint,
                        x2: varint,
                        default: void,
                    }),
                displayName: SwitchType(action, struct {
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
        };

        pub const Bed = struct {
            entityId: varint,
            location: position,
        };

        pub const UnlockRecipes = struct {
            action: varint,
            craftingBookOpen: bool,
            filteringCraftable: bool,
            recipes1: ArrayType(varint, varint),
            recipes2: SwitchType(action, struct {
                x0: ArrayType(varint, varint),
                default: void,
            }),
        };

        pub const EntityDestroy = struct {
            entityIds: ArrayType(varint, varint),
        };

        pub const RemoveEntityEffect = struct {
            entityId: varint,
            effectId: i8,
        };

        pub const ResourcePackSend = struct {
            url: []u8,
            hash: []u8,
        };

        pub const Respawn = struct {
            dimension: i32,
            difficulty: u8,
            gamemode: u8,
            levelType: []u8,
        };

        pub const EntityHeadRotation = struct {
            entityId: varint,
            headYaw: i8,
        };

        pub const WorldBorder = struct {
            action: varint,
            radius: SwitchType(action, struct {
                x0: f64,
                default: void,
            }),
            x: SwitchType(action, struct {
                x2: f64,
                x3: f64,
                default: void,
            }),
            z: SwitchType(action, struct {
                x2: f64,
                x3: f64,
                default: void,
            }),
            old_radius: SwitchType(action, struct {
                x1: f64,
                x3: f64,
                default: void,
            }),
            new_radius: SwitchType(action, struct {
                x1: f64,
                x3: f64,
                default: void,
            }),
            speed: SwitchType(action, struct {
                x1: varint,
                x3: varint,
                default: void,
            }),
            portalBoundary: SwitchType(action, struct {
                x3: varint,
                default: void,
            }),
            warning_time: SwitchType(action, struct {
                x3: varint,
                x4: varint,
                default: void,
            }),
            warning_blocks: SwitchType(action, struct {
                x3: varint,
                x5: varint,
                default: void,
            }),
        };

        pub const Camera = struct {
            cameraId: varint,
        };

        pub const HeldItemSlot = struct {
            slot: i8,
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
            slot: varint,
            item: slot,
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
                x0: []u8,
                x2: []u8,
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
            color: SwitchType(mode, struct {
                x0: i8,
                x2: i8,
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
                x1: void,
                default: varint,
            }),
        };

        pub const SpawnPosition = struct {
            location: position,
        };

        pub const UpdateTime = struct {
            age: i64,
            time: i64,
        };

        pub const Title = struct {
            action: varint,
            text: SwitchType(action, struct {
                x0: []u8,
                x1: []u8,
                x2: []u8,
                default: void,
            }),
            fadeIn: SwitchType(action, struct {
                x3: i32,
                default: void,
            }),
            stay: SwitchType(action, struct {
                x3: i32,
                default: void,
            }),
            fadeOut: SwitchType(action, struct {
                x3: i32,
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
            properties: ArrayType(i32, struct {
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

        spawn_entity: SpawnEntity,
        spawn_entity_experience_orb: SpawnEntityExperienceOrb,
        spawn_entity_weather: SpawnEntityWeather,
        spawn_entity_living: SpawnEntityLiving,
        spawn_entity_painting: SpawnEntityPainting,
        named_entity_spawn: NamedEntitySpawn,
        animation: Animation,
        statistics: Statistics,
        block_break_animation: BlockBreakAnimation,
        tile_entity_data: TileEntityData,
        block_action: BlockAction,
        block_change: BlockChange,
        boss_bar: BossBar,
        difficulty: Difficulty,
        tab_complete: TabComplete,
        chat: Chat,
        multi_block_change: MultiBlockChange,
        transaction: Transaction,
        close_window: CloseWindow,
        open_window: OpenWindow,
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
        keep_alive: KeepAlive,
        map_chunk: MapChunk,
        world_event: WorldEvent,
        world_particles: WorldParticles,
        login: Login,
        map: Map,
        entity: Entity,
        rel_entity_move: RelEntityMove,
        entity_move_look: EntityMoveLook,
        entity_look: EntityLook,
        vehicle_move: VehicleMove,
        open_sign_entity: OpenSignEntity,
        abilities: Abilities,
        combat_event: CombatEvent,
        player_info: PlayerInfo,
        position: Position,
        bed: Bed,
        unlock_recipes: UnlockRecipes,
        entity_destroy: EntityDestroy,
        remove_entity_effect: RemoveEntityEffect,
        resource_pack_send: ResourcePackSend,
        respawn: Respawn,
        entity_head_rotation: EntityHeadRotation,
        select_advancement_tab: SelectAdvancementTab,
        world_border: WorldBorder,
        camera: Camera,
        held_item_slot: HeldItemSlot,
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
        spawn_position: SpawnPosition,
        update_time: UpdateTime,
        title: Title,
        sound_effect: SoundEffect,
        playerlist_header: PlayerlistHeader,
        collect: Collect,
        entity_teleport: EntityTeleport,
        advancements: Advancements,
        entity_update_attributes: EntityUpdateAttributes,
        entity_effect: EntityEffect,
    
        pub const S2C = enum(u8) {
            spawn_entity: 0x00,
            spawn_entity_experience_orb: 0x01,
            spawn_entity_weather: 0x02,
            spawn_entity_living: 0x03,
            spawn_entity_painting: 0x04,
            named_entity_spawn: 0x05,
            animation: 0x06,
            statistics: 0x07,
            block_break_animation: 0x08,
            tile_entity_data: 0x09,
            block_action: 0x0a,
            block_change: 0x0b,
            boss_bar: 0x0c,
            difficulty: 0x0d,
            tab_complete: 0x0e,
            chat: 0x0f,
            multi_block_change: 0x10,
            transaction: 0x11,
            close_window: 0x12,
            open_window: 0x13,
            window_items: 0x14,
            craft_progress_bar: 0x15,
            set_slot: 0x16,
            set_cooldown: 0x17,
            custom_payload: 0x18,
            named_sound_effect: 0x19,
            kick_disconnect: 0x1a,
            entity_status: 0x1b,
            explosion: 0x1c,
            unload_chunk: 0x1d,
            game_state_change: 0x1e,
            keep_alive: 0x1f,
            map_chunk: 0x20,
            world_event: 0x21,
            world_particles: 0x22,
            login: 0x23,
            map: 0x24,
            entity: 0x25,
            rel_entity_move: 0x26,
            entity_move_look: 0x27,
            entity_look: 0x28,
            vehicle_move: 0x29,
            open_sign_entity: 0x2a,
            abilities: 0x2b,
            combat_event: 0x2c,
            player_info: 0x2d,
            position: 0x2e,
            bed: 0x2f,
            unlock_recipes: 0x30,
            entity_destroy: 0x31,
            remove_entity_effect: 0x32,
            resource_pack_send: 0x33,
            respawn: 0x34,
            entity_head_rotation: 0x35,
            select_advancement_tab: 0x36,
            world_border: 0x37,
            camera: 0x38,
            held_item_slot: 0x39,
            scoreboard_display_objective: 0x3a,
            entity_metadata: 0x3b,
            attach_entity: 0x3c,
            entity_velocity: 0x3d,
            entity_equipment: 0x3e,
            experience: 0x3f,
            update_health: 0x40,
            scoreboard_objective: 0x41,
            set_passengers: 0x42,
            teams: 0x43,
            scoreboard_score: 0x44,
            spawn_position: 0x45,
            update_time: 0x46,
            title: 0x47,
            sound_effect: 0x48,
            playerlist_header: 0x49,
            collect: 0x4a,
            entity_teleport: 0x4b,
            advancements: 0x4c,
            entity_update_attributes: 0x4d,
            entity_effect: 0x4e,
        };
    };

    pub const c2s = union(C2S) {
        pub const TeleportConfirm = struct {
            teleportId: varint,
        };

        pub const PrepareCraftingGrid = struct {
            windowId: u8,
            actionNumber: u16,
            returnEntry: ArrayType(u16, struct {
                item: slot,
                craftingSlot: u8,
                playerSlot: u8,
            }),
            prepareEntry: ArrayType(u16, struct {
                item: slot,
                craftingSlot: u8,
                playerSlot: u8,
            }),
        };

        pub const TabComplete = struct {
            text: []u8,
            assumeCommand: bool,
            lookedAtBlock: ?position,
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
        };

        pub const Transaction = struct {
            windowId: i8,
            action: i16,
            accepted: bool,
        };

        pub const EnchantItem = struct {
            windowId: i8,
            enchantment: i8,
        };

        pub const WindowClick = struct {
            windowId: u8,
            slot: i16,
            mouseButton: i8,
            action: i16,
            mode: i8,
            item: slot,
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
        };

        pub const KeepAlive = struct {
            keepAliveId: varint,
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

        pub const Abilities = struct {
            flags: i8,
            flyingSpeed: f32,
            walkingSpeed: f32,
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

        pub const CraftingBookData = struct {
            type: varint,
            undefined: SwitchType(type, struct {
                x0: struct {
            displayedRecipe: i32,
        },
                x1: struct {
            craftingBookOpen: bool,
            craftingFilter: bool,
        },
                default: void,
            }),
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
            location: position,
            direction: varint,
            hand: varint,
            cursorX: f32,
            cursorY: f32,
            cursorZ: f32,
        };

        pub const UseItem = struct {
            hand: varint,
        };

        pub const AdvancementTab = struct {
            action: varint,
            tabId: SwitchType(action, struct {
                x0: []u8,
                x1: void,
                default: void,
            }),
        };

        teleport_confirm: TeleportConfirm,
        prepare_crafting_grid: PrepareCraftingGrid,
        tab_complete: TabComplete,
        chat: Chat,
        client_command: ClientCommand,
        settings: Settings,
        transaction: Transaction,
        enchant_item: EnchantItem,
        window_click: WindowClick,
        close_window: CloseWindow,
        custom_payload: CustomPayload,
        use_entity: UseEntity,
        keep_alive: KeepAlive,
        flying: Flying,
        position: Position,
        position_look: PositionLook,
        look: Look,
        vehicle_move: VehicleMove,
        steer_boat: SteerBoat,
        abilities: Abilities,
        block_dig: BlockDig,
        entity_action: EntityAction,
        steer_vehicle: SteerVehicle,
        crafting_book_data: CraftingBookData,
        resource_pack_receive: ResourcePackReceive,
        advancement_tab: AdvancementTab,
        held_item_slot: HeldItemSlot,
        set_creative_slot: SetCreativeSlot,
        update_sign: UpdateSign,
        arm_animation: ArmAnimation,
        spectate: Spectate,
        block_place: BlockPlace,
        use_item: UseItem,
    
        pub const C2S = enum(u8) {
            teleport_confirm: 0x00,
            prepare_crafting_grid: 0x01,
            tab_complete: 0x02,
            chat: 0x03,
            client_command: 0x04,
            settings: 0x05,
            transaction: 0x06,
            enchant_item: 0x07,
            window_click: 0x08,
            close_window: 0x09,
            custom_payload: 0x0a,
            use_entity: 0x0b,
            keep_alive: 0x0c,
            flying: 0x0d,
            position: 0x0e,
            position_look: 0x0f,
            look: 0x10,
            vehicle_move: 0x11,
            steer_boat: 0x12,
            abilities: 0x13,
            block_dig: 0x14,
            entity_action: 0x15,
            steer_vehicle: 0x16,
            crafting_book_data: 0x17,
            resource_pack_receive: 0x18,
            advancement_tab: 0x19,
            held_item_slot: 0x1a,
            set_creative_slot: 0x1b,
            update_sign: 0x1c,
            arm_animation: 0x1d,
            spectate: 0x1e,
            block_place: 0x1f,
            use_item: 0x20,
        };
    };
};
