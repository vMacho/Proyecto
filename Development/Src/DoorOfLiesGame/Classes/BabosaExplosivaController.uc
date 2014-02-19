class BabosaExplosivaController extends AIController;
 
var Actor target;
var Vector TempDest;
 
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
        
        if(playerDistance > HumanoidPawn(Pawn).WeaponRange && playerDistance < HumanoidPawn(Pawn).distanceTosee) GotoState('Follow');

        //else GotoState('Attack');
    }
Begin:
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
 
    if( NavigationHandle.ActorReachable( target) ) MoveToward( target, target, ,true );
    else if( FindNavMeshPath(target) )
    {
        NavigationHandle.SetFinalDestination(target.Location);
        
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ) MoveTo( TempDest, target ); //Nos movemos hasta el primer nodo del Path
        else MoveTo(Pawn.Location, Pawn);
    }
    else GotoState('Idle');
    
    playerDistance = VSize(Pawn.Location - target.Location);
        
    if(playerDistance > HumanoidPawn(Pawn).WeaponRange && playerDistance < HumanoidPawn(Pawn).distanceTosee) goto 'Begin';
    else GotoState('Idle');
    
}
/*********************************/

/******** ESTADO Explode *************/
state Explode
{
    
Begin:
    sleep(1);
    Pawn.Destroy();
    
}
/*********************************/

DefaultProperties
{
    
}