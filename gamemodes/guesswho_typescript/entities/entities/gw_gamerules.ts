import { GWClassNames } from "../../gamemode/classnames";
import { GWGameState } from "../../gamemode/gamestate";
import { GWTeam } from "../../gamemode/team";

AddCSLuaFile();

/** !Extension ENT */
export class GWGamerules extends Entity {
    public Type: string = "point";

    private SpawnPoints: Entity[];

    private WalkerCount: number;

    private MaxWalkers: number;

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
        return GetConVar("gw_hidinguration").GetInt();
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
        return this["dt"].GameTimerEndTime;
    }

    private set GameTimerEndTime(time: number) {
        this["dt"].GameTimerEndTime = time;
    }

    public get GameTime(): number {
        return this.GameTimerEndTime - CurTime();
    }

    public get GameState(): GWGameState {
        return this["dt"].GameState;
    }

    public set GameState(state: GWGameState) {
        this["dt"].GameState = state;
    }

    protected SetupDataTables(): void {
        this.DTVar("Float", 0, "GameTimerEndTime");
        this.DTVar("Int", 0, "GameState");
    }

    protected Initialize(): void {
        hook.Add(
            "PlayerDeath", "gw_rules_player_death",
            (victim, inflictor, attacker) => {
                this.HandlePlayerDeath(victim, attacker, inflictor);
            });

        this.GameTimerEndTime = CurTime();

        this.HandleWaiting();

        this.UpdateSpawnpoints();

        print("Initializing Gamerules");
    }

    protected Think(): boolean {
        if (SERVER) {
            if (this.GameState === GWGameState.WAITING) {
                if (team.NumPlayers(GWTeam.HIDERS) < this.SettingMinHiders ||
                    team.NumPlayers(GWTeam.SEEKERS) < this.SettingMinSeekers) {
                    (ents.FindByClass(GWClassNames.NPC_WALKER) as Entity[]).forEach(ent => ent.Remove());
                    this.NextThink(CurTime() + 1);
                    print("Wating");
                    return true;
                } else {
                    this.HandleCreating();
                }
            }
        }

        return false;
    }

    protected UpdateTransmitState(): TRANSMIT {
        return TRANSMIT.TRANSMIT_ALWAYS;
    }

    private HandlePlayerDeath(victim: Player, inflictor: Entity, attacker: Entity): void {
        const playersOnVictimTeam = team.GetPlayers(victim.Team()) as Player[];
        const someAlive = playersOnVictimTeam.some(ply => ply.Alive());
        if (!someAlive) {
            this.HandlePostRound();
        }
    }

    private HandleWaiting(): void {
        this.GameState = GWGameState.WAITING;
        this.GameTimerEndTime = CurTime() + 1;
    }

    private HandleCreating(): void {
        this.GameState = GWGameState.CREATING;

        this.WalkerCount = 0;

        const playerCount = player.GetCount();

        this.MaxWalkers = this.SettingBaseWalkerAmount + (playerCount * this.SettingWalkerPerPly);

        if (this.SpawnPoints.length >= this.MaxWalkers) {
            const walkersSpawned = this.SpawnNPCWave();
            MsgN("GW Spawned ", walkersSpawned, " NPCs in 1 wave.");
        } else {
            const spawnRounds = math.floor(this.MaxWalkers / this.SpawnPoints.length);
            this.GameTimerEndTime = CurTime() + spawnRounds * 5;
            for (let wave = 0; wave <= spawnRounds; wave++) {
                timer.Simple(wave * 5, () => {
                    const walkersSpawned = this.SpawnNPCWave();
                    MsgN("GW Spawned ", walkersSpawned, " NPCs in wave ", wave + 1, ".");
                    if (wave === spawnRounds) {
                        this.HandleHiding();
                    }
                });
            }
        }
    }

    private HandleHiding(): void {
        this.GameState = GWGameState.HIDING;
        this.GameTimerEndTime = CurTime() + this.SettingHidingDuration;
        (team.GetPlayers( GWTeam.HIDERS ) as Player[]).forEach(ply => ply.Spawn());
        timer.Simple(this.SettingHidingDuration, () => this.HandleSeeking());
    }

    private HandleSeeking(): void {
        this.GameState = GWGameState.SEEKING;
        this.GameTimerEndTime = CurTime() + this.SettingRoundDuration;
        timer.Simple(this.SettingHidingDuration, () => this.HandlePostRound());
    }

    private HandlePostRound(): void {
        const hiders = team.GetPlayers(GWTeam.HIDERS) as Player[];
        const someHidersAlive = hiders.some(ply => ply.Alive());
        if (someHidersAlive) {
            print("Hiders Win");
        } else {
            print("Seekers Win");
        }
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

        this.SpawnPoints = [];

        spawnPointClasses.forEach(sp => this.SpawnPoints.push(...(ents.FindByClass(sp) as Entity[])));

        // fast schuffle
        const rand = math.random;
        let n = this.SpawnPoints.length - 1;

        while (n > 2) {
            const k = rand(1, n);  // 1 <= k <= n

            const temp = this.SpawnPoints[n];
            this.SpawnPoints[n] = this.SpawnPoints[k];
            this.SpawnPoints[k] = temp;
            n = n - 1;
        }
    }

    private SpawnNPCWave(): number {
        let spawnedWalkers = 0;
        this.SpawnPoints.forEach(sp => {
            if (this.WalkerCount < this.MaxWalkers) {
                const mins: Vector = sp.GetPos() as any + new Vector(-16, -16, 0) as any;
                const maxs: Vector = sp.GetPos() as any + new Vector(16, 16, 64) as any;
                const occupied =
                    (ents.FindInBox(mins, maxs) as Entity[]).some(ent => ent.GetClass() === GWClassNames.NPC_WALKER);
                if (!occupied) {
                    const walker = ents.Create(GWClassNames.NPC_WALKER);
                    if (IsValid(walker)) {
                        walker.SetPos(sp.GetPos());
                        walker.Spawn();
                        walker.Activate();
                    }
                    spawnedWalkers++;
                }
            }
        });
        this.WalkerCount += spawnedWalkers;
        return spawnedWalkers;
    }
}
