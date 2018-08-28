AddCSLuaFile();

enum GWNetMessageName {
    RequestConfigUpdate = "gwRequestConfigUpdate",
    SendConfig = "gwSendConfig",
}
if (SERVER) {
    for (const message in GWNetMessageName) {
        util.AddNetworkString(GWNetMessageName[message]);
    }
}
