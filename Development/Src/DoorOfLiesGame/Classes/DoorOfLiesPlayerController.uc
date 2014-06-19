 /* Victor Macho
    Clase del control del player
 */

class DoorOfLiesPlayerController extends PlayerController;

/*****************************************************************/
var Vector2D    PlayerMouse;                //Hold calculated mouse position (this is calculated in HUD)

var Vector      MouseHitWorldLocation;      //Hold where the ray casted from the mouse in 3d coordinate intersect with world geometry. We will
											//use this information for our movement target when not in pathfinding.

var Vector      MouseHitWorldNormal;        //Hold the normalized vector of world location to get direction to MouseHitWorldLocation (calculated in HUD, not used)
var Vector      MousePosWorldLocation;      //Hold deprojected mouse location in 3d world coordinates. (calculated in HUD, not used)
var Vector      MousePosWorldNormal;        //Hold deprojected mouse location normal. (calculated in HUD, used for camera ray from above)

var vector      StartTrace;                 //Hold calculated start of ray from camera
var Vector      EndTrace;                   //Hold calculated end of ray from camera to ground
var vector      RayDir;                     //Hold the direction for the ray query.
var Vector      PawnEyeLocation;            //Hold location of pawn eye for rays that query if an obstacle exist to destination to pathfind.
var Actor       TraceActor;                 //If an actor is found under mouse cursor when mouse moves, its going to end up here.

var bool        bLeftMousePressed;          //Initialize this function in StartFire and off in StopFire
var bool        bRightMousePressed;         //Initialize this function in StartFire and off in StopFire
var float       DeltaTimeAccumulated;       //Accumulate time to check for mouse clicks

var float       DistanceRemaining;          //This is the calculated distance the pawn has left to get to MouseHitWorldLocation.
var bool        bPawnNearDestination;       //This indicates if pawn is within acceptable offset of destination to stop moving.

var Actor       ScriptedMoveTarget;
var Route       ScriptedRoute;
var int         ScriptedRouteIndex;

var() Vector TempDest;
var bool GotToDest;
var bool hability_finished;
var Vector NavigationDestination;
var Vector2D DistanceCheck;

var Attackable Target;

/*****************************************************************/

var (DoorOfLies) float RotationSpeed;

struct Hability
{
   var bool active;
   var bool activable;
   var int manas;
   var name name;
   var float cooldown;
   var float actual_cooldown;
   var float seconds_spawn_wall;
   var float default_seconds_spawn_wall;
//   var delegate <AttackHability> Attack;
//   var delegate <DefendHability> Defend;
};

/*enum Habilities
{
	Fuego,
	Agua,
	Tierra,
	Aire
};

var array <Hability> powers;
*/
/*****************************************************************/

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    //Set_Habilities();
}

//Truncamos la rotacion
function UpdateRotation( float DeltaTime ) {}

//Truncamos la rotacion
function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot ) {}


//Cada frame
event PlayerTick( float DeltaTime )
{
	super.PlayerTick(DeltaTime);

	if(bRightMousePressed)
	{
		DeltaTimeAccumulated += DeltaTime; //Guardamos el tiempo que el boton DRCH ha estado pulsado

		SetDestinationPosition(MouseHitWorldLocation); //Actualizamos la posicion mientras el boton siga presionado
		
		if(DeltaTimeAccumulated >= 0.33f)
		{
			if(!IsInState('MoveMousePressedAndHold')) PushState('MoveMousePressedAndHold');
			else GotoState('MoveMousePressedAndHold', 'Begin', false, true);
		}
		
	}

	if(bLeftMousePressed) 
	{

	DeltaTimeAccumulated += DeltaTime; 
	}//Guardamos el tiempo que el boton IZQ ha estado pulsado

	//UpdateHabilities(DeltaTime);
}

exec function PauseGame()
{
  	MyHud(myHUD).MyHudHealth.PauseGameControlPlayer();
}


