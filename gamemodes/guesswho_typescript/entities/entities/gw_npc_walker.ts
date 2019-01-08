AddCSLuaFile();

/**
 * Debug: https://developer.valvesoftware.com/wiki/Nb_debug
 */

const eyeGlow = new IMaterial("sprites/redglow1");
const white = Color(255, 255, 255, 255);

/** @extension ENT */
class GWNPCWalker extends NextBot {

    public get LastAct(): ACT {
        return this.GetDTInt(0);
    }

    public set LastAct(act: ACT) {
        this.SetDTInt(0, act);
    }

    public get WalkerColorIndex(): number {
        return this.GetDTInt(1);
    }

    public set WalkerColorIndex(index: number) {
        this.SetDTInt(1, index);
    }

    public get WalkerModelIndex(): number {
        return this.GetDTInt(2);
    }

    public set WalkerModelIndex(index: number) {
        this.SetDTInt(2, index);
    }

    public get Locomotion(): CLuaLocomotion {
        return this.loco;
    }

    public Base: string = "base_nextbot";

    private walkerColor: Vector;

    private GetPlayerColor: () => Vector;

    private loco: CLuaLocomotion;

    private isJumping: boolean;

    private nextPossibleJump: number;

    private nextPossibleSettingsChange: number;

    private shouldCrouch: boolean;

    private isStuck: boolean;

    private isSitting: boolean;

    private sitUntil: number;

    private isDancing: boolean;

    private isFirstPath: boolean;

    private stuckTime: number;

    private stuckPos: Vector;

    private behaviourTree: BehaviourTree;

    private currentPath: PathFollower;
    private hasPath: boolean;
    private currentPathMaxAge: number;

    private dogeUntil: number;
    private dogePos: Vector;
    private isDoging: boolean;

    private boundsSize: number = 10;

    private targetPos: Vector;

    public Sit(duration: number = math.random(10, 30)): void {
        this.isSitting = true;
        this.sitUntil = CurTime() + duration;
    }

    public SetCrouchCollision(state: boolean): void {
        if (state) {
            this.SetCollisionBounds(new Vector(-this.boundsSize, -this.boundsSize, 0), new Vector(this.boundsSize, this.boundsSize, 36));
        } else {
            this.SetCollisionBounds(new Vector(-this.boundsSize, -this.boundsSize, 0), new Vector(this.boundsSize, this.boundsSize, 70));
        }
    }

    public Doge(dogePos: Vector, maxDuration: number = 0.35): void {
        this.dogePos = dogePos;
        this.dogeUntil = CurTime() + maxDuration;
        this.isDoging = true;
    }

    public Jump(): void {
        if (this.isJumping || this.nextPossibleJump > CurTime()) {
            return;
        }

        this.loco.Jump();
        this.isJumping = true;
        this.nextPossibleJump = CurTime() + 3;
    }

    public SetupDataTables(): void {
        this.DTVar("Int", 0, "LastAct");
        this.DTVar("Int", 1, "WalkerColorIndex");
        this.DTVar("Int", 2, "WalkerModelIndex");
    }

    public Initialize(): void {
        const models = GWConfigManager.GetInstance().Data.HiderModels;

        if (SERVER) {
            this.WalkerModelIndex = math.random(models.length) - 1;
        }

        this.SetModel(models[this.WalkerModelIndex]);

        const walkerColors = GWConfigManager.GetInstance().Data.WalkerColors;

        if (SERVER) {
            this.WalkerColorIndex = math.random(walkerColors.length) - 1;
        }

        const walkerClr = walkerColors[this.WalkerColorIndex];

        this.walkerColor = new Vector(walkerClr.r / 255, walkerClr.g / 255, walkerClr.b / 255);

        this.GetPlayerColor = () => this.walkerColor;

        this.SetHealth(100);

        if (SERVER) {
            this.SetCollisionBounds(new Vector(-this.boundsSize, -this.boundsSize, 0), new Vector(this.boundsSize, this.boundsSize, 70));
            this.loco.SetStepHeight(20);
            this.loco.SetJumpHeight(68);
            this.loco.SetDesiredSpeed(100);
            this.nextPossibleJump = CurTime() + 8;
            this.nextPossibleSettingsChange = CurTime() + 10;
            this.dogeUntil = CurTime();
            this.isJumping = false;
            this.shouldCrouch = false;
            this.isFirstPath = true;
        }
    }

    // public Draw(): void {
    //     this.DrawModel();
    //     let leftEye = this.GetAttachment(this.LookupAttachment("lefteye"));
    //     let rightEye = this.GetAttachment(this.LookupAttachment("righteye"));

