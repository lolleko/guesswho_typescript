
-- Lua Library Imports
BehaviourAction = BehaviourAction or {}
BehaviourAction.__index = BehaviourAction
function BehaviourAction.new(construct, ...)
    local instance = setmetatable({}, BehaviourAction)
    if construct and BehaviourAction.constructor then BehaviourAction.constructor(instance, ...) end
    return instance
end
function BehaviourAction.constructor(self,func)
    self.func = func
end
function BehaviourAction.tick(self,state)
    return self.func(state)
end