exec function Q_Hability ()
{
	//change_habilty(Fuego);
	local AreaAmistosa bola;
	
	`log("Spawn de Bola de Fuego");

	bola = Spawn(class 'AreaAmistosa',,,pawn.Location);
	bola.Constructor(400,1200,true,true,0,0.5,2,DecalMaterial'Decals.Materials.Area_lanzamiento',400,ParticleSystem'fuego2.ParticleSystem.ParticleFireFlame',0);
	bola.targetPoint = MouseHitWorldLocation;
	bola.emitterPawn = pawn;
}

exec function W_Hability ()
{
	//change_habilty(Agua);
	local AreaAmistosa water;
	
	`log("Spawn de Area de hielo");

	water = Spawn(class 'AreaAmistosa',,,pawn.Location);
	water.Constructor(450,100,true,false,0,0.5,2,DecalMaterial'Decals.Materials.Area_Ciruclar',400,ParticleSystem'Murosuelo.Particles.Muro_part',2);  //EFECTO RALENTIZA.
	water.targetPoint = MouseHitWorldLocation;
	water.emitterPawn = pawn;


}

exec function E_Hability ()
{
	local AreaAmistosa water;
	
	`log("Spawn de Teleport");

	water = Spawn(class 'AreaAmistosa',,,pawn.Location);
	water.Constructor(50,50,true,false,1,0.15,1,DecalMaterial'Decals.Materials.Area_Ciruclar',400,ParticleSystem'rotura.Particles.flash',1);  //EFECTO TELEPORT
	water.targetPoint = MouseHitWorldLocation;
	water.emitterPawn = pawn;
}

exec function R_Hability ()
{
	//change_habilty(Aire);
}

exec function ZoomCameraDown() //Scroll de la camara
{
	PlayerCamera.FreeCamDistance += (PlayerCamera.FreeCamDistance < DoorOfLiesPlayerCamera(PlayerCamera).DefaultFreeCamDistance) ? 64 : 0;
}
exec function ZoomCameraUp() //Scroll de la camara
{
	PlayerCamera.FreeCamDistance -= (PlayerCamera.FreeCamDistance > 128) ? 64 : 0;
}

exec function SelectAction()
{
	
	Target = Attackable(TraceActor);
}

//Se lanza cuando pulsamos un boton del ratón y da el destino al que dirigirse
exec function StartFire(optional byte FireModeNum)
{
	
	if(myHUD.bShowHUD)
	{
		ResetMove();
		//Set timer
		DeltaTimeAccumulated = 0;

		//Set initial location of destination
		SetDestinationPosition(MouseHitWorldLocation);

		//Initialize this to false, so we can at least do one state-frame and evaluate distance again.
		bPawnNearDestination = false;

		//Initialize mouse pressed over time.
		/*
		bLeftMousePressed = FireModeNum == 0;
		`log("antes"$bRightMousePressed);
		bRightMousePressed = FireModeNum == 1;
		`log("despues"$bRightMousePressed);*/
		if(FireModeNum==0) {

			bLeftMousePressed=true;
			bRightMousePressed=false;
		}
		if(FireModeNum==1)
		{ 
			bRightMousePressed=true;
			bLeftMousePressed=false;
		}
	}
}

//Relase del boton del ratón, mandamos al jugador al punto de destino
exec function StopFire(optional byte FireModeNum )
{
	local float Distancewithtarget;
	local Vector2D  DistanceCheckMove;
	local Actor local_target;
	if(myHUD.bShowHUD)
	{
		//Reseteamos el tiempo de pulsado de los botones del ratón
		if(bLeftMousePressed==true && FireModeNum == 0)
		{
			
			bLeftMousePressed = false;
		
		}
		
		if(bRightMousePressed && FireModeNum == 1)
		{
			bRightMousePressed = false;
			
			if(!IsInState('CastingHability')) //Si no esta ejecutando un ataque de habilidad
			{
				local_target = Attackable(TraceActor);
				if(local_target != none && local_target != Pawn) 
				{
					Target = Attackable(TraceActor);

					DistanceCheckMove.X = TraceActor.Location.X - Pawn.Location.X;
					DistanceCheckMove.Y = TraceActor.Location.Y - Pawn.Location.Y;
					Distancewithtarget = Sqrt((DistanceCheckMove.X*DistanceCheckMove.X) + (DistanceCheckMove.Y*DistanceCheckMove.Y));

					if(Distancewithtarget >= 220) //Hacer dependible del target
					{
						`log("DENTRO MOVIMIENTO DE ATAQUE");
						
						if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true)) GotoState('MoveToAttack');	 //Movimiento simple
						//else ExecutePathFindMove(); //Ejecutamos el pathfinding
					}
					else if( !IsInState('Attack') )  GotoState('Attack');
				}
				else
				{
					//Si no estamos cerca del destino y hemos pulsado el botón derecho del ratón
					if(!bPawnNearDestination && DeltaTimeAccumulated < 0.13f)
					{
						//Our pawn has been ordered to a single location on mouse release.
						//Simulate a firing bullet. If it would be ok (clear sight) then we can move to and simply ignore pathfinding.
						if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true)) MovePawnToDestination(FireModeNum); //Movimiento simple
						else ExecutePathFindMove(); //Ejecutamos el pathfinding
					}
					else
					{

						if( !IsInState('MoveMousePressedAndHold') ) { MovePawnToDestination(FireModeNum);}//PopState();`log("AQUI ERROR");} //Paramos al jugador por que se encuentra cerca del punto de destino
						else 
						GotoState('Idle');
					}
				}
			}
		}
		
		DeltaTimeAccumulated = 0; //Reseteamos el tiempo de pulsado del botón
	}
}

