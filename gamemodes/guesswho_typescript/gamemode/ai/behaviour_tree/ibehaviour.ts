interface IBehaviour<T> {
    tick(state: T): BehaviourStatus;
}
