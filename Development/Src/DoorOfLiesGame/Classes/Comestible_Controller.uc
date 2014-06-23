class Comestible_Controller extends AIController;
 
var Actor target;
var Vector TempDest;
var float speedFlee;
var int RangoHuir;
var vector LocationRespawn;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    LocationRespawn = location;
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
        
        if(playerDistance < RangoHuir) GotoState('Flee');
    }

    Begin:

        Comestible(Pawn).SetAnimationState(ST_Normal);
        ResetMove();
        target = none;
        GotoState('merodeando');
    
}
/*********************************/

state merodeando
{
    local float rand, timeNextMove, playerDistance;
    local vector randomMove;

    event SeePlayer (Pawn Seen)
    {
        super.SeePlayer(Seen);
        target = Seen;

        playerDistance = VSize(Pawn.Location - target.Location);
        
        if(playerDistance < RangoHuir) GotoState('Flee');
    }


    function GetRandonDestiny()
    {
       randomMove=LocationRespawn;
       rand = RandRange(-300,300);
       randomMove.X=randomMove.X+rand;
       rand = RandRange(-300,300);
       randomMove.Y=randomMove.Y+rand;
       
       rand = 1;   //De esta manera solo se ejecuta la primera vez y luego solo cuando llega a su destino
       timeNextMove = 100;
    }
    
    Begin:

        if( rand == 0 ) GetRandonDestiny();

        if( timeNextMove > 0 ) timeNextMove -= 1;
        
        Comestible(Pawn).SetAnimationState(ST_Normal);
        
        NavigationHandle.SetFinalDestination(randomMove);
        
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ){ MoveTo( TempDest, none );}
        else MoveTo(randomMove, none );

        if( timeNextMove == 0 ) GetRandonDestiny();
        
        goto 'Begin';
}
/*********************************/

state Flee
{
    local vector selfPlayer;
    local float playerDistance;

    event PlayerOutOfReach()
    {
        GotoState('Idle');
    }

    event Tick(float deltaTime)
    {
        selfPlayer      = Pawn.Location - target.Location;
        selfPlayer.z    = Pawn.Location.z;
        playerDistance  = Abs( VSize( selfPlayer ) );
        
       if ( playerDistance > RangoHuir ) PlayerOutOfReach();
       else
       {
          Pawn.Velocity = Normal( selfPlayer ) * speedFlee;
          Pawn.SetRotation( rotator( selfPlayer ) );
          Pawn.Move( Pawn.Velocity * deltaTime );
       }
    }

    Begin:
        Comestible(Pawn).SetAnimationState(ST_Flee);
}

/*********************************/

/******** ESTADO Explode *************/
state Explode
{
    local DoorOfLiesPlayerController PlayerController;

    event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);

        PlayerController = DoorOfLiesPlayerController(GetALocalPlayerController());

        switch (Comestible(Pawn).type)
        {
            case Com_Fuego:
                PlayerController.powers[0].manas++;
            break;
            case Com_Agua:
                PlayerController.powers[1].manas++;
            break;
            case Com_Tierra:
                PlayerController.powers[2].manas++;
            break;
            case Com_Viento:
                PlayerController.powers[3].manas++;
            break;           
        }

        Pawn.Destroy();
    }
Begin:
    MoveTo( Pawn.Location, Pawn );
    Comestible(Pawn).SetAnimationState( ST_Die );    
}
/*********************************/


/********************************************************************/

DefaultProperties
{
    RangoHuir = 1024;
    speedFlee = 250;
}
