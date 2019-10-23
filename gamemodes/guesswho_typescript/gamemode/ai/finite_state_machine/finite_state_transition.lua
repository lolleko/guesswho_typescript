--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
StateTransition = StateTransition or {};
StateTransition.__index = StateTransition;
StateTransition.prototype = StateTransition.prototype or {};
StateTransition.prototype.__index = StateTransition.prototype;
StateTransition.prototype.constructor = StateTransition;
StateTransition.new = function(...)
    local self = setmetatable({}, StateTransition.prototype);
    self:____constructor(...);
    return self;
end;
StateTransition.prototype.____constructor = function(self, fromState, toState, condition)
    self.fromState = fromState;
    self.toState = toState;
    if condition then
        self.condition = condition;
    else
        self.condition = function(____)
            return true;
        end;
    end
end;
