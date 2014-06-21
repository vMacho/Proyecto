class BabosaExplosivaController extends AIController;
 
var Actor target;
var Vector TempDest;
var float TimerAttack;
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    InitNavigationHandle();
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition); 
    Pawn.SetMovementPhysics();
}

event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    //DumpStateStack();
}

function ResetMove()
{
    TempDest = vect(0,0,0);
    Velocity = vect(0,0,0);
    Acceleration = vect(0,0,0);
    MoveTimer = -1.0;
}

function bool FindNavMeshPath(Actor targetAct)
{
    // Clear cache and constraints
    NavigationHandle.PathConstraintList = none;
    NavigationHandle.PathGoalList = none;

    // Create constraints
    class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,  targetAct);
    class'NavMeshGoal_At'.static.AtActor( NavigationHandle, targetAct, 32 );

    // Find path
    return NavigationHandle.FindPath();
}

/******************************************************************
 *                      ESTADOS
 *****************************************************************/

/******** ESTADO Idle *************/
auto state Idle
{
    local float playerDistance;
    event SeePlayer (Pawn Seen)
    {
        super.SeePlayer(Seen);
        target = Seen;
        playerDistance = VSize(Pawn.Location - target.Location);
        
        if(playerDistance > MocoPawn(Pawn).AttackRange && playerDistance < MocoPawn(Pawn).distanceTosee) GotoState('Follow');
        else if(playerDistance < MocoPawn(Pawn).AttackRange) GotoState('Attack');
    }
Begin:
    BabosaExplosivaPawn(Pawn).SetAnimationState(ST_Normal);
    ResetMove();
    target = none;
}
/*********************************/

/******** ESTADO Follow *************/
state Follow
{
    local float playerDistance;

    ignores SeePlayer;
Begin:
    BabosaExplosivaPawn(Pawn).SetAnimationState(ST_Normal);
    
    playerDistance = VSize(Pawn.Location - target.Location);
        
    if(playerDistance > MocoPawn(Pawn).AttackRange && playerDistance < MocoPawn(Pawn).distanceTosee)
    {
        if( NavigationHandle.ActorReachable( target) ) MoveToward( target, target, ,true );
        else if( FindNavMeshPath(target) )
        {
            NavigationHandle.SetFinalDestination(target.Location);
            
            if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ) MoveTo( TempDest, target ); //Nos movemos hasta el primer nodo del Path
            else MoveTo(Pawn.Location, Pawn);
        }
        else GotoState('Idle');

        goto 'Begin';
    }
    else if(playerDistance < MocoPawn(Pawn).AttackRange) GotoState('Attack');
    else GotoState('Idle');
    
}
/*********************************/

/******** ESTADO Explode *************/
state Explode
{
    event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);

        WorldInfo.MyDecalManager.SpawnDecal (DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak', // UMaterialInstance used for this decal.
                                         Pawn.Location, // Decal spawned at the hit location.
                                         Rotator(vect(0.0f,0.0f,-1.0f)), // Orient decal into the surface.
                                         254, 254, // Decal size in tangent/binormal directions.
                                         512, // Decal size in normal direction.
                                         false, // If TRUE, use "NoClip" codepath.
                                         FRand() * 360, // random rotation
                                         ,true ,true //bProjectOnTerrain y bProjectOnSkeletalMeshes
                            );

        Pawn.Destroy();
    }
Begin:
    MoveTo(Pawn.Location, Pawn);
    BabosaExplosivaPawn(Pawn).SetAnimationState(ST_Die);    
}
/*********************************/

/******** ESTADO Attack *************/
state Attack
{
    local float playerDistance;
    local Vector playerpos;
    ignores SeePlayer;

    event Tick(float DeltaTime)
    {
        super.Tick(DeltaTime);

        TimerAttack += DeltaTime;
        
        if(TimerAttack >= MocoPawn(Pawn).AttackTime) Shoot();
    }

    function Shoot()
    {
        local AreaEnemiga bola;

        if(target != none)
        {
            TimerAttack = 0;

            /*Spawn(MocoPawn(Pawn).bulletClass,,, playerpos);*/

            bola = Spawn(class 'AreaEnemiga',,,target.Location);
            bola.Constructor(300,300,false,false,1,1,4,DecalMaterial'Decals.Materials.Area_Ciruclar',0,ParticleSystem'Murosuelo.Particles.Muro_part',3);
            bola.targetPoint = target.Location;
            bola.emitterPawn = pawn;

            
            playerDistance = VSize(Pawn.Location - target.Location);

            if( playerDistance <= MocoPawn(Pawn).AttackRange ) GotoState('Attack');
            else GotoState('Idle');
        }
    }

Begin:
    BabosaExplosivaPawn(Pawn).SetAnimationState(ST_Attack);
    playerpos = target.Location;
    /*WorldInfo.MyDecalManager.SpawnDecal (DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak', // UMaterialInstance used for this decal.
                                         playerpos, // Decal spawned at the hit location.
                                         Rotator(vect(0.0f,0.0f,-1.0f)), // Orient decal into the surface.
                                         254, 254, // Decal size in tangent/binormal directions.
                                         512, // Decal size in normal direction.
                                         false, // If TRUE, use "NoClip" codepath.
                                         FRand() * 360, // random rotation
                                         ,true ,true, //bProjectOnTerrain y bProjectOnSkeletalMeshes
                                         ,,,MocoPawn(Pawn).AttackTime + 1
                            );*/
}
/*********************************/

DefaultProperties
{
    TimerAttack = 0;
}