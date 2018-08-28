
-- Lua Library Imports
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

AddCSLuaFile()
local eyeGlow = Material("sprites/redglow1")

local white = Color(255,255,255,255)

ENT.Base = "base_nextbot"
function ENT.get__LastAct(self)
    return self:GetDTInt(0)
end
function ENT.get__WalkerColorIndex(self)
    return self:GetDTInt(1)
end
function ENT.get__WalkerModelIndex(self)
    return self:GetDTInt(2)
end
function ENT.set__LastAct(self,act)
    self:SetDTInt(0,act)
end
function ENT.set__WalkerColorIndex(self,index)
    self:SetDTInt(1,index)
end
function ENT.set__WalkerModelIndex(self,index)
    self:SetDTInt(2,index)
end
function ENT.MoveSomeWhere(self,distance)
    if distance==nil then distance=1000 end
    self.loco:SetDesiredSpeed(100)
    local navs = navmesh.Find(self:GetPos(),distance,120,120)

    local nav = navs[math.random(#navs)-1+1]

    if (not IsValid(nav)) then
        return
    end
    if nav:IsUnderwater() then
        return
    end
    local pos = nav:GetRandomPoint()

    local maxAge = math.Clamp(pos:Distance(self:GetPos())/120,0.1,10)

    self:MoveToPos(pos,{tolerance = 30,maxage = maxAge,lookahead = 10,repath = 2})
end
function ENT.MoveToSpot(self,type)
    local pos = self:FindSpot("random",{type = type,radius = 5000})

    if pos then
        local nav = navmesh.GetNavArea(pos,20)

        if (not IsValid(nav)) then
            return
        end
        if (not nav:IsUnderwater()) then
            self.loco:SetDesiredSpeed(200)
            self:MoveToPos(pos,{tolerance = 30,lookahead = 10,repath = 2})
        end
    end
end
function ENT.Sit(self)
    self:SetSequence("sit_zen")
    self.isSitting = true
    self:SetCollisionBounds(Vector(-8,-8,0),Vector(8,8,36))
    coroutine.wait(math.Rand(10,60))
    self:SetCollisionBounds(Vector(-8,-8,0),Vector(8,8,70))
    self.isSitting = false
end
function ENT.SetupDataTables(self)
    self:DTVar("Int",0,"LastAct")
    self:DTVar("Int",1,"WalkerColorIndex")
    self:DTVar("Int",2,"WalkerModelIndex")
end
function ENT.Initialize(self)
    local models = GWConfigManager:GetInstance():get__Data().HiderModels

    if SERVER then
        PrintTable(models)
        self:set__WalkerModelIndex((math.random(#models)-1))
    end
    self:SetModel(models[self:get__WalkerModelIndex()+1])
    local walkerColors = GWConfigManager:GetInstance():get__Data().WalkerColors

    if SERVER then
        self:set__WalkerColorIndex((math.random(#walkerColors)-1))
    end
    local walkerClr = walkerColors[self:get__WalkerColorIndex()+1]

    self.walkerColor = Vector(walkerClr.r/255,walkerClr.g/255,walkerClr.b/255)
    self.GetPlayerColor = function() return self.walkerColor end
    self:SetHealth(100)
    if SERVER then
        self:SetCollisionBounds(Vector(-16,-16,0),Vector(16,16,70))
        self.loco:SetStepHeight(22)
        self.nextPossibleJump = (CurTime()+5)
        self.isJumping = false
        self.shouldCrouch = false
    end
end
function ENT.Draw(self)
    self:DrawModel()
    local leftEye = self:GetAttachment(self:LookupAttachment("lefteye"))

    local rightEye = self:GetAttachment(self:LookupAttachment("righteye"))

    if (not leftEye) then
        leftEye = self:GetAttachment(self:LookupAttachment("left_eye"))
        rightEye = self:GetAttachment(self:LookupAttachment("right_eye"))
    end
    local leftEyePos = nil

    local rightEyePos = nil

    if leftEye and rightEye then
        leftEyePos = (leftEye.Pos+self:GetForward())
        rightEyePos = (rightEye.Pos+self:GetForward())
    else
        local eyes = self:GetAttachment(self:LookupAttachment("eyes"))

        if eyes then
            leftEyePos = ((self:GetRight())*-1.5)+((self:GetForward())*0.5)
            rightEyePos = ((self:GetRight())*1.5)+((self:GetForward())*0.5)
        end
    end
    if leftEyePos and rightEyePos then
        render.SetMaterial(eyeGlow)
        render.DrawSprite(leftEyePos,4,4,white)
        render.DrawSprite(rightEyePos,4,4,white)
    end
end
function ENT.Think(self)
    if SERVER then
        local doors = ents.FindInSphere(self:GetPos(),60)

        for _, door in ipairs(doors) do
            do
                local doorClass = door:GetClass()

                if ((doorClass=="func_door") or (doorClass=="func_door_rotating")) or (doorClass=="prop_door_rotating") then
                    door:Fire("Unlock","",0)
                    door:Fire("Open","",0.01)
                    door:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                end
            end
            ::__continue0::
        end
        if (self.isStuck and (CurTime()>(self.stuckTime+20))) and (self.stuckPos:DistToSqr(self:GetPos())<25) then
            local spawnPoints = (GAMEMODE):get__Gamerules():get__SpawnPoints()

            local spawnPoint = spawnPoints[math.random(#spawnPoints)-1+1]:GetPos()

            self:SetPos(spawnPoint)
            self.isStuck = false
            MsgN("Nextbot ["..tostring(tostring(self:EntIndex())).."]["..tostring(self:GetClass()).."]" .. "Got Stuck for over 20 seconds and will be repositioned, if this error gets spammed" .. "you might want to consider the following: Edit the navmesh or lower the walker amount.")
        end
        if self.isStuck and (self.stuckPos:DistToSqr(self:GetPos())>100) then
            self.isStuck = false
        end
        if (not self.isJumping) and (self:GetSolidMask()==MASK_NPCSOLID_BRUSHONLY) then
            local entsInBox = ents.FindInBox(self:GetPos()+Vector(-16,-16,0),self:GetPos()+Vector(16,16,70))

            local occupied = __TS__ArraySome(entsInBox, function(ent) return (ent:GetClass()=="npc_walker") and (ent~=self) end)

            if (not occupied) then
                self:SetSolidMask(MASK_NPCSOLID)
            end
        end
    end
    return false
end
function ENT.RunBehaviour(self)
    while true do
        do
            self:MoveSomeWhere(10000)
            while true do
                do
                    local rand = math.random(1,100)

                    if (rand>0) and (rand<10) then
                        self:MoveToSpot("hiding")
                        coroutine.wait(math.random(1,10))
                    else
                        if (rand>10) and (rand<15) then
                            self:Sit()
                            coroutine.wait(1)
                        else
                            self:MoveSomeWhere()
                            coroutine.wait(1)
                        end
                    end
                end
                ::__continue2::
            end
        end
        ::__continue1::
    end
end
