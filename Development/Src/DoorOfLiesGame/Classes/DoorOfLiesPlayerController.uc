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
var Vector NavigationDestination;
var Vector2D DistanceCheck;

var Attackable Target;
var bool CurrentTargetIsReachable;

/*****************************************************************/

var (DoorOfLies) float RotationSpeed;
var PointerActor PointerCursor;


function UpdateRotation( float DeltaTime ) //Truncamos la rotacion
{
	
}

function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot ) //Truncamos la rotacion
{
	
}


//Cada frame
event PlayerTick( float DeltaTime )
{
	super.PlayerTick(DeltaTime);

	if(bRightMousePressed) //Usamos el boton derecho para movernos
	{
		DeltaTimeAccumulated += DeltaTime; //Guardamos el tiempo que dicho boton ha estado pulsado

		SetDestinationPosition(MouseHitWorldLocation); //Actualizamos la posicion mientras el boton siga presionado
		
		//If its not already pushed, push the state that makes the pawn run to destination
		//until mouse is unpressed. Make sure we do it after the allocated time for a single
		//click or else two states could be pushed simultaneously
		if(DeltaTimeAccumulated >= 0.13f)
		{
			if(!IsInState('MoveMousePressedAndHold'))
			{
				//`Log("Pushed MoveMousePressedAndHold state");
				PushState('MoveMousePressedAndHold');
			}
			else
			{
				//Specify execution of current state, starting from label Begin:, ignoring all events and
				//keeping our current pushed state MoveMousePressedAndHold. To better understand why this 
				//continually execute each frame from our Begin: label
				GotoState('MoveMousePressedAndHold', 'Begin', false, true);
			}
		}
	}

	if(bLeftMousePressed) //Usamos el boton Izquierdo para atacar, si pulsamos sobre un enemigo primero va hasta su posicion
	{
		DeltaTimeAccumulated += DeltaTime; //Guardamos el tiempo que dicho boton ha estado pulsado
	}

	//DumpStateStack();
}

exec function PauseGame()
{
  	MyHud(myHUD).MyHudHealth.PauseGameControlPlayer();
}

exec function ZoomCameraDown() //Scroll de la camara
{
	PlayerCamera.FreeCamDistance += (PlayerCamera.FreeCamDistance < DoorOfLiesPlayerCamera(PlayerCamera).DefaultFreeCamDistance) ? 64 : 0;
}
exec function ZoomCameraUp() //Scroll de la camara
{
	PlayerCamera.FreeCamDistance -= (PlayerCamera.FreeCamDistance > 128) ? 64 : 0;
}


//Se lanza cuando pulsamos un boton del ratón y da el destino al que dirigirse
exec function StartFire(optional byte FireModeNum)
{
	if(myHUD.bShowHUD)
	{
		//Pop all states to get pawn in auto moving to mouse target location.
		PopState(true);
		
		//Set timer
		DeltaTimeAccumulated = 0;

		//Set initial location of destination
		SetDestinationPosition(MouseHitWorldLocation);

		//Initialize this to false, so we can at least do one state-frame and evaluate distance again.
		bPawnNearDestination = false;

		//Initialize mouse pressed over time.
		bLeftMousePressed = FireModeNum == 0;
		bRightMousePressed = FireModeNum == 1;
	}
}

//Relase del boton del ratón, mandamos al jugador al punto de destino
exec function StopFire(optional byte FireModeNum )
{
	//`Log("delta accumulated"@DeltaTimeAccumulated);
	if(myHUD.bShowHUD)
	{
		//Reseteamos el tiempo de pulsado de los botones del ratón
		if(bLeftMousePressed && FireModeNum == 0)
		{
			bLeftMousePressed = false;

			if(!bPawnNearDestination && DeltaTimeAccumulated < 0.13f)
			{
				//Our pawn has been ordered to a single location on mouse release.
				//Simulate a firing bullet. If it would be ok (clear sight) then we can move to and simply ignore pathfinding.
				if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true)) MovePawnToDestination(0); //Movimiento simple
			}
			else PopState(); //Paramos al jugador por que se encuentra cerca del punto de destino
		}
		
		if(bRightMousePressed && FireModeNum == 1)
		{
			bRightMousePressed = false;
		
			//Si no estamos cerca del destino y hemos pulsado el botón derecho del ratón
			if(!bPawnNearDestination && DeltaTimeAccumulated < 0.13f)
			{
				//Our pawn has been ordered to a single location on mouse release.
				//Simulate a firing bullet. If it would be ok (clear sight) then we can move to and simply ignore pathfinding.
				if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true)) MovePawnToDestination(1); //Movimiento simple
				else ExecutePathFindMove(); //Ejecutamos el pathfinding
			}
			else PopState(); //Paramos al jugador por que se encuentra cerca del punto de destino
		}
		
		DeltaTimeAccumulated = 0; //Reseteamos el tiempo de pulsado del botón
	}
}

