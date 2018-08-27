
-- Lua Library Imports
local exports = exports or {}
local ibehaviour0 = include("./ibehaviour.lua")
local IBehaviour = ibehaviour0.IBehaviour
local ibehaviour_composite1 = include("./ibehaviour_composite.lua")
local IBehaviourComposite = ibehaviour_composite1.IBehaviourComposite
local behaviour_status2 = include("./behaviour_status.lua")
local BehaviourStatus = behaviour_status2.BehaviourStatus
local BehaviourTree = BehaviourTree or {}
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
exports.BehaviourTree = BehaviourTree
return exports
