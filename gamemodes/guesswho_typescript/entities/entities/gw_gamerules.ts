AddCSLuaFile();

/** !Extension ENT */
class GWGamerules extends Entity {
    public Type: string = "point";

    public get SpawnPoints(): Entity[] {
        return this.spawnPoints;
    }

    private spawnPoints: Entity[];

    private walkerCount: number;

    private maxWalkers: number;

    public get SettingBaseWalkerAmount(): number {
        return GetConVar("gw_basewalkeramount").GetInt();
    }
    public get SettingWalkerPerPly(): number {
        return GetConVar("gw_walkerperplayer").GetInt();
    }
    public get SettingPreGameDuration(): number {
        return GetConVar("gw_pregameduration").GetInt();
    }
    public get SettingRoundDuration(): number {
        return GetConVar("gw_roundduration").GetInt();
    }
    public get SettingHidingDuration(): number {
        return GetConVar("gw_hideduration").GetInt();
    }
    public get SettingPostRoundDuration(): number {
        return GetConVar("gw_postroundduration").GetInt();
    }
    public get SettingMaxRounds(): number {
        return GetConVar("gw_maxrounds").GetInt();
    }
    public get SettingMinHiders(): number {
        return GetConVar("gw_minhiders").GetInt();
    }
    public get SettingMinSeekers(): number {
        return GetConVar("gw_minseekers").GetInt();
    }

    private get GameTimerEndTime(): number {
        return this.GetDTFloat(0);
    }

    private set GameTimerEndTime(time: number) {
        this.SetDTFloat(0, time);
    }

    public get GameTime(): number {
        return this.GameTimerEndTime - CurTime();
    }

    public get GameState(): GWGameState {
        return this.GetDTInt(0);
    }

    public set GameState(state: GWGameState) {
        this.SetDTInt(0, state);
    }

    public SetupDataTables(): void {
        this.DTVar("Float", 0, "GameTimerEndTime");
        this.DTVar("Int", 0, "GameState");
    }

    public Initialize(): void {
        hook.Add(
            "PlayerDeath", "gw_rules_player_death",
            (victim, inflictor, attacker) => {
                this.HandlePlayerDeath(victim, attacker, inflictor);
            });

        this.GameTimerEndTime = CurTime();

        this.HandleWaiting();

        print("updating spawnpoints");

        this.UpdateSpawnpoints();

        print("Initializing Gamerules");
    }

    public Think(): boolean {
        if (SERVER) {
            if (this.GameState === GWGameState.WAITING) {
                if (team.NumPlayers(TEAM.HIDER) < this.SettingMinHiders ||
                    team.NumPlayers(TEAM.SEEKER) < this.SettingMinSeekers) {
                    // ents.FindByClass(GWClassName.NPC_WALKER).forEach(ent => ent.Remove());
                    this.NextThink(CurTime() + 1);
                    print("Wating");
                    return true;
                } else {
                    this.HandleCreating();
                }
            }
        }
        DebugInfo(0, "TIME: " + this.GameTime);
        DebugInfo(1, "STATE: " + this.GameState);

        return false;
    }

    public UpdateTransmitState(): TRANSMIT {
        return TRANSMIT.TRANSMIT_ALWAYS;
    }

    private HandlePlayerDeath(victim: Player, inflictor: Entity, attacker: Entity): void {
        const playersOnVictimTeam = team.GetPlayers(victim.Team()) as Player[];
        const someAlive = playersOnVictimTeam.some(ply => ply.Alive() && ply !== victim);
        print("dead ", someAlive);
        if (!someAlive && this.GameState === GWGameState.SEEKING) {
            print(this);
            this.HandlePostRound();
        }
    }

    private HandleWaiting(): void {
        this.GameState = GWGameState.WAITING;
        this.GameTimerEndTime = CurTime() + 1;
    }

    private HandleCreating(): void {
        this.GameState = GWGameState.CREATING;

        this.walkerCount = 0;

        const playerCount = player.GetCount();

        this.maxWalkers = this.SettingBaseWalkerAmount + (playerCount * this.SettingWalkerPerPly);

        if (this.spawnPoints.length >= this.maxWalkers) {
            const walkersSpawned = this.SpawnNPCWave();
            MsgN("GW Spawned ", walkersSpawned, " NPCs in 1 wave.");
        } else {
            const spawnRounds = math.ceil(this.maxWalkers / this.spawnPoints.length);
            this.GameTimerEndTime = CurTime() + spawnRounds * 7;
            for (let wave = 0; wave < spawnRounds; wave++) {
                timer.Simple(wave * 7, () => {
                    const walkersSpawned = this.SpawnNPCWave();
                    MsgN("GW Spawned ", walkersSpawned, " NPCs in wave ", wave + 1, ".");
                });
            }

            timer.Simple(spawnRounds * 7, () => {
                this.HandleHiding();
            });
        }
    }