//Movimiento sin pathfinding, ponemos al jugador en el estado MoveMouseClick
function MovePawnToDestination(optional byte FireModeNum)
{	
	SetDestinationPosition(MouseHitWorldLocation);

	//Spawn(class'PointerActor',,,MouseHitWorldLocation,,,);

	if( !IsInState('MoveMouseClick') ) PushState('MoveMouseClick');
}

//Movimiento com pathfinding,Dependiendo de si hay path y de cuantos nodos tiene elegimos un movimiento más simple (PathFind) o desarrollado (NavMeshSeeking)
function ExecutePathFindMove()
{
	ScriptedMoveTarget = FindPathTo(GetDestinationPosition());
	
	if( RouteCache.Length > 0 ) PushState('PathFind');
	else PushState('NavMeshSeeking');

	Spawn(class'PointerActor',,,MouseHitWorldLocation,,,);
}

//Función que prevee que el jugador no se quede atascado con un obstaculo, al cabo de un tiempo el jugador se para
function StopLingering()
{

	PopState(true);
}

function PlayerMove(float DeltaTime)
{
	local Vector PawnXYLocation;
	local Vector DestinationXYLocation;
	local Vector    Destination;
	local Vector2D  DistanceCheckMove;          

	super.PlayerMove(DeltaTime);

	//Calculamos distancia hasta el punto de destino

	Destination = GetDestinationPosition();
	DistanceCheckMove.X = Destination.X - Pawn.Location.X;
	DistanceCheckMove.Y = Destination.Y - Pawn.Location.Y;
	DistanceRemaining = Sqrt((DistanceCheckMove.X*DistanceCheckMove.X) + (DistanceCheckMove.Y*DistanceCheckMove.Y));
	
	//`Log("DistanceCheckMove is"@DistanceCheckMove.X@DistanceCheckMove.Y);
	//`Log("Distance remaining"@DistanceRemaining);
	
	bPawnNearDestination = DistanceRemaining < 15.0f;
	//`Log("Has pawn come near destination ?"@bPawnNearDestination);

	PawnXYLocation.X = Pawn.Location.X;
	PawnXYLocation.Y = Pawn.Location.Y;

	DestinationXYLocation.X = GetDestinationPosition().X;
	DestinationXYLocation.Y = GetDestinationPosition().Y;

	Pawn.SetRotation(RInterpTo(Pawn.Rotation, Rotator(DestinationXYLocation - PawnXYLocation), DeltaTime, RotationSpeed));
}


/******************************************************************
 *                      ESTADOS
 *****************************************************************/

/******** ESTADO Idle *************/
auto state Idle extends PlayerWalking
{

Begin:
	ResetMove();
	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Normal);
}
/************************************/

/******** ESTADO Mover a un punto *************/
state MoveMouseClick
{
	//local vector LastDestino;
	event PoppedState()
	{
		//Si el timer de StopLingering estaba activo lo desabilitamos.
		if(IsTimerActive(nameof(StopLingering))) ClearTimer(nameof(StopLingering));
	}

	event PushedState()
	{
		//Añadimos el timer para el StopLingering (Para al jugador al cabo de un rato)
		SetTimer(3, false, nameof(StopLingering));
	}

Begin:
	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Normal);

	while(!bPawnNearDestination) //Mientras no estemos cerca del destino
	{
		//if(bRightMousePressed==true)
		//{
		//	LastDestino=GetDestinationPosition();
		//}
		MoveTo(GetDestinationPosition());
	}

	GotoState('Idle');
}
/************************************/

