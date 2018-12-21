BehaviourAction = BehaviourAction or {}
BehaviourAction.__index = BehaviourAction
function BehaviourAction.new(construct, ...)
    local self = setmetatable({}, BehaviourAction)
    if construct and BehaviourAction.constructor then BehaviourAction.constructor(self, ...) end
    return self
end
function BehaviourAction.constructor(self,func)
    self.func = func;
end
function BehaviourAction.tick(self)
    return self.func()
end