    private HandleHiding(): void {
        this.GameState = GWGameState.HIDING;
        this.GameTimerEndTime = CurTime() + this.SettingHidingDuration;
        (team.GetPlayers( TEAM.HIDER ) as Player[]).forEach(ply => ply.Spawn());
        timer.Simple(this.SettingHidingDuration, () => this.HandleSeeking());
    }

    private HandleSeeking(): void {
        this.GameState = GWGameState.SEEKING;
        this.GameTimerEndTime = CurTime() + this.SettingRoundDuration;
        timer.Create("GWRoundEndTimer", this.SettingRoundDuration, 1, () => this.HandlePostRound());
    }

    private HandlePostRound(): void {
        if (timer.Exists("GWRoundEndTimer")) {
            timer.Remove("GWRoundEndTimer");
        }
        const hiders = team.GetPlayers(TEAM.HIDER) as Player[];
        const someHidersAlive = hiders.some(ply => ply.Alive());
        if (someHidersAlive) {
            print("Hiders Win");
        } else {
            print("Seekers Win");
        }

        // Cleanup
        game.CleanUpMap(false, [this.GetClass()]);

        ents.FindByClass(GWClassName.NPC_WALKER).forEach(npc => npc.Remove());

        // TeamSwap
        (player.GetAll() as Player[]).forEach(ply => {
            if (ply.Team() === TEAM.HIDER) {
                ply.SetTeam(TEAM.SEEKER);
            } else if (ply.Team() === TEAM.SEEKER) {
                ply.SetTeam(TEAM.HIDER);
            }
        });

        this.GameTimerEndTime = CurTime() + this.SettingPostRoundDuration;
        timer.Simple(this.SettingPostRoundDuration, () => this.HandleWaiting());
    }

    private UpdateSpawnpoints(): void {
        const spawnPointClasses = [
            "info_player_start",
            "info_player_deathmatch",
            "info_player_combine",
            "info_player_rebel",
            "info_player_counterterrorist",
            "info_player_terrorist",
            "info_player_axis",
            "info_player_allies",
            "gmod_player_start",
            "info_player_teamspawn",
            "ins_spawnpoint",
            "aoc_spawnpoint",
            "dys_spawn_point",
            "info_player_pirate",
            "info_player_viking",
            "info_player_knight",
            "diprip_start_team_blue",
            "diprip_start_team_red",
            "info_player_red",
            "info_player_blue",
            "info_player_coop",
            "info_player_human",
            "info_player_zombie",
            "info_player_deathmatch",
            "info_player_zombiemaster",
        ];

        this.spawnPoints = [];

        for (const sp of spawnPointClasses) {
            this.spawnPoints.push(...ents.FindByClass(sp));
        }

        // fast schuffle
        const rand = math.random;
        let n = this.spawnPoints.length - 1;

        while (n > 2) {
            const k = rand(1, n);  // 1 <= k <= n

            const temp = this.spawnPoints[n];
            this.spawnPoints[n] = this.spawnPoints[k];
            this.spawnPoints[k] = temp;
            n = n - 1;
        }
    }

    private SpawnNPCWave(): number {
        let spawnedWalkers = 0;
        this.spawnPoints.forEach(sp => {
            if (this.walkerCount < this.maxWalkers) {
                const mins: Vector = sp.GetPos() as any + new Vector(-16, -16, 0);
                const maxs: Vector = sp.GetPos() as any + new Vector(16, 16, 64);
                const occupied =
                    ents.FindInBox(mins, maxs).some(ent => ent.GetClass() === GWClassName.NPC_WALKER);
                if (!occupied) {
                    const walker = ents.Create(GWClassName.NPC_WALKER);
                    if (IsValid(walker)) {
                            walker.SetPos(sp.GetPos());
                            walker.Spawn();
                            walker.Activate();
                        }
                    spawnedWalkers++;
                }
            }
        });
        this.walkerCount += spawnedWalkers;
        return spawnedWalkers;
    }
}
