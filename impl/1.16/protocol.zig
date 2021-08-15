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
                        icon: ?Slot,
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
            nbtData: ?NBT,
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
            windowId: varint,
            inventoryType: varint,
            windowTitle: []u8,
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

        pub const SetSlot = struct {
            windowId: i8,
            slot: i16,
            item: ?Slot,
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
            groundUp: bool,
            ignoreOldData: bool,
            bitMap: varint,
            heightmaps: nbt,
            biomes: SwitchType(groundUp, struct {
                xfalse: void,
                xtrue: ArrayType(undefined, i32),
                default: void,
            }),
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
            data: particleData,
        };

        pub const UpdateLight = struct {
            chunkX: varint,
            chunkZ: varint,
            trustEdges: bool,
            skyLightMask: varint,
            blockLightMask: varint,
            emptySkyLightMask: varint,
            emptyBlockLightMask: varint,
            data: []u8,
        };

        pub const Login = struct {
            entityId: i32,
            gameMode: u8,
            previousGameMode: u8,
            worldNames: ArrayType(varint, []u8),
            dimensionCodec: nbt,
            dimension: []u8,
            worldName: []u8,
            hashedSeed: i64,
            maxPlayers: u8,
            viewDistance: varint,
            reducedDebugInfo: bool,
            enableRespawnScreen: bool,
            isDebug: bool,
            isFlat: bool,
        };

        pub const Map = struct {
            itemDamage: varint,
            scale: i8,
            trackingPosition: bool,
            locked: bool,
            icons: ArrayType(varint, struct {
                type: varint,
                x: i8,
                y: i8,
                direction: u8,
                displayName: ?[]u8,
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

        pub const TradeList = struct {
            windowId: varint,
            trades: ArrayType(u8, struct {
                inputItem1: ?Slot,
                outputItem: ?Slot,
                inputItem2: ??Slot,
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

        pub const UnlockRecipes = struct {
            action: varint,
            craftingBookOpen: bool,
            filteringCraftable: bool,
            smeltingBookOpen: bool,
            filteringSmeltable: bool,
            recipes1: ArrayType(varint, []u8),
            recipes2: SwitchType(action, struct {
                x0: ArrayType(varint, []u8),
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
            dimension: []u8,
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
                item: ?Slot,
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

        pub const Tags = struct {
            blockTags: ,
            itemTags: ,
            fluidTags: ,
            entityTags: ,
        };

        pub const AcknowledgePlayerDigging = struct {
            location: position,
            block: varint,
            status: varint,
            successful: bool,
        };

        spawn_entity: SpawnEntity,
        spawn_entity_experience_orb: SpawnEntityExperienceOrb,
        spawn_entity_living: SpawnEntityLiving,
        spawn_entity_painting: SpawnEntityPainting,
        named_entity_spawn: NamedEntitySpawn,
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
        multi_block_change: MultiBlockChange,
        tab_complete: TabComplete,
        declare_commands: DeclareCommands,
        transaction: Transaction,
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
        entity: Entity,
        vehicle_move: VehicleMove,
        open_book: OpenBook,
        open_window: OpenWindow,
        open_sign_entity: OpenSignEntity,
        craft_recipe_response: CraftRecipeResponse,
        abilities: Abilities,
        combat_event: CombatEvent,
        player_info: PlayerInfo,
        face_player: FacePlayer,
        position: Position,
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
        update_time: UpdateTime,
        title: Title,
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
            animation: 0x05,
            statistics: 0x06,
            acknowledge_player_digging: 0x07,
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
            keep_alive: 0x20,
            map_chunk: 0x21,
            world_event: 0x22,
            world_particles: 0x23,
            update_light: 0x24,
            login: 0x25,
            map: 0x26,
            trade_list: 0x27,
            rel_entity_move: 0x28,
            entity_move_look: 0x29,
            entity_look: 0x2a,
            entity: 0x2b,
            vehicle_move: 0x2c,
            open_book: 0x2d,
            open_window: 0x2e,
            open_sign_entity: 0x2f,
            craft_recipe_response: 0x30,
            abilities: 0x31,
            combat_event: 0x32,
            player_info: 0x33,
            face_player: 0x34,
            position: 0x35,
            unlock_recipes: 0x36,
            entity_destroy: 0x37,
            remove_entity_effect: 0x38,
            resource_pack_send: 0x39,
            respawn: 0x3a,
            entity_head_rotation: 0x3b,
            select_advancement_tab: 0x3c,
            world_border: 0x3d,
            camera: 0x3e,
            held_item_slot: 0x3f,
            update_view_position: 0x40,
            update_view_distance: 0x41,
            spawn_position: 0x42,
            scoreboard_display_objective: 0x43,
            entity_metadata: 0x44,
            attach_entity: 0x45,
            entity_velocity: 0x46,
            entity_equipment: 0x47,
            experience: 0x48,
            update_health: 0x49,
            scoreboard_objective: 0x4a,
            set_passengers: 0x4b,
            teams: 0x4c,
            scoreboard_score: 0x4d,
            update_time: 0x4e,
            title: 0x4f,
            entity_sound_effect: 0x50,
            sound_effect: 0x51,
            stop_sound: 0x52,
            playerlist_header: 0x53,
            nbt_query_response: 0x54,
            collect: 0x55,
            entity_teleport: 0x56,
            advancements: 0x57,
            entity_update_attributes: 0x58,
            entity_effect: 0x59,
            declare_recipes: 0x5a,
            tags: 0x5b,
        };
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
            new_book: ?Slot,
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
            item: ?Slot,
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

        pub const CraftingBookData = struct {
            type: varint,
            undefined: SwitchType(type, struct {
                x0: struct {
            displayedRecipe: []u8,
        },
                x1: struct {
            craftingBookOpen: bool,
            craftingFilter: bool,
            smeltingBookOpen: bool,
            smeltingFilter: bool,
            blastingBookOpen: bool,
            blastingFilter: bool,
            smokingBookOpen: bool,
            smokingFilter: bool,
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
            item: ?Slot,
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
                x1: void,
                default: void,
            }),
        };

        teleport_confirm: TeleportConfirm,
        query_block_nbt: QueryBlockNbt,
        set_difficulty: SetDifficulty,
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
            transaction: 0x07,
            enchant_item: 0x08,
            window_click: 0x09,
            close_window: 0x0a,
            custom_payload: 0x0b,
            edit_book: 0x0c,
            query_entity_nbt: 0x0d,
            use_entity: 0x0e,
            generate_structure: 0x0f,
            keep_alive: 0x10,
            lock_difficulty: 0x11,
            position: 0x12,
            position_look: 0x13,
            look: 0x14,
            flying: 0x15,
            vehicle_move: 0x16,
            steer_boat: 0x17,
            pick_item: 0x18,
            craft_recipe_request: 0x19,
            abilities: 0x1a,
            block_dig: 0x1b,
            entity_action: 0x1c,
            steer_vehicle: 0x1d,
            crafting_book_data: 0x1e,
            name_item: 0x1f,
            resource_pack_receive: 0x20,
            advancement_tab: 0x21,
            select_trade: 0x22,
            set_beacon_effect: 0x23,
            held_item_slot: 0x24,
            update_command_block: 0x25,
            update_command_block_minecart: 0x26,
            set_creative_slot: 0x27,
            update_jigsaw_block: 0x28,
            update_structure_block: 0x29,
            update_sign: 0x2a,
            arm_animation: 0x2b,
            spectate: 0x2c,
            block_place: 0x2d,
            use_item: 0x2e,
        };
    };
};
