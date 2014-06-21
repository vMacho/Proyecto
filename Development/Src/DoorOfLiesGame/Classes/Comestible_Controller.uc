class Comestible_Controller extends AIController;
 
var Actor target;
var Vector TempDest;
var float TimerAttack;
var int RangoPerseguir;
var int RangoAtacar;
var vector LocationRespawn;
var float distanceToComeback;
var int cantidadAtaquesDistance;
var int recargarataque;
//PRUEBAS


simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    LocationRespawn=location;
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
    
    AddOneattack();
    
    //DumpStateStack();
}

function ResetMove()
{
    TempDest = vect(0,0,0);
    Velocity = vect(0,0,0);
    Acceleration = vect(0,0,0);
    MoveTimer = -1.0;
}
function AddOneattack()
{
    if( cantidadAtaquesDistance == 0 )
    {
        if( recargarataque == 0 )
        {
            cantidadAtaquesDistance = cantidadAtaquesDistance+1;
            recargarataque=400;
            `log("RECARGA");
        }
        else if( recargarataque > 0 ) recargarataque = recargarataque - 1;
    }
}
//PRUEBAS 


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
        
        if(playerDistance < RangoPerseguir)
        { 
            //GotoState('Follow');
        } 
    }

Begin:

    Comestible(Pawn).SetAnimationState(ST_Normal);
    ResetMove();
    target = none;
    GotoState('merodeando');
    
}

state merodeando
{
    local float playerDistance,rand,timeNextMove;
    local vector randomMove;

    event SeePlayer (Pawn Seen)
    {
        super.SeePlayer(Seen);
        target = Seen;

        playerDistance = VSize(Pawn.Location - target.Location);
        
        if(playerDistance < RangoPerseguir)
        { 
            //GotoState('Follow');
        } 
    }


    function GetRandonDestiny()
    {
       randomMove=LocationRespawn;
       rand = RandRange(-300,300);
       randomMove.X=randomMove.X+rand;
       rand = RandRange(-300,300);
       randomMove.Y=randomMove.Y+rand;
       
       rand = 1;   //De esta manera solo se ejecuta la primera vez y luego solo cuando llega a su destino
       timeNextMove = 200;
    }
    
    Begin:

        if( rand == 0 ) GetRandonDestiny();

        if(timeNextMove>0) timeNextMove = timeNextMove - 1;
        
        Comestible(Pawn).SetAnimationState(ST_Normal);
        playerDistance = VSize(Pawn.Location - randomMove);
        NavigationHandle.SetFinalDestination(randomMove);
        
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ){ MoveTo( TempDest, none );}
        else MoveTo(randomMove, none );

        if( timeNextMove == 0 ) GetRandonDestiny();
        
        goto 'Begin';
}

/*********************************/

state Comeback
{

    local float playerDistance;
    local int TimeOnComeBack;
    
    Begin:
        TimeOnComeBack=TimeOnComeBack+1;
        playerDistance = VSize(Pawn.Location - LocationRespawn);
        NavigationHandle.SetFinalDestination( LocationRespawn );

        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius() ) ) MoveTo( TempDest, none );
        else MoveTo(LocationRespawn, none );

        if( playerDistance < 100 || TimeOnComeBack > 400 )
        {
            LocationRespawn=pawn.Location;
            GotoState('Idle');
        }

        goto 'begin';
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
    Comestible(Pawn).SetAnimationState(ST_Die);    
}
/*********************************/


/*********************************/

DefaultProperties
{
    cantidadAtaquesDistance=0;
    RangoAtacar=0;
    distanceToComeback=1000;
    RangoPerseguir=800;
    TimerAttack = 0;
}
