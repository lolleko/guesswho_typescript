type BehaviourFunction<T> = (state: T) => BehaviourStatus;

class BehaviourAction<T> implements IBehaviour<T> {
    private func: BehaviourFunction<T>;

    constructor(func: BehaviourFunction<T>) {
        this.func = func;
    }

    public tick(state: T): BehaviourStatus {
        return this.func(state);
    }
}