    //     if (!leftEye) {
    //         leftEye = this.GetAttachment(this.LookupAttachment("left_eye"));
    //         rightEye = this.GetAttachment(this.LookupAttachment("right_eye"));
    //     }

    //     let leftEyePos: Vector | undefined;
    //     let rightEyePos: Vector | undefined;

    //     if (leftEye && rightEye) {
    //         leftEyePos = leftEye.Pos as any + this.GetForward();
    //         rightEyePos = rightEye.Pos as any + this.GetForward();
    //     } else {
    //         const eyes = this.GetAttachment(this.LookupAttachment("eyes"));
    //         if (eyes) {
    //             leftEyePos = (this.GetRight() as any) * -1.5 + (this.GetForward() as any) * 0.5 as any;
    //             rightEyePos = (this.GetRight() as any) * 1.5 + (this.GetForward() as any) * 0.5 as any;
    //         }
    //     }

    //     if (leftEyePos && rightEyePos) {
    //         render.SetMaterial(eyeGlow);
    //         render.DrawSprite(leftEyePos, 4, 4, white);
    //         render.DrawSprite(rightEyePos, 4, 4, white);
    //     }
    // }

    public Think(): boolean {
        if (SERVER) {
            const doors = ents.FindInSphere(this.GetPos(), 60);
            for (const door of doors) {
                const doorClass = door.GetClass();
                if (doorClass === "func_door"
                    || doorClass === "func_door_rotating"
                    || doorClass === "prop_door_rotating") {
                    door.Fire("Unlock", "", 0);
                    door.Fire("Open", "", 0.01);
                    door.SetCollisionGroup(COLLISION_GROUP.COLLISION_GROUP_DEBRIS);
                }
            }
            if (this.isStuck && CurTime() > this.stuckTime + 15 && this.stuckPos.DistToSqr(this.GetPos()) < 25) {
                const spawnPoints = (GAMEMODE as GWGamemodeSH).Gamerules.SpawnPoints;
                const spawnPoint = spawnPoints[math.random(spawnPoints.length) - 1].GetPos();
                this.SetPos(spawnPoint);
                this.isStuck = false;
                MsgN(`Nextbot [${tostring(this.EntIndex())}][${this.GetClass()}]` +
                    "Got Stuck for over 15 seconds and will be repositioned, if this error gets spammed" +
                    "you might want to consider the following: Edit the navmesh or lower the walker amount.");
            }
            if (this.isStuck && this.stuckPos.DistToSqr(this.GetPos()) > 400) {
                this.isStuck = false;
            }
            if (this.GetSolidMask() === MASK.MASK_NPCSOLID_BRUSHONLY) {
                const entsInBox = ents.FindInBox(this.GetPos() as any + new Vector(-this.boundsSize, -this.boundsSize, 0),
                                                 this.GetPos() as any + new Vector(this.boundsSize, this.boundsSize, 70));
                const occupied = entsInBox.some(ent => ent.GetClass() === "npc_walker" && ent !== this);
                if (!occupied) {
                    this.SetSolidMask(MASK.MASK_NPCSOLID);
                }
            }
        }
        return false;
    }

