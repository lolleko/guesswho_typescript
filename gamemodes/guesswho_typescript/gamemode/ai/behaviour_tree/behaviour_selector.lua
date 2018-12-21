
-- Lua Library Imports
function __TS__ArrayPush(arr,...)
    local items = { ... }
    local __loopVariable0 = items;
    for i0=1, #__loopVariable0 do
        local item = __loopVariable0[i0];
        do
            arr[(#arr)+1] = item;
        end
    end
    return #arr
end

BehaviourSelector = BehaviourSelector or {}
BehaviourSelector.__index = BehaviourSelector
function BehaviourSelector.new(construct, ...)
    local self = setmetatable({}, BehaviourSelector)
    if construct and BehaviourSelector.constructor then BehaviourSelector.constructor(self, ...) end
    return self
end
function BehaviourSelector.constructor(self)
    self.children = {};
    self.currentChildID = 0;
end
function BehaviourSelector.addChild(self,child)
    __TS__ArrayPush(self.children, child);
end
function BehaviourSelector.tick(self)
    local currentChild = self.children[(self.currentChildID)+1];
    while true do
        do
            local status = currentChild:tick();
            if status==BehaviourStatus.Success then
                self.currentChildID = 0;
                return status
            elseif status==BehaviourStatus.Running then
                return status
            end
            do local __TS_obj, __TS_index = self, "currentChildID"; local __TS_tmp = __TS_obj[__TS_index]; __TS_obj[__TS_index] = (__TS_tmp+(1)); end;
            if self.currentChildID==#self.children then
                self.currentChildID = 0;
                return BehaviourStatus.Failure
            end
        end
        ::__continue0::
    end
end
