
-- Lua Library Imports
function __TS__ArrayPush(arr,...)
    local items = { ... }
    local i = 0
    while(i<#items) do
        do
            arr[#arr+1] = items[i+1]
        end
        i = (i+1)
    end
    return #arr
end

BehaviourSelector = BehaviourSelector or {}
BehaviourSelector.__index = BehaviourSelector
function BehaviourSelector.new(construct, ...)
    local instance = setmetatable({}, BehaviourSelector)
    if construct and BehaviourSelector.constructor then BehaviourSelector.constructor(instance, ...) end
    return instance
end
function BehaviourSelector.constructor(self)
    self.children = {}
    self.currentChildID = 0
end
function BehaviourSelector.addChild(self,child)
    __TS__ArrayPush(self.children, child)
end
function BehaviourSelector.tick(self,state)
    local currentChild = self.children[self.currentChildID+1]

    while true do
        do
            local status = currentChild:tick(state)

            if status==BehaviourStatus.Success then
                self.currentChildID = 0
                return status
            else
                if status==BehaviourStatus.Running then
                    return status
                end
            end
            self.currentChildID = (self.currentChildID+1)
            if self.currentChildID==#self.children then
                self.currentChildID = 0
                return BehaviourStatus.Failure
            end
        end
        ::__continue0::
    end
end