    public RunBehaviour(): void {
        this.behaviourTree = new BehaviourTreeBuilder()
            .sequence()
            .action(() => {
                if (this.nextPossibleSettingsChange > CurTime()) {
                    return BehaviourStatus.Success;
                }
                const rand = math.random(1, 100);
                if (rand > 0 && rand < 15) {
                    this.loco.SetDesiredSpeed(200);
                } else if (rand > 15 && rand < 22) {
                    const entsAround = ents.FindInSphere(this.GetPos(), 300);
                    const walkersAround = entsAround.filter(ent => ent.GetClass() === this.GetClass());
                    const doorsAround = entsAround.filter(
                        ent => ent.GetClass() === "func_door" || ent.GetClass() === "func_door_rotating" || ent.GetClass() === "prop_door_rotating");
                    if (walkersAround.length < 3 && doorsAround.length === 0) {
                        this.Sit(math.random(10, 60));
                    }
                } else {
                    this.loco.SetDesiredSpeed(100);
                }

                this.nextPossibleSettingsChange = CurTime() + 5;
                // Always succed we jsut set soem settings here
                return BehaviourStatus.Success;
            })
            .action(() => {
                if (!this.isSitting) {
                    return BehaviourStatus.Success;
                }

                this.SetSequence("sit_zen");
                this.SetCrouchCollision(true);

                if (this.sitUntil < CurTime()) {
                    this.SetCrouchCollision(false);
                    this.isSitting = false;
                    return BehaviourStatus.Success;
                }

                return BehaviourStatus.Running;
            })
            .action(() => {
                if (this.hasPath && this.currentPath.IsValid()) {
                    return BehaviourStatus.Success;
                }

                let radius = 2200;
                if (this.isFirstPath) {
                    radius = 8000;
                }

                const navs = navmesh.Find(this.GetPos(), radius, 200, 200);
                const nav = navs[math.random(navs.length) - 1];

                if (!IsValid(nav)) {
                    return BehaviourStatus.Failure;
                }
                if (nav.IsUnderwater()) {
                    return BehaviourStatus.Failure;
                }
                this.targetPos = nav.GetRandomPoint();

                this.currentPath = Path("Follow");
                this.currentPath.SetMinLookAheadDistance(10);
                this.currentPath.SetGoalTolerance(10);
                // dont use custom this.PathGenerator() for now for performance reasons
                this.currentPath.Compute(this, this.targetPos);

                if (this.isFirstPath) {
                    this.currentPathMaxAge = 20;
                } else {
                    this.currentPathMaxAge = math.Clamp(this.currentPath.GetLength() / 90, 0.1, 12);
                }

                if (!this.currentPath.IsValid()) {
                    return BehaviourStatus.Failure;
                }

                this.isFirstPath = false;
                this.hasPath = true;

                return BehaviourStatus.Success;
            })
            .action(() => {
                // If the path is no longer valid we have reached our goal
                if (!this.currentPath.IsValid()) {
                    return BehaviourStatus.Success;
                }

                if (this.isDoging && this.dogeUntil > CurTime() && this.dogePos.DistToSqr(this.GetPos()) > 100) {
                    // @ts-ignore
                    const dogeDirection = (this.dogePos - this.GetPos()).GetNormalized();
                    this.loco.FaceTowards(this.dogePos);
                    // @ts-ignore
                    this.loco.SetVelocity(dogeDirection * 80);
                    // @ts-ignore
                    this.loco.Approach(this.dogePos, 1);
                    return BehaviourStatus.Running;
                } else {
                    this.isDoging = false;
                }

                const goal = this.currentPath.GetCurrentGoal();
                const distToGoal = this.GetPos().Distance(goal.pos);

                if (goal.type === 3) {
                    this.isJumping = true;
                    this.loco.JumpAcrossGap(goal.pos, goal.forward);
                } else if (!goal.area.HasAttributes(NAV_MESH.NAV_MESH_NO_JUMP | NAV_MESH.NAV_MESH_STAIRS)) {
                    if (goal.type === 2 && distToGoal  < 30) {
                        this.Jump();
                    } else {
                        const scanDist = 25;
                        // @ts-ignore
                        const scanPoint = this.currentPath.GetClosestPosition(this.EyePos()[0] + this.loco.GetGroundMotionVector() * scanDist);
                        if (math.abs(this.GetPos().z - scanPoint.z) > this.loco.GetStepHeight() && distToGoal  < 300) {
                            this.Jump();
                        }
                    }
                }

                this.currentPath.Update(this);

                // this.currentPath.Draw();

                if (this.loco.IsStuck()) {
                    this.HandleStuck();
                }

                if (this.currentPath.GetAge() > this.currentPathMaxAge) {
                    return BehaviourStatus.Failure;
                }

                return BehaviourStatus.Running;
            })
            .finish()
            .build();
        while (true) {
            this.behaviourTree.tick();
            coroutine.yield();
        }
    }

    public BodyUpdate(): void {
        let idealAct = ACT.ACT_HL2MP_IDLE;

        // if act != this:GetLastAct() then act = this:GetLastAct() this:StartActivity(act) end

        const velocity = this.GetVelocity();

        const len2d = velocity.Length2D();

        if ( len2d > 150 ) {
            idealAct = ACT.ACT_HL2MP_RUN;
        } else if ( len2d > 10 ) {
            idealAct = ACT.ACT_HL2MP_WALK;
        }

        if (this.isJumping && this.WaterLevel() <= 0) {
            idealAct = ACT.ACT_HL2MP_JUMP_SLAM;
        }

        if (this.GetActivity() !== idealAct && !this.isSitting && !this.isDancing) {
            this.StartActivity(idealAct);
        }

        if (idealAct === ACT.ACT_HL2MP_RUN || idealAct === ACT.ACT_HL2MP_WALK) {

            this.BodyMoveXY();

        }

        this.FrameAdvance();
    }

    public OnLandOnGround(ent: Entity): void {
        this.isJumping = false;
        this.SetCrouchCollision(false);
    }

    public OnLeaveGround(ent: Entity): void {
        this.isJumping = true;
        this.SetCrouchCollision(true);
    }

