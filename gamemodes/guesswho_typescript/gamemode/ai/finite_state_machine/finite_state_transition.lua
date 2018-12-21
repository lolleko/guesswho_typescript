StateTransition = StateTransition or {}
StateTransition.__index = StateTransition
function StateTransition.new(construct, ...)
    local self = setmetatable({}, StateTransition)
    if construct and StateTransition.constructor then StateTransition.constructor(self, ...) end
    return self
end
function StateTransition.constructor(self,fromState,toState,condition)
    self.fromState = fromState;
    self.toState = toState;
    if condition then
        self.condition = condition;
    else
        self.condition = function() return true end;
    end
end
