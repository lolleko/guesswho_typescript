
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
function ENT.get__Locomotion(self)
    return self.loco
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
function ENT.Sit(self,duration)
    if duration==nil then duration=math.random(10,30) end
    self.isSitting = true
    self.sitUntil = (CurTime()+duration)
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
        self:SetCollisionBounds(Vector(-8,-8,0),Vector(8,8,70))
        self.loco:SetStepHeight(21)
        self.loco:SetJumpHeight(68)
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
        if self:GetSolidMask()==MASK_NPCSOLID_BRUSHONLY then
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
    self.behaviourTree = BehaviourTreeBuilder.new(true):sequence():action(function()
        if (not self.isSitting) then
            return BehaviourStatus.Success
        end
        self:SetSequence("sit_zen")
        self:SetCollisionBounds(Vector(-8,-8,0),Vector(8,8,36))
        if self.sitUntil<CurTime() then
            self:SetCollisionBounds(Vector(-8,-8,0),Vector(8,8,70))
            self.isSitting = false
            return BehaviourStatus.Success
        end
        return BehaviourStatus.Running
    end
):action(function()
        if self.hasPath and self.currentPath:IsValid() then
            return BehaviourStatus.Success
        end
        self.loco:SetDesiredSpeed(100)
        local navs = navmesh.Find(self:GetPos(),1000,120,120)

        local nav = navs[math.random(#navs)-1+1]

        if (not IsValid(nav)) then
            return BehaviourStatus.Failure
        end
        if nav:IsUnderwater() then
            return BehaviourStatus.Failure
        end
        self.targetPos = nav:GetRandomPoint()
        self.currentPath = Path("Follow")
        self.currentPath:SetMinLookAheadDistance(10)
        self.currentPath:SetGoalTolerance(10)
        self.currentPath:Compute(self,self.targetPos,self:PathGenerator())
        self.currentPathMaxAge = math.Clamp(self.currentPath:GetLength()/90,0.1,15)
        if (not self.currentPath:IsValid()) then
            return BehaviourStatus.Failure
        end
        return BehaviourStatus.Success
    end
):action(function()
        if (not self.currentPath:IsValid()) then
            return BehaviourStatus.Success
        end
        local goal = self.currentPath:GetCurrentGoal()

        if goal.type==3 then
            self.loco:JumpAcrossGap(goal.pos,goal.forward)
        else
            if (goal.type==2) and (self:GetPos():Distance(goal.pos)<30) then
                self.isJumping = true
                self.loco:Jump()
            end
        end
        self.currentPath:Update(self)
        self.currentPath:Draw()
        if self.loco:IsStuck() then
            self:HandleStuck()
        end
        if self.currentPath:GetAge()>self.currentPathMaxAge then
            return BehaviourStatus.Failure
        end
        return BehaviourStatus.Running
    end
):finish():build()
    while true do
        do
            self.behaviourTree:tick()
            coroutine.yield()
        end
        ::__continue1::
    end
end
function ENT.BodyUpdate(self)
    local act = self:GetActivity()

    local idealAct = ACT_HL2MP_IDLE

    local velocity = self:GetVelocity()

    local len2d = velocity:Length2D()

    if len2d>150 then
        idealAct = ACT_HL2MP_RUN
    else
        if len2d>10 then
            idealAct = ACT_HL2MP_WALK
        end
    end
    if self.isJumping and (self:WaterLevel()<=0) then
        idealAct = ACT_HL2MP_JUMP_SLAM
    end
    if ((self:GetActivity()~=idealAct) and (not self.isSitting)) and (not self.isDancing) then
        self:StartActivity(idealAct)
    end
    if (idealAct==ACT_HL2MP_RUN) or (idealAct==ACT_HL2MP_WALK) then
        self:BodyMoveXY()
    end
    self:FrameAdvance()
end
function ENT.OnLandOnGround(self,ent)
    self.isJumping = false
end
function ENT.OnLeaveGround(self,ent)
    self.isJumping = true
end
function ENT.OnContact(self,ent)
    if (ent:GetClass()==self:GetClass()) or ent:IsPlayer() then
        local calcDogeGoal = function(collider)
            local dogeDirection = Vector(collider:GetPos())

            dogeDirection:Add(collider:GetRight()*30)
            dogeDirection:Add(collider:GetForward()*30)
            return dogeDirection
        end


        self.loco:Approach(calcDogeGoal(self),1000)
        if math.abs(self:GetPos().z-ent:GetPos().z)>30 then
            self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
        end
    end
    if (ent:GetClass()=="prop_physics_multiplayer") or ((ent:GetClass()=="prop_physics") and (not GetConVar("gw_propfreeze_enabled"):GetBool())) then
        local phys = ent:GetPhysicsObject()

        if (not IsValid(phys)) then
            return
        end
        phys:ApplyForceCenter(self:GetPos()-(ent:GetPos()*1.2))
        DropEntityIfHeld(ent)
    end
    if (ent:GetClass()=="func_breakable") or (ent:GetClass()=="func_breakable_surf") then
        ent:Fire("Shatter")
    end
end
function ENT.OnStuck(self)
    if (not self.isStuck) then
        self.stuckTime = CurTime()
    end
    self.stuckPos = self:GetPos()
end
function ENT.OnUnStuck(self)
    if (self.stuckPos:Distance(self:GetPos())>10) or self.isSitting then
        self.isStuck = false
    end
end
function ENT.Use(self,activator,caller,useType,value)
    if (caller):IsHider() and GetConVar("gw_changemodel_hiding"):GetBool() then
        self:SetModel(self:GetModel())
    end
end
function ENT.PathGenerator(self)
    return function(area,fromArea,ladder,elevator,length)
        if (not IsValid(fromArea)) then
            return 0
        end
        if (not self.loco:IsAreaTraversable(area)) then
            return -1
        end
        local dist = 0

        if IsValid(ladder) then
            dist = ladder:GetLength()
        else
            if length>0 then
                dist = length
            else
                dist = area:GetCenter():Distance(fromArea:GetCenter())
            end
        end
        local cost = dist+fromArea:GetCostSoFar()

        local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area)

        if deltaZ>=self.loco:GetStepHeight() then
            if deltaZ>=(self.loco:GetMaxJumpHeight()-20) then
                return -1
            end
            cost = (cost+deltaZ)
        else
            if deltaZ<-self.loco:GetDeathDropHeight() then
                return -1
            end
        end
        return cost
    end

end
