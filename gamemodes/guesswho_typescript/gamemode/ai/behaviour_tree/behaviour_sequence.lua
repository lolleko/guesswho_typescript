
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

local exports = exports or {}
local ibehaviour0 = include("./ibehaviour.lua")
local IBehaviour = ibehaviour0.IBehaviour
local ibehaviour_composite1 = include("./ibehaviour_composite.lua")
local IBehaviourComposite = ibehaviour_composite1.IBehaviourComposite
local behaviour_status2 = include("./behaviour_status.lua")
local BehaviourStatus = behaviour_status2.BehaviourStatus
local BehaviourSequence = BehaviourSequence or {}
BehaviourSequence.__index = BehaviourSequence
function BehaviourSequence.new(construct, ...)
    local instance = setmetatable({}, BehaviourSequence)
    if construct and BehaviourSequence.constructor then BehaviourSequence.constructor(instance, ...) end
    return instance
end
function BehaviourSequence.constructor(self)
    self.children = {}
    self.currentChildID = 0
end
function BehaviourSequence.addChild(self,child)
    __TS__ArrayPush(self.children, child)
end
function BehaviourSequence.tick(self)
    local currentChild = self.children[self.currentChildID+1]

    while true do
        do
            local status = currentChild:tick()

            if status==BehaviourStatus.Failure then
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
                return BehaviourStatus.Success
            end
        end
        ::__continue0::
    end
end
exports.BehaviourSequence = BehaviourSequence
return exports
