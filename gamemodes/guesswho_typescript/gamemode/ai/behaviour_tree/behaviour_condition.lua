
-- Lua Library Imports
function __TS__Ternary(condition,cb1,cb2)
    if condition then
        return cb1()
    else
        return cb2()
    end
end

BehaviourCondition = BehaviourCondition or {}
BehaviourCondition.__index = BehaviourCondition
function BehaviourCondition.new(construct, ...)
    local self = setmetatable({}, BehaviourCondition)
    if construct and BehaviourCondition.constructor then BehaviourCondition.constructor(self, ...) end
    return self
end
function BehaviourCondition.constructor(self,func)
    self.func = func;
end
function BehaviourCondition.tick(self)
    return __TS__Ternary(self.func(), function() return BehaviourStatus.Success end, function() return BehaviourStatus.Failure end)
end
