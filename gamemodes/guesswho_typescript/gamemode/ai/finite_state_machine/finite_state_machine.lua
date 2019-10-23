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

FiniteStateMachine = FiniteStateMachine or {};
FiniteStateMachine.__index = FiniteStateMachine;
FiniteStateMachine.prototype = FiniteStateMachine.prototype or {};
FiniteStateMachine.prototype.__index = FiniteStateMachine.prototype;
FiniteStateMachine.prototype.constructor = FiniteStateMachine;
FiniteStateMachine.new = function(...)
    local self = setmetatable({}, FiniteStateMachine.prototype);
    self:____constructor(...);
    return self;
end;
FiniteStateMachine.prototype.____constructor = function(self, startState)
    self.startState = startState;
    self.currentState = startState;
    self.transitions = {};
    self.enterCallbacks = {};
    self.leaveCallbacks = {};
end;
FiniteStateMachine.prototype.AddTransition = function(self, fromState, toState, condition)
    local newTransition = StateTransition.new(fromState, toState, condition);
    do
        local i = 0;
        while i < (#self.transitions) do
            do
                local transition = self.transitions[i + 1];
                if (transition.fromState == fromState) and (transition.toState == toState) then
                    self.transitions[i + 1] = newTransition;
                    return;
                end
            end
            ::__continue3::
            i = i + 1;
        end
    end
    __TS__ArrayPush(self.transitions, newTransition);
end;
FiniteStateMachine.prototype.CanJump = function(self, fromState, toState)
    local ____TS_array = self.transitions;
    for ____TS_index = 1, #____TS_array do
        local transition = ____TS_array[____TS_index];
        do
            if (transition.fromState == fromState) and (transition.toState == toState) then
                return transition:condition();
            end
        end
        ::__continue6::
    end
    return false;
end;
FiniteStateMachine.prototype.Jump = function(self, toState)
    if self:CanJump(self.currentState, toState) then
        local prevState = self.currentState;
        if self.leaveCallbacks[tostring(nil, self.currentState)] then
            (function()
                local ____TS_self = self.leaveCallbacks;
                return ____TS_self[tostring(nil, self.currentState)](____TS_self, toState);
            end)();
        end
        self.currentState = toState;
        if self.enterCallbacks[tostring(nil, self.currentState)] then
            (function()
                local ____TS_self = self.enterCallbacks;
                return ____TS_self[tostring(nil, self.currentState)](____TS_self, prevState);
            end)();
        end
        return true;
    end
    return false;
end;
FiniteStateMachine.prototype.GetCurrentState = function(self)
    return self.currentState;
end;
FiniteStateMachine.prototype.IsInState = function(self, state)
    return self.currentState == state;
end;
FiniteStateMachine.prototype.Reset = function(self)
    self.currentState = self.startState;
end;
