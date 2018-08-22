
-- Lua Library Imports
local NetMessageNames0 = include("./NetMessageNames.lua")
local GWNetMessageNames = NetMessageNames0.GWNetMessageNames
local team1 = include("./team.lua")
local GWTeam = team1.GWTeam
GWConfigManager = GWConfigManager or {}
GWConfigManager.__index = GWConfigManager
function GWConfigManager.new(construct, ...)
    local instance = setmetatable({}, GWConfigManager)
    if construct and GWConfigManager.constructor then GWConfigManager.constructor(instance, ...) end
    return instance
end
function GWConfigManager.constructor(self)
    if SERVER then
        hook.Add("PlayerInitialSpawn","gW_config_manager_initial_spawn",function(ply) return self:HandlePlayerInitialSpawn(ply) end)
        net.Receive(GWNetMessageNames.RequestConfigUpdate,function(len,ply) return self:RPCRequestConfigUpdate(ply) end)
    end
    if CLIENT then
        net.Receive(GWNetMessageNames.SendConfig,function(len,ply) return self:RPCReceiveConfig(ply) end)
    end
end
function GWConfigManager.HandlePlayerInitialSpawn(self,ply)
    self:SendConfig()
end
function GWConfigManager.SendConfig(self,ply)
    local filter = RecipientFilter()

    if ply then
        filter:AddPlayer(ply)
    else
        filter:AddAllPlayers()
    end
    net.Start(GWNetMessageNames.SendConfig)
    net.WriteTable(self.data)
    net.Send(filter)
end
function GWConfigManager.RPCRequestConfigUpdate(self,ply)
    if (not ply:IsSuperAdmin()) then
        return
    end
    local newData = net.ReadTable()

    self.data = newData
    self:WriteConfig()
    self:SendConfig()
end
function GWConfigManager.RPCReceiveConfig(self,ply)
    local newData = net.ReadTable()

    self.data = newData
    team.SetColor(GWTeam.HIDERS,self.data.TeamHidingColor)
    team.SetColor(GWTeam.SEEKERS,self.data.TeamSeekingColor)
end
function GWConfigManager.WriteConfig(self)
    if (not file.Exists("guesswho","DATA")) then
        file.CreateDir("guesswho")
    end
    file.Write("guesswho/config.txt",util.TableToJSON(self.data))
end
function GWConfigManager.ReadConfig(self)
    self.data = util.JSONToTable(file.Read("guesswho/config.txt"))
end
function GWConfigManager.ExistsConfig(self)
    return file.Exists("guesswho/config.txt","DATA")
end
