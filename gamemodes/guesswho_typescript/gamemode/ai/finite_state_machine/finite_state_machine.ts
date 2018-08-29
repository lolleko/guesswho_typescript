type StateCondition = () => boolean;
type StateEnterCallback<T> = (prevState: T) => void;
type StateLeaveCallback<T> = (newState: T) => void;

// Hack to convert enums to string
declare function tostring(obj: any): string;

class FiniteStateMachine<T>
{
    private startState: T;
    private currentState: T;
    private transitions: Array<StateTransition<T>>;

    private enterCallbacks: {[state: string]: StateEnterCallback<T>};
    private leaveCallbacks: {[state: string]: StateLeaveCallback<T>};

    constructor(startState: T)
    {
        this.startState = startState;
        this.currentState = startState;
        this.transitions = [];
        this.enterCallbacks = {};
        this.leaveCallbacks = {};
    }

    public AddTransition(fromState: T, toState: T, condition?: StateCondition)
    {
        const newTransition = new StateTransition<T>(fromState, toState, condition);
        for (let i = 0; i < this.transitions.length; i++)
        {
            const transition = this.transitions[i];
            if (transition.fromState === fromState && transition.toState === toState)
            {
                // overwrite if already exists
                this.transitions[i] = newTransition;
                return;
            }
        }
        this.transitions.push(newTransition);
    }

    public CanJump(fromState: T, toState: T): boolean
    {
        for (const transition of this.transitions)
        {
            // check if transition exists
            if (transition.fromState === fromState && transition.toState === toState)
            {
                // check condition
                return transition.condition();
            }
        }
        return false;
    }

    public Jump(toState: T): boolean
    {
        if (this.CanJump(this.currentState, toState))
        {
            const prevState = this.currentState;
            if (this.leaveCallbacks[tostring(this.currentState)])
            {
                this.leaveCallbacks[tostring(this.currentState)](toState);
            }
            this.currentState = toState;
            if (this.enterCallbacks[tostring(this.currentState)])
            {
                this.enterCallbacks[tostring(this.currentState)](prevState);
            }
            return true;
        }
        return false;
    }

    public GetCurrentState(): T
    {
        return this.currentState;
    }

    public IsInState(state: T): boolean
    {
        return this.currentState === state;
    }

    public Reset()
    {
        this.currentState = this.startState;
    }
}
