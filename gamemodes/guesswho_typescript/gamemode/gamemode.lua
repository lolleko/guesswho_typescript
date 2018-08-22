
-- Lua Library Imports
local classnames1 = include("./classnames.lua")
local GWClassNames = classnames1.GWClassNames
local team2 = include("./team.lua")
local GWTeam = team2.GWTeam
AddCSLuaFile()
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
    team.SetSpawnPoint(TEAM_SPECTATOR,"worldspawn")
end
function GM.InitPostEntity(self)
    print("Creating gamerules")
    if SERVER then
        self.Gamerules = ents.Create(GWClassNames.ENT_GAMERULES)
    else
        self.Gamerules = ents.FindByClass(GWClassNames.ENT_GAMERULES)
    end
end
