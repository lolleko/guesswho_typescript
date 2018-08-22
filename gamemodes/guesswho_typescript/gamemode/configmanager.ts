import { GWNetMessageNames } from "./NetMessageNames";
import { GWTeam } from "./team";

class GWConfigManager {

    public private;
    private data: GWConfigData;

    constructor() {
        if (SERVER) {
            hook.Add("PlayerInitialSpawn",
                     "gW_config_manager_initial_spawn",
                     ply => this.HandlePlayerInitialSpawn(ply));

            net.Receive(GWNetMessageNames.RequestConfigUpdate, (len, ply) => this.RPCRequestConfigUpdate(ply));
        }
        if (CLIENT) {
            net.Receive(GWNetMessageNames.SendConfig, (len, ply) => this.RPCReceiveConfig(ply));
        }
    }

    private HandlePlayerInitialSpawn(ply: Player): void {
        this.SendConfig();
    }

    private SendConfig(ply?: Player): void {
        const filter = RecipientFilter();
        if (ply) {
            filter.AddPlayer(ply);
        } else {
            filter.AddAllPlayers();
        }

        net.Start(GWNetMessageNames.SendConfig);
        net.WriteTable(this.data);
        net.Send(filter);
    }

    // SERVER
    private RPCRequestConfigUpdate(ply: Player): void {
        if (!ply.IsSuperAdmin()) {
            return;
        }
        const newData = net.ReadTable();
        this.data = newData as GWConfigData;
        this.WriteConfig();

        this.SendConfig();
    }

    // CLIENT
    private RPCReceiveConfig(ply: Player): void {
        const newData = net.ReadTable();
        this.data = newData as GWConfigData;

        team.SetColor(GWTeam.HIDERS, this.data.TeamHidingColor);
        team.SetColor(GWTeam.SEEKERS, this.data.TeamSeekingColor);
    }

    private WriteConfig(): void {
        if (!file.Exists("guesswho", "DATA")) {
            file.CreateDir("guesswho");
        }
        file.Write("guesswho/config.txt", util.TableToJSON(this.data));
    }

    private ReadConfig(): void {
        this.data = util.JSONToTable(file.Read("guesswho/config.txt")) as GWConfigData;
    }

    private ExistsConfig(): boolean {
        return file.Exists("guesswho/config.txt", "DATA");
    }
}

interface GWConfigData {
    Version: string;
    TeamHidingColor: Color;
    TeamSeekingColor: Color;
}
