import {IBehaviour} from "./ibehaviour";

import {BehaviourStatus} from "./behaviour_status";

export type BehaviourFunction<T> = (state: T) => BehaviourStatus;

export class BehaviourAction<T> implements IBehaviour<T>
{
    private func: BehaviourFunction<T>;

    constructor(func: BehaviourFunction<T>)
    {
        this.func = func;
    }

    public tick(state: T): BehaviourStatus
    {
        return this.func(state);
    }
}
