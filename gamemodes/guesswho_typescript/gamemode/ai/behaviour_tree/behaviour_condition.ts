type BehaviourConditionFunction<T> = (state: T) => boolean;

class BehaviourCondition<T> implements IBehaviour<T> {
    private func: BehaviourConditionFunction<T>;

    constructor(func: BehaviourConditionFunction<T>) {
        this.func = func;
    }

    public tick(state: T): BehaviourStatus {
        return this.func(state) ? BehaviourStatus.Success : BehaviourStatus.Failure;
    }
}
