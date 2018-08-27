
-- Lua Library Imports
local exports = exports or {}
local configmanager1 = include("./configmanager.lua")
local GWConfigManager = configmanager1.GWConfigManager
local GWConfigData = configmanager1.GWConfigData
local classname2 = include("./classname.lua")
local GWClassName = classname2.GWClassName
local team3 = include("./team.lua")
local GWTeam = team3.GWTeam
AddCSLuaFile()
function GM.get__Gamerules(self)
    return self.gamerules
end
function GM.get__ConfigManager(self)
    return self.configManager
end
function GM.get__ConfigData(self)
    return self.configManager:get__Data()
end
function GM.CreateTeams(self)
    team.SetUp(GWTeam.HIDERS,"Hiding",Color(0,0,0))
    team.SetClass(GWTeam.HIDERS,"player_hiding")
    team.SetSpawnPoint(GWTeam.HIDERS,"info_player_start")
    team.SetSpawnPoint(GWTeam.HIDERS,"info_player_deathmatch")
    team.SetSpawnPoint(GWTeam.HIDERS,"info_player_rebel")
    team.SetSpawnPoint(GWTeam.HIDERS,"info_player_combine")
    team.SetSpawnPoint(GWTeam.HIDERS,"info_player_counterterrorist")
    team.SetSpawnPoint(GWTeam.HIDERS,"info_player_terrorist")
    team.SetUp(GWTeam.SEEKERS,"Seekers",Color(0,0,0))
    team.SetClass(GWTeam.SEEKERS,"player_seeker")
    team.SetSpawnPoint(GWTeam.SEEKERS,"info_player_start")
    team.SetSpawnPoint(GWTeam.SEEKERS,"info_player_deathmatch")
    team.SetSpawnPoint(GWTeam.SEEKERS,"info_player_rebel")
    team.SetSpawnPoint(GWTeam.SEEKERS,"info_player_combine")
    team.SetSpawnPoint(GWTeam.SEEKERS,"info_player_counterterrorist")
    team.SetSpawnPoint(GWTeam.SEEKERS,"info_player_terrorist")
    team.SetSpawnPoint(TEAM.TEAM_SPECTATOR,"worldspawn")
end
function GM.InitPostEntity(self)
    print("Creating gamerules")
    if SERVER then
        self.gamerules = ents.Create(GWClassName.ENT_GAMERULES)
    else
        self.gamerules = ents.FindByClass(GWClassName.ENT_GAMERULES)[0+1]
    end
    self.configManager = GWConfigManager.new(true)
end
return exports
