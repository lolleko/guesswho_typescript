
-- Lua Library Imports
AddCSLuaFile()
ENT.Base = "base_nextbot"
function ENT.RunBehaviour(self)
    self.behaviourTree = BehaviourTreeBuilder.new(true):sequence():action(function(ent)
        if ent.hasPath and ent.currentPath:IsValid() then
            return BehaviourStatus.Success
        end
        ent.targetPos = ((VectorRand()*200)+(ent:GetPos()))
        ent.currentPath = Path("Follow")
        ent.currentPath:SetMinLookAheadDistance(300)
        ent.currentPath:SetGoalTolerance(20)
        ent.currentPath:Compute(self,ent.targetPos)
        if (not ent.currentPath:IsValid()) then
            return BehaviourStatus.Failure
        end
        return BehaviourStatus.Success
    end
):action(function(ent)
        if (not ent.currentPath:IsValid()) then
            return BehaviourStatus.Success
        end
        ent.currentPath:Update(self)
        ent.currentPath:Draw()
        if self.loco:IsStuck() then
            self:HandleStuck()
        end
        if self.currentPath:GetAge()>10 then
            return BehaviourStatus.Failure
        end
        return BehaviourStatus.Running
    end
):finish():build()
    while true do
        do
            self.behaviourTree:tick(self)
            coroutine.yield()
        end
        ::__continue0::
    end
end
