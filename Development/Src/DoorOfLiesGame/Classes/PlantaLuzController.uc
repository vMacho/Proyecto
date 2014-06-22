class PlantaLuzController extends AIController;
 
var Actor target;
 
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

/******** ESTADO Do_Nothing *************/
auto state Do_Nothing
{
    local float playerDistance;
    event Tick (float Deltatime)
    {
        super.Tick(Deltatime);

        target = GetALocalPlayerController().Pawn;
        playerDistance = ABS(VSize(Pawn.Location - target.Location));
        
        if(playerDistance < PlantaLuz(Pawn).ActivateRange ) GotoState('Born');
    }

    Begin:
        PlantaLuz(Pawn).SetAnimationState( ST_Do_Nothing );
}
/*********************************/

/******** ESTADO Born *************/
state Born
{
    event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);

        PlantaLuz(Pawn).TurnOnLight();

        GotoState('Idle');
    }

    Begin:
        PlantaLuz(Pawn).SetAnimationState(ST_Born);
}
/*********************************/

/******** ESTADO Idle *************/
state Idle
{
    Begin:
        //PlantaLuz(Pawn).SetAnimationState(ST_Idle);
        `log("DENTRO 3");
}
/*********************************/

/***************************************************************/

DefaultProperties
{
    
}