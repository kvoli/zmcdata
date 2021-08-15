pub const position = packed struct {
    x: i26,
    y: i12,
    z: i26,
};

pub const handshaking = struct {
    pub const s2c = union(S2C) {
    
        pub const S2C = enum(u8) {
        };
    };

    pub const c2s = union(C2S) {
        pub const SetProtocol = struct {
            protocol_version: vi,
            server_host: []u8,
            server_port: u16,
            next_state: vi,
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
            server_id: []u8,
            public_key: []u8,
            verify_token: []u8,
        };

        pub const Success = struct {
            uuid: []u8,
            username: []u8,
        };

        pub const Compress = struct {
            threshold: vi,
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
            shared_secret: []u8,
            verify_token: []u8,
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
            keep_alive_id: vi,
        };

        pub const Login = struct {
            entity_id: i32,
            game_mode: u8,
            dimension: i8,
            difficulty: u8,
            max_players: u8,
            level_type: []u8,
            reduced_debug_info: bool,
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
            entity_id: vi,
            slot: vi,
            item: Slot,
        };

        pub const SpawnPosition = struct {
            location: position,
        };

        pub const UpdateHealth = struct {
            health: f32,
            food: vi,
            food_saturation: f32,
        };

        pub const Respawn = struct {
            dimension: i32,
            difficulty: u8,
            gamemode: u8,
            level_type: []u8,
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
            entity_id: vi,
            location: position,
        };

        pub const Animation = struct {
            entity_id: vi,
            animation: u8,
        };

        pub const NamedEntitySpawn = struct {
            entity_id: vi,
            player_uuid: UUID,
            x: i32,
            y: i32,
            z: i32,
            yaw: i8,
            pitch: i8,
            metadata: EntityMetadata,
        };

        pub const Collect = struct {
            collected_entity_id: vi,
            collector_entity_id: vi,
        };

        pub const SpawnEntity = struct {
            entity_id: vi,
            entity_uuid: UUID,
            @"type": i8,
            x: i32,
            y: i32,
            z: i32,
            pitch: i8,
            yaw: i8,
            object_data: i32,
            velocity_x: i16,
            velocity_y: i16,
            velocity_z: i16,
        };

        pub const SpawnEntityLiving = struct {
            entity_id: vi,
            entity_uuid: UUID,
            @"type": u8,
            x: i32,
            y: i32,
            z: i32,
            yaw: i8,
            pitch: i8,
            head_pitch: i8,
            velocity_x: i16,
            velocity_y: i16,
            velocity_z: i16,
            metadata: EntityMetadata,
        };

        pub const SpawnEntityPainting = struct {
            entity_id: vi,
            title: []u8,
            location: position,
            direction: u8,
        };

        pub const SpawnEntityExperienceOrb = struct {
            entity_id: vi,
            x: i32,
            y: i32,
            z: i32,
            count: i16,
        };

        pub const EntityVelocity = struct {
            entity_id: vi,
            velocity_x: i16,
            velocity_y: i16,
            velocity_z: i16,
        };

        pub const EntityDestroy = struct {
            entity_ids: []vi,
        };

        pub const Entity = struct {
            entity_id: vi,
        };

        pub const RelEntityMove = struct {
            entity_id: vi,
            d_x: i8,
            d_y: i8,
            d_z: i8,
            on_ground: bool,
        };

        pub const EntityLook = struct {
            entity_id: vi,
            yaw: i8,
            pitch: i8,
            on_ground: bool,
        };

        pub const EntityMoveLook = struct {
            entity_id: vi,
            d_x: i8,
            d_y: i8,
            d_z: i8,
            yaw: i8,
            pitch: i8,
            on_ground: bool,
        };

        pub const EntityTeleport = struct {
            entity_id: vi,
            x: i32,
            y: i32,
            z: i32,
            yaw: i8,
            pitch: i8,
            on_ground: bool,
        };

        pub const EntityHeadRotation = struct {
            entity_id: vi,
            head_yaw: i8,
        };

        pub const EntityStatus = struct {
            entity_id: i32,
            entity_status: i8,
        };

        pub const AttachEntity = struct {
            entity_id: i32,
            vehicle_id: i32,
            leash: bool,
        };

        pub const EntityMetadata = struct {
            entity_id: vi,
            metadata: EntityMetadata,
        };

        pub const EntityEffect = struct {
            entity_id: vi,
            effect_id: i8,
            amplifier: i8,
            duration: vi,
            hide_particles: bool,
        };

        pub const RemoveEntityEffect = struct {
            entity_id: vi,
            effect_id: i8,
        };

        pub const Experience = struct {
            experience_bar: f32,
            level: vi,
            total_experience: vi,
        };

        pub const UpdateAttributes = struct {
            entity_id: vi,
            properties: []struct {
                key: []u8,
                value: f64,
                modifiers: []struct {
                        uuid: UUID,
                        amount: f64,
                        operation: i8,
                    },
            },
        };

        pub const MapChunk = struct {
            x: i32,
            z: i32,
            ground_up: bool,
            bit_map: vi,
            chunk_data: []u8,
        };

        pub const MultiBlockChange = struct {
            chunk_x: i32,
            chunk_z: i32,
            records: []struct {
                horizontal_pos: u8,
                y: u8,
                block_id: vi,
            },
        };

        pub const BlockChange = struct {
            location: position,
            @"type": vi,
        };

        pub const BlockAction = struct {
            location: position,
            byte1: u8,
            byte2: u8,
            block_id: vi,
        };

        pub const BlockBreakAnimation = struct {
            entity_id: vi,
            location: position,
            destroy_stage: i8,
        };

        pub const Explosion = struct {
            x: f32,
            y: f32,
            z: f32,
            radius: f32,
            affected_block_offsets: []struct {
                x: i8,
                y: i8,
                z: i8,
            },
            player_motion_x: f32,
            player_motion_y: f32,
            player_motion_z: f32,
        };

        pub const WorldEvent = struct {
            effect_id: i32,
            location: position,
            data: i32,
            global: bool,
        };

        pub const NamedSoundEffect = struct {
            sound_name: []u8,
            x: i32,
            y: i32,
            z: i32,
            volume: f32,
            pitch: u8,
        };

        pub const GameStateChange = struct {
            reason: u8,
            game_mode: f32,
        };

        pub const SpawnEntityWeather = struct {
            entity_id: vi,
            @"type": i8,
            x: i32,
            y: i32,
            z: i32,
        };

        pub const OpenWindow = struct {
            window_id: u8,
            inventory_type: []u8,
            window_title: []u8,
            slot_count: u8,
            entity_id: union(enum(u8)) {
                @"EntityHorse": struct {
                    entity_id: i32,
                },
        },
        };

        pub const CloseWindow = struct {
            window_id: u8,
        };

        pub const SetSlot = struct {
            window_id: i8,
            slot: i16,
            item: Slot,
        };

        pub const WindowItems = struct {
            window_id: u8,
            items: []Slot,
        };

        pub const CraftProgressBar = struct {
            window_id: u8,
            property: i16,
            value: i16,
        };

        pub const Transaction = struct {
            window_id: i8,
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
            item_damage: vi,
            scale: i8,
            tracking_position: bool,
            icons: []struct {
                direction_and_type: i8,
                x: i8,
                y: i8,
            },
            columns: i8,
            rows: union(enum(u8)) {
                @"default": struct {
                    rows: i8,
                    x: i8,
                    y: i8,
                    data: []u8,
                },
        },
        };

        pub const TileEntityData = struct {
            location: position,
            action: u8,
            nbt_data: ?NBT,
        };

        pub const OpenSignEntity = struct {
            location: position,
        };

        pub const Statistics = struct {
            entries: []struct {
                name: []u8,
                value: vi,
            },
        };

        pub const Abilities = struct {
            flags: i8,
            flying_speed: f32,
            walking_speed: f32,
        };

        pub const TabComplete = struct {
            matches: [][]u8,
        };

        pub const ScoreboardObjective = struct {
            name: []u8,
            action: i8,
            display_text: union(enum(u8)) {
                @"0": struct {
                    display_text: []u8,
                    @"type": []u8,
                },
                @"2": struct {
                    display_text: []u8,
                    @"type": []u8,
                },
        },
        };

        pub const ScoreboardDisplayObjective = struct {
            position: i8,
            name: []u8,
        };

        pub const ScoreboardTeam = struct {
            team: []u8,
            mode: i8,
            name: union(enum(u8)) {
                @"0": struct {
                    name: []u8,
                    prefix: []u8,
                    suffix: []u8,
                    friendly_fire: i8,
                    name_tag_visibility: []u8,
                    collision_rule: []u8,
                    color: i8,
                    players: [][]u8,
                },
                @"2": struct {
                    name: []u8,
                    prefix: []u8,
                    suffix: []u8,
                    friendly_fire: i8,
                    name_tag_visibility: []u8,
                    collision_rule: []u8,
                    color: i8,
                },
                @"3": struct {
                    players: [][]u8,
                },
                @"4": struct {
                    players: [][]u8,
                },
        },
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
            event: vi,
            duration: union(enum(u8)) {
                @"1": struct {
                    duration: vi,
                    entity_id: i32,
                },
                @"2": struct {
                    player_id: vi,
                    entity_id: i32,
                    message: []u8,
                },
        },
        };

        pub const Camera = struct {
            camera_id: vi,
        };

        pub const WorldBorder = struct {
            action: vi,
            radius: union(enum(u8)) {
                @"0": struct {
                    radius: f64,
                },
                @"1": struct {
                    old_radius: f64,
                    new_radius: f64,
                    speed: vi,
                },
                @"2": struct {
                    x: f64,
                    z: f64,
                },
                @"3": struct {
                    x: f64,
                    z: f64,
                    old_radius: f64,
                    new_radius: f64,
                    speed: vi,
                    portal_boundary: vi,
                    warning_time: vi,
                    warning_blocks: vi,
                },
                @"4": struct {
                    warning_time: vi,
                },
                @"5": struct {
                    warning_blocks: vi,
                },
        },
        };

        pub const Title = struct {
            action: vi,
            text: union(enum(u8)) {
                @"0": struct {
                    text: []u8,
                },
                @"1": struct {
                    text: []u8,
                },
                @"2": struct {
                    fade_in: i32,
                    stay: i32,
                    fade_out: i32,
                },
        },
        };

        pub const SetCompression = struct {
            threshold: vi,
        };

        pub const PlayerlistHeader = struct {
            header: []u8,
            footer: []u8,
        };

        pub const ResourcePackSend = struct {
            url: []u8,
            hash: []u8,
        };

        pub const BossBar = struct {
            entity_uuid: UUID,
            action: vi,
            title: union(enum(u8)) {
                @"0": struct {
                    title: []u8,
                    health: f32,
                    color: vi,
                    dividers: vi,
                    flags: u8,
                },
                @"2": struct {
                    health: f32,
                },
                @"3": struct {
                    title: []u8,
                },
                @"4": struct {
                    color: vi,
                    dividers: vi,
                },
                @"5": struct {
                    flags: u8,
                },
        },
        };

        pub const SetCooldown = struct {
            item_id: vi,
            cooldown_ticks: vi,
        };

        pub const UnloadChunk = struct {
            chunk_x: i32,
            chunk_z: i32,
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
        boss_bar: BossBar,
        set_cooldown: SetCooldown,
        unload_chunk: UnloadChunk,
    
        pub const S2C = enum(u8) {
            keep_alive: 0x1f,
            login: 0x24,
            chat: 0x0f,
            update_time: 0x43,
            entity_equipment: 0x3c,
            spawn_position: 0x42,
            update_health: 0x3e,
            respawn: 0x33,
            position: 0x2e,
            held_item_slot: 0x37,
            bed: 0x2f,
            animation: 0x06,
            named_entity_spawn: 0x05,
            collect: 0x47,
            spawn_entity: 0x00,
            spawn_entity_living: 0x03,
            spawn_entity_painting: 0x04,
            spawn_entity_experience_orb: 0x01,
            entity_velocity: 0x3b,
            entity_destroy: 0x30,
            entity: 0x29,
            rel_entity_move: 0x26,
            entity_look: 0x28,
            entity_move_look: 0x27,
            entity_teleport: 0x48,
            entity_head_rotation: 0x34,
            entity_status: 0x1a,
            attach_entity: 0x3a,
            entity_metadata: 0x39,
            entity_effect: 0x4a,
            remove_entity_effect: 0x31,
            experience: 0x3d,
            update_attributes: 0x49,
            map_chunk: 0x20,
            multi_block_change: 0x10,
            block_change: 0x0b,
            block_action: 0x0a,
            block_break_animation: 0x08,
            explosion: 0x1b,
            world_event: 0x21,
            named_sound_effect: 0x23,
            world_particles: 0x22,
            game_state_change: 0x1e,
            spawn_entity_weather: 0x02,
            open_window: 0x13,
            close_window: 0x12,
            set_slot: 0x16,
            window_items: 0x14,
            craft_progress_bar: 0x15,
            transaction: 0x11,
            update_sign: 0x45,
            map: 0x25,
            tile_entity_data: 0x09,
            open_sign_entity: 0x2a,
            statistics: 0x07,
            player_info: 0x2d,
            abilities: 0x2b,
            tab_complete: 0x0e,
            scoreboard_objective: 0x3f,
            scoreboard_score: 0x41,
            scoreboard_display_objective: 0x38,
            scoreboard_team: 0x40,
            custom_payload: 0x18,
            kick_disconnect: 0x19,
            difficulty: 0x0d,
            combat_event: 0x2c,
            camera: 0x36,
            world_border: 0x35,
            title: 0x44,
            set_compression: 0x1d,
            playerlist_header: 0x46,
            resource_pack_send: 0x32,
            boss_bar: 0x0c,
            set_cooldown: 0x17,
            unload_chunk: 0x1c,
        };
    };

    pub const c2s = union(C2S) {
        pub const KeepAlive = struct {
            keep_alive_id: vi,
        };

        pub const Chat = struct {
            message: []u8,
        };

        pub const UseEntity = struct {
            target: vi,
            mouse: vi,
            x: union(enum(u8)) {
                @"0": struct {
                    hand: vi,
                },
                @"2": struct {
                    x: f32,
                    y: f32,
                    z: f32,
                    hand: vi,
                },
        },
        };

        pub const Flying = struct {
            on_ground: bool,
        };

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
            on_ground: bool,
        };

        pub const Look = struct {
            yaw: f32,
            pitch: f32,
            on_ground: bool,
        };

        pub const PositionLook = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
            on_ground: bool,
        };

        pub const BlockDig = struct {
            status: i8,
            location: position,
            face: i8,
        };

        pub const BlockPlace = struct {
            location: position,
            direction: vi,
            hand: vi,
            cursor_x: i8,
            cursor_y: i8,
            cursor_z: i8,
        };

        pub const HeldItemSlot = struct {
            slot_id: i16,
        };

        pub const ArmAnimation = struct {
            hand: vi,
        };

        pub const EntityAction = struct {
            entity_id: vi,
            action_id: vi,
            jump_boost: vi,
        };

        pub const SteerVehicle = struct {
            sideways: f32,
            forward: f32,
            jump: u8,
        };

        pub const CloseWindow = struct {
            window_id: u8,
        };

        pub const WindowClick = struct {
            window_id: u8,
            slot: i16,
            mouse_button: i8,
            action: i16,
            mode: i8,
            item: Slot,
        };

        pub const Transaction = struct {
            window_id: i8,
            action: i16,
            accepted: bool,
        };

        pub const SetCreativeSlot = struct {
            slot: i16,
            item: Slot,
        };

        pub const EnchantItem = struct {
            window_id: i8,
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
            flying_speed: f32,
            walking_speed: f32,
        };

        pub const TabComplete = struct {
            text: []u8,
            block: ?position,
        };

        pub const Settings = struct {
            locale: []u8,
            view_distance: i8,
            chat_flags: vi,
            chat_colors: bool,
            skin_parts: u8,
            main_hand: vi,
        };

        pub const ClientCommand = struct {
            payload: vi,
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
            result: vi,
        };

        pub const UseItem = struct {
            hand: vi,
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
        use_item: UseItem,
    
        pub const C2S = enum(u8) {
            keep_alive: 0x0a,
            chat: 0x01,
            use_entity: 0x09,
            flying: 0x0e,
            position: 0x0b,
            look: 0x0d,
            position_look: 0x0c,
            block_dig: 0x10,
            block_place: 0x19,
            held_item_slot: 0x14,
            arm_animation: 0x17,
            entity_action: 0x11,
            steer_vehicle: 0x12,
            close_window: 0x07,
            window_click: 0x06,
            transaction: 0x04,
            set_creative_slot: 0x15,
            enchant_item: 0x05,
            update_sign: 0x16,
            abilities: 0x0f,
            tab_complete: 0x00,
            settings: 0x03,
            client_command: 0x02,
            custom_payload: 0x08,
            spectate: 0x18,
            resource_pack_receive: 0x13,
            use_item: 0x1a,
        };
    };
};
