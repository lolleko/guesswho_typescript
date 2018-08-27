import { GWGamerules } from "../entities/entities/gw_gamerules";

import { GWConfigManager, GWConfigData } from "./configmanager"
import { GWClassName } from "./classname";
import { GWTeam } from "./team";

AddCSLuaFile();

/** !Extension GM */
export class GWGamemode extends Gamemode {
    private gamerules: GWGamerules;
    private configManager: GWConfigManager;

    public get Gamerules(): GWGamerules {
        return this.gamerules;
    }

    public get ConfigManager(): GWConfigManager {
        return this.configManager;
    }

    public get ConfigData(): GWConfigData {
        return this.configManager.Data;
    }

    public CreateTeams(): void {
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

    public InitPostEntity(): void {
        print("Creating gamerules");
        if (SERVER) {
            this.gamerules = ents.Create(GWClassName.ENT_GAMERULES) as GWGamerules;
        } else {
            this.gamerules = ents.FindByClass(GWClassName.ENT_GAMERULES)[0] as GWGamerules;
        }

        this.configManager = new GWConfigManager();
    }
}
