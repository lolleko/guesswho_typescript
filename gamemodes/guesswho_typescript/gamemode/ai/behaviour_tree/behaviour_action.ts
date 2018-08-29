type BehaviourFunction = () => BehaviourStatus;

class BehaviourAction implements IBehaviour {
    private func: BehaviourFunction;

    constructor(func: BehaviourFunction) {
        this.func = func;
    }

    public tick(): BehaviourStatus {
        return this.func();
    }
}
