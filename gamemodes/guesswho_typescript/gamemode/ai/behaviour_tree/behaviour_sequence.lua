--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
-- Lua Library inline imports
__TS__ArrayPush = function(arr, ...)
    local items = ({...});
    for ____TS_index = 1, #items do
        local item = items[____TS_index];
        arr[(#arr) + 1] = item;
    end
    return #arr;
end;

BehaviourSequence = BehaviourSequence or {};
BehaviourSequence.__index = BehaviourSequence;
BehaviourSequence.prototype = BehaviourSequence.prototype or {};
BehaviourSequence.prototype.__index = BehaviourSequence.prototype;
BehaviourSequence.prototype.constructor = BehaviourSequence;
BehaviourSequence.new = function(...)
    local self = setmetatable({}, BehaviourSequence.prototype);
    self:____constructor(...);
    return self;
end;
BehaviourSequence.prototype.____constructor = function(self)
    self.children = {};
    self.currentChildID = 0;
end;
BehaviourSequence.prototype.addChild = function(self, child)
    __TS__ArrayPush(self.children, child);
end;
BehaviourSequence.prototype.tick = function(self)
    while true do
        do
            local currentChild = self.children[self.currentChildID + 1];
            local status = currentChild:tick();
            if status == BehaviourStatus.Failure then
                self.currentChildID = 0;
                return status;
            elseif status == BehaviourStatus.Running then
                return status;
            end
            self.currentChildID = self.currentChildID + 1;
            if self.currentChildID == (#self.children) then
                self.currentChildID = 0;
                return BehaviourStatus.Success;
            end
        end
        ::__continue4::
    end
end;
