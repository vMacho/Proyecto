class EnemyController extends AIController;
 
var Actor target;
var Vector TempDest;
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    `Log("Enemy is alive !");
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition); 
    Pawn.SetMovementPhysics();
}
 
auto state Idle
{
    event SeePlayer (Pawn Seen)
    {
        super.SeePlayer(Seen);
        target = Seen;
        
        GotoState('Follow');
    }
    Begin:
}

state Follow
{
    ignores SeePlayer;

    function bool FindNavMeshPath()
    {
        // Clear cache and constraints (ignore recycling for the moment)
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;
 
        // Create constraints
        class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,target );
        class'NavMeshGoal_At'.static.AtActor( NavigationHandle, target,32 );
 
        // Find path
        return NavigationHandle.FindPath();
    }
Begin:
    
    if( NavigationHandle.ActorReachable( target) )
    {
        //FlushPersistentDebugLines();
 
        MoveToward( target,target ); //Direct move
    }
    else if( FindNavMeshPath() )
    {
        NavigationHandle.SetFinalDestination(target.Location);
        //FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);
 
        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
            //DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
            //DrawDebugSphere(TempDest,16,20,255,0,0,true);
 
            MoveTo( TempDest, target );
        }
    }
    else GotoState('Idle'); //No podemos seguirle volvemos al estado Idle
 
    goto 'Begin';
}
 
DefaultProperties
{
    
}