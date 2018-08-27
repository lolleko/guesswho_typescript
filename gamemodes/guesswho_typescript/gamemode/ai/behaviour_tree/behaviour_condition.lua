
-- Lua Library Imports
function __TS__Ternary(condition,cb1,cb2)
    if condition then
        return cb1()
    else
        return cb2()
    end
end

local exports = exports or {}
local ibehaviour0 = include("./ibehaviour.lua")
local IBehaviour = ibehaviour0.IBehaviour
local behaviour_status1 = include("./behaviour_status.lua")
local BehaviourStatus = behaviour_status1.BehaviourStatus
local BehaviourCondition = BehaviourCondition or {}
BehaviourCondition.__index = BehaviourCondition
function BehaviourCondition.new(construct, ...)
    local instance = setmetatable({}, BehaviourCondition)
    if construct and BehaviourCondition.constructor then BehaviourCondition.constructor(instance, ...) end
    return instance
end
function BehaviourCondition.constructor(self,func)
    self.func = func
end
function BehaviourCondition.tick(self)
    return __TS__Ternary(self.func(), function() return BehaviourStatus.Success end, function() return BehaviourStatus.Failure end)
end
exports.BehaviourCondition = BehaviourCondition
return exports
