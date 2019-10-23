AddCSLuaFile();

/** @extension GM */
class GWGamemodeSH extends Gamemode {
    public TeamBased = true;

    private gamerules: GWGamerules;

    public get Gamerules(): GWGamerules {
        return this.gamerules;
    }

    public CreateTeams(): void {
        // TODO color in cfg or gamerules
        team.SetUp(TEAM.HIDER, "Hiding", GWConfigManager.GetInstance().Data.TeamHidingColor);
        team.SetClass(TEAM.HIDER, "player_hiding");
        team.SetSpawnPoint(TEAM.HIDER, "info_player_start");
        team.SetSpawnPoint(TEAM.HIDER, "info_player_deathmatch");
        team.SetSpawnPoint(TEAM.HIDER, "info_player_rebel");
        team.SetSpawnPoint(TEAM.HIDER, "info_player_combine");
        team.SetSpawnPoint(TEAM.HIDER, "info_player_counterterrorist");
        team.SetSpawnPoint(TEAM.HIDER, "info_player_terrorist");

        team.SetUp(TEAM.SEEKER, "Seekers", GWConfigManager.GetInstance().Data.TeamSeekingColor);
        team.SetClass(TEAM.SEEKER, "player_seeker");
        team.SetSpawnPoint(TEAM.SEEKER, "info_player_start");
        team.SetSpawnPoint(TEAM.SEEKER, "info_player_deathmatch");
        team.SetSpawnPoint(TEAM.SEEKER, "info_player_rebel");
        team.SetSpawnPoint(TEAM.SEEKER, "info_player_combine");
        team.SetSpawnPoint(TEAM.SEEKER, "info_player_counterterrorist");
        team.SetSpawnPoint(TEAM.SEEKER, "info_player_terrorist");

        team.SetSpawnPoint(TEAM.TEAM_SPECTATOR, "worldspawn");
    }

    public InitPostEntity(): void {
        print("Creating gamerules");
        if (SERVER) {
            this.gamerules = ents.Create(GWClassName.ENT_GAMERULES) as GWGamerules;
            this.gamerules.Spawn();
            GWConfigManager.Setup();
        } else {
            this.gamerules = ents.FindByClass(GWClassName.ENT_GAMERULES)[0] as GWGamerules;
        }
    }
}
