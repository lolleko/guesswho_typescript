
-- Lua Library Imports
BehaviourTree = BehaviourTree or {}
BehaviourTree.__index = BehaviourTree
function BehaviourTree.new(construct, ...)
    local instance = setmetatable({}, BehaviourTree)
    if construct and BehaviourTree.constructor then BehaviourTree.constructor(instance, ...) end
    return instance
end
function BehaviourTree.constructor(self,root)
    self.root = root
end
function BehaviourTree.setRoot(self,root)
    self.root = root
end
function BehaviourTree.tick(self)
    if self.root then
        return self.root:tick()
    else
        print("TICKING EMPTY BEHAVIOR TREE")
        return BehaviourStatus.Failure
    end
end
