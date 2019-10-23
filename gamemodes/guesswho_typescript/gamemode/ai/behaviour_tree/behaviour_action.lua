--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
BehaviourAction = BehaviourAction or {};
BehaviourAction.__index = BehaviourAction;
BehaviourAction.prototype = BehaviourAction.prototype or {};
BehaviourAction.prototype.__index = BehaviourAction.prototype;
BehaviourAction.prototype.constructor = BehaviourAction;
BehaviourAction.new = function(...)
    local self = setmetatable({}, BehaviourAction.prototype);
    self:____constructor(...);
    return self;
end;
BehaviourAction.prototype.____constructor = function(self, func)
    self.func = func;
end;
BehaviourAction.prototype.tick = function(self)
    return self:func();
end;
