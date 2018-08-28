AddCSLuaFile();

/** !Extension ENT */
class GWNPCTest extends NextBot {
    public Base: string = "base_nextbot";

    private behaviourTree: BehaviourTree<GWNPCTest>;

    private currentPath: PathFollower;

    private hasPath: boolean;

    private targetPos: Vector;

    private loco: CLuaLocomotion;

    protected RunBehaviour(): void {
        this.behaviourTree = new BehaviourTreeBuilder<GWNPCTest>()
            .sequence()
                .action(ent => {
                    if (ent.hasPath && ent.currentPath.IsValid()) {
                        return BehaviourStatus.Success;
                    }

                    ent.targetPos = VectorRand() as any * 200 + (ent.GetPos() as any);
                    ent.currentPath = Path("Follow");
                    ent.currentPath.SetMinLookAheadDistance(300);
                    ent.currentPath.SetGoalTolerance(20);
                    ent.currentPath.Compute(this, ent.targetPos);

                    if (!ent.currentPath.IsValid()) {
                        return BehaviourStatus.Failure;
                    }

                    return BehaviourStatus.Success;
                })
                .action(ent => {
                    // If the path is no longer valid we have reached our goal
                    if (!ent.currentPath.IsValid()) {
                        return BehaviourStatus.Success;
                    }
                    ent.currentPath.Update(this);

                    // Draw the path (only visible on listen servers or single player)
                    ent.currentPath.Draw();

                    // If we're stuck then call the HandleStuck function and abandon
                    if (this.loco.IsStuck()) {
                        this.HandleStuck();
                    }

                    // If they set maxage on options then make sure the path is younger than it
                    if (this.currentPath.GetAge() > 10) {
                        return BehaviourStatus.Failure;
                    }

                    // If they set repath then rebuild the path every x seconds
                    // if ( options.repath ) then
                    //    if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
                    // end
                    return BehaviourStatus.Running;
                })
            .finish()
        .build();
        while (true) {
            this.behaviourTree.tick(this);
            coroutine.yield();
        }
    }
}
