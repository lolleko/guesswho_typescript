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

BehaviourSelector = BehaviourSelector or {};
BehaviourSelector.__index = BehaviourSelector;
BehaviourSelector.prototype = BehaviourSelector.prototype or {};
BehaviourSelector.prototype.__index = BehaviourSelector.prototype;
BehaviourSelector.prototype.constructor = BehaviourSelector;
BehaviourSelector.new = function(...)
    local self = setmetatable({}, BehaviourSelector.prototype);
    self:____constructor(...);
    return self;
end;
BehaviourSelector.prototype.____constructor = function(self)
    self.children = {};
    self.currentChildID = 0;
end;
BehaviourSelector.prototype.addChild = function(self, child)
    __TS__ArrayPush(self.children, child);
end;
BehaviourSelector.prototype.tick = function(self)
    local currentChild = self.children[self.currentChildID + 1];
    while true do
        do
            local status = currentChild:tick();
            if status == BehaviourStatus.Success then
                self.currentChildID = 0;
                return status;
            elseif status == BehaviourStatus.Running then
                return status;
            end
            self.currentChildID = self.currentChildID + 1;
            if self.currentChildID == (#self.children) then
                self.currentChildID = 0;
                return BehaviourStatus.Failure;
            end
        end
        ::__continue4::
    end
end;
