
-- Lua Library Imports
AddCSLuaFile()
GWNetMessageName={}
GWNetMessageName.RequestConfigUpdate="gwRequestConfigUpdate"
GWNetMessageName.SendConfig="gwSendConfig"
if SERVER then
    for message, _ in pairs(GWNetMessageName) do
        do
            util.AddNetworkString(GWNetMessageName[message])
        end
        ::__continue0::
    end
end
