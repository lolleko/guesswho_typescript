
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
local BehaviourParallel = BehaviourParallel or {}
BehaviourParallel.__index = BehaviourParallel
function BehaviourParallel.new(construct, ...)
    local instance = setmetatable({}, BehaviourParallel)
    if construct and BehaviourParallel.constructor then BehaviourParallel.constructor(instance, ...) end
    return instance
end
function BehaviourParallel.constructor(self,requiredToFail,requiredToSucceed)
    self.children = {}
    self.requiredToFail = requiredToFail
    self.requiredToSucceed = requiredToSucceed
end
function BehaviourParallel.addChild(self,child)
    __TS__ArrayPush(self.children, child)
end
function BehaviourParallel.tick(self)
    local successCounter = 0

    local failCounter = 0

    for _, child in ipairs(self.children) do
        do
            local result = child:tick()

            if result==BehaviourStatus.Failure then
                failCounter = (failCounter+1)
                if failCounter==self.requiredToFail then
                    return BehaviourStatus.Failure
                end
            end
            if result==BehaviourStatus.Success then
                successCounter = (successCounter+1)
                if failCounter==self.requiredToSucceed then
                    return BehaviourStatus.Success
                end
            end
        end
        ::__continue0::
    end
    if (self.requiredToFail==-1) and (failCounter==#self.children) then
        return BehaviourStatus.Failure
    end
    if (self.requiredToSucceed==-1) and (successCounter==#self.children) then
        return BehaviourStatus.Success
    end
    return BehaviourStatus.Running
end
exports.BehaviourParallel = BehaviourParallel
return exports
