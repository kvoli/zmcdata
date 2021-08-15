pub const position_iii = struct {
    x: i32,
    y: i32,
    z: i32,
};

pub const position_isi = struct {
    x: i32,
    y: i16,
    z: i32,
};

pub const position_ibi = struct {
    x: i32,
    y: u8,
    z: i32,
};

pub const entityMetadataItem = ;

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

        disconnect: Disconnect,
        encryption_begin: EncryptionBegin,
        success: Success,
    
        pub const S2C = enum(u8) {
            disconnect: 0x00,
            encryption_begin: 0x01,
            success: 0x02,
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
            keep_alive_id: i32,
        };

        pub const Login = struct {
            entity_id: i32,
            game_mode: u8,
            dimension: i8,
            difficulty: u8,
            max_players: u8,
            level_type: []u8,
        };

        pub const Chat = struct {
            message: []u8,
        };

        pub const UpdateTime = struct {
            age: i64,
            time: i64,
        };

        pub const EntityEquipment = struct {
            entity_id: i32,
            slot: i16,
            item: Slot,
        };

        pub const SpawnPosition = struct {
            location: position_iii,
        };

        pub const UpdateHealth = struct {
            health: f32,
            food: i16,
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
            on_ground: bool,
        };

        pub const HeldItemSlot = struct {
            slot: i8,
        };

        pub const Bed = struct {
            entity_id: i32,
            location: position_ibi,
        };

        pub const Animation = struct {
            entity_id: vi,
            animation: u8,
        };

        pub const NamedEntitySpawn = struct {
            entity_id: vi,
            player_uuid: []u8,
            player_name: []u8,
            data: []struct {
                name: []u8,
                value: []u8,
                signature: []u8,
            },
            x: i32,
            y: i32,
            z: i32,
            yaw: i8,
            pitch: i8,
            current_item: i16,
            metadata: EntityMetadata,
        };

        pub const Collect = struct {
            collected_entity_id: i32,
            collector_entity_id: i32,
        };

        pub const SpawnEntity = struct {
            entity_id: vi,
            typed: i8,
            x: i32,
            y: i32,
            z: i32,
            pitch: i8,
            yaw: i8,
            object_data: struct {
            int_field: i32,
            velocity_x: union(enum(u8)) {
                    xdefault: struct {
                        velocity_x: i16,
                        velocity_y: i16,
                        velocity_z: i16,
                    },
            },
        },
        };

        pub const SpawnEntityLiving = struct {
            entity_id: vi,
            typed: u8,
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
            location: position_iii,
            direction: i32,
        };

        pub const SpawnEntityExperienceOrb = struct {
            entity_id: vi,
            x: i32,
            y: i32,
            z: i32,
            count: i16,
        };

        pub const EntityVelocity = struct {
            entity_id: i32,
            velocity_x: i16,
            velocity_y: i16,
            velocity_z: i16,
        };

        pub const EntityDestroy = struct {
            entity_ids: []i32,
        };

        pub const Entity = struct {
            entity_id: i32,
        };

        pub const RelEntityMove = struct {
            entity_id: i32,
            d_x: i8,
            d_y: i8,
            d_z: i8,
        };

        pub const EntityLook = struct {
            entity_id: i32,
            yaw: i8,
            pitch: i8,
        };

        pub const EntityMoveLook = struct {
            entity_id: i32,
            d_x: i8,
            d_y: i8,
            d_z: i8,
            yaw: i8,
            pitch: i8,
        };

        pub const EntityTeleport = struct {
            entity_id: i32,
            x: i32,
            y: i32,
            z: i32,
            yaw: i8,
            pitch: i8,
        };

        pub const EntityHeadRotation = struct {
            entity_id: i32,
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
            entity_id: i32,
            metadata: EntityMetadata,
        };

        pub const EntityEffect = struct {
            entity_id: i32,
            effect_id: i8,
            amplifier: i8,
            duration: i16,
        };

        pub const RemoveEntityEffect = struct {
            entity_id: i32,
            effect_id: i8,
        };

        pub const Experience = struct {
            experience_bar: f32,
            level: i16,
            total_experience: i16,
        };

        pub const UpdateAttributes = struct {
            entity_id: i32,
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
            bit_map: u16,
            add_bit_map: u16,
            compressed_chunk_data: []u8,
        };

        pub const MultiBlockChange = struct {
            chunk_x: i32,
            chunk_z: i32,
            record_count: ,
            data_length: i32,
            records: []struct {
undefined
                y: u8,
undefined
            },
        };

        pub const BlockChange = struct {
            location: position_ibi,
            typed: vi,
            metadata: u8,
        };

        pub const BlockAction = struct {
            location: position_isi,
            byte1: u8,
            byte2: u8,
            block_id: vi,
        };

        pub const BlockBreakAnimation = struct {
            entity_id: vi,
            location: position_iii,
            destroy_stage: i8,
        };

        pub const MapChunkBulk = struct {
            chunk_column_count: ,
            data_length: ,
            sky_light_sent: bool,
            compressed_chunk_data: []u8,
            meta: []struct {
                x: i32,
                z: i32,
                bit_map: u16,
                add_bit_map: u16,
            },
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
            location: position_ibi,
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
            typed: i8,
            x: i32,
            y: i32,
            z: i32,
        };

        pub const OpenWindow = struct {
            window_id: u8,
            inventory_type: u8,
            window_title: []u8,
            slot_count: u8,
            use_provided_title: bool,
            entity_id: union(enum(u8)) {
                xEntityHorse: struct {
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
            window_id: u8,
            action: i16,
            accepted: bool,
        };

        pub const UpdateSign = struct {
            location: position_isi,
            text1: []u8,
            text2: []u8,
            text3: []u8,
            text4: []u8,
        };

        pub const Map = struct {
            item_damage: vi,
            data: []u8,
        };

        pub const TileEntityData = struct {
            location: position_isi,
            action: u8,
            nbt_data: compressedNbt,
        };

        pub const OpenSignEntity = struct {
            location: position_iii,
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
            display_text: []u8,
            action: i8,
        };

        pub const ScoreboardDisplayObjective = struct {
            position: i8,
            name: []u8,
        };

        pub const ScoreboardTeam = struct {
            team: []u8,
            mode: i8,
            name: union(enum(u8)) {
                x0: struct {
                    name: []u8,
                    prefix: []u8,
                    suffix: []u8,
                    friendly_fire: i8,
                    players: [][]u8,
                },
                x2: struct {
                    name: []u8,
                    prefix: []u8,
                    suffix: []u8,
                    friendly_fire: i8,
                },
                x3: struct {
                    players: [][]u8,
                },
                x4: struct {
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
        };
    };

    pub const c2s = union(C2S) {
        pub const KeepAlive = struct {
            keep_alive_id: i32,
        };

        pub const Chat = struct {
            message: []u8,
        };

        pub const UseEntity = struct {
            target: i32,
            mouse: i8,
            x: union(enum(u8)) {
                x2: struct {
                    x: f32,
                    y: f32,
                    z: f32,
                },
        },
        };

        pub const Flying = struct {
            on_ground: bool,
        };

        pub const Position = struct {
            x: f64,
            stance: f64,
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
            stance: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
            on_ground: bool,
        };

        pub const BlockDig = struct {
            status: i8,
            location: position_ibi,
            face: i8,
        };

        pub const BlockPlace = struct {
            location: position_ibi,
            direction: i8,
            held_item: Slot,
            cursor_x: i8,
            cursor_y: i8,
            cursor_z: i8,
        };

        pub const HeldItemSlot = struct {
            slot_id: i16,
        };

        pub const ArmAnimation = struct {
            entity_id: i32,
            animation: i8,
        };

        pub const EntityAction = struct {
            entity_id: i32,
            action_id: i8,
            jump_boost: i32,
        };

        pub const SteerVehicle = struct {
            sideways: f32,
            forward: f32,
            jump: bool,
            unmount: bool,
        };

        pub const CloseWindow = struct {
            window_id: u8,
        };

        pub const WindowClick = struct {
            window_id: i8,
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
            location: position_isi,
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
        };

        pub const Settings = struct {
            locale: []u8,
            view_distance: i8,
            chat_flags: i8,
            chat_colors: bool,
            difficulty: u8,
            show_cape: bool,
        };

        pub const ClientCommand = struct {
            payload: i8,
        };

        pub const CustomPayload = struct {
            channel: []u8,
            data: []u8,
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
        };
    };
};
