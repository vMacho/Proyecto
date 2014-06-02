class AnfibioPantano_Controller extends AIController;
 
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
        
        if(playerDistance > HumanoidPawn(Pawn).AttackRange && playerDistance < HumanoidPawn(Pawn).distanceTosee) GotoState('Follow');
        else if(playerDistance < HumanoidPawn(Pawn).AttackRange) GotoState('Attack');
    }
Begin:
    AnfibioPantano_Pawn(Pawn).SetAnimationState(ST_Normal);
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
    AnfibioPantano_Pawn(Pawn).SetAnimationState(ST_Normal);
    
    playerDistance = VSize(Pawn.Location - target.Location);
        
    if(playerDistance > HumanoidPawn(Pawn).AttackRange && playerDistance < HumanoidPawn(Pawn).distanceTosee)
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
    else if(playerDistance < HumanoidPawn(Pawn).AttackRange) GotoState('Attack');
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
    AnfibioPantano_Pawn(Pawn).SetAnimationState(ST_Die);    
}
/*********************************/

/******** ESTADO Attack *************/
state Attack
{
    local float playerDistance;
    local Vector playerpos;
    ignores SeePlayer;
    
    event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);

        if( Pawn(target).Health > 0 ) GotoState('Attack');
    }

    function Shoot()
    {
        AnfibioPantano_Pawn(Pawn).SetAnimationState(ST_Attack_distancia);
        WorldInfo.MyDecalManager.SpawnDecal (DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak', // UMaterialInstance used for this decal.
                                             playerpos, // Decal spawned at the hit location.
                                             Rotator(vect(0.0f,0.0f,-1.0f)), // Orient decal into the surface.
                                             254, 254, // Decal size in tangent/binormal directions.
                                             512, // Decal size in normal direction.
                                             false, // If TRUE, use "NoClip" codepath.
                                             FRand() * 360, // random rotation
                                             ,true ,true, //bProjectOnTerrain y bProjectOnSkeletalMeshes
                                             ,,,HumanoidPawn(Pawn).AttackTime + 1
                                );    
    }

    function Hit()
    {
        AnfibioPantano_Pawn(Pawn).SetAnimationState(ST_Attack_cerca);
        WorldInfo.MyDecalManager.SpawnDecal (DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak', // UMaterialInstance used for this decal.
                                             playerpos, // Decal spawned at the hit location.
                                             Rotator(vect(0.0f,0.0f,-1.0f)), // Orient decal into the surface.
                                             254, 254, // Decal size in tangent/binormal directions.
                                             512, // Decal size in normal direction.
                                             false, // If TRUE, use "NoClip" codepath.
                                             FRand() * 360, // random rotation
                                             ,true ,true, //bProjectOnTerrain y bProjectOnSkeletalMeshes
                                             ,,,HumanoidPawn(Pawn).AttackTime + 1
                                );    
    }

Begin:
    playerpos = target.Location;

    playerDistance = VSize(Pawn.Location - target.Location); 

    if( playerDistance > 220 && playerDistance < AnfibioPantano_Pawn(Pawn).AttackRange) Shoot();
    else if( playerDistance < 220 ) Hit();
    else GotoState('Idle');
}
/*********************************/

DefaultProperties
{
    TimerAttack = 0;
}