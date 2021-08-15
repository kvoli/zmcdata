pub const ingredient = []Slot;

pub const position = packed struct {
    x: i26,
    z: i26,
    y: i12,
};

pub const handshaking = struct {
    pub const s2c = union(S2C) {
        pub const S2C = enum(u8) {};
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
        pub const PingStart = struct {};

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
            uuid: UUID,
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
            @"type": vi,
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
            difficulty_locked: bool,
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
            sender: UUID,
        };

        pub const MultiBlockChange = struct {
            chunk_coordinates: packed struct {
                x: i22,
                z: i22,
                y: u20,
            },
            not_trust_edges: bool,
            records: []vi,
        };

        pub const CloseWindow = struct {
            window_id: u8,
        };

        pub const OpenWindow = struct {
            window_id: vi,
            inventory_type: vi,
            window_title: []u8,
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

        pub const OpenHorseWindow = struct {
            window_id: u8,
            nb_slots: vi,
            entity_id: i32,
        };

        pub const KeepAlive = struct {
            keep_alive_id: i64,
        };

        pub const MapChunk = struct {
            x: i32,
            z: i32,
            primary_bit_mask: []i64,
            heightmaps: NBT,
            biomes: []vi,
            chunk_data: []u8,
            block_entities: []NBT,
        };

        pub const WorldEvent = struct {
            effect_id: i32,
            location: position,
            data: i32,
            global: bool,
        };

        pub const UpdateLight = struct {
            chunk_x: vi,
            chunk_z: vi,
            trust_edges: bool,
            sky_light_mask: []i64,
            block_light_mask: []i64,
            empty_sky_light_mask: []i64,
            empty_block_light_mask: []i64,
            sky_light: [][]u8,
            block_light: [][]u8,
        };

        pub const Login = struct {
            entity_id: i32,
            is_hardcore: bool,
            game_mode: u8,
            previous_game_mode: i8,
            world_names: [][]u8,
            dimension_codec: NBT,
            dimension: NBT,
            world_name: []u8,
            hashed_seed: i64,
            max_players: vi,
            view_distance: vi,
            reduced_debug_info: bool,
            enable_respawn_screen: bool,
            is_debug: bool,
            is_flat: bool,
        };

        pub const Map = struct {
            item_damage: vi,
            scale: i8,
            locked: bool,
            icons: ?[]struct {
                @"type": vi,
                x: i8,
                y: i8,
                direction: u8,
                display_name: ?[]u8,
            },
            columns: u8,
            rows: union(enum(u8)) {
                @"default": struct {
                    rows: u8,
                    x: u8,
                    y: u8,
                    data: []u8,
                },
            },
        };

        pub const TradeList = struct {
            window_id: vi,
            trades: []struct {
                input_item1: Slot,
                output_item: Slot,
                input_item2: ?Slot,
                trade_disabled: bool,
                nb_trade_uses: i32,
                maximum_nb_trade_uses: i32,
                xp: i32,
                special_price: i32,
                price_multiplier: f32,
                demand: i32,
            },
            villager_level: vi,
            experience: vi,
            is_regular_villager: bool,
            can_restock: bool,
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

        pub const VehicleMove = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
        };

        pub const OpenBook = struct {
            hand: vi,
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

        pub const EndCombatEvent = struct {
            duration: vi,
            entity_id: i32,
        };

        pub const EnterCombatEvent = struct {};

        pub const DeathCombatEvent = struct {
            player_id: vi,
            entity_id: i32,
            message: []u8,
        };

        pub const Position = struct {
            x: f64,
            y: f64,
            z: f64,
            yaw: f32,
            pitch: f32,
            flags: i8,
            teleport_id: vi,
            dismount_vehicle: bool,
        };

        pub const DestroyEntity = struct {
            entity_ids: vi,
        };

        pub const RemoveEntityEffect = struct {
            entity_id: vi,
            effect_id: i8,
        };

        pub const ResourcePackSend = struct {
            url: []u8,
            hash: []u8,
            forced: bool,
        };

        pub const Respawn = struct {
            dimension: NBT,
            world_name: []u8,
            hashed_seed: i64,
            gamemode: u8,
            previous_gamemode: u8,
            is_debug: bool,
            is_flat: bool,
            copy_metadata: bool,
        };

        pub const EntityHeadRotation = struct {
            entity_id: vi,
            head_yaw: i8,
        };

        pub const Camera = struct {
            camera_id: vi,
        };

        pub const HeldItemSlot = struct {
            slot: i8,
        };

        pub const UpdateViewPosition = struct {
            chunk_x: vi,
            chunk_z: vi,
        };

        pub const UpdateViewDistance = struct {
            view_distance: vi,
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
            equipments: TopBitArrayType(struct {
                slot: i8,
                item: Slot,
            }),
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
                    prefix: []u8,
                    suffix: []u8,
                    players: [][]u8,
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
            angle: f32,
        };

        pub const UpdateTime = struct {
            age: i64,
            time: i64,
        };

        pub const EntitySoundEffect = struct {
            sound_id: vi,
            sound_category: vi,
            entity_id: vi,
            volume: f32,
            pitch: f32,
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
            tags: []struct {
                tag_type: []u8,
                tags: Tags,
            },
        };

        pub const AcknowledgePlayerDigging = struct {
            location: position,
            block: vi,
            status: vi,
            successful: bool,
        };

        pub const SculkVibrationSignal = struct {
            source_position: position,
            destination_identifier: []u8,
            destination: union(enum(u8)) {
                @"block": struct {
                    destination: position,
                },
                @"entityId": struct {
                    destination: vi,
                },
            },
            arrival_ticks: vi,
        };

        pub const ClearTitles = struct {
            reset: bool,
        };

        pub const InitializeWorldBorder = struct {
            x: f64,
            z: f64,
            old_diameter: f64,
            new_diameter: f64,
            speed: vi,
            portal_teleport_boundary: vi,
            warning_blocks: vi,
            warning_time: vi,
        };

        pub const ActionBar = struct {
            text: []u8,
        };

        pub const WorldBorderCenter = struct {
            x: f64,
            z: f64,
        };

        pub const WorldBorderLerpSize = struct {
            old_diameter: f64,
            new_diameter: f64,
            speed: vi,
        };

        pub const WorldBorderSize = struct {
            diameter: f64,
        };

        pub const WorldBorderWarningDelay = struct {
            warning_time: vi,
        };

        pub const WorldBorderWarningReach = struct {
            warning_blocks: vi,
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
            fade_in: i32,
            stay: i32,
            fade_out: i32,
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

        pub const S2C = enum(u8) {
            spawn_entity: 0x00,
            spawn_entity_experience_orb: 0x01,
            spawn_entity_living: 0x02,
            spawn_entity_painting: 0x03,
            named_entity_spawn: 0x04,
            sculk_vibration_signal: 0x05,
            animation: 0x06,
            statistics: 0x07,
            acknowledge_player_digging: 0x08,
            block_break_animation: 0x09,
            tile_entity_data: 0x0a,
            block_action: 0x0b,
            block_change: 0x0c,
            boss_bar: 0x0d,
            difficulty: 0x0e,
            chat: 0x0f,
            clear_titles: 0x10,
            tab_complete: 0x11,
            declare_commands: 0x12,
            close_window: 0x13,
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
            open_horse_window: 0x1f,
            initialize_world_border: 0x20,
            keep_alive: 0x21,
            map_chunk: 0x22,
            world_event: 0x23,
            world_particles: 0x24,
            update_light: 0x25,
            login: 0x26,
            map: 0x27,
            trade_list: 0x28,
            rel_entity_move: 0x29,
            entity_move_look: 0x2a,
            entity_look: 0x2b,
            vehicle_move: 0x2c,
            open_book: 0x2d,
            open_window: 0x2e,
            open_sign_entity: 0x2f,
            ping: 0x30,
            craft_recipe_response: 0x31,
            abilities: 0x32,
            end_combat_event: 0x33,
            enter_combat_event: 0x34,
            death_combat_event: 0x35,
            player_info: 0x36,
            face_player: 0x37,
            position: 0x38,
            unlock_recipes: 0x39,
            destroy_entity: 0x3a,
            remove_entity_effect: 0x3b,
            resource_pack_send: 0x3c,
            respawn: 0x3d,
            entity_head_rotation: 0x3e,
            multi_block_change: 0x3f,
            select_advancement_tab: 0x40,
            action_bar: 0x41,
            world_border_center: 0x42,
            world_border_lerp_size: 0x43,
            world_border_size: 0x44,
            world_border_warning_delay: 0x45,
            world_border_warning_reach: 0x46,
            camera: 0x47,
            held_item_slot: 0x48,
            update_view_position: 0x49,
            update_view_distance: 0x4a,
            spawn_position: 0x4b,
            scoreboard_display_objective: 0x4c,
            entity_metadata: 0x4d,
            attach_entity: 0x4e,
            entity_velocity: 0x4f,
            entity_equipment: 0x50,
            experience: 0x51,
            update_health: 0x52,
            scoreboard_objective: 0x53,
            set_passengers: 0x54,
            teams: 0x55,
            scoreboard_score: 0x56,
            set_title_subtitle: 0x57,
            update_time: 0x58,
            set_title_text: 0x59,
            set_title_time: 0x5a,
            entity_sound_effect: 0x5b,
            sound_effect: 0x5c,
            stop_sound: 0x5d,
            playerlist_header: 0x5e,
            nbt_query_response: 0x5f,
            collect: 0x60,
            entity_teleport: 0x61,
            advancements: 0x62,
            entity_update_attributes: 0x63,
            entity_effect: 0x64,
            declare_recipes: 0x65,
            tags: 0x66,
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

        pub const SetDifficulty = struct {
            new_difficulty: u8,
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
            disable_text_filtering: bool,
        };

        pub const EnchantItem = struct {
            window_id: i8,
            enchantment: i8,
        };

        pub const WindowClick = struct {
            window_id: u8,
            slot: i16,
            mouse_button: i8,
            mode: i8,
            changed_slots: []struct {
                location: i16,
                item: Slot,
            },
            clicked_item: Slot,
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
            sneaking: bool,
        };

        pub const GenerateStructure = struct {
            location: position,
            levels: vi,
            keep_jigsaws: bool,
        };

        pub const KeepAlive = struct {
            keep_alive_id: i64,
        };

        pub const LockDifficulty = struct {
            locked: bool,
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

        pub const DisplayedRecipe = struct {
            recipe_id: []u8,
        };

        pub const RecipeBook = struct {
            book_id: vi,
            book_open: bool,
            filter_active: bool,
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

        pub const UpdateJigsawBlock = struct {
            location: position,
            name: []u8,
            target: []u8,
            pool: []u8,
            final_state: []u8,
            joint_type: []u8,
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
            hand: vi,
            location: position,
            direction: vi,
            cursor_x: f32,
            cursor_y: f32,
            cursor_z: f32,
            inside_block: bool,
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

        pub const C2S = enum(u8) {
            teleport_confirm: 0x00,
            query_block_nbt: 0x01,
            set_difficulty: 0x02,
            chat: 0x03,
            client_command: 0x04,
            settings: 0x05,
            tab_complete: 0x06,
            enchant_item: 0x07,
            window_click: 0x08,
            close_window: 0x09,
            custom_payload: 0x0a,
            edit_book: 0x0b,
            query_entity_nbt: 0x0c,
            use_entity: 0x0d,
            generate_structure: 0x0e,
            keep_alive: 0x0f,
            lock_difficulty: 0x10,
            position: 0x11,
            position_look: 0x12,
            look: 0x13,
            flying: 0x14,
            vehicle_move: 0x15,
            steer_boat: 0x16,
            pick_item: 0x17,
            craft_recipe_request: 0x18,
            abilities: 0x19,
            block_dig: 0x1a,
            entity_action: 0x1b,
            steer_vehicle: 0x1c,
            pong: 0x1d,
            displayed_recipe: 0x1e,
            recipe_book: 0x1f,
            name_item: 0x20,
            resource_pack_receive: 0x21,
            advancement_tab: 0x22,
            select_trade: 0x23,
            set_beacon_effect: 0x24,
            held_item_slot: 0x25,
            update_command_block: 0x26,
            update_command_block_minecart: 0x27,
            set_creative_slot: 0x28,
            update_jigsaw_block: 0x29,
            update_structure_block: 0x2a,
            update_sign: 0x2b,
            arm_animation: 0x2c,
            spectate: 0x2d,
            block_place: 0x2e,
            use_item: 0x2f,
        };
    };
};
