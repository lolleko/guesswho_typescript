class StateTransition<T>
{
    public fromState: T;
    public toState: T;
    public condition: StateCondition;

    constructor(fromState: T, toState: T, condition?: StateCondition)
    {
        this.fromState = fromState;
        this.toState = toState;
        if (condition)
        {
            this.condition = condition;
        }
        else
        {
            this.condition = () => true;
        }
    }
}
