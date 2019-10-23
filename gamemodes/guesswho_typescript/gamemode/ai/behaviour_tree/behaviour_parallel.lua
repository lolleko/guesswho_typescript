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

BehaviourParallel = BehaviourParallel or {};
BehaviourParallel.__index = BehaviourParallel;
BehaviourParallel.prototype = BehaviourParallel.prototype or {};
BehaviourParallel.prototype.__index = BehaviourParallel.prototype;
BehaviourParallel.prototype.constructor = BehaviourParallel;
BehaviourParallel.new = function(...)
    local self = setmetatable({}, BehaviourParallel.prototype);
    self:____constructor(...);
    return self;
end;
BehaviourParallel.prototype.____constructor = function(self, requiredToFail, requiredToSucceed)
    if requiredToFail == nil then
        requiredToFail = -1;
    end
    if requiredToSucceed == nil then
        requiredToSucceed = -1;
    end
    self.children = {};
    self.requiredToFail = requiredToFail;
    self.requiredToSucceed = requiredToSucceed;
end;
BehaviourParallel.prototype.addChild = function(self, child)
    __TS__ArrayPush(self.children, child);
end;
BehaviourParallel.prototype.tick = function(self)
    local successCounter = 0;
    local failCounter = 0;
    local ____TS_array = self.children;
    for ____TS_index = 1, #____TS_array do
        local child = ____TS_array[____TS_index];
        do
            local result = child:tick();
            if result == BehaviourStatus.Failure then
                failCounter = failCounter + 1;
                if failCounter == self.requiredToFail then
                    return BehaviourStatus.Failure;
                end
            end
            if result == BehaviourStatus.Success then
                successCounter = successCounter + 1;
                if failCounter == self.requiredToSucceed then
                    return BehaviourStatus.Success;
                end
            end
        end
        ::__continue4::
    end
    if (self.requiredToFail == (-1)) and (failCounter == (#self.children)) then
        return BehaviourStatus.Failure;
    end
    if (self.requiredToSucceed == (-1)) and (successCounter == (#self.children)) then
        return BehaviourStatus.Success;
    end
    return BehaviourStatus.Running;
end;
