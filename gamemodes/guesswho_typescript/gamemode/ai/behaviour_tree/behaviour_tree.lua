--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
BehaviourTree = BehaviourTree or {};
BehaviourTree.__index = BehaviourTree;
BehaviourTree.prototype = BehaviourTree.prototype or {};
BehaviourTree.prototype.__index = BehaviourTree.prototype;
BehaviourTree.prototype.constructor = BehaviourTree;
BehaviourTree.new = function(...)
    local self = setmetatable({}, BehaviourTree.prototype);
    self:____constructor(...);
    return self;
end;
BehaviourTree.prototype.____constructor = function(self, root)
    self.root = root;
end;
BehaviourTree.prototype.setRoot = function(self, root)
    self.root = root;
end;
BehaviourTree.prototype.tick = function(self)
    if self.root then
        return self.root:tick();
    else
        print("TICKING EMPTY BEHAVIOR TREE");
        return BehaviourStatus.Failure;
    end
end;
