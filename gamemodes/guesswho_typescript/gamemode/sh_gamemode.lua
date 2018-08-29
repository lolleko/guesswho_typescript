
-- Lua Library Imports
AddCSLuaFile()
function GM.get__Gamerules(self)
    return self.gamerules
end
function GM.CreateTeams(self)
    team.SetUp(HIDER,"Hiding",Color(0,0,0))
    team.SetClass(HIDER,"player_hiding")
    team.SetSpawnPoint(HIDER,"info_player_start")
    team.SetSpawnPoint(HIDER,"info_player_deathmatch")
    team.SetSpawnPoint(HIDER,"info_player_rebel")
    team.SetSpawnPoint(HIDER,"info_player_combine")
    team.SetSpawnPoint(HIDER,"info_player_counterterrorist")
    team.SetSpawnPoint(HIDER,"info_player_terrorist")
    team.SetUp(SEEKER,"Seekers",Color(0,0,0))
    team.SetClass(SEEKER,"player_seeker")
    team.SetSpawnPoint(SEEKER,"info_player_start")
    team.SetSpawnPoint(SEEKER,"info_player_deathmatch")
    team.SetSpawnPoint(SEEKER,"info_player_rebel")
    team.SetSpawnPoint(SEEKER,"info_player_combine")
    team.SetSpawnPoint(SEEKER,"info_player_counterterrorist")
    team.SetSpawnPoint(SEEKER,"info_player_terrorist")
    team.SetSpawnPoint(TEAM_SPECTATOR,"worldspawn")
end
function GM.InitPostEntity(self)
    print("Creating gamerules")
    if SERVER then
        self.gamerules = ents.Create(GWClassName.ENT_GAMERULES)
        GWConfigManager:Setup()
    else
        self.gamerules = ents.FindByClass(GWClassName.ENT_GAMERULES)[0+1]
    end
end
