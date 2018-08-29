
-- Lua Library Imports
function __TS__ArrayForEach(arr,callbackFn)
    local i = 0
    while(i<#arr) do
        do
            callbackFn(arr[i+1],i,arr)
        end
        i = (i+1)
    end
end

function __TS__ArraySome(arr,callbackfn)
    local i = 0
    while(i<#arr) do
        do
            if callbackfn(arr[i+1],i,arr) then
                return true
            end
        end
        i = (i+1)
    end
    return false
end

function __TS__ArrayPush(arr,...)
    local items = { ... }
    local i = 0
    while(i<#items) do
        do
            arr[#arr+1] = items[i+1]
        end
        i = (i+1)
    end
    return #arr
end

AddCSLuaFile()
ENT.Type = "point"
function ENT.get__SpawnPoints(self)
    return self.spawnPoints
end
function ENT.get__SettingBaseWalkerAmount(self)
    return GetConVar("gw_basewalkeramount"):GetInt()
end
function ENT.get__SettingWalkerPerPly(self)
    return GetConVar("gw_walkerperplayer"):GetInt()
end
function ENT.get__SettingPreGameDuration(self)
    return GetConVar("gw_pregameduration"):GetInt()
end
function ENT.get__SettingRoundDuration(self)
    return GetConVar("gw_roundduration"):GetInt()
end
function ENT.get__SettingHidingDuration(self)
    return GetConVar("gw_hidinguration"):GetInt()
end
function ENT.get__SettingPostRoundDuration(self)
    return GetConVar("gw_postroundduration"):GetInt()
end
function ENT.get__SettingMaxRounds(self)
    return GetConVar("gw_maxrounds"):GetInt()
end
function ENT.get__SettingMinHiders(self)
    return GetConVar("gw_minhiders"):GetInt()
end
function ENT.get__SettingMinSeekers(self)
    return GetConVar("gw_minseekers"):GetInt()
end
function ENT.get__GameTimerEndTime(self)
    return self:GetDTFloat(0)
end
function ENT.get__GameTime(self)
    return self:get__GameTimerEndTime()-CurTime()
end
function ENT.get__GameState(self)
    return self:GetDTInt(0)
end
function ENT.set__GameTimerEndTime(self,time)
    self:SetDTFloat(0,time)
end
function ENT.set__GameState(self,state)
    self:SetDTInt(0,state)
end
function ENT.SetupDataTables(self)
    self:DTVar("Float",0,"GameTimerEndTime")
    self:DTVar("Int",0,"GameState")
end
function ENT.Initialize(self)
    hook.Add("PlayerDeath","gw_rules_player_death",function(victim,inflictor,attacker)
        self:HandlePlayerDeath(victim,attacker,inflictor)
    end
)
    self:set__GameTimerEndTime(CurTime())
    self:HandleWaiting()
    self:UpdateSpawnpoints()
    print("Initializing Gamerules")
end
function ENT.Think(self)
    if SERVER then
        if self:get__GameState()==GWGameState.WAITING then
            if (team.NumPlayers(HIDER)<self:get__SettingMinHiders()) or (team.NumPlayers(SEEKER)<self:get__SettingMinSeekers()) then
                __TS__ArrayForEach(ents.FindByClass(GWClassName.NPC_WALKER), function(ent) return ent:Remove() end)
                self:NextThink(CurTime()+1)
                print("Wating")
                return true
            else
                self:HandleCreating()
            end
        end
    end
    return false
end
function ENT.UpdateTransmitState(self)
    return TRANSMIT_ALWAYS
end
function ENT.HandlePlayerDeath(self,victim,inflictor,attacker)
    local playersOnVictimTeam = team.GetPlayers(victim:Team())

    local someAlive = __TS__ArraySome(playersOnVictimTeam, function(ply) return ply:Alive() end)

    if (not someAlive) then
        self:HandlePostRound()
    end
end
function ENT.HandleWaiting(self)
    self:set__GameState(GWGameState.WAITING)
    self:set__GameTimerEndTime((CurTime()+1))
end
function ENT.HandleCreating(self)
    self:set__GameState(GWGameState.CREATING)
    self.walkerCount = 0
    local playerCount = player.GetCount()

    self.maxWalkers = (self:get__SettingBaseWalkerAmount()+(playerCount*self:get__SettingWalkerPerPly()))
    if #self.spawnPoints>=self.maxWalkers then
        local walkersSpawned = self:SpawnNPCWave()

        MsgN("GW Spawned ",walkersSpawned," NPCs in 1 wave.")
    else
        local spawnRounds = math.floor(self.maxWalkers/#self.spawnPoints)

        self:set__GameTimerEndTime((CurTime()+(spawnRounds*5)))
        local wave = 0
        while(wave<=spawnRounds) do
            do
                timer.Simple(wave*5,function()
                    local walkersSpawned = self:SpawnNPCWave()

                    MsgN("GW Spawned ",walkersSpawned," NPCs in wave ",wave+1,".")
                    if wave==spawnRounds then
                        self:HandleHiding()
                    end
                end
)
            end
            ::__continue0::
            wave = (wave+1)
        end
    end
end
function ENT.HandleHiding(self)
    self:set__GameState(GWGameState.HIDING)
    self:set__GameTimerEndTime((CurTime()+self:get__SettingHidingDuration()))
    __TS__ArrayForEach((team.GetPlayers(HIDER)), function(ply) return ply:Spawn() end)
    timer.Simple(self:get__SettingHidingDuration(),function() return self:HandleSeeking() end)
end
function ENT.HandleSeeking(self)
    self:set__GameState(GWGameState.SEEKING)
    self:set__GameTimerEndTime((CurTime()+self:get__SettingRoundDuration()))
    timer.Simple(self:get__SettingHidingDuration(),function() return self:HandlePostRound() end)
end
function ENT.HandlePostRound(self)
    local hiders = team.GetPlayers(HIDER)

    local someHidersAlive = __TS__ArraySome(hiders, function(ply) return ply:Alive() end)

    if someHidersAlive then
        print("Hiders Win")
    else
        print("Seekers Win")
    end
    self:set__GameTimerEndTime((CurTime()+self:get__SettingPostRoundDuration()))
    timer.Simple(self:get__SettingPostRoundDuration(),function() return self:HandleWaiting() end)
end
function ENT.UpdateSpawnpoints(self)
    local spawnPointClasses = {"info_player_start","info_player_deathmatch","info_player_combine","info_player_rebel","info_player_counterterrorist","info_player_terrorist","info_player_axis","info_player_allies","gmod_player_start","info_player_teamspawn","ins_spawnpoint","aoc_spawnpoint","dys_spawn_point","info_player_pirate","info_player_viking","info_player_knight","diprip_start_team_blue","diprip_start_team_red","info_player_red","info_player_blue","info_player_coop","info_player_human","info_player_zombie","info_player_deathmatch","info_player_zombiemaster"}

    self.spawnPoints = {}
    __TS__ArrayForEach(spawnPointClasses, function(sp) return __TS__ArrayPush(self.spawnPoints, table.unpack(ents.FindByClass(sp))) end)
    local rand = math.random

    local n = #self.spawnPoints-1

    while n>2 do
        do
            local k = rand(1,n)

            local temp = self.spawnPoints[n+1]

            self.spawnPoints[n+1] = self.spawnPoints[k+1]
            self.spawnPoints[k+1] = temp
            n = (n-1)
        end
        ::__continue1::
    end
end
function ENT.SpawnNPCWave(self)
    local spawnedWalkers = 0

    __TS__ArrayForEach(self.spawnPoints, function(sp)
        if self.walkerCount<self.maxWalkers then
            local mins = sp:GetPos()+Vector(-16,-16,0)

            local maxs = sp:GetPos()+Vector(16,16,64)

            local occupied = __TS__ArraySome(ents.FindInBox(mins,maxs), function(ent) return ent:GetClass()==GWClassName.NPC_WALKER end)

            if (not occupied) then
                local walker = ents.Create(GWClassName.NPC_WALKER)

                if IsValid(walker) then
                    walker:SetPos(sp:GetPos())
                    walker:Spawn()
                    walker:Activate()
                end
                spawnedWalkers = (spawnedWalkers+1)
            end
        end
    end
)
    self.walkerCount = (self.walkerCount+spawnedWalkers)
    return spawnedWalkers
end
