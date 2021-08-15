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
        pub const KeepAlive = struct {
            keepAliveId: varint,
        };

        pub const Login = struct {
            entityId: i32,
            gameMode: u8,
            dimension: i8,
            difficulty: u8,
            maxPlayers: u8,
            levelType: []u8,
            reducedDebugInfo: bool,
        };

        pub const Chat = struct {
            message: []u8,
            position: i8,
        };

        pub const UpdateTime = struct {
            age: i64,
            time: i64,
        };

        pub const EntityEquipment = struct {
            entityId: varint,
            slot: i16,
            item: ?Slot,
        };

        pub const SpawnPosition = struct {
            location: position,
        };

        pub const UpdateHealth = struct {
            health: f32,
            food: varint,
            foodSaturation: f32,
        };

        pub const Respawn = struct {
            dimension: i32,
            difficulty: u8,
            gamemode: u8,
            levelType: []u8,
        };

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
            flags: i8,
        };

        pub const HeldItemSlot = struct {
            slot: i8,
        };

        pub const Bed = struct {
            entityId: varint,
            location: position,
        };

        pub const Animation = struct {
            entityId: varint,
            animation: u8,
        };

        pub const NamedEntitySpawn = struct {
            entityId: varint,
            playerUUID: UUID,
            x: i32,
            y: i32,
            z: i32,
            yaw: i8,
            pitch: i8,
            currentItem: i16,
            metadata: EntityMetadata,
        };

        pub const Collect = struct {
            collectedEntityId: varint,
            collectorEntityId: varint,
        };

        pub const SpawnEntity = struct {
            entityId: varint,
            type: i8,
            x: i32,
            y: i32,
            z: i32,
            pitch: i8,
            yaw: i8,
            objectData: struct {
            intField: i32,
            velocityX: SwitchType(intField, struct {
                    x0: void,
                    default: i16,
                }),
            velocityY: SwitchType(intField, struct {
                    x0: void,
                    default: i16,
                }),
            velocityZ: SwitchType(intField, struct {
                    x0: void,
                    default: i16,
                }),
        },
        };

        pub const SpawnEntityLiving = struct {
            entityId: varint,
            type: u8,
            x: i32,
            y: i32,
            z: i32,
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
            title: []u8,
            location: position,
            direction: u8,
        };

        pub const SpawnEntityExperienceOrb = struct {
            entityId: varint,
            x: i32,
            y: i32,
            z: i32,
            count: i16,
        };

        pub const EntityVelocity = struct {
            entityId: varint,
            velocityX: i16,
            velocityY: i16,
            velocityZ: i16,
        };

        pub const EntityDestroy = struct {
            entityIds: ArrayType(varint, varint),
        };

        pub const Entity = struct {
            entityId: varint,
        };

        pub const RelEntityMove = struct {
            entityId: varint,
            dX: i8,
            dY: i8,
            dZ: i8,
            onGround: bool,
        };

        pub const EntityLook = struct {
            entityId: varint,
            yaw: i8,
            pitch: i8,
            onGround: bool,
        };

        pub const EntityMoveLook = struct {
            entityId: varint,
            dX: i8,
            dY: i8,
            dZ: i8,
            yaw: i8,
            pitch: i8,
            onGround: bool,
        };

        pub const EntityTeleport = struct {
            entityId: varint,
            x: i32,
            y: i32,
            z: i32,
            yaw: i8,
            pitch: i8,
            onGround: bool,
        };

        pub const EntityHeadRotation = struct {
            entityId: varint,
            headYaw: i8,
        };

        pub const EntityStatus = struct {
            entityId: i32,
            entityStatus: i8,
        };

        pub const AttachEntity = struct {
            entityId: i32,
            vehicleId: i32,
            leash: bool,
        };

        pub const EntityMetadata = struct {
            entityId: varint,
            metadata: EntityMetadata,
        };

        pub const EntityEffect = struct {
            entityId: varint,
            effectId: i8,
            amplifier: i8,
            duration: varint,
            hideParticles: bool,
        };

        pub const RemoveEntityEffect = struct {
            entityId: varint,
            effectId: i8,
        };

        pub const Experience = struct {
            experienceBar: f32,
            level: varint,
            totalExperience: varint,
        };

        pub const UpdateAttributes = struct {
            entityId: varint,
            properties: ArrayType(i32, struct {
                key: []u8,
                value: f64,
                modifiers: ArrayType(varint, struct {
                        UUID: UUID,
                        amount: f64,
                        operation: i8,
                    }),
            }),
        };

        pub const MapChunk = struct {
            x: i32,
            z: i32,
            groundUp: bool,
            bitMap: u16,
            chunkData: []u8,
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

        pub const BlockChange = struct {
            location: position,
            type: varint,
        };

        pub const BlockAction = struct {
            location: position,
            byte1: u8,
            byte2: u8,
            blockId: varint,
        };

        pub const BlockBreakAnimation = struct {
            entityId: varint,
            location: position,
            destroyStage: i8,
        };

        pub const MapChunkBulk = struct {
            skyLightSent: bool,
            meta: ArrayType(varint, struct {
                x: i32,
                z: i32,
                bitMap: u16,
            }),
            data: []u8,
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

        pub const WorldEvent = struct {
            effectId: i32,
            location: position,
            data: i32,
            global: bool,
        };

        pub const NamedSoundEffect = struct {
            soundName: []u8,
            x: i32,
            y: i32,
            z: i32,
            volume: f32,
            pitch: u8,
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

        pub const GameStateChange = struct {
            reason: u8,
            gameMode: f32,
        };

        pub const SpawnEntityWeather = struct {
            entityId: varint,
            type: i8,
            x: i32,
            y: i32,
            z: i32,
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

        pub const CloseWindow = struct {
            windowId: u8,
        };

        pub const SetSlot = struct {
            windowId: i8,
            slot: i16,
            item: ?Slot,
        };

        pub const WindowItems = struct {
            windowId: u8,
            items: ArrayType(i16, ?Slot),
        };

        pub const CraftProgressBar = struct {
            windowId: u8,
            property: i16,
            value: i16,
        };

        pub const Transaction = struct {
            windowId: i8,
            action: i16,
            accepted: bool,
        };

        pub const UpdateSign = struct {
            location: position,
            text1: []u8,
            text2: []u8,
            text3: []u8,
            text4: []u8,
        };

        pub const Map = struct {
            itemDamage: varint,
            scale: i8,
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

        pub const TileEntityData = struct {
            location: position,
            action: u8,
            nbtData: ?NBT,
        };

        pub const OpenSignEntity = struct {
            location: position,
        };

        pub const Statistics = struct {
            entries: ArrayType(varint, struct {
                name: []u8,
                value: varint,
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

        pub const Abilities = struct {
            flags: i8,
            flyingSpeed: f32,
            walkingSpeed: f32,
        };

        pub const TabComplete = struct {
            matches: ArrayType(varint, []u8),
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

        pub const ScoreboardScore = struct {
            itemName: []u8,
            action: i8,
            scoreName: []u8,
            value: SwitchType(action, struct {
                x1: void,
                default: varint,
            }),
        };

        pub const ScoreboardDisplayObjective = struct {
            position: i8,
            name: []u8,
        };

        pub const ScoreboardTeam = struct {
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

        pub const CustomPayload = struct {
            channel: []u8,
            data: []u8,
        };

        pub const KickDisconnect = struct {
            reason: []u8,
        };

        pub const Difficulty = struct {
            difficulty: u8,
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

        pub const Camera = struct {
            cameraId: varint,
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

        pub const Title = struct {
            action: varint,
            text: SwitchType(action, struct {
                x0: []u8,
                x1: []u8,
                default: void,
            }),
            fadeIn: SwitchType(action, struct {
                x2: i32,
                default: void,
            }),
            stay: SwitchType(action, struct {
                x2: i32,
                default: void,
            }),
            fadeOut: SwitchType(action, struct {
                x2: i32,
                default: void,
            }),
        };

        pub const SetCompression = struct {
            threshold: varint,
        };

        pub const PlayerlistHeader = struct {
            header: []u8,
            footer: []u8,
        };

        pub const ResourcePackSend = struct {
            url: []u8,
            hash: []u8,
        };

        pub const UpdateEntityNbt = struct {
            entityId: varint,
            tag: nbt,
        };

        keep_alive: KeepAlive,
        login: Login,
        chat: Chat,
        update_time: UpdateTime,
        entity_equipment: EntityEquipment,
        spawn_position: SpawnPosition,
        update_health: UpdateHealth,
        respawn: Respawn,
        position: Position,
        held_item_slot: HeldItemSlot,
        bed: Bed,
        animation: Animation,
        named_entity_spawn: NamedEntitySpawn,
        collect: Collect,
        spawn_entity: SpawnEntity,
        spawn_entity_living: SpawnEntityLiving,
        spawn_entity_painting: SpawnEntityPainting,
        spawn_entity_experience_orb: SpawnEntityExperienceOrb,
        entity_velocity: EntityVelocity,
        entity_destroy: EntityDestroy,
        entity: Entity,
        rel_entity_move: RelEntityMove,
        entity_look: EntityLook,
        entity_move_look: EntityMoveLook,
        entity_teleport: EntityTeleport,
        entity_head_rotation: EntityHeadRotation,
        entity_status: EntityStatus,
        attach_entity: AttachEntity,
        entity_metadata: EntityMetadata,
        entity_effect: EntityEffect,
        remove_entity_effect: RemoveEntityEffect,
        experience: Experience,
        update_attributes: UpdateAttributes,
        map_chunk: MapChunk,
        multi_block_change: MultiBlockChange,
        block_change: BlockChange,
        block_action: BlockAction,
        block_break_animation: BlockBreakAnimation,
        map_chunk_bulk: MapChunkBulk,
        explosion: Explosion,
        world_event: WorldEvent,
        named_sound_effect: NamedSoundEffect,
        world_particles: WorldParticles,
        game_state_change: GameStateChange,
        spawn_entity_weather: SpawnEntityWeather,
        open_window: OpenWindow,
        close_window: CloseWindow,
        set_slot: SetSlot,
        window_items: WindowItems,
        craft_progress_bar: CraftProgressBar,
        transaction: Transaction,
        update_sign: UpdateSign,
        map: Map,
        tile_entity_data: TileEntityData,
        open_sign_entity: OpenSignEntity,
        statistics: Statistics,
        player_info: PlayerInfo,
        abilities: Abilities,
        tab_complete: TabComplete,
        scoreboard_objective: ScoreboardObjective,
        scoreboard_score: ScoreboardScore,
        scoreboard_display_objective: ScoreboardDisplayObjective,
        scoreboard_team: ScoreboardTeam,
        custom_payload: CustomPayload,
        kick_disconnect: KickDisconnect,
        difficulty: Difficulty,
        combat_event: CombatEvent,
        camera: Camera,
        world_border: WorldBorder,
        title: Title,
        set_compression: SetCompression,
        playerlist_header: PlayerlistHeader,
        resource_pack_send: ResourcePackSend,
        update_entity_nbt: UpdateEntityNbt,
    
        pub const S2C = enum(u8) {
            keep_alive: 0x00,
            login: 0x01,
            chat: 0x02,
            update_time: 0x03,
            entity_equipment: 0x04,
            spawn_position: 0x05,
            update_health: 0x06,
            respawn: 0x07,
            position: 0x08,
            held_item_slot: 0x09,
            bed: 0x0a,
            animation: 0x0b,
            named_entity_spawn: 0x0c,
            collect: 0x0d,
            spawn_entity: 0x0e,
            spawn_entity_living: 0x0f,
            spawn_entity_painting: 0x10,
            spawn_entity_experience_orb: 0x11,
            entity_velocity: 0x12,
            entity_destroy: 0x13,
            entity: 0x14,
            rel_entity_move: 0x15,
            entity_look: 0x16,
            entity_move_look: 0x17,
            entity_teleport: 0x18,
            entity_head_rotation: 0x19,
            entity_status: 0x1a,
            attach_entity: 0x1b,
            entity_metadata: 0x1c,
            entity_effect: 0x1d,
            remove_entity_effect: 0x1e,
            experience: 0x1f,
            update_attributes: 0x20,
            map_chunk: 0x21,
            multi_block_change: 0x22,
            block_change: 0x23,
            block_action: 0x24,
            block_break_animation: 0x25,
            map_chunk_bulk: 0x26,
            explosion: 0x27,
            world_event: 0x28,
            named_sound_effect: 0x29,
            world_particles: 0x2a,
            game_state_change: 0x2b,
            spawn_entity_weather: 0x2c,
            open_window: 0x2d,
            close_window: 0x2e,
            set_slot: 0x2f,
            window_items: 0x30,
            craft_progress_bar: 0x31,
            transaction: 0x32,
            update_sign: 0x33,
            map: 0x34,
            tile_entity_data: 0x35,
            open_sign_entity: 0x36,
            statistics: 0x37,
            player_info: 0x38,
            abilities: 0x39,
            tab_complete: 0x3a,
            scoreboard_objective: 0x3b,
            scoreboard_score: 0x3c,
            scoreboard_display_objective: 0x3d,
            scoreboard_team: 0x3e,
            custom_payload: 0x3f,
            kick_disconnect: 0x40,
            difficulty: 0x41,
            combat_event: 0x42,
            camera: 0x43,
            world_border: 0x44,
            title: 0x45,
            set_compression: 0x46,
            playerlist_header: 0x47,
            resource_pack_send: 0x48,
            update_entity_nbt: 0x49,
        };
    };

    pub const c2s = union(C2S) {
        pub const KeepAlive = struct {
            keepAliveId: varint,
        };

        pub const Chat = struct {
            message: []u8,
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
        };

        pub const Flying = struct {
            onGround: bool,
        };

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
            onGround: bool,
        };

        pub const Look = struct {
            yaw: f32,
            pitch: f32,
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

        pub const BlockDig = struct {
            status: i8,
            location: position,
            face: i8,
        };

        pub const BlockPlace = struct {
            location: position,
            direction: i8,
            heldItem: ?Slot,
            cursorX: i8,
            cursorY: i8,
            cursorZ: i8,
        };

        pub const HeldItemSlot = struct {
            slotId: i16,
        };

        pub const ArmAnimation = struct {
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

        pub const CloseWindow = struct {
            windowId: u8,
        };

        pub const WindowClick = struct {
            windowId: u8,
            slot: i16,
            mouseButton: i8,
            action: i16,
            mode: i8,
            item: ?Slot,
        };

        pub const Transaction = struct {
            windowId: i8,
            action: i16,
            accepted: bool,
        };

        pub const SetCreativeSlot = struct {
            slot: i16,
            item: ?Slot,
        };

        pub const EnchantItem = struct {
            windowId: i8,
            enchantment: i8,
        };

        pub const UpdateSign = struct {
            location: position,
            text1: []u8,
            text2: []u8,
            text3: []u8,
            text4: []u8,
        };

        pub const Abilities = struct {
            flags: i8,
            flyingSpeed: f32,
            walkingSpeed: f32,
        };

        pub const TabComplete = struct {
            text: []u8,
            block: ?position,
        };

        pub const Settings = struct {
            locale: []u8,
            viewDistance: i8,
            chatFlags: i8,
            chatColors: bool,
            skinParts: u8,
        };

        pub const ClientCommand = struct {
            payload: varint,
        };

        pub const CustomPayload = struct {
            channel: []u8,
            data: []u8,
        };

        pub const Spectate = struct {
            target: UUID,
        };

        pub const ResourcePackReceive = struct {
            hash: []u8,
            result: varint,
        };

        keep_alive: KeepAlive,
        chat: Chat,
        use_entity: UseEntity,
        flying: Flying,
        position: Position,
        look: Look,
        position_look: PositionLook,
        block_dig: BlockDig,
        block_place: BlockPlace,
        held_item_slot: HeldItemSlot,
        arm_animation: ArmAnimation,
        entity_action: EntityAction,
        steer_vehicle: SteerVehicle,
        close_window: CloseWindow,
        window_click: WindowClick,
        transaction: Transaction,
        set_creative_slot: SetCreativeSlot,
        enchant_item: EnchantItem,
        update_sign: UpdateSign,
        abilities: Abilities,
        tab_complete: TabComplete,
        settings: Settings,
        client_command: ClientCommand,
        custom_payload: CustomPayload,
        spectate: Spectate,
        resource_pack_receive: ResourcePackReceive,
    
        pub const C2S = enum(u8) {
            keep_alive: 0x00,
            chat: 0x01,
            use_entity: 0x02,
            flying: 0x03,
            position: 0x04,
            look: 0x05,
            position_look: 0x06,
            block_dig: 0x07,
            block_place: 0x08,
            held_item_slot: 0x09,
            arm_animation: 0x0a,
            entity_action: 0x0b,
            steer_vehicle: 0x0c,
            close_window: 0x0d,
            window_click: 0x0e,
            transaction: 0x0f,
            set_creative_slot: 0x10,
            enchant_item: 0x11,
            update_sign: 0x12,
            abilities: 0x13,
            tab_complete: 0x14,
            settings: 0x15,
            client_command: 0x16,
            custom_payload: 0x17,
            spectate: 0x18,
            resource_pack_receive: 0x19,
        };
    };
};
