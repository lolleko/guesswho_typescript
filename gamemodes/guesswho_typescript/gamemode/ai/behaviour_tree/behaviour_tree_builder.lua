--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
BehaviourTreeBuilder = BehaviourTreeBuilder or {};
BehaviourTreeBuilder.__index = BehaviourTreeBuilder;
BehaviourTreeBuilder.prototype = BehaviourTreeBuilder.prototype or {};
BehaviourTreeBuilder.prototype.__index = BehaviourTreeBuilder.prototype;
BehaviourTreeBuilder.prototype.constructor = BehaviourTreeBuilder;
BehaviourTreeBuilder.new = function(...)
    local self = setmetatable({}, BehaviourTreeBuilder.prototype);
    self:____constructor(...);
    return self;
end;
BehaviourTreeBuilder.prototype.____constructor = function(self)
    self.parentStack = {};
    self.result = BehaviourTree.new();
end;
BehaviourTreeBuilder.prototype.action = function(self, func)
    assert(not self:parentStackEmpty(), "Can\'t create this node without a parent (sequence/selector)");
    self:peekParent():addChild(BehaviourAction.new(func));
    return self;
end;
BehaviourTreeBuilder.prototype.condition = function(self, func)
    assert(not self:parentStackEmpty(), "Can\'t create this node without a parent (sequence/selector)");
    self:peekParent():addChild(BehaviourCondition.new(func));
    return self;
end;
BehaviourTreeBuilder.prototype.sequence = function(self)
    self:pushParent(BehaviourSequence.new());
    return self;
end;
BehaviourTreeBuilder.prototype.selector = function(self)
    self:pushParent(BehaviourSelector.new());
    return self;
end;
BehaviourTreeBuilder.prototype.finish = function(self)
    self:popParent();
    return self;
end;
BehaviourTreeBuilder.prototype.build = function(self)
    return self.result;
end;
BehaviourTreeBuilder.prototype.pushParent = function(self, parent)
    if self:parentStackEmpty() then
        self.result:setRoot(parent);
    end
    self.parentStack[(#self.parentStack) + 1] = parent;
end;
BehaviourTreeBuilder.prototype.popParent = function(self)
    local old = self:peekParent();
    self.parentStack[((#self.parentStack) - 1) + 1] = nil;
    return old;
end;
BehaviourTreeBuilder.prototype.peekParent = function(self)
    return self.parentStack[((#self.parentStack) - 1) + 1];
end;
BehaviourTreeBuilder.prototype.parentStackEmpty = function(self)
    return (#self.parentStack) == 0;
end;
