interface IBehaviourComposite<T> extends IBehaviour<T> {
    addChild(child: IBehaviour<T>): void;
}
