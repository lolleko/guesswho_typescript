
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

FiniteStateMachine = FiniteStateMachine or {}
FiniteStateMachine.__index = FiniteStateMachine
function FiniteStateMachine.new(construct, ...)
    local self = setmetatable({}, FiniteStateMachine)
    if construct and FiniteStateMachine.constructor then FiniteStateMachine.constructor(self, ...) end
    return self
end
function FiniteStateMachine.constructor(self,startState)
    self.startState = startState;
    self.currentState = startState;
    self.transitions = {};
    self.enterCallbacks = {};
    self.leaveCallbacks = {};
end
function FiniteStateMachine.AddTransition(self,fromState,toState,condition)
    local newTransition = StateTransition.new(true,fromState,toState,condition);
    local i = 0
    while(i<#self.transitions) do
        do
            local transition = self.transitions[(i)+1];
            if (transition.fromState==fromState) and (transition.toState==toState) then
                self.transitions[(i)+1] = newTransition;
                return
            end
        end
        ::__continue0::
        i = (i+1)
    end
    __TS__ArrayPush(self.transitions, newTransition);
end
function FiniteStateMachine.CanJump(self,fromState,toState)
    local __loopVariable1 = self.transitions;
    for i1=1, #__loopVariable1 do
        local transition = __loopVariable1[i1];
        do
            if (transition.fromState==fromState) and (transition.toState==toState) then
                return transition.condition()
            end
        end
        ::__continue1::
    end
    return false
end
function FiniteStateMachine.Jump(self,toState)
    if self:CanJump(self.currentState,toState) then
        local prevState = self.currentState;
        if self.leaveCallbacks[tostring(self.currentState)] then
            self.leaveCallbacks[tostring(self.currentState)](toState);
        end
        self.currentState = toState;
        if self.enterCallbacks[tostring(self.currentState)] then
            self.enterCallbacks[tostring(self.currentState)](prevState);
        end
        return true
    end
    return false
end
function FiniteStateMachine.GetCurrentState(self)
    return self.currentState
end
function FiniteStateMachine.IsInState(self,state)
    return self.currentState==state
end
function FiniteStateMachine.Reset(self)
    self.currentState = self.startState;
end