//Movimiento sin pathfinding, ponemos al jugador en el estado MoveMouseClick
function MovePawnToDestination(int buttonpressed)
{	
	if(buttonpressed == 0) //left mouse button
	{
		if(Attackable(TraceActor) != none)
		{
			Target = Attackable(TraceActor);
			PushState('Attack');
			SetDestinationPosition(Target.Location);
		}		
	}
	else //right mouse button
	{
		SetDestinationPosition(MouseHitWorldLocation);
		PushState('MoveMouseClick');
		PointerCursor = Spawn(class'PointerActor',,,MouseHitWorldLocation,,,);
	}
}

//Movimiento com pathfinding,Dependiendo de si hay path y de cuantos nodos tiene elegimos un movimiento más simple (PathFind) o desarrollado (NavMeshSeeking)
function ExecutePathFindMove()
{
	ScriptedMoveTarget = FindPathTo(GetDestinationPosition());
	
	if( RouteCache.Length > 0 ) PushState('PathFind');
	else PushState('NavMeshSeeking');

	PointerCursor = Spawn(class'PointerActor',,,MouseHitWorldLocation,,,);
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

	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Normal);
}


/******************************************************************
 *                      ESTADOS
 *****************************************************************/

/******** ESTADO Mover a un punto *************/
state MoveMouseClick
{
	event PoppedState()
	{
		//Si el timer de StopLingering estaba activo lo desabilitamos.
		if(IsTimerActive(nameof(StopLingering))) ClearTimer(nameof(StopLingering));

		PointerCursor.Destroy();
	}

	event PushedState()
	{
		//Añadimos el timer para el StopLingering (Para al jugador al cabo de un rato)
		SetTimer(3, false, nameof(StopLingering));
	}

Begin:
	while(!bPawnNearDestination) //Mientras no estemos cerca del destino
	{
		MoveTo(GetDestinationPosition());
	}

	PopState(); //Ya hemos llegado al destino quitamos el estado
}
/************************************/

/******** ESTADO Movimiento continuado (Botón derecho pulsado)*************/
state MoveMousePressedAndHold
{
	event PoppedState() {}

Begin:
	
	if(!bPawnNearDestination)  MoveTo(GetDestinationPosition()); //Mientras no estemos cerca del destino
	else PopState();
}
/************************************/

/******** ESTADO Que Busca el camino por pathfindig simple*************/
state PathFind
{
	event PoppedState()
	{
		PointerCursor.Destroy();
	}

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
	event PoppedState()
	{
		PointerCursor.Destroy();
	}

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

    event PoppedState()
	{
		PointerCursor.Destroy();
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
                        if (!NavigationHandle.SuggestMovePreparation( TempDest,self)) MoveTo( TempDest, None, , true );
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
	if(Target != none)
	{
		while(!bPawnNearDestination) //Mientras no estemos cerca del destino
		{
			MoveTo(Target.Location);
		}
		DoorOfLiesPawn(Pawn).SetAnimationState(ST_Attack);
		while(Target.health > 0)
		{
			if( Pawn.Weapon != None )
			{
				Pawn.Weapon.StartFire(0);
			}
		}

	}
	
	PopState(); //Ya hemos llegado al destino quitamos el estado
}
/************************************/

/******************************************************************/

simulated function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,damageType,Momentum);

	MyHud(myHUD).MyHudHealth.SetDamage(Damage);
}

DefaultProperties
{
	CameraClass=class'DoorOfLiesPlayerCamera'
	InputClass = class'DoorOfLiesPlayerInput';
	RotationSpeed = 10;
}