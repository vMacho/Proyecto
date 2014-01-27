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

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	`Log("I am alive !");
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

	//Comocamos en la posicion el cursor 3D, en este caso no usamos.
	//MouseCursor.SetLocation(MouseHitWorldLocation);	

	//Usamos el boton derecho para movernos
	if(bRightMousePressed)
	{
		//Guardamos el tiempo que dicho boton ha estado pulsado
		DeltaTimeAccumulated += DeltaTime;

		//Actualizamos la posicion mientras el boton siga presionado
		SetDestinationPosition(MouseHitWorldLocation);
		
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

	//Usamos el boton derecho para atacar, si pulsamos sobre un enemigo primero va hasta su posicion
	if(bLeftMousePressed)
	{
		//Guardamos el tiempo que dicho boton ha estado pulsado
		DeltaTimeAccumulated += DeltaTime;
		
		//BUSCAMOS EL TARGET
		//targetTogo = none;
		//if(targetTogo != none)
		//{
			DoorOfLiesPawn(Pawn).SetAnimationState(ST_Attack);
			targetTogo = Pawn.Location;
			//SetDestinationPosition(targetTogo);

			if(DeltaTimeAccumulated >= 0.13f)
			{
				if(!IsInState('AttackEnemy'))
				{
					`Log("Pushed AttackEnemy state");
					PushState('AttackEnemy');
				}
				else
				{
					//Specify execution of current state, starting from label Begin:, ignoring all events and
					//keeping our current pushed state MoveMousePressedAndHold. To better understand why this 
					//continually execute each frame from our Begin: label
					GotoState('AttackEnemy', 'Begin', false, true);
				}
			}
		//}

	}

	//DumpStateStack();
}

exec function NextWeapon() //Scroll de la camara
{
	PlayerCamera.FreeCamDistance += (PlayerCamera.FreeCamDistance < 512) ? 64 : 0;
}
exec function PrevWeapon() //Scroll de la camara
{
	PlayerCamera.FreeCamDistance -= (PlayerCamera.FreeCamDistance > 128) ? 64 : 0;
}


/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  StartFire is called on mouse pressed, here to calculate a mouse click we
 *  set the timer to 0, then initialize mouseButtons according to function 
 *  parameter and set the initial destination of the mouse press. Real
 *  process is in PlayerTick function.
 *
 ******************************************************************/
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

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  StopFire is called on mouse release, here check the time the buttons have
 *  been pressed (this should be enhanced, but it was kept simple for the tutorial).
 *  if DeltaAccumulated < 0.1300 (medium time mouse click) then we calculate it as
 *  a mouse click, else simply stop any state running. EDIT: You must understand only
 *  a single timer has been kept for all mouse button, you should duplicate a timer
 *  for each individual mouse button if you want to support thing like auto-fire while
 *  walking in a direction.
 *
 ******************************************************************/