/******** ESTADO Movimiento continuado (Botón derecho pulsado)*************/
state MoveMousePressedAndHold
{
	event PoppedState(){ ResetMove(); }

Begin:
	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Normal);
	if( !bPawnNearDestination )  MoveTo( GetDestinationPosition() ); //Mientras no estemos cerca del destino
	else GotoState('Idle');
}
/************************************/

/******** ESTADO Que Busca el camino por pathfindig simple*************/
state PathFind
{
	Begin:
	    if( RouteCache.Length > 0 )
	    {
	        ScriptedRouteIndex = 0;
	        while (Pawn != None && ScriptedRouteIndex < RouteCache.length && ScriptedRouteIndex >= 0)
	        {
                ScriptedMoveTarget = RouteCache[ScriptedRouteIndex];
                if (ScriptedMoveTarget != None) PushState('ScriptedMove');

                ScriptedRouteIndex++;
	        }
	        PopState();
	    }
}
/***********************************************************************/

/******** ESTADO Que mueve al jugador por pathfindig simple*************/
state ScriptedMove
{
	Begin:
        while(ScriptedMoveTarget != none && Pawn != none && !Pawn.ReachedDestination(ScriptedMoveTarget))
        {
            if (ActorReachable(ScriptedMoveTarget)) //Si podemos llegar directamente
            {
                MoveToward(ScriptedMoveTarget, ScriptedMoveTarget);
                SetDestinationPosition(ScriptedMoveTarget.Location);
            }
            else
            {
                MoveTarget = FindPathToward(ScriptedMoveTarget);
                if (MoveTarget != None)
                {
                    MoveToward(MoveTarget, MoveTarget);
                    SetDestinationPosition(MoveTarget.Location);
                    DoorOfLiesPawn(Pawn).SetAnimationState(ST_Normal);
                }
                else
                {
                    //Si llegamos a este punto es por un error al encontrar el camino en el mapa
                    `warn("Failed to find path to"@ScriptedMoveTarget);
                    ScriptedMoveTarget = None;
                }
            }
        }
        PopState();
}
/***********************************************************************/

/******** ESTADO Que mueve al jugador por NavMesh (Pylon)*************/
state NavMeshSeeking
{
    function bool FindNavMeshPath()
    {
	    NavigationHandle.PathConstraintList = none;
	    NavigationHandle.PathGoalList = none;

	    class'NavMeshPath_Toward'.static.TowardPoint( NavigationHandle, NavigationDestination );
	    class'NavMeshGoal_At'.static.AtLocation( NavigationHandle, NavigationDestination, 50, );

	    return NavigationHandle.FindPath();
    }

    Begin:
        NavigationDestination = GetDestinationPosition();

        if( FindNavMeshPath() )
        {
            NavigationHandle.SetFinalDestination(NavigationDestination);
            
            //FlushPersistentDebugLines();
            //NavigationHandle.DrawPathCache(,TRUE);

            while( Pawn != None && !Pawn.ReachedPoint(NavigationDestination, None) )
            {
                if( NavigationHandle.PointReachable( NavigationDestination ) ) MoveTo( NavigationDestination, None, , true ); //Si podemos llegar a este punto directamente
                else
                {
                	//Nos movemos al primer nodo de la ruta escogida
                    if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
                    {
                        if (!NavigationHandle.SuggestMovePreparation( TempDest,self))
                        {
                        	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Normal);
                        	MoveTo( TempDest, None, , true );
                        }
                    }
                }
                DistanceCheck.X = NavigationDestination.X - Pawn.Location.X;
                DistanceCheck.Y = NavigationDestination.Y - Pawn.Location.Y;
                DistanceRemaining = Sqrt((DistanceCheck.X*DistanceCheck.X) + (DistanceCheck.Y*DistanceCheck.Y));
                
                GotToDest = Pawn.ReachedPoint(NavigationDestination, None);

                if( DistanceRemaining < 15) break;
            }
        }
        else
        {
            //Si llegamos a este punto es por un error al encontrar el camino en el mapa
            `warn("FindNavMeshPath failed to find a path to"@ScriptedMoveTarget);
            ScriptedMoveTarget = None;
        }   

	    Pawn.ZeroMovementVariables();
	    PopState(); //Volvemos al anterior estado
}
/***********************************************************************/

/******** ESTADO Atacar *************/
state Attack 
{
	local Vector    Destination;
	local Vector2D  DistanceCheckMove;    
	local float distancia;

	event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode, PlayerTime, ExcessTime);
        
        Destination = Target.location;
    	DistanceCheckMove.X = Destination.X - Pawn.Location.X;
		DistanceCheckMove.Y = Destination.Y - Pawn.Location.Y;
		distancia = Sqrt((DistanceCheckMove.X*DistanceCheckMove.X) + (DistanceCheckMove.Y*DistanceCheckMove.Y));

        if(distancia <= 200 )
        {
        	Target.SetDamage( DoorOfLiesPawn(Pawn).strength );

	        if(Target.Health > 0)
	        {
	        	`log("VIVO "$Target.Health);
				
	        	if(distancia < 200) GotoState('Attack');
	        	else GotoState('MoveToAttack');
	        }
	        else
	        {
	        	`log("Muerto");
	        	GotoState('Idle');
	        } 
        }
        else GotoState('MoveToAttack');
    }

Begin:
	ResetMove();
	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Attack);
	MoveTo(GetDestinationPosition());
	
}
/************************************/

