AddCSLuaFile();

const GWDefaultConfigData: GWConfigData = {
    ActiveAbilities: [
        "weapon_gw_prophunt",
        "weapon_gw_surge",
        "weapon_gw_shockwave",
        "weapon_gw_cloak",
        "weapon_gw_shrink",
        "weapon_gw_decoy",
        "weapon_gw_sudoku",
        "weapon_gw_disguise",
        "weapon_gw_vampirism",
        "weapon_gw_ragdoll",
        "weapon_gw_superhot",
        "weapon_gw_dance_party",
        "weapon_gw_blasting_off",
        "weapon_gw_decoy2",
        "weapon_gw_teleport",
        "weapon_gw_deflect",
        "weapon_gw_timelapse",
        "weapon_gw_solarflare",
        "weapon_gw_mind_control",
        "weapon_gw_ant",
    ],
    AllAbilities: [
        "weapon_gw_prophunt",
        "weapon_gw_surge",
        "weapon_gw_shockwave",
        "weapon_gw_cloak",
        "weapon_gw_shrink",
        "weapon_gw_decoy",
        "weapon_gw_sudoku",
        "weapon_gw_disguise",
        "weapon_gw_vampirism",
        "weapon_gw_ragdoll",
        "weapon_gw_superhot",
        "weapon_gw_dance_party",
        "weapon_gw_blasting_off",
        "weapon_gw_decoy2",
        "weapon_gw_teleport",
        "weapon_gw_deflect",
        "weapon_gw_timelapse",
        "weapon_gw_solarflare",
        "weapon_gw_mind_control",
        "weapon_gw_ant",
    ],
    HiderModels: [
        "models/player/alyx.mdl",
        "models/player/breen.mdl",
        "models/player/barney.mdl",
        "models/player/eli.mdl",
        "models/player/gman_high.mdl",
        "models/player/kleiner.mdl",
        "models/player/monk.mdl",
        "models/player/odessa.mdl",
        "models/player/magnusson.mdl",
        "models/player/p2_chell.mdl",
        "models/player/mossman_arctic.mdl",
    ],
    SeekerModels: [
        "models/player/combine_super_soldier.mdl",
    ],
    TeamHidingColor: Color(138, 155, 15),
    TeamSeekingColor: Color(23, 89, 150),
    Version: "3.0.0",
    WalkerColors: [
        Color(61, 87, 105),
        Color(240, 240, 240),
        Color(50, 50, 50),
        Color(139, 115, 85),
        Color(241, 169, 101),
        Color(75, 97, 34),
        Color(157, 107, 0),
        Color(159, 205, 234),
        Color(94, 25, 34),
    ],
};

class GWConfigManager {

    public get Data(): GWConfigData {
        return this.data;
    }

    public set Data(data: GWConfigData) {
        this.data = data;
    }

    public static GetInstance(): GWConfigManager {
        if (!GWConfigManager.instance) {
            GWConfigManager.instance = new GWConfigManager();
        }
        return GWConfigManager.instance;
    }

    public static Setup(): void {
        if (SERVER) {
            const instance = GWConfigManager.GetInstance();

            if (instance.ExistsConfig()) {
                instance.ReadConfig();
            } else {
                instance.data = GWDefaultConfigData;
                instance.WriteConfig();
            }
            hook.Add("PlayerInitialSpawn",
                     "gw_config_manager_initial_spawn",
                     ply => instance.HandlePlayerInitialSpawn(ply));
        }
    }

    private static instance: GWConfigManager;

    private data: GWConfigData;

    private constructor() {

    }

    public WriteConfig(): void {
        if (!file.Exists("guesswho", "DATA")) {
            file.CreateDir("guesswho");
        }
        file.Write("guesswho/config.txt", util.TableToJSON(this.data));
    }

    public ReadConfig(): void {
        this.data = util.JSONToTable(file.Read("guesswho/config.txt")) as GWConfigData;
    }

    public ExistsConfig(): boolean {
        return file.Exists("guesswho/config.txt", "DATA");
    }

    public SendConfig(ply?: Player): void {
        const filter = RecipientFilter();
        if (ply) {
            filter.AddPlayer(ply);
        } else {
            filter.AddAllPlayers();
        }

        net.Start(GWNetMessageName.SendConfig);
        net.WriteTable(this.data);
        net.Send(filter);
    }

    private HandlePlayerInitialSpawn(ply: Player): void {
        this.SendConfig(ply);
    }
}

interface GWConfigData {
    Version: string;
    TeamHidingColor: Color;
    TeamSeekingColor: Color;
    HiderModels: string[];
    SeekerModels: string[];
    ActiveAbilities: string[];
    AllAbilities: string[];
    WalkerColors: Color[];
}

if (SERVER) {
    net.Receive(GWNetMessageName.RequestConfigUpdate, (len: number, ply: Player) => {
                    if (!ply.IsSuperAdmin()) {
                        return;
                    }
                    const newData = net.ReadTable();
                    GWConfigManager.GetInstance().Data = newData as GWConfigData;
                    GWConfigManager.GetInstance().WriteConfig();

                    GWConfigManager.GetInstance().SendConfig();
                });
}

if (CLIENT) {
    net.Receive(GWNetMessageName.SendConfig, (len: number, ply: Player) => {
        const newData = net.ReadTable() as GWConfigData;
        GWConfigManager.GetInstance().Data = newData;

        team.SetColor(GWTeam.HIDERS, newData.TeamHidingColor);
        team.SetColor(GWTeam.SEEKERS, newData.TeamSeekingColor);
    });
}