    public OnContact(ent: Entity): void {
        if (ent.GetClass() === this.GetClass() || ent.IsPlayer()) {
            if (math.abs(this.GetPos().z - ent.GetPos().z) > 20) {
                this.SetSolidMask(MASK.MASK_NPCSOLID_BRUSHONLY);
            } else if (!this.isDoging) {
                // @ts-ignore
                const dogeDirection: Vector = (ent.GetPos() - this.GetPos()).GetNormalized();
                dogeDirection.Rotate(new Angle(0, math.random(85, 95), 0));
                dogeDirection.z = 0;
                // @ts-ignore
                this.Doge(this.GetPos() + dogeDirection * 200, math.random(0.2, 0.35));
            }
        }
        if  (ent.GetClass() === "prop_physics_multiplayer"
             || ent.GetClass() === "prop_physics"
             && !GetConVar("gw_propfreeze_enabled").GetBool()) {
            // this.loco:Approach( this:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
            const phys = ent.GetPhysicsObject();
            if (!IsValid(phys)) {
                return;
            }
            // @ts-ignore
            const force: Vector = (ent.GetPos() - this.GetPos()).GetNormalized() * 3 * this.GetVelocity().Length2D();
            force.z = 0;
            phys.ApplyForceCenter(force);
            DropEntityIfHeld( ent );
        }
        if (ent.GetClass() === "func_breakable" || ent.GetClass() === "func_breakable_surf") {
            ent.Fire("Shatter");
        }
        // if we are stuck and our bbox overlaps with this npc nocollide
        if (this.isStuck && (ent.GetClass() === this.GetClass() || ent.IsPlayer())) {

            const thisMin: Vector = this.OBBMins() as any + this.GetPos();
            const thisMax: Vector = this.OBBMaxs() as any + this.GetPos();

            const entMin: Vector = ent.OBBMins() as any + ent.GetPos();
            const entMax: Vector = ent.OBBMaxs() as any + ent.GetPos();

            // 2d box overlap test
            if (!(thisMax.x < entMin.x || thisMin.x > entMax.x || thisMax.y < entMin.y || thisMin.y > entMax.y)) {
                this.SetSolidMask(MASK.MASK_NPCSOLID_BRUSHONLY);
            }
        }
    }

    public OnStuck(): void {
        if (!this.isStuck) {
            this.stuckTime = CurTime();
            this.isStuck = true;
        }
        this.stuckPos = this.GetPos();

        // if our velocity is zero and we are pathing, try to usntuck
        if (this.hasPath && !this.isDoging && this.loco.GetVelocity().Length2DSqr() < 0.1) {
            // @ts-ignore
            const randomDir: Vector = VectorRand() * 100;
            randomDir.z = 0;
            // @ts-ignore
            this.Doge(this.GetPos() + randomDir, 0.4);
        }
    }
    public OnUnStuck(): void {
        if (this.stuckPos.DistToSqr(this.GetPos()) > 100 || this.isSitting) {
            this.isStuck = false;
        }
    }

    public Use(activator: Entity, caller: Entity, useType: USE, value: number): void {
        if ((caller as GWPlayer).IsHider() && GetConVar( "gw_changemodel_hiding" ).GetBool()) {
            this.SetModel(this.GetModel());
        }
    }

    private PathGenerator(): (area: CNavArea, fromArea: CNavArea, ladder: CNavLadder, elevator: any, length: number) => number {
        return (area: CNavArea, fromArea: CNavArea, ladder: CNavLadder, elevator: any, length: number) => {
            if (!IsValid(fromArea)) {
                // first area in path, no cost
                return 0;
            }

            if (!this.loco.IsAreaTraversable(area)) {
                // our locomotor says we can't move here
                return -1;
            }

            // compute distance traveled along path so far
            let dist = 0;

            if ( IsValid( ladder ) ) {
                dist = ladder.GetLength();
            } else if ( length > 0 ) {
                // optimization to avoid recomputing length
                dist = length;
            } else {
                dist = area.GetCenter().Distance(fromArea.GetCenter());
            }

            let cost = dist + fromArea.GetCostSoFar();

            // check height change
            const deltaZ = fromArea.ComputeAdjacentConnectionHeightChange(area);
            if (deltaZ >= this.loco.GetStepHeight()) {
                if ( deltaZ >= this.loco.GetMaxJumpHeight() - 20) {
                    return -1;
                }
                cost = cost + deltaZ;
            } else if ( deltaZ < -this.loco.GetDeathDropHeight()) {
                // too far to drop
                return -1;
            }

            return cost;
        };
    }
}
