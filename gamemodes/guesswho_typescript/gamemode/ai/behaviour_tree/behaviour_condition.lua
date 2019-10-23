--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
BehaviourCondition = BehaviourCondition or {};
BehaviourCondition.__index = BehaviourCondition;
BehaviourCondition.prototype = BehaviourCondition.prototype or {};
BehaviourCondition.prototype.__index = BehaviourCondition.prototype;
BehaviourCondition.prototype.constructor = BehaviourCondition;
BehaviourCondition.new = function(...)
    local self = setmetatable({}, BehaviourCondition.prototype);
    self:____constructor(...);
    return self;
end;
BehaviourCondition.prototype.____constructor = function(self, func)
    self.func = func;
end;
BehaviourCondition.prototype.tick = function(self)
    return (self:func() and BehaviourStatus.Success) or BehaviourStatus.Failure;
end;
