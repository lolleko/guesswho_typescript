--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
-- Lua Library inline imports
__TS__ArraySome = function(arr, callbackfn)
    do
        local i = 0;
        while i < (#arr) do
            if callbackfn(_G, arr[i + 1], i, arr) then
                return true;
            end
            i = i + 1;
        end
    end
    return false;
end;

__TS__ArrayForEach = function(arr, callbackFn)
    do
        local i = 0;
        while i < (#arr) do
            callbackFn(_G, arr[i + 1], i, arr);
            i = i + 1;
        end
    end
end;

__TS__ArrayPush = function(arr, ...)
    local items = ({...});
    for ____TS_index = 1, #items do
        local item = items[____TS_index];
        arr[(#arr) + 1] = item;
    end
    return #arr;
end;

AddCSLuaFile();
ENT.Type = "point";
ENT.SpawnPoints = function(self)
    return self.spawnPoints;
end;
ENT.SettingBaseWalkerAmount = function(self)
    return GetConVar("gw_basewalkeramount"):GetInt();
end;
ENT.SettingWalkerPerPly = function(self)
    return GetConVar("gw_walkerperplayer"):GetInt();
end;
ENT.SettingPreGameDuration = function(self)
    return GetConVar("gw_pregameduration"):GetInt();
end;
ENT.SettingRoundDuration = function(self)
    return GetConVar("gw_roundduration"):GetInt();
end;
ENT.SettingHidingDuration = function(self)
    return GetConVar("gw_hideduration"):GetInt();
end;
ENT.SettingPostRoundDuration = function(self)
    return GetConVar("gw_postroundduration"):GetInt();
end;
ENT.SettingMaxRounds = function(self)
    return GetConVar("gw_maxrounds"):GetInt();
end;
ENT.SettingMinHiders = function(self)
    return GetConVar("gw_minhiders"):GetInt();
end;
ENT.SettingMinSeekers = function(self)
    return GetConVar("gw_minseekers"):GetInt();
end;
ENT.GameTimerEndTime = function(self)
    return self:GetDTFloat(0);
end;
ENT.GameTime = function(self)
    return self.GameTimerEndTime - CurTime();
end;
ENT.GameState = function(self)
    return self:GetDTInt(0);
end;
ENT.GameStateLabel = function(self)
    local roundToken = "ERROR!";
    local ____TS_switch15 = self.GameState;
    if ____TS_switch15 == GWGameState.MESH_GENERATION then
        goto ____TS_switch15_case_0;
    end
    if ____TS_switch15 == GWGameState.WAITING then
        goto ____TS_switch15_case_1;
    end
    if ____TS_switch15 == GWGameState.CREATING then
        goto ____TS_switch15_case_2;
    end
    if ____TS_switch15 == GWGameState.HIDING then
        goto ____TS_switch15_case_3;
    end
    if ____TS_switch15 == GWGameState.SEEKING then
        goto ____TS_switch15_case_4;
    end
    if ____TS_switch15 == GWGameState.POST_ROUND then
        goto ____TS_switch15_case_5;
    end
    goto ____TS_switch15_end;
    ::____TS_switch15_case_0::
    do
        roundToken = "game_state_nav_mesh_generation";
        goto ____TS_switch15_end;
    end
    ::____TS_switch15_case_1::
    do
        roundToken = "game_state_waiting";
        goto ____TS_switch15_end;
    end
    ::____TS_switch15_case_2::
    do
        roundToken = "game_state_creating";
        goto ____TS_switch15_end;
    end
    ::____TS_switch15_case_3::
    do
        roundToken = "game_state_hiding";
        goto ____TS_switch15_end;
    end
    ::____TS_switch15_case_4::
    do
        roundToken = "game_state_seeking";
        goto ____TS_switch15_end;
    end
    ::____TS_switch15_case_5::
    do
        roundToken = "game_state_post_round";
        goto ____TS_switch15_end;
    end
    ::____TS_switch15_end::
    return GWLocalization:GetInstance():Translate(roundToken);
end;
ENT.GameTimerEndTime = function(self, time)
    self:SetDTFloat(0, time);
end;
ENT.GameState = function(self, state)
    self:SetDTInt(0, state);
end;
ENT.SetupDataTables = function(self)
    self:DTVar("Float", 0, "GameTimerEndTime");
    self:DTVar("Int", 0, "GameState");
end;
ENT.Initialize = function(self)
    hook.Add("PlayerDeath", "gw_rules_player_death", function(victim, inflictor, attacker)
        self:HandlePlayerDeath(victim, attacker, inflictor);
    end);
    self.GameTimerEndTime = CurTime();
    self:HandleWaiting();
    print("updating spawnpoints");
    self:UpdateSpawnpoints();
    print("Initializing Gamerules");
end;
ENT.Think = function(self)
    if SERVER then
        if self.GameState == GWGameState.WAITING then
            if (team.NumPlayers(HIDER) < self.SettingMinHiders) or (team.NumPlayers(SEEKER) < self.SettingMinSeekers) then
                self:NextThink(CurTime() + 1);
                print("Wating");
                return true;
            else
                self:HandleCreating();
            end
        end
    end
    DebugInfo(0, "TIME: " .. self.GameTime);
    DebugInfo(1, "STATE: " .. self.GameState);
    DebugInfo(2, "STATE: " .. self.GameStateLabel);
    return false;
end;
ENT.UpdateTransmitState = function(self)
    return TRANSMIT_ALWAYS;
end;
ENT.HandlePlayerDeath = function(self, victim, inflictor, attacker)
    local playersOnVictimTeam = team.GetPlayers(victim:Team());
    local someAlive = __TS__ArraySome(playersOnVictimTeam, function(____, ply)
        return ply:Alive() and (ply ~= victim);
    end);
    print("dead ", someAlive);
    if (not someAlive) and (self.GameState == GWGameState.SEEKING) then
        print(self);
        self:HandlePostRound();
    end
end;
ENT.HandleWaiting = function(self)
    self.GameState = GWGameState.WAITING;
    self.GameTimerEndTime = CurTime() + 1;
end;
ENT.HandleCreating = function(self)
    self.GameState = GWGameState.CREATING;
    self.walkerCount = 0;
    local playerCount = player.GetCount();
    self.maxWalkers = self.SettingBaseWalkerAmount + (playerCount * self.SettingWalkerPerPly);
    if (#self.spawnPoints) >= self.maxWalkers then
        local walkersSpawned = self:SpawnNPCWave();
        MsgN("GW Spawned ", walkersSpawned, " NPCs in 1 wave.");
    else
        local spawnRounds = math.ceil(self.maxWalkers / (#self.spawnPoints));
        self.GameTimerEndTime = CurTime() + (spawnRounds * 7);
        do
            local wave = 0;
            while wave < spawnRounds do
                do
                    timer.Simple(wave * 7, function(____)
                        local walkersSpawned = self:SpawnNPCWave();
                        MsgN("GW Spawned ", walkersSpawned, " NPCs in wave ", wave + 1, ".");
                    end);
                end
                ::__continue34::
                wave = wave + 1;
            end
        end
        timer.Simple(spawnRounds * 7, function(____)
            self:HandleHiding();
        end);
    end
end;
ENT.HandleHiding = function(self)
    self.GameState = GWGameState.HIDING;
    self.GameTimerEndTime = CurTime() + self.SettingHidingDuration;
    __TS__ArrayForEach((team.GetPlayers(HIDER)), function(____, ply)
        return ply:Spawn();
    end);
    timer.Simple(self.SettingHidingDuration, function(____)
        return self:HandleSeeking();
    end);
end;
ENT.HandleSeeking = function(self)
    self.GameState = GWGameState.SEEKING;
    self.GameTimerEndTime = CurTime() + self.SettingRoundDuration;
    timer.Create("GWRoundEndTimer", self.SettingRoundDuration, 1, function(____)
        return self:HandlePostRound();
    end);
end;
ENT.HandlePostRound = function(self)
    if timer.Exists("GWRoundEndTimer") then
        timer.Remove("GWRoundEndTimer");
    end
    local hiders = team.GetPlayers(HIDER);
    local someHidersAlive = __TS__ArraySome(hiders, function(____, ply)
        return ply:Alive();
    end);
    if someHidersAlive then
        print("Hiders Win");
    else
        print("Seekers Win");
    end
    game.CleanUpMap(false, {self:GetClass()});
    __TS__ArrayForEach(ents.FindByClass(GWClassName.NPC_WALKER), function(____, npc)
        return npc:Remove();
    end);
    __TS__ArrayForEach((player.GetAll()), function(____, ply)
        if ply:Team() == HIDER then
            ply:SetTeam(SEEKER);
        elseif ply:Team() == SEEKER then
            ply:SetTeam(HIDER);
        end
    end);
    self.GameTimerEndTime = CurTime() + self.SettingPostRoundDuration;
    timer.Simple(self.SettingPostRoundDuration, function(____)
        return self:HandleWaiting();
    end);
end;
ENT.UpdateSpawnpoints = function(self)
    local spawnPointClasses = {"info_player_start", "info_player_deathmatch", "info_player_combine", "info_player_rebel", "info_player_counterterrorist", "info_player_terrorist", "info_player_axis", "info_player_allies", "gmod_player_start", "info_player_teamspawn", "ins_spawnpoint", "aoc_spawnpoint", "dys_spawn_point", "info_player_pirate", "info_player_viking", "info_player_knight", "diprip_start_team_blue", "diprip_start_team_red", "info_player_red", "info_player_blue", "info_player_coop", "info_player_human", "info_player_zombie", "info_player_deathmatch", "info_player_zombiemaster"};
    self.spawnPoints = {};
    for ____TS_index = 1, #spawnPointClasses do
        local sp = spawnPointClasses[____TS_index];
        do
            __TS__ArrayPush(self.spawnPoints, unpack(ents.FindByClass(sp)));
        end
        ::__continue53::
    end
    local rand;
    rand = math.random;
    local n = (#self.spawnPoints) - 1;
    while n > 2 do
        do
            local k = rand(1, n);
            local temp = self.spawnPoints[n + 1];
            self.spawnPoints[n + 1] = self.spawnPoints[k + 1];
            self.spawnPoints[k + 1] = temp;
            n = n - 1;
        end
        ::__continue54::
    end
end;
ENT.SpawnNPCWave = function(self)
    local spawnedWalkers = 0;
    __TS__ArrayForEach(self.spawnPoints, function(____, sp)
        if self.walkerCount < self.maxWalkers then
            local mins = sp:GetPos() + Vector(-16, -16, 0);
            local maxs = sp:GetPos() + Vector(16, 16, 64);
            local occupied = __TS__ArraySome(ents.FindInBox(mins, maxs), function(____, ent)
                return ent:GetClass() == GWClassName.NPC_WALKER;
            end);
            if not occupied then
                local walker = ents.Create(GWClassName.NPC_WALKER);
                if IsValid(walker) then
                    walker:SetPos(sp:GetPos());
                    walker:Spawn();
                    walker:Activate();
                end
                spawnedWalkers = spawnedWalkers + 1;
            end
        end
    end);
    self.walkerCount = self.walkerCount + spawnedWalkers;
    return spawnedWalkers;
end;
