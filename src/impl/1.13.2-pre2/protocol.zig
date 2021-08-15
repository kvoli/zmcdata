pub const ingredient = []Slot;

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

        pub const LoginPluginRequest = struct {
            message_id: vi,
            channel: []u8,
            data: []u8,
        };

        disconnect: Disconnect,
        encryption_begin: EncryptionBegin,
        success: Success,
        compress: Compress,
        login_plugin_request: LoginPluginRequest,
    
        pub const S2C = enum(u8) {
            disconnect: 0x00,
            encryption_begin: 0x01,
            success: 0x02,
            compress: 0x03,
            login_plugin_request: 0x04,
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

        pub const LoginPluginResponse = struct {
            message_id: vi,
            data: ?[]u8,
        };

        login_start: LoginStart,
        encryption_begin: EncryptionBegin,
        login_plugin_response: LoginPluginResponse,
    
        pub const C2S = enum(u8) {
            login_start: 0x00,
            encryption_begin: 0x01,
            login_plugin_response: 0x02,
        };
    };
};
pub const play = struct {
    pub const s2c = union(S2C) {
        pub const SpawnEntity = struct {
            entity_id: vi,
            object_uuid: UUID,
            @"type": i8,
            x: f64,
            y: f64,
            z: f64,
            pitch: i8,
            yaw: i8,
            object_data: i32,
            velocity_x: i16,
            velocity_y: i16,
            velocity_z: i16,
        };

        pub const SpawnEntityExperienceOrb = struct {
            entity_id: vi,
            x: f64,
            y: f64,
            z: f64,
            count: i16,
        };

        pub const SpawnEntityWeather = struct {
            entity_id: vi,
            @"type": i8,
            x: f64,
            y: f64,
            z: f64,
        };

        pub const SpawnEntityLiving = struct {
            entity_id: vi,
            entity_uuid: UUID,
            @"type": vi,
            x: f64,
            y: f64,
            z: f64,
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
            entity_uuid: UUID,
            title: vi,
            location: position,
            direction: u8,
        };

        pub const NamedEntitySpawn = struct {
            entity_id: vi,
            player_uuid: UUID,
            x: f64,
            y: f64,
            z: f64,
            yaw: i8,
            pitch: i8,
            metadata: EntityMetadata,
        };

        pub const Animation = struct {
            entity_id: vi,
            animation: u8,
        };

        pub const Statistics = struct {
            entries: []struct {
                category_id: vi,
                statistic_id: vi,
                value: vi,
            },
        };

        pub const Advancements = struct {
            reset: bool,
            advancement_mapping: []struct {
                key: []u8,
                value: struct {
                    parent_id: ?[]u8,
                    display_data: ?struct {
                        title: []u8,
                        description: []u8,
                        icon: Slot,
                        frame_type: vi,
                        flags: packed struct {
                            unused: u29,
                            hidden: u1,
                            show_toast: u1,
                            has_background_texture: u1,
                        },
                        background_texture: union(enum(u8)) {
                                @"1": struct {
                                    background_texture: []u8,
                                },
                        },
                        x_cord: f32,
                        y_cord: f32,
                    },
                    criteria: []struct {
                            key: []u8,
                            value: void,
                        },
                    requirements: [][][]u8,
                },
            },
            identifiers: [][]u8,
            progress_mapping: []struct {
                key: []u8,
                value: []struct {
                        criterion_identifier: []u8,
                        criterion_progress: ?i64,
                    },
            },
        };

        pub const BlockBreakAnimation = struct {
            entity_id: vi,
            location: position,
            destroy_stage: i8,
        };

        pub const TileEntityData = struct {
            location: position,
            action: u8,
            nbt_data: ?NBT,
        };

        pub const BlockAction = struct {
            location: position,
            byte1: u8,
            byte2: u8,
            block_id: vi,
        };

        pub const BlockChange = struct {
            location: position,
            @"type": vi,
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

        pub const Difficulty = struct {
            difficulty: u8,
        };

        pub const TabComplete = struct {
            transaction_id: vi,
            start: vi,
            length: vi,
            matches: []struct {
                match: []u8,
                tooltip: ?[]u8,
            },
        };

        pub const FacePlayer = struct {
            feet_eyes: vi,
            x: f64,
            y: f64,
            z: f64,
            is_entity: bool,
            entity_id: union(enum(u8)) {
                @"true": struct {
                    entity_id: vi,
                    entity_feet_eyes: []u8,
                },
        },
        };

        pub const NbtQueryResponse = struct {
            transaction_id: vi,
            nbt: NBT,
        };

        pub const Chat = struct {
            message: []u8,
            position: i8,
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

        pub const Transaction = struct {
            window_id: i8,
            action: i16,
            accepted: bool,
        };

        pub const CloseWindow = struct {
            window_id: u8,
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

        pub const WindowItems = struct {
            window_id: u8,
            items: []Slot,
        };

        pub const CraftProgressBar = struct {
            window_id: u8,
            property: i16,
            value: i16,
        };

        pub const SetSlot = struct {
            window_id: i8,
            slot: i16,
            item: Slot,
        };

        pub const SetCooldown = struct {
            item_id: vi,
            cooldown_ticks: vi,
        };

        pub const CustomPayload = struct {
            channel: []u8,
            data: []u8,
        };

        pub const NamedSoundEffect = struct {
            sound_name: []u8,
            sound_category: vi,
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
            entity_id: i32,
            entity_status: i8,
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

        pub const UnloadChunk = struct {
            chunk_x: i32,
            chunk_z: i32,
        };

        pub const GameStateChange = struct {
            reason: u8,
            game_mode: f32,
        };

        pub const KeepAlive = struct {
            keep_alive_id: i64,
        };

        pub const MapChunk = struct {
            x: i32,
            z: i32,
            ground_up: bool,
            bit_map: vi,
            chunk_data: []u8,
            block_entities: []NBT,
        };

        pub const WorldEvent = struct {
            effect_id: i32,
            location: position,
            data: i32,
            global: bool,
        };

        pub const Login = struct {
            entity_id: i32,
            game_mode: u8,
            dimension: i32,
            difficulty: u8,
            max_players: u8,
            level_type: []u8,
            reduced_debug_info: bool,
        };

        pub const Map = struct {
            item_damage: vi,
            scale: i8,
            tracking_position: bool,
            icons: []struct {
                @"type": vi,
                x: i8,
                y: i8,
                direction: u8,
                display_name: ?[]u8,
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

        pub const RelEntityMove = struct {
            entity_id: vi,
            d_x: i16,
            d_y: i16,
            d_z: i16,
            on_ground: bool,
        };

        pub const EntityMoveLook = struct {
            entity_id: vi,
            d_x: i16,
            d_y: i16,
            d_z: i16,
            yaw: i8,
            pitch: i8,
            on_ground: bool,
        };

        pub const EntityLook = struct {
            entity_id: vi,
            yaw: i8,
            pitch: i8,
            on_ground: bool,
        };

        pub const Entity = struct {
            entity_id: vi,
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

        pub const CraftRecipeResponse = struct {
            window_id: i8,
            recipe: []u8,
        };

        pub const Abilities = struct {
            flags: i8,
            flying_speed: f32,
            walking_speed: f32,
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

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
            flags: i8,
            teleport_id: vi,
        };

        pub const Bed = struct {
            entity_id: vi,
            location: position,
        };

        pub const EntityDestroy = struct {
            entity_ids: []vi,
        };

        pub const RemoveEntityEffect = struct {
            entity_id: vi,
            effect_id: i8,
        };

        pub const ResourcePackSend = struct {
            url: []u8,
            hash: []u8,
        };

        pub const Respawn = struct {
            dimension: i32,
            difficulty: u8,
            gamemode: u8,
            level_type: []u8,
        };

        pub const EntityHeadRotation = struct {
            entity_id: vi,
            head_yaw: i8,
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

        pub const Camera = struct {
            camera_id: vi,
        };

        pub const HeldItemSlot = struct {
            slot: i8,
        };

        pub const ScoreboardDisplayObjective = struct {
            position: i8,
            name: []u8,
        };

        pub const EntityMetadata = struct {
            entity_id: vi,
            metadata: EntityMetadata,
        };

        pub const AttachEntity = struct {
            entity_id: i32,
            vehicle_id: i32,
        };

        pub const EntityVelocity = struct {
            entity_id: vi,
            velocity_x: i16,
            velocity_y: i16,
            velocity_z: i16,
        };

        pub const EntityEquipment = struct {
            entity_id: vi,
            slot: vi,
            item: Slot,
        };

        pub const Experience = struct {
            experience_bar: f32,
            level: vi,
            total_experience: vi,
        };

        pub const UpdateHealth = struct {
            health: f32,
            food: vi,
            food_saturation: f32,
        };

        pub const ScoreboardObjective = struct {
            name: []u8,
            action: i8,
            display_text: union(enum(u8)) {
                @"0": struct {
                    display_text: []u8,
                    @"type": vi,
                },
                @"2": struct {
                    display_text: []u8,
                    @"type": vi,
                },
        },
        };

        pub const SetPassengers = struct {
            entity_id: vi,
            passengers: []vi,
        };

        pub const Teams = struct {
            team: []u8,
            mode: i8,
            name: union(enum(u8)) {
                @"0": struct {
                    name: []u8,
                    friendly_fire: i8,
                    name_tag_visibility: []u8,
                    collision_rule: []u8,
                    formatting: vi,
                    players: [][]u8,
                    prefix: []u8,
                    suffix: []u8,
                },
                @"2": struct {
                    name: []u8,
                    friendly_fire: i8,
                    name_tag_visibility: []u8,
                    collision_rule: []u8,
                    formatting: vi,
                    prefix: []u8,
                    suffix: []u8,
                },
                @"3": struct {
                    players: [][]u8,
                },
                @"4": struct {
                    players: [][]u8,
                },
        },
        };

        pub const SpawnPosition = struct {
            location: position,
        };

        pub const UpdateTime = struct {
            age: i64,
            time: i64,
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
                    text: []u8,
                },
                @"3": struct {
                    fade_in: i32,
                    stay: i32,
                    fade_out: i32,
                },
        },
        };

        pub const StopSound = struct {
            flags: i8,
            source: union(enum(u8)) {
                @"1": struct {
                    source: vi,
                },
                @"2": struct {
                    sound: []u8,
                },
                @"3": struct {
                    source: vi,
                    sound: []u8,
                },
        },
        };

        pub const SoundEffect = struct {
            sound_id: vi,
            sound_category: vi,
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
            collected_entity_id: vi,
            collector_entity_id: vi,
            pickup_item_count: vi,
        };

        pub const EntityTeleport = struct {
            entity_id: vi,
            x: f64,
            y: f64,
            z: f64,
            yaw: i8,
            pitch: i8,
            on_ground: bool,
        };

        pub const EntityUpdateAttributes = struct {
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

        pub const EntityEffect = struct {
            entity_id: vi,
            effect_id: i8,
            amplifier: i8,
            duration: vi,
            hide_particles: i8,
        };

        pub const SelectAdvancementTab = struct {
            id: ?[]u8,
        };

        pub const Tags = struct {
            block_tags: Tags,
            item_tags: Tags,
            fluid_tags: Tags,
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
        chat: Chat,
        multi_block_change: MultiBlockChange,
        tab_complete: TabComplete,
        declare_commands: DeclareCommands,
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
        nbt_query_response: NbtQueryResponse,
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
        craft_recipe_response: CraftRecipeResponse,
        abilities: Abilities,
        combat_event: CombatEvent,
        player_info: PlayerInfo,
        face_player: FacePlayer,
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
        stop_sound: StopSound,
        sound_effect: SoundEffect,
        playerlist_header: PlayerlistHeader,
        collect: Collect,
        entity_teleport: EntityTeleport,
        advancements: Advancements,
        entity_update_attributes: EntityUpdateAttributes,
        entity_effect: EntityEffect,
        declare_recipes: DeclareRecipes,
        tags: Tags,
    
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
            chat: 0x0e,
            multi_block_change: 0x0f,
            tab_complete: 0x10,
            declare_commands: 0x11,
            transaction: 0x12,
            close_window: 0x13,
            open_window: 0x14,
            window_items: 0x15,
            craft_progress_bar: 0x16,
            set_slot: 0x17,
            set_cooldown: 0x18,
            custom_payload: 0x19,
            named_sound_effect: 0x1a,
            kick_disconnect: 0x1b,
            entity_status: 0x1c,
            nbt_query_response: 0x1d,
            explosion: 0x1e,
            unload_chunk: 0x1f,
            game_state_change: 0x20,
            keep_alive: 0x21,
            map_chunk: 0x22,
            world_event: 0x23,
            world_particles: 0x24,
            login: 0x25,
            map: 0x26,
            entity: 0x27,
            rel_entity_move: 0x28,
            entity_move_look: 0x29,
            entity_look: 0x2a,
            vehicle_move: 0x2b,
            open_sign_entity: 0x2c,
            craft_recipe_response: 0x2d,
            abilities: 0x2e,
            combat_event: 0x2f,
            player_info: 0x30,
            face_player: 0x31,
            position: 0x32,
            bed: 0x33,
            unlock_recipes: 0x34,
            entity_destroy: 0x35,
            remove_entity_effect: 0x36,
            resource_pack_send: 0x37,
            respawn: 0x38,
            entity_head_rotation: 0x39,
            select_advancement_tab: 0x3a,
            world_border: 0x3b,
            camera: 0x3c,
            held_item_slot: 0x3d,
            scoreboard_display_objective: 0x3e,
            entity_metadata: 0x3f,
            attach_entity: 0x40,
            entity_velocity: 0x41,
            entity_equipment: 0x42,
            experience: 0x43,
            update_health: 0x44,
            scoreboard_objective: 0x45,
            set_passengers: 0x46,
            teams: 0x47,
            scoreboard_score: 0x48,
            spawn_position: 0x49,
            update_time: 0x4a,
            title: 0x4b,
            stop_sound: 0x4c,
            sound_effect: 0x4d,
            playerlist_header: 0x4e,
            collect: 0x4f,
            entity_teleport: 0x50,
            advancements: 0x51,
            entity_update_attributes: 0x52,
            entity_effect: 0x53,
            declare_recipes: 0x54,
            tags: 0x55,
        };
    };

    pub const c2s = union(C2S) {
        pub const TeleportConfirm = struct {
            teleport_id: vi,
        };

        pub const QueryBlockNbt = struct {
            transaction_id: vi,
            location: position,
        };

        pub const EditBook = struct {
            new_book: Slot,
            signing: bool,
            hand: vi,
        };

        pub const QueryEntityNbt = struct {
            transaction_id: vi,
            entity_id: vi,
        };

        pub const PickItem = struct {
            slot: vi,
        };

        pub const NameItem = struct {
            name: []u8,
        };

        pub const SelectTrade = struct {
            slot: vi,
        };

        pub const SetBeaconEffect = struct {
            primary_effect: vi,
            secondary_effect: vi,
        };

        pub const UpdateCommandBlock = struct {
            location: position,
            command: []u8,
            mode: vi,
            flags: u8,
        };

        pub const UpdateCommandBlockMinecart = struct {
            entity_id: vi,
            command: []u8,
            track_output: bool,
        };

        pub const UpdateStructureBlock = struct {
            location: position,
            action: vi,
            mode: vi,
            name: []u8,
            offset_x: u8,
            offset_y: u8,
            offset_z: u8,
            size_x: u8,
            size_y: u8,
            size_z: u8,
            mirror: vi,
            rotation: vi,
            metadata: []u8,
            integrity: f32,
            seed: vi,
            flags: u8,
        };

        pub const TabComplete = struct {
            transaction_id: vi,
            text: []u8,
        };

        pub const Chat = struct {
            message: []u8,
        };

        pub const ClientCommand = struct {
            action_id: vi,
        };

        pub const Settings = struct {
            locale: []u8,
            view_distance: i8,
            chat_flags: vi,
            chat_colors: bool,
            skin_parts: u8,
            main_hand: vi,
        };

        pub const Transaction = struct {
            window_id: i8,
            action: i16,
            accepted: bool,
        };

        pub const EnchantItem = struct {
            window_id: i8,
            enchantment: i8,
        };

        pub const WindowClick = struct {
            window_id: u8,
            slot: i16,
            mouse_button: i8,
            action: i16,
            mode: i8,
            item: Slot,
        };

        pub const CloseWindow = struct {
            window_id: u8,
        };

        pub const CustomPayload = struct {
            channel: []u8,
            data: []u8,
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

        pub const KeepAlive = struct {
            keep_alive_id: i64,
        };

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
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

        pub const Look = struct {
            yaw: f32,
            pitch: f32,
            on_ground: bool,
        };

        pub const Flying = struct {
            on_ground: bool,
        };

        pub const VehicleMove = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
        };

        pub const SteerBoat = struct {
            left_paddle: bool,
            right_paddle: bool,
        };

        pub const CraftRecipeRequest = struct {
            window_id: i8,
            recipe: []u8,
            make_all: bool,
        };

        pub const Abilities = struct {
            flags: i8,
            flying_speed: f32,
            walking_speed: f32,
        };

        pub const BlockDig = struct {
            status: i8,
            location: position,
            face: i8,
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

        pub const ResourcePackReceive = struct {
            result: vi,
        };

        pub const HeldItemSlot = struct {
            slot_id: i16,
        };

        pub const SetCreativeSlot = struct {
            slot: i16,
            item: Slot,
        };

        pub const UpdateSign = struct {
            location: position,
            text1: []u8,
            text2: []u8,
            text3: []u8,
            text4: []u8,
        };

        pub const ArmAnimation = struct {
            hand: vi,
        };

        pub const Spectate = struct {
            target: UUID,
        };

        pub const BlockPlace = struct {
            location: position,
            direction: vi,
            hand: vi,
            cursor_x: f32,
            cursor_y: f32,
            cursor_z: f32,
        };

        pub const UseItem = struct {
            hand: vi,
        };

        pub const AdvancementTab = struct {
            action: vi,
            tab_id: union(enum(u8)) {
                @"0": struct {
                    tab_id: []u8,
                },
        },
        };

        teleport_confirm: TeleportConfirm,
        query_block_nbt: QueryBlockNbt,
        chat: Chat,
        client_command: ClientCommand,
        settings: Settings,
        tab_complete: TabComplete,
        transaction: Transaction,
        enchant_item: EnchantItem,
        window_click: WindowClick,
        close_window: CloseWindow,
        custom_payload: CustomPayload,
        edit_book: EditBook,
        query_entity_nbt: QueryEntityNbt,
        use_entity: UseEntity,
        keep_alive: KeepAlive,
        flying: Flying,
        position: Position,
        position_look: PositionLook,
        look: Look,
        vehicle_move: VehicleMove,
        steer_boat: SteerBoat,
        pick_item: PickItem,
        craft_recipe_request: CraftRecipeRequest,
        abilities: Abilities,
        block_dig: BlockDig,
        entity_action: EntityAction,
        steer_vehicle: SteerVehicle,
        crafting_book_data: CraftingBookData,
        name_item: NameItem,
        resource_pack_receive: ResourcePackReceive,
        advancement_tab: AdvancementTab,
        select_trade: SelectTrade,
        set_beacon_effect: SetBeaconEffect,
        held_item_slot: HeldItemSlot,
        update_command_block: UpdateCommandBlock,
        update_command_block_minecart: UpdateCommandBlockMinecart,
        set_creative_slot: SetCreativeSlot,
        update_structure_block: UpdateStructureBlock,
        update_sign: UpdateSign,
        arm_animation: ArmAnimation,
        spectate: Spectate,
        block_place: BlockPlace,
        use_item: UseItem,
    
        pub const C2S = enum(u8) {
            teleport_confirm: 0x00,
            query_block_nbt: 0x01,
            chat: 0x02,
            client_command: 0x03,
            settings: 0x04,
            tab_complete: 0x05,
            transaction: 0x06,
            enchant_item: 0x07,
            window_click: 0x08,
            close_window: 0x09,
            custom_payload: 0x0a,
            edit_book: 0x0b,
            query_entity_nbt: 0x0c,
            use_entity: 0x0d,
            keep_alive: 0x0e,
            flying: 0x0f,
            position: 0x10,
            position_look: 0x11,
            look: 0x12,
            vehicle_move: 0x13,
            steer_boat: 0x14,
            pick_item: 0x15,
            craft_recipe_request: 0x16,
            abilities: 0x17,
            block_dig: 0x18,
            entity_action: 0x19,
            steer_vehicle: 0x1a,
            crafting_book_data: 0x1b,
            name_item: 0x1c,
            resource_pack_receive: 0x1d,
            advancement_tab: 0x1e,
            select_trade: 0x1f,
            set_beacon_effect: 0x20,
            held_item_slot: 0x21,
            update_command_block: 0x22,
            update_command_block_minecart: 0x23,
            set_creative_slot: 0x24,
            update_structure_block: 0x25,
            update_sign: 0x26,
            arm_animation: 0x27,
            spectate: 0x28,
            block_place: 0x29,
            use_item: 0x2a,
        };
    };
};