simulated function StopFire(optional byte FireModeNum )
{
	//`Log("delta accumulated"@DeltaTimeAccumulated);

	if(myHUD.bShowHUD)
	{
		//Un-Initialize mouse pressed over time.
		if(bLeftMousePressed && FireModeNum == 0)
		{
			bLeftMousePressed = false;
			//`Log("Left Mouse released");
		}
		if(bRightMousePressed && FireModeNum == 1)
		{
			bRightMousePressed = false;
			//`Log("Right Mouse released");
		
			//If we are not near destination and click occured
			if(!bPawnNearDestination && DeltaTimeAccumulated < 0.13f)
			{
				//Our pawn has been ordered to a single location on mouse release.
				//Simulate a firing bullet. If it would be ok (clear sight) then we can move to and simply ignore pathfinding.
				if(FastTrace(MouseHitWorldLocation, PawnEyeLocation,, true))
				{
					//Simply move to destination.
					MovePawnToDestination();
				}
				else
				{
					//fire up pathfinding
					//ExecutePathFindMove();
				}
			}
			else
			{
				//Stop player from going on in that direction forever. This normally needs to be done
				//after a long mouse held. This will make the player stop its current MoveMousePressedAndHold
				//state.
				PopState();
			}
		}
		//reset accumulated timer for mouse held button
		DeltaTimeAccumulated = 0;
	}
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  MovePawnToDestination will push a MoveMouseClick state that will make
 *  the pawn go to a single destination with a mouse click and then
 *  stop near the destination.
 *
 ******************************************************************/
function MovePawnToDestination()
{
	//`Log("Moving to location without pathfinding!");
	SetDestinationPosition(MouseHitWorldLocation);
	PushState('MoveMouseClick');
}

/******************************************************************
 *
 *  TUTORIAL FUNCTION
 *
 *  This is a timer function, it prevents the MoveMouseClick state from
 *  looking to get stuck in an obstacle. After a set of seconds it
 *  pushes the entire state stack so the pawn revert to PlayerMove
 *  automatic state.
 *
 ******************************************************************/
function StopLingering()
{
	//Remove all current move state and query for input from now on.
	//`Log("Stopped lingering...");
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

	//Get player destination for a check on distance left. (calculate distance)
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
 *                      STATES
 *****************************************************************/

/******************************************************************
 *
 *  TUTORIAL STATE (MoveMouseClick)
 *
 *  MoveMouseClick is the state when a mouse button is pressed
 *  once (simple click). Simply go to a set destination.
 *
 *
 ******************************************************************/
state MoveMouseClick
{
	event PoppedState()
	{
		//`Log("MoveMouseClick state popped, disabling StopLingering timer.");
		//Disable all active timers to stop lingering if they are active.
		if(IsTimerActive(nameof(StopLingering)))
		{
			ClearTimer(nameof(StopLingering));
		}
	}

	event PushedState()
	{
		//Set a function timer. If the pawn is stuck it will stop moving
		//by itself.
		SetTimer(3, false, nameof(StopLingering));
		if (Pawn != None)
		{
			// make sure the pawn physics are initialized
			//Pawn.SetMovementPhysics(); //HACE SALTO RARO AL COMENZAR A ANDAR
		}
	}

Begin:
	while(!bPawnNearDestination)
	{
		//`Log("Simple Move in progress");
		MoveTo(GetDestinationPosition());
		
	}

	//`Log("MoveMouseClick: Pawn is near destination, go out of this state");
	PopState();
}

/******** ESTADO ATACAR *************/
state AttackEnemy
{
	event PoppedState()
	{
		//`Log("AttackEnemy state popped, disabling StopLingering timer.");
		//Disable all active timers to stop lingering if they are active.
		if(IsTimerActive(nameof(StopLingering)))
		{
			ClearTimer(nameof(StopLingering));
		}
		bLeftMousePressed = false;
	}

	event PushedState()
	{
		SetTimer(3, false, nameof(StopLingering));
	}

Begin:
	while(!bPawnNearDestination)
	{
		//`Log("Go To Target");
		MoveTo(targetTogo);

	}
	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Attack);
	//`Log("AttackEnemy: Pawn is near enemy, go out of this state");
	PopState();
	
}
/************************************/

/******************************************************************
 *
 *  TUTORIAL STATE (MoveMousePressedAndHold)
 *
 *  MoveMousePressedAndHold is the state when a mouse button is pressed
 *  and kept to move the pawn freely.
 *
 *
 ******************************************************************/
state MoveMousePressedAndHold
{
Begin:
	if(!bPawnNearDestination)
	{
		//`Log("MoveMousePressedAndHold at pos"@GetDestinationPosition());
		MoveTo(GetDestinationPosition());
	}
	else
	{
		PopState();
	}
}

simulated function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,damageType,Momentum);

	MyHud(myHUD).MyHudHealth.SetDamage(Damage);
}

exec function PauseGame()
{
  	MyHud(myHUD).MyHudHealth.PauseGameControlPlayer();
}

DefaultProperties
{
	CameraClass=class'DoorOfLiesPlayerCamera'
	InputClass = class'DoorOfLiesPlayerInput';
	RotationSpeed = 10;
}