
-- Lua Library Imports
AddCSLuaFile()
local GWDefaultConfigData = {ActiveAbilities = {"weapon_gw_prophunt","weapon_gw_surge","weapon_gw_shockwave","weapon_gw_cloak","weapon_gw_shrink","weapon_gw_decoy","weapon_gw_sudoku","weapon_gw_disguise","weapon_gw_vampirism","weapon_gw_ragdoll","weapon_gw_superhot","weapon_gw_dance_party","weapon_gw_blasting_off","weapon_gw_decoy2","weapon_gw_teleport","weapon_gw_deflect","weapon_gw_timelapse","weapon_gw_solarflare","weapon_gw_mind_control","weapon_gw_ant"},AllAbilities = {"weapon_gw_prophunt","weapon_gw_surge","weapon_gw_shockwave","weapon_gw_cloak","weapon_gw_shrink","weapon_gw_decoy","weapon_gw_sudoku","weapon_gw_disguise","weapon_gw_vampirism","weapon_gw_ragdoll","weapon_gw_superhot","weapon_gw_dance_party","weapon_gw_blasting_off","weapon_gw_decoy2","weapon_gw_teleport","weapon_gw_deflect","weapon_gw_timelapse","weapon_gw_solarflare","weapon_gw_mind_control","weapon_gw_ant"},HiderModels = {"models/player/alyx.mdl","models/player/breen.mdl","models/player/barney.mdl","models/player/eli.mdl","models/player/gman_high.mdl","models/player/kleiner.mdl","models/player/monk.mdl","models/player/odessa.mdl","models/player/magnusson.mdl","models/player/p2_chell.mdl","models/player/mossman_arctic.mdl"},SeekerModels = {"models/player/combine_super_soldier.mdl"},TeamHidingColor = Color(138,155,15),TeamSeekingColor = Color(23,89,150),Version = "3.0.0",WalkerColors = {Color(61,87,105),Color(240,240,240),Color(50,50,50),Color(139,115,85),Color(241,169,101),Color(75,97,34),Color(157,107,0),Color(159,205,234),Color(94,25,34)}}

GWConfigManager = GWConfigManager or {}
GWConfigManager.__index = GWConfigManager
function GWConfigManager.new(construct, ...)
    local instance = setmetatable({}, GWConfigManager)
    if construct and GWConfigManager.constructor then GWConfigManager.constructor(instance, ...) end
    return instance
end
function GWConfigManager.constructor(self)
end
function GWConfigManager.get__Data(self)
    return self.data
end
function GWConfigManager.set__Data(self,data)
    self.data = data
end
function GWConfigManager.GetInstance(self)
    if (not GWConfigManager.instance) then
        GWConfigManager.instance = GWConfigManager.new(true)
    end
    return GWConfigManager.instance
end
function GWConfigManager.Setup(self)
    if SERVER then
        local instance = GWConfigManager:GetInstance()

        if instance:ExistsConfig() then
            instance:ReadConfig()
        else
            instance.data = GWDefaultConfigData
            instance:WriteConfig()
        end
        hook.Add("PlayerInitialSpawn","gw_config_manager_initial_spawn",function(ply) return instance:HandlePlayerInitialSpawn(ply) end)
    end
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
function GWConfigManager.SendConfig(self,ply)
    local filter = RecipientFilter()

    if ply then
        filter:AddPlayer(ply)
    else
        filter:AddAllPlayers()
    end
    net.Start(GWNetMessageName.SendConfig)
    net.WriteTable(self.data)
    net.Send(filter)
end
function GWConfigManager.HandlePlayerInitialSpawn(self,ply)
    self:SendConfig(ply)
end
if SERVER then
    net.Receive(GWNetMessageName.RequestConfigUpdate,function(len,ply)
        if (not ply:IsSuperAdmin()) then
            return
        end
        local newData = net.ReadTable()

        GWConfigManager:GetInstance():set__Data(newData)
        GWConfigManager:GetInstance():WriteConfig()
        GWConfigManager:GetInstance():SendConfig()
    end
)
end
if CLIENT then
    net.Receive(GWNetMessageName.SendConfig,function(len,ply)
        local newData = net.ReadTable()

        GWConfigManager:GetInstance():set__Data(newData)
        team.SetColor(GWTeam.HIDERS,newData.TeamHidingColor)
        team.SetColor(GWTeam.SEEKERS,newData.TeamSeekingColor)
    end
)
end
