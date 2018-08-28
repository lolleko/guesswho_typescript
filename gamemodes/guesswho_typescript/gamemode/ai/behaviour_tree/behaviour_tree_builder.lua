
-- Lua Library Imports
BehaviourTreeBuilder = BehaviourTreeBuilder or {}
BehaviourTreeBuilder.__index = BehaviourTreeBuilder
function BehaviourTreeBuilder.new(construct, ...)
    local instance = setmetatable({}, BehaviourTreeBuilder)
    if construct and BehaviourTreeBuilder.constructor then BehaviourTreeBuilder.constructor(instance, ...) end
    return instance
end
function BehaviourTreeBuilder.constructor(self)
    self.parentStack = {}
    self.result = BehaviourTree.new(true)
end
function BehaviourTreeBuilder.action(self,func)
    assert((not self:parentStackEmpty()),"Can\'t create this node without a parent (sequence/selector)")
    self:peekParent():addChild(BehaviourAction.new(true,func))
    return self
end
function BehaviourTreeBuilder.condition(self,func)
    assert((not self:parentStackEmpty()),"Can\'t create this node without a parent (sequence/selector)")
    self:peekParent():addChild(BehaviourCondition.new(true,func))
    return self
end
function BehaviourTreeBuilder.sequence(self)
    self:pushParent(BehaviourSequence.new(true))
    return self
end
function BehaviourTreeBuilder.selector(self)
    self:pushParent(BehaviourSelector.new(true))
    return self
end
function BehaviourTreeBuilder.finish(self)
    self:popParent()
    return self
end
function BehaviourTreeBuilder.build(self)
    return self.result
end
function BehaviourTreeBuilder.pushParent(self,parent)
    if self:parentStackEmpty() then
        self.result:setRoot(parent)
    end
    self.parentStack[#self.parentStack+1] = parent
end
function BehaviourTreeBuilder.popParent(self)
    local old = self:peekParent()

    self.parentStack[#self.parentStack-1+1]=nil
    return old
end
function BehaviourTreeBuilder.peekParent(self)
    return self.parentStack[#self.parentStack-1+1]
end
function BehaviourTreeBuilder.parentStackEmpty(self)
    return #self.parentStack==0
end
