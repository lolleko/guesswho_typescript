import { GWGamerules } from "../entities/entities/gw_gamerules";

import { GWClassNames } from "./classnames";
import { GWTeam } from "./team";

AddCSLuaFile();

/** !Extension GM */
class GWGamemode extends GM {
    private Gamerules: GWGamerules;

    protected CreateTeams(): void {
        // TODO color in cfg or gamerules
        team.SetUp(GWTeam.HIDERS, "Hiding", Color(0, 0, 0));
        team.SetClass(GWTeam.HIDERS, "player_hiding");
        team.SetSpawnPoint(GWTeam.HIDERS, "info_player_start");
        team.SetSpawnPoint(GWTeam.HIDERS, "info_player_deathmatch");
        team.SetSpawnPoint(GWTeam.HIDERS, "info_player_rebel");
        team.SetSpawnPoint(GWTeam.HIDERS, "info_player_combine");
        team.SetSpawnPoint(GWTeam.HIDERS, "info_player_counterterrorist");
        team.SetSpawnPoint(GWTeam.HIDERS, "info_player_terrorist");

        team.SetUp(GWTeam.SEEKERS, "Seekers", Color(0, 0, 0));
        team.SetClass(GWTeam.SEEKERS, "player_seeker");
        team.SetSpawnPoint(GWTeam.SEEKERS, "info_player_start");
        team.SetSpawnPoint(GWTeam.SEEKERS, "info_player_deathmatch");
        team.SetSpawnPoint(GWTeam.SEEKERS, "info_player_rebel");
        team.SetSpawnPoint(GWTeam.SEEKERS, "info_player_combine");
        team.SetSpawnPoint(GWTeam.SEEKERS, "info_player_counterterrorist");
        team.SetSpawnPoint(GWTeam.SEEKERS, "info_player_terrorist");

        team.SetSpawnPoint(TEAM.TEAM_SPECTATOR, "worldspawn");
    }

    protected InitPostEntity(): void {
        print("Creating gamerules");
        if (SERVER) {
            this.Gamerules = ents.Create(GWClassNames.ENT_GAMERULES) as GWGamerules;
        } else {
            this.Gamerules = ents.FindByClass(GWClassNames.ENT_GAMERULES) as GWGamerules;
        }
    }
}
