--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
AddCSLuaFile();
GM.TeamBased = true;
GM.Gamerules = function(self)
    return self.gamerules;
end;
GM.CreateTeams = function(self)
    team.SetUp(HIDER, "Hiding", GWConfigManager:GetInstance().Data.TeamHidingColor);
    team.SetClass(HIDER, "player_hiding");
    team.SetSpawnPoint(HIDER, "info_player_start");
    team.SetSpawnPoint(HIDER, "info_player_deathmatch");
    team.SetSpawnPoint(HIDER, "info_player_rebel");
    team.SetSpawnPoint(HIDER, "info_player_combine");
    team.SetSpawnPoint(HIDER, "info_player_counterterrorist");
    team.SetSpawnPoint(HIDER, "info_player_terrorist");
    team.SetUp(SEEKER, "Seekers", GWConfigManager:GetInstance().Data.TeamSeekingColor);
    team.SetClass(SEEKER, "player_seeker");
    team.SetSpawnPoint(SEEKER, "info_player_start");
    team.SetSpawnPoint(SEEKER, "info_player_deathmatch");
    team.SetSpawnPoint(SEEKER, "info_player_rebel");
    team.SetSpawnPoint(SEEKER, "info_player_combine");
    team.SetSpawnPoint(SEEKER, "info_player_counterterrorist");
    team.SetSpawnPoint(SEEKER, "info_player_terrorist");
    team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn");
end;
GM.InitPostEntity = function(self)
    print("Creating gamerules");
    if SERVER then
        self.gamerules = ents.Create(GWClassName.ENT_GAMERULES);
        self.gamerules:Spawn();
        GWConfigManager:Setup();
    else
        self.gamerules = ents.FindByClass(GWClassName.ENT_GAMERULES)[0 + 1];
    end
end;
