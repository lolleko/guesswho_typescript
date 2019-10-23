--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
AddCSLuaFile();
ENT.Base = "base_nextbot";
ENT.RunBehaviour = function(self)
    self.behaviourTree = BehaviourTreeBuilder.new():sequence():action(function(____)
        if self.hasPath and self.currentPath:IsValid() then
            return BehaviourStatus.Success;
        end
        self.targetPos = (VectorRand() * 200) + (self:GetPos());
        self.currentPath = Path("Follow");
        self.currentPath:SetMinLookAheadDistance(300);
        self.currentPath:SetGoalTolerance(20);
        self.currentPath:Compute(self, self.targetPos);
        if not self.currentPath:IsValid() then
            return BehaviourStatus.Failure;
        end
        return BehaviourStatus.Success;
    end):action(function(____)
        if not self.currentPath:IsValid() then
            return BehaviourStatus.Success;
        end
        self.currentPath:Update(self);
        self.currentPath:Draw();
        if self.loco:IsStuck() then
            self:HandleStuck();
        end
        if self.currentPath:GetAge() > 10 then
            return BehaviourStatus.Failure;
        end
        return BehaviourStatus.Running;
    end):finish():build();
    while true do
        do
            self.behaviourTree:tick();
            coroutine.yield();
        end
        ::__continue9::
    end
end;
