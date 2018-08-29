type BehaviourConditionFunction = () => boolean;

class BehaviourCondition implements IBehaviour {
    private func: BehaviourConditionFunction;

    constructor(func: BehaviourConditionFunction) {
        this.func = func;
    }

    public tick(): BehaviourStatus {
        return this.func() ? BehaviourStatus.Success : BehaviourStatus.Failure;
    }
}
