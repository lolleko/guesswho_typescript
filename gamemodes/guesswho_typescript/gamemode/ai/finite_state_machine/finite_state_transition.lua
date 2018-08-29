
-- Lua Library Imports
StateTransition = StateTransition or {}
StateTransition.__index = StateTransition
function StateTransition.new(construct, ...)
    local instance = setmetatable({}, StateTransition)
    if construct and StateTransition.constructor then StateTransition.constructor(instance, ...) end
    return instance
end
function StateTransition.constructor(self,fromState,toState,condition)
    self.fromState = fromState
    self.toState = toState
    if condition then
        self.condition = condition
    else
        self.condition = function() return true end
    end
end
