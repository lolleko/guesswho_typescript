
-- Lua Library Imports
AddCSLuaFile()
function GM.get__Gamerules(self)
    return self.gamerules
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