/******** ESTADO Mover a un target *************/
state MoveToAttack
{
	event PoppedState()
	{
		if( IsTimerActive( nameof( StopLingering ) ) ) ClearTimer( nameof( StopLingering ) ); //Si el timer de StopLingering estaba activo lo desabilitamos.
	}

	event PushedState()
	{
		SetTimer( 3, false, nameof( StopLingering ) ); //Añadimos el timer para el StopLingering (Para al jugador al cabo de un rato)
	}

	function PlayerMove(float DeltaTime)
	{
		local Vector 	PawnXYLocation;
		local Vector 	DestinationXYLocation;
		local Vector    Destination;
		local Vector2D  DistanceCheckMove;          

		super.PlayerMove(DeltaTime);

		//Calculamos distancia hasta el punto de destino
		Destination = GetDestinationPosition();
		DistanceCheckMove.X = Destination.X - Pawn.Location.X;
		DistanceCheckMove.Y = Destination.Y - Pawn.Location.Y;
		DistanceRemaining = Sqrt((DistanceCheckMove.X*DistanceCheckMove.X) + (DistanceCheckMove.Y*DistanceCheckMove.Y));
		
		bPawnNearDestination = DistanceRemaining < 200.0f; //Hacer dependible del target

		PawnXYLocation.X = Pawn.Location.X;
		PawnXYLocation.Y = Pawn.Location.Y;

		if(bPawnNearDestination) ResetMove();
		else
		{
			DestinationXYLocation.X = GetDestinationPosition().X;
			DestinationXYLocation.Y = GetDestinationPosition().Y;

			Pawn.SetRotation(RInterpTo(Pawn.Rotation, Rotator(DestinationXYLocation - PawnXYLocation), DeltaTime, RotationSpeed));

			DoorOfLiesPawn(Pawn).SetAnimationState(ST_Normal);
		}
	}

Begin:
	ResetMove();

	while(!bPawnNearDestination && target != none) //Mientras no estemos cerca del destino
	{
		SetDestinationPosition(Target.Location);
		
		MoveTo(GetDestinationPosition());
	}

	GotoState('Attack');
}

state CastingHability extends PlayerWalking
{

Begin:

	ResetMove();
	
	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Attack);
	if(hability_finished)
	{
	`log("entra");
	hability_finished=false;
	GotoState('idle');
	}
}

function ResetMove()
{
	ClearAllTimers();
    TempDest = vect(0,0,0);
    Velocity = vect(0,0,0);
    Acceleration = vect(0,0,0);
    MoveTimer = -1.0;
}

function SetDamage(float damage)
{
	Pawn.Health -= damage;
	MyHud(myHUD).MyHudHealth.SetDamage(damage);
}

simulated function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,damageType,Momentum);

	MyHud(myHUD).MyHudHealth.SetDamage(Damage);
}

DefaultProperties
{
	hability_finished=false;
	CameraClass=class'DoorOfLiesPlayerCamera'
	InputClass = class'DoorOfLiesPlayerInput';
	RotationSpeed = 10;
}