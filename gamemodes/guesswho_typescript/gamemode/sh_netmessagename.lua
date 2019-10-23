--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
AddCSLuaFile();
GWNetMessageName = {};
GWNetMessageName.RequestConfigUpdate = "gwRequestConfigUpdate";
GWNetMessageName.gwRequestConfigUpdate = "RequestConfigUpdate";
GWNetMessageName.SendConfig = "gwSendConfig";
GWNetMessageName.gwSendConfig = "SendConfig";
if SERVER then
    for message in pairs(GWNetMessageName) do
        do
            util.AddNetworkString(GWNetMessageName[message]);
        end
        ::__continue2::
    end
end
