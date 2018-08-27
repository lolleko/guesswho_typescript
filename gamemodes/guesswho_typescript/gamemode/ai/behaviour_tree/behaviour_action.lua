
-- Lua Library Imports
local exports = exports or {}
local ibehaviour0 = include("./ibehaviour.lua")
local IBehaviour = ibehaviour0.IBehaviour
local behaviour_status1 = include("./behaviour_status.lua")
local BehaviourStatus = behaviour_status1.BehaviourStatus
local BehaviourAction = BehaviourAction or {}
BehaviourAction.__index = BehaviourAction
function BehaviourAction.new(construct, ...)
    local instance = setmetatable({}, BehaviourAction)
    if construct and BehaviourAction.constructor then BehaviourAction.constructor(instance, ...) end
    return instance
end
function BehaviourAction.constructor(self,func)
    self.func = func
end
function BehaviourAction.tick(self)
    return self.func()
end
exports.BehaviourAction = BehaviourAction
return exports
