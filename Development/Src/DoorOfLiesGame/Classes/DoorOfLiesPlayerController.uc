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

/***************************************************************** 
 *  Calculated in Hud after mouse deprojection, uses MousePosWorldNormal as direction vector 
 *  This is what calculated MouseHitWorldLocation and MouseHitWorldNormal.
 *  
 *  See Hud.PostRender, Mouse deprojection needs Canvas variable.
 *  
 *  **/
var vector      StartTrace;                 //Hold calculated start of ray from camera
var Vector      EndTrace;                   //Hold calculated end of ray from camera to ground
var vector      RayDir;                     //Hold the direction for the ray query.
var Vector      PawnEyeLocation;            //Hold location of pawn eye for rays that query if an obstacle exist to destination to pathfind.
var Actor       TraceActor;                 //If an actor is found under mouse cursor when mouse moves, its going to end up here.

//var MeshMouseCursor MouseCursor;              //Hold the 3d mouse cursor

/*****************************************************************
 *
 *  Mouse button handling
 *
 */

var bool        bLeftMousePressed;          //Initialize this function in StartFire and off in StopFire
var bool        bRightMousePressed;         //Initialize this function in StartFire and off in StopFire
var float       DeltaTimeAccumulated;       //Accumulate time to check for mouse clicks

/*****************************************************************/

var float       DistanceRemaining;          //This is the calculated distance the pawn has left to get to MouseHitWorldLocation.
var bool        bPawnNearDestination;       //This indicates if pawn is within acceptable offset of destination to stop moving.

var vector targetTogo;

var (DoorOfLies) float RotationSpeed;
var PointerActor PointerCursor;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
}

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
		
		//BUSCAMOS EL TARGET
		//targetTogo = none;
		//if(targetTogo != none)
		//{
			SetDestinationPosition(MouseHitWorldLocation);

			if(DeltaTimeAccumulated >= 0.13f) //Si Mantenemos pulsado
			{
				if(!IsInState('AttackEnemy')) //Si no estabamos atacando
				{
					`Log("Pushed AttackEnemy state");
					PushState('AttackEnemy');
				}
				else GotoState('AttackEnemy', 'Begin', false, true);
			}
		//}

	}

	//DumpStateStack();
}

exec function PauseGame()
{
  	MyHud(myHUD).MyHudHealth.PauseGameControlPlayer();
}

exec function NextWeapon() //Scroll de la camara
{
	PlayerCamera.FreeCamDistance += (PlayerCamera.FreeCamDistance < 512) ? 64 : 0;
}
exec function PrevWeapon() //Scroll de la camara
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
		DeltaTimeAccumulated =0;

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
simulated function StopFire(optional byte FireModeNum )
{
	//`Log("delta accumulated"@DeltaTimeAccumulated);

	if(myHUD.bShowHUD)
	{
		//Reseteamos el tiempo de pulsado de los botones del ratón
		if(bLeftMousePressed && FireModeNum == 0)
		{
			bLeftMousePressed = false;
		
			//Si no estamos cerca del destino y hemos pulsado el botón Izquierdo del ratón
			if(!bPawnNearDestination && DeltaTimeAccumulated < 0.13f)
			{
				//Our pawn has been ordered to a single location on mouse release.
				//Simulate a firing bullet. If it would be ok (clear sight) then we can move to and simply ignore pathfinding.
				if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true))
				{
					MovePawnToDestination(); //Movimiento simple
				}
				else
				{
					//ExecutePathFindMove(); //Ejecutamos el pathfinding
				}
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
				if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true))
				{
					MovePawnToDestination(); //Movimiento simple
				}
				else
				{
					//ExecutePathFindMove(); //Ejecutamos el pathfinding
				}
			}
			else PopState(); //Paramos al jugador por que se encuentra cerca del punto de destino
		}
		
		DeltaTimeAccumulated = 0; //Reseteamos el tiempo de pulsado del botón
	}
}

//Movimiento sin pathfinding simple, ponemos al jugador en el estado MoveMouseClick
function MovePawnToDestination()
{
	SetDestinationPosition(MouseHitWorldLocation);
	PushState('MoveMouseClick');
	PointerCursor = Spawn(class'PointerActor',,,MouseHitWorldLocation,,,);
}

//Función que prevee que el jugador no se quede atascado con un obstaculo, al cabo de un tiempo el jugador se para
function StopLingering()
{
	PopState(true);
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  PlayerMove is called each frame, we declare it here inside the
 *  PlayerController so its general to all states. It can be possible
 *  to declare this function in each single state, having multiple
 *  PlayerMove scenario, but for the simplicity of the tutorial
 *  we have put it here in the class. It controls the player in that
 *  it does a distance check when moving. It calculates the remaining
 *  distance to the target. If target is within 2D(X,Y) offset, then
 *  set the var bPawnNearDestination for state control.
 *  
 *  Rotation
 *  
 *  This function overrides the controller rotation of the pawn. Depending
 *  on the situation (state) the pawn will either face a direction or rotate
 *  to face the destination.
 *
 ******************************************************************/
function PlayerMove(float DeltaTime)
{
	local Vector PawnXYLocation;
	local Vector DestinationXYLocation;
	local Vector    Destination;
	local Vector2D  DistanceCheck;          

	super.PlayerMove(DeltaTime);

	//Calculamos distancia hasta el punto de destino
	Destination = GetDestinationPosition();
	DistanceCheck.X = Destination.X - Pawn.Location.X;
	DistanceCheck.Y = Destination.Y - Pawn.Location.Y;
	DistanceRemaining = Sqrt((DistanceCheck.X*DistanceCheck.X) + (DistanceCheck.Y*DistanceCheck.Y));
	
	//`Log("DistanceCheck is"@DistanceCheck.X@DistanceCheck.Y);
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

/******** ESTADO ATACAR *************/
state AttackEnemy
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
	while(!bPawnNearDestination) //Mientras no estemos cerca del destino
	{
		MoveTo(GetDestinationPosition());
	}

	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Attack); //Hemos llegado al destino, atacamos
	
	PopState();
	
}
/************************************/

/******** ESTADO Movimiento continuado (Botón derecho pulsado)*************/
state MoveMousePressedAndHold
{
	event PoppedState()
	{
		
	}

Begin:
	if(!bPawnNearDestination) //Mientras no estemos cerca del destino
	{
		MoveTo(GetDestinationPosition());
	}
	else PopState();
}
/************************************/

/******************************************************************
 *****************************************************************/

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