class EnemyController extends AIController;
 
var Actor target;
var (EnemyPumpkin) OrcPumpkinCollectionArea BaseCollection;
var Vector TempDest;
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    BaseCollection = GetBaseCollection();

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

function OrcPumpkinCollectionArea GetBaseCollection()
{
    local OrcPumpkinCollectionArea Tower;

    foreach AllActors(class'OrcPumpkinCollectionArea', Tower)
    {
        if(Tower.tagPlayer == Pawn.Tag) return Tower;
    }

    return none;
}

function Actor seekPumpkin()
{
    local calabazaPawn C, TargetC;
    local vector DistanceCheck;
    local float distance, min_distance;

    min_distance = 0;

    foreach WorldInfo.AllPawns(class'CalabazaPawn', C)
    {
        DistanceCheck.X = C.Location.X - Pawn.Location.X;
        DistanceCheck.Y = C.Location.Y - Pawn.Location.Y;
        
        distance = Sqrt((DistanceCheck.X * DistanceCheck.X) + (DistanceCheck.Y * DistanceCheck.Y));

        if(distance < min_distance || min_distance == 0)
        {
            TargetC = C;
            min_distance = distance;
        }
    }

    if(target != TargetC) ResetMove();

    return TargetC;
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
    event Tick(float DeltaTime)
    {
        super.Tick(DeltaTime);

        if(EnemyPawn(Pawn).calabazas.length < EnemyPawn(Pawn).maxCalabazas) //Si no hemos alcanzado el max de calabazas que podemos llevar
        {
            target = seekPumpkin();
            if(target != none) GotoState('FindPumpkin');
        }
        else
        {
            ResetMove();
            GotoState('PushPumpkin'); //Si lo hemos alcanzado ve a entregarlas
        }
    }

    Begin:
        target = none;
}
/*********************************/

/******** ESTADO Ir a por calabaza *************/
state FindPumpkin
{
    event Tick(float DeltaTime)
    {
        super.Tick(DeltaTime);
        if(BaseCollection == none) BaseCollection = GetBaseCollection();

        //Si hemos alcanzado el max ve a entregarlas O Ya tenemos las necesarias para acabar
        if( (EnemyPawn(Pawn).calabazas.length >= EnemyPawn(Pawn).maxCalabazas) 
          ||(EnemyPawn(Pawn).calabazas.length >= BaseCollection.calabazas && BaseCollection.calabazas > 0) ) 
        {
            ResetMove();
            GotoState('PushPumpkin'); 
        }
        else target = seekPumpkin(); //Si podemos coger mas, seguimos buscandolas
    }

    Begin:
        if( NavigationHandle.ActorReachable( target) ) MoveToward( target, target, ,true );
        else if( FindNavMeshPath(target) )
        {
            NavigationHandle.SetFinalDestination(target.Location);
            
            if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ) MoveTo( TempDest, target ); //Nos movemos hasta el primer nodo del Path
            else MoveTo(Pawn.Location, Pawn); //No encuentra como ir hasta la base
        }
        else GotoState('Idle');
        
        goto 'Begin';
}
/*********************************/

/******** ESTADO Entregar calabaza *************/
state PushPumpkin
{
    Begin:
        if(BaseCollection == none) BaseCollection = GetBaseCollection();
        MoveTo(Pawn.Location, Pawn);
    End:
        if(EnemyPawn(Pawn).calabazas.length == 0) GotoState('Idle');

        if( NavigationHandle.ActorReachable( BaseCollection) )
        {
            MoveToward( BaseCollection, BaseCollection);
        }
        else if( FindNavMeshPath(BaseCollection) )
        {
            NavigationHandle.SetFinalDestination(BaseCollection.Location);

            if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
            {
                MoveTo( TempDest, BaseCollection ); // Nos movemos hasta el primer nodo del Path
            }
            else
            {
                MoveTo(Pawn.Location, Pawn); //No encuentra como ir hasta la base
                `Log("NO ENCUENTRA EL CAMINO");
            }

        }
        
        goto 'End';
}
/*********************************/

DefaultProperties
{
    
}

//32768.000000