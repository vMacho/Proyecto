class Boss_Controller extends AIController;
 
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
            cantidadAtaquesDistance ++;
            recargarataque = 400;
            `log("RECARGA");
        }
        else if( recargarataque > 0 ) recargarataque --;
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
auto state SpawnBoss
{
    event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);

       //GotoState('Idle');
    }

    Begin:

        Boss(Pawn).SetAnimationState(ST_Spawn);
        ResetMove();
        target = none;    
}

state Idle
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

    Boss(Pawn).SetAnimationState(ST_Normal);
    ResetMove();
    target = none;
    //GotoState('merodeando');
    
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
            GotoState('Follow');
        } 
    }


    function GetRandonDestiny()
    {
       randomMove=LocationRespawn;
       rand = RandRange(-300,300);
       randomMove.X=randomMove.X+rand;
       rand = RandRange(-300,300);
       randomMove.Y=randomMove.Y+rand;
       
       rand=1;   //De esta manera solo se ejecuta la primera vez y luego solo cuando llega a su destino
       timeNextMove=200;
    }
    Begin:
    if(rand==0)
    {
        GetRandonDestiny();
    }
    if(timeNextMove>0)
    {
    timeNextMove=timeNextMove-1;
    }
    Boss(Pawn).SetAnimationState(ST_Normal);
    playerDistance = VSize(Pawn.Location - randomMove);
    NavigationHandle.SetFinalDestination(randomMove);
     if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) ){ MoveTo( TempDest, none );}
     else
     {
          MoveTo(randomMove, none );
     }
     if(timeNextMove==0)
     {
         GetRandonDestiny();
     }
     goto 'Begin';
}

/*********************************/

/******** ESTADO Follow *************/
state Follow
{
    local float playerDistance,DistancefromRespawn;

   // ignores SeePlayer;
    Begin:

    Boss(Pawn).SetAnimationState(ST_Normal);
    
    playerDistance = VSize(Pawn.Location - target.Location);
    DistancefromRespawn  = VSize(Pawn.Location - LocationRespawn);

    if(DistancefromRespawn>distanceToComeback)
    {
        GotoState('Comeback');

    }   

    if(playerDistance > RangoAtacar || cantidadAtaquesDistance<1)   // Si la distancia es mayor que el rango de ataque
    {
        if( NavigationHandle.ActorReachable( target) )    //Si podemos llegar a el
        { 

            MoveToward( target, target, 20 );
             GotoState('Attack');
        }
        else if( FindNavMeshPath(target) )
        {
            NavigationHandle.SetFinalDestination(target.Location);

            if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
            {
             MoveTo( TempDest, target ); //Nos movemos hasta el primer nodo del Path

            }
            else
            {
             MoveToward( target, target, 20 );

            }
        }
        else
        {

            MoveToward( target, target, 20 );
        }
        
        if(playerdistance<100)  //GO TO ATTACk para ataqe basico
        {
             GotoState('Attack');
        }

    }
    else
    {
        GotoState('Attack');
    }

    

    goto 'Begin';
    
}


state Comeback
{

    local float playerDistance;
    local int TimeOnComeBack;

    Begin:
     
         TimeOnComeBack ++;
         playerDistance = VSize(Pawn.Location - LocationRespawn);
         NavigationHandle.SetFinalDestination(LocationRespawn);
         
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
    Boss(Pawn).SetAnimationState(ST_Die);    
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
        local AreaEnemiga bola;
        Boss(Pawn).SetAnimationState(ST_Attack_cerca);
          
         
      
        bola = Spawn(class 'AreaEnemiga',,,target.Location);
        bola.Constructor(300,300,false,false,1,2,4,DecalMaterial'Decals.Materials.Area_Ciruclar',0,ParticleSystem'fuego2.ParticleSystem.ParticleFireFlame',0);
        bola.targetPoint = target.Location;
        bola.emitterPawn = pawn;
    }

    function Hit()
    {
        
       local AreaEnemiga bola;
        Boss(Pawn).SetAnimationState(ST_Attack_cerca);
        bola = Spawn(class 'AreaEnemiga',,,target.Location);
        bola.Constructor(200,200,false,false,0,2,4,DecalMaterial'Decals.Materials.Area_Ciruclar',0,ParticleSystem'fuego2.ParticleSystem.ParticleFireFlame',0);
        bola.targetPoint = target.Location;
        bola.emitterPawn = pawn;
    }

Begin:
    ResetMove();
    playerpos = target.Location;

    playerDistance = VSize(Pawn.Location - target.Location); 

    if( playerDistance < RangoAtacar) 
    {
        if(cantidadAtaquesDistance>0 )
        {
        Shoot();
        cantidadAtaquesDistance=cantidadAtaquesDistance-1;
        }
        else if(playerDistance<120)
        {
            Hit();
        }
        else
        {
            GotoState('Follow');
        }
    }
    else 
    {
        GotoState('Follow');
    }
        
}



/*********************************/

DefaultProperties
{
    cantidadAtaquesDistance=2;
    RangoAtacar=600;
    distanceToComeback=1000;
    RangoPerseguir=800;
    TimerAttack = 0;
}
