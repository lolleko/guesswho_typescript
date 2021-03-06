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

__TS__ArrayFilter = function(arr, callbackfn)
    local result = {};
    do
        local i = 0;
        while i < (#arr) do
            if callbackfn(_G, arr[i + 1], i, arr) then
                result[(#result) + 1] = arr[i + 1];
            end
            i = i + 1;
        end
    end
    return result;
end;

AddCSLuaFile();
local eyeGlow = Material("sprites/redglow1");
local white = Color(255, 255, 255, 255);
ENT.Base = "base_nextbot";
ENT.boundsSize = 10;
ENT.LastAct = function(self)
    return self:GetDTInt(0);
end;
ENT.WalkerColorIndex = function(self)
    return self:GetDTInt(1);
end;
ENT.WalkerModelIndex = function(self)
    return self:GetDTInt(2);
end;
ENT.Locomotion = function(self)
    return self.loco;
end;
ENT.LastAct = function(self, act)
    self:SetDTInt(0, act);
end;
ENT.WalkerColorIndex = function(self, index)
    self:SetDTInt(1, index);
end;
ENT.WalkerModelIndex = function(self, index)
    self:SetDTInt(2, index);
end;
ENT.Sit = function(self, duration)
    if duration == nil then
        duration = math.random(10, 30);
    end
    self.isSitting = true;
    self.sitUntil = CurTime() + duration;
end;
ENT.SetCrouchCollision = function(self, state)
    if state then
        self:SetCollisionBounds(Vector(-self.boundsSize, -self.boundsSize, 0), Vector(self.boundsSize, self.boundsSize, 36));
    else
        self:SetCollisionBounds(Vector(-self.boundsSize, -self.boundsSize, 0), Vector(self.boundsSize, self.boundsSize, 70));
    end
end;
ENT.Doge = function(self, dogePos, maxDuration)
    if maxDuration == nil then
        maxDuration = 0.35;
    end
    self.dogePos = dogePos;
    self.dogeUntil = CurTime() + maxDuration;
    self.isDoging = true;
end;
ENT.Jump = function(self)
    if self.isJumping or (self.nextPossibleJump > CurTime()) then
        return;
    end
    self.loco:Jump();
    self.isJumping = true;
    self.nextPossibleJump = CurTime() + 3;
end;
ENT.SetupDataTables = function(self)
    self:DTVar("Int", 0, "LastAct");
    self:DTVar("Int", 1, "WalkerColorIndex");
    self:DTVar("Int", 2, "WalkerModelIndex");
end;
ENT.Initialize = function(self)
    local models = GWConfigManager:GetInstance().Data.HiderModels;
    if SERVER then
        self.WalkerModelIndex = math.random(#models) - 1;
    end
    self:SetModel(models[self.WalkerModelIndex + 1]);
    local walkerColors = GWConfigManager:GetInstance().Data.WalkerColors;
    if SERVER then
        self.WalkerColorIndex = math.random(#walkerColors) - 1;
    end
    local walkerClr = walkerColors[self.WalkerColorIndex + 1];
    self.walkerColor = Vector(walkerClr.r / 255, walkerClr.g / 255, walkerClr.b / 255);
    self.GetPlayerColor = function(____)
        return self.walkerColor;
    end;
    self:SetHealth(100);
    if SERVER then
        self:SetCollisionBounds(Vector(-self.boundsSize, -self.boundsSize, 0), Vector(self.boundsSize, self.boundsSize, 70));
        self.loco:SetStepHeight(20);
        self.loco:SetJumpHeight(68);
        self.loco:SetDesiredSpeed(100);
        self.nextPossibleJump = CurTime() + 8;
        self.nextPossibleSettingsChange = CurTime() + 10;
        self.dogeUntil = CurTime();
        self.isJumping = false;
        self.shouldCrouch = false;
        self.isFirstPath = true;
    end
end;
ENT.Think = function(self)
    if SERVER then
        local doors = ents.FindInSphere(self:GetPos(), 60);
        for ____TS_index = 1, #doors do
            local door = doors[____TS_index];
            do
                local doorClass = door:GetClass();
                if ((doorClass == "func_door") or (doorClass == "func_door_rotating")) or (doorClass == "prop_door_rotating") then
                    door:Fire("Unlock", "", 0);
                    door:Fire("Open", "", 0.01);
                    door:SetCollisionGroup(COLLISION_GROUP_DEBRIS);
                end
            end
            ::__continue23::
        end
        if (self.isStuck and (CurTime() > (self.stuckTime + 15))) and (self.stuckPos:DistToSqr(self:GetPos()) < 25) then
            local spawnPoints = (GAMEMODE).Gamerules.SpawnPoints;
            local spawnPoint = spawnPoints[(math.random(#spawnPoints) - 1) + 1]:GetPos();
            self:SetPos(spawnPoint);
            self.isStuck = false;
            MsgN(((("Nextbot [" .. (tostring(tostring(nil, self:EntIndex())) .. "][")) .. (tostring(self:GetClass()) .. "]")) .. "Got Stuck for over 15 seconds and will be repositioned, if this error gets spammed") .. "you might want to consider the following: Edit the navmesh or lower the walker amount.");
        end
        if self.isStuck and (self.stuckPos:DistToSqr(self:GetPos()) > 400) then
            self.isStuck = false;
        end
        if self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY then
            local entsInBox = ents.FindInBox(self:GetPos() + Vector(-self.boundsSize, -self.boundsSize, 0), self:GetPos() + Vector(self.boundsSize, self.boundsSize, 70));
            local occupied = __TS__ArraySome(entsInBox, function(____, ent)
                return (ent:GetClass() == "npc_walker") and (ent ~= self);
            end);
            if not occupied then
                self:SetSolidMask(MASK_NPCSOLID);
            end
        end
    end
    return false;
end;
ENT.RunBehaviour = function(self)
    self.behaviourTree = BehaviourTreeBuilder.new():sequence():action(function(____)
        if self.nextPossibleSettingsChange > CurTime() then
            return BehaviourStatus.Success;
        end
        local rand = math.random(1, 100);
        if (rand > 0) and (rand < 15) then
            self.loco:SetDesiredSpeed(200);
        elseif (rand > 15) and (rand < 22) then
            local entsAround = ents.FindInSphere(self:GetPos(), 300);
            local walkersAround = __TS__ArrayFilter(entsAround, function(____, ent)
                return ent:GetClass() == self:GetClass();
            end);
            local doorsAround = __TS__ArrayFilter(entsAround, function(____, ent)
                return ((ent:GetClass() == "func_door") or (ent:GetClass() == "func_door_rotating")) or (ent:GetClass() == "prop_door_rotating");
            end);
            if ((#walkersAround) < 3) and ((#doorsAround) == 0) then
                self:Sit(math.random(10, 60));
            end
        else
            self.loco:SetDesiredSpeed(100);
        end
        self.nextPossibleSettingsChange = CurTime() + 5;
        return BehaviourStatus.Success;
    end):action(function(____)
        if not self.isSitting then
            return BehaviourStatus.Success;
        end
        self:SetSequence("sit_zen");
        self:SetCrouchCollision(true);
        if self.sitUntil < CurTime() then
            self:SetCrouchCollision(false);
            self.isSitting = false;
            return BehaviourStatus.Success;
        end
        return BehaviourStatus.Running;
    end):action(function(____)
        if self.hasPath and self.currentPath:IsValid() then
            return BehaviourStatus.Success;
        end
        local radius = 2200;
        if self.isFirstPath then
            radius = 8000;
        end
        local navs = navmesh.Find(self:GetPos(), radius, 200, 200);
        local nav = navs[(math.random(#navs) - 1) + 1];
        if not IsValid(nav) then
            return BehaviourStatus.Failure;
        end
        if nav:IsUnderwater() then
            return BehaviourStatus.Failure;
        end
        self.targetPos = nav:GetRandomPoint();
        self.currentPath = Path("Follow");
        self.currentPath:SetMinLookAheadDistance(10);
        self.currentPath:SetGoalTolerance(10);
        self.currentPath:Compute(self, self.targetPos);
        if self.isFirstPath then
            self.currentPathMaxAge = 20;
        else
            self.currentPathMaxAge = math.Clamp(self.currentPath:GetLength() / 90, 0.1, 12);
        end
        if not self.currentPath:IsValid() then
            return BehaviourStatus.Failure;
        end
        self.isFirstPath = false;
        self.hasPath = true;
        return BehaviourStatus.Success;
    end):action(function(____)
        if not self.currentPath:IsValid() then
            return BehaviourStatus.Success;
        end
        if (self.isDoging and (self.dogeUntil > CurTime())) and (self.dogePos:DistToSqr(self:GetPos()) > 100) then
            local dogeDirection = (self.dogePos - self:GetPos()):GetNormalized();
            self.loco:FaceTowards(self.dogePos);
            self.loco:SetVelocity(dogeDirection * 80);
            self.loco:Approach(self.dogePos, 1);
            return BehaviourStatus.Running;
        else
            self.isDoging = false;
        end
        local goal = self.currentPath:GetCurrentGoal();
        local distToGoal = self:GetPos():Distance(goal.pos);
        if goal.type == 3 then
            self.isJumping = true;
            self.loco:JumpAcrossGap(goal.pos, goal.forward);
        elseif not goal.area:HasAttributes(bit.bor(NAV_MESH_NO_JUMP, NAV_MESH_STAIRS)) then
            if (goal.type == 2) and (distToGoal < 30) then
                self:Jump();
            else
                local scanDist = 25;
                local scanPoint = self.currentPath:GetClosestPosition(({self:EyePos()})[0 + 1] + (self.loco:GetGroundMotionVector() * scanDist));
                if (math.abs(self:GetPos().z - scanPoint.z) > self.loco:GetStepHeight()) and (distToGoal < 300) then
                    self:Jump();
                end
            end
        end
        self.currentPath:Update(self);
        if self.loco:IsStuck() then
            self:HandleStuck();
        end
        if self.currentPath:GetAge() > self.currentPathMaxAge then
            return BehaviourStatus.Failure;
        end
        return BehaviourStatus.Running;
    end):finish():build();
    while true do
        do
            self.behaviourTree:tick();
            coroutine.yield();
        end
        ::__continue61::
    end
end;
ENT.BodyUpdate = function(self)
    local idealAct = ACT_HL2MP_IDLE;
    local velocity = self:GetVelocity();
    local len2d = velocity:Length2D();
    if len2d > 150 then
        idealAct = ACT_HL2MP_RUN;
    elseif len2d > 10 then
        idealAct = ACT_HL2MP_WALK;
    end
    if self.isJumping and (self:WaterLevel() <= 0) then
        idealAct = ACT_HL2MP_JUMP_SLAM;
    end
    if ((self:GetActivity() ~= idealAct) and (not self.isSitting)) and (not self.isDancing) then
        self:StartActivity(idealAct);
    end
    if (idealAct == ACT_HL2MP_RUN) or (idealAct == ACT_HL2MP_WALK) then
        self:BodyMoveXY();
    end
    self:FrameAdvance();
end;
ENT.OnLandOnGround = function(self, ent)
    self.isJumping = false;
    self:SetCrouchCollision(false);
end;
ENT.OnLeaveGround = function(self, ent)
    self.isJumping = true;
    self:SetCrouchCollision(true);
end;
ENT.OnContact = function(self, ent)
    if (ent:GetClass() == self:GetClass()) or ent:IsPlayer() then
        if math.abs(self:GetPos().z - ent:GetPos().z) > 20 then
            self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY);
        elseif not self.isDoging then
            local dogeDirection = (ent:GetPos() - self:GetPos()):GetNormalized();
            dogeDirection:Rotate(Angle(0, math.random(85, 95), 0));
            dogeDirection.z = 0;
            self:Doge(self:GetPos() + (dogeDirection * 200), math.random(0.2, 0.35));
        end
    end
    if (ent:GetClass() == "prop_physics_multiplayer") or ((ent:GetClass() == "prop_physics") and (not GetConVar("gw_propfreeze_enabled"):GetBool())) then
        local phys = ent:GetPhysicsObject();
        if not IsValid(phys) then
            return;
        end
        local force = ((ent:GetPos() - self:GetPos()):GetNormalized() * 3) * self:GetVelocity():Length2D();
        force.z = 0;
        phys:ApplyForceCenter(force);
        DropEntityIfHeld(ent);
    end
    if (ent:GetClass() == "func_breakable") or (ent:GetClass() == "func_breakable_surf") then
        ent:Fire("Shatter");
    end
    if self.isStuck and ((ent:GetClass() == self:GetClass()) or ent:IsPlayer()) then
        local thisMin = self:OBBMins() + self:GetPos();
        local thisMax = self:OBBMaxs() + self:GetPos();
        local entMin = ent:OBBMins() + ent:GetPos();
        local entMax = ent:OBBMaxs() + ent:GetPos();
        if not ((((thisMax.x < entMin.x) or (thisMin.x > entMax.x)) or (thisMax.y < entMin.y)) or (thisMin.y > entMax.y)) then
            self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY);
        end
    end
end;
ENT.OnStuck = function(self)
    if not self.isStuck then
        self.stuckTime = CurTime();
        self.isStuck = true;
    end
    self.stuckPos = self:GetPos();
    if (self.hasPath and (not self.isDoging)) and (self.loco:GetVelocity():Length2DSqr() < 0.1) then
        local randomDir = VectorRand() * 100;
        randomDir.z = 0;
        self:Doge(self:GetPos() + randomDir, 0.4);
    end
end;
ENT.OnUnStuck = function(self)
    if (self.stuckPos:DistToSqr(self:GetPos()) > 100) or self.isSitting then
        self.isStuck = false;
    end
end;
ENT.Use = function(self, activator, caller, useType, value)
    if (caller):IsHider() and GetConVar("gw_changemodel_hiding"):GetBool() then
        self:SetModel(self:GetModel());
    end
end;
ENT.PathGenerator = function(self)
    return function(____, area, fromArea, ladder, elevator, length)
        if not IsValid(fromArea) then
            return 0;
        end
        if not self.loco:IsAreaTraversable(area) then
            return -1;
        end
        local dist = 0;
        if IsValid(ladder) then
            dist = ladder:GetLength();
        elseif length > 0 then
            dist = length;
        else
            dist = area:GetCenter():Distance(fromArea:GetCenter());
        end
        local cost = dist + fromArea:GetCostSoFar();
        local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area);
        if deltaZ >= self.loco:GetStepHeight() then
            if deltaZ >= (self.loco:GetMaxJumpHeight() - 20) then
                return -1;
            end
            cost = cost + deltaZ;
        elseif deltaZ < (-self.loco:GetDeathDropHeight()) then
            return -1;
        end
        return cost;
    end;
end;
