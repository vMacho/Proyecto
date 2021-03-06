 /* Victor Macho
    Clase del control del player
 */

class DoorOfLiesPlayerController extends PlayerController;

/********************* MOVIMIENTO PATHFINDING **********************************/
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
/*****************************************************************/

var Attackable Target;

var bool use_button;
var float RotationSpeed;

var array<Quest> misiones;

/************** HABILIDADES *************************/

var bool hability_finished;

struct Hability
{
   var bool active;
   var bool activable;
   var int manas;
   var name name;
   var float cooldown;
   var float actual_cooldown;
};

enum Habilities
{
	Fuego,
	Agua,
	Aire,
	Tierra
};

var array <Hability> powers;

var AreaAmistosa area_activa;
var int Hability_active;
var float time_inmune;

function Set_Habilities()
{
	local int i;

	powers.length = 4;

	for( i = 0; i < powers.length; i++ )
	{
		powers[i].active = false;

		powers[i].manas = 5;
	}

	powers[Fuego].name = 'Fuego';
    powers[Fuego].cooldown = 5;

    powers[Agua].name = 'Agua';
    powers[Agua].cooldown = 5;


    powers[Tierra].name = 'Tierra';
    powers[Tierra].cooldown = 6;


    powers[Aire].name = 'Aire';
    powers[Aire].cooldown = 3;

    powers[Fuego].activable = DoorOfLiesPawn(Pawn).hability_fire;
    powers[Agua].activable = DoorOfLiesPawn(Pawn).hability_water;
    powers[Tierra].activable = DoorOfLiesPawn(Pawn).hability_earth;
    powers[Aire].activable = DoorOfLiesPawn(Pawn).hability_wind;
}

function bool change_habilty ( int Hability_to_active )
{
	local int i;
	
	if( area_activa != none ) area_activa.CancelCast();

	if( powers[Hability_to_active].activable )
	{
		if( powers[Hability_to_active].actual_cooldown <= 0 )
		{
			if( powers[Hability_to_active].manas > 0 )
			{
				for(i = 0; i < powers.length; i++ ) powers[i].active = false;
				powers[Hability_to_active].active = true;
				Hability_active = Hability_to_active;
			}
			else
			{
				powers[Hability_to_active].active = false;
				AddDanger("No Mana");
			}
		}
		else
		{
			powers[Hability_to_active].active = false;
			AddDanger("No esta listo todavia");
		}
	}
	else
	{
		powers[Hability_to_active].active = false;
		`log("HABILIDAD NO ACTIVA TODAVIA");
	}

	return powers[Hability_to_active].active;
}

function UpdateHabilities( float DeltaTime )
{
	local int i;

	for(i = 0; i < powers.length; i++ )
	{
		if ( powers[i].actual_cooldown  > 0 ) powers[i].actual_cooldown -= DeltaTime;
	}

	if( DoorOfLiesPawn(Pawn).inmune )
	{
		if( time_inmune <= 0 )
		{
			DoorOfLiesPawn(Pawn).inmune = false;
			time_inmune = default.time_inmune;
			DoorOfLiesPawn(Pawn).sistema_particulas_inmune.DeactivateSystem();
		}
		else time_inmune -= DeltaTime;
	}
}

exec function Q_Hability ()
{	
	if( change_habilty(Fuego) ) //Si esta valida la habilidad
	{
		area_activa = Spawn(class 'AreaAmistosa',,,pawn.Location);
		area_activa.Constructor(400,1200,true,true,0,0.5,2,DecalMaterial'Decals.Materials.Area_lanzamiento',400,ParticleSystem'fuego2.ParticleSystem.ParticleFireFlame',0, 25);
		area_activa.targetPoint = MouseHitWorldLocation;
		area_activa.emitterPawn = pawn;
		area_activa.habilidad_player = Fuego;

		MyHud(myHUD).MyHudHealth.ActiveSkill(Fuego);
	}
}

exec function W_Hability ()
{	
	if( change_habilty(Agua) )
	{
		area_activa = Spawn(class 'AreaAmistosa',,,pawn.Location);
		area_activa.Constructor(100,100,true,false,0,0.5,2,DecalMaterial'Decals.Materials.Area_Ciruclar',400,ParticleSystem'Murosuelo.Particles.Muro_part',2, 0);  //EFECTO RALENTIZA.
		area_activa.targetPoint = MouseHitWorldLocation;
		area_activa.emitterPawn = pawn;
		area_activa.habilidad_player = Agua;

		MyHud(myHUD).MyHudHealth.ActiveSkill(Agua);
	}
}

exec function E_Hability ()
{
	if( change_habilty(Aire) )
	{
		area_activa = Spawn(class 'AreaAmistosa',,,pawn.Location);
		area_activa.Constructor(50,50,true,false,1,0.15,1,DecalMaterial'Decals.Materials.Area_Ciruclar',400,ParticleSystem'rotura.Particles.flash',1, 0);  //EFECTO TELEPORT
		area_activa.targetPoint = MouseHitWorldLocation;
		area_activa.emitterPawn = pawn;
		area_activa.habilidad_player = Aire;

		MyHud(myHUD).MyHudHealth.ActiveSkill(Aire);
	}
}

exec function R_Hability ()
{
	if( change_habilty(Tierra) )
	{
		DoorOfLiesPawn(Pawn).inmune = true;
		DoorOfLiesPawn(Pawn).sistema_particulas_inmune.ActivateSystem();

		powers[Tierra].manas--;
        powers[Tierra].actual_cooldown = powers[Tierra].cooldown;

        MyHud(myHUD).MyHudHealth.ActiveSkill(Tierra);
        MyHud(myHUD).MyHudHealth.ColdownSkill(Tierra, powers[Tierra].actual_cooldown);
	}
}

/*****************************************************************/

exec function Use_action(bool mode)
{
	use_button = mode;
}

function CreateQuest( int id, string title, string description )
{
	local Quest mision;

	mision = new class 'Quest';

	mision.Quest( id, title, description );

	misiones.AddItem( mision );
	MyHud(myHUD).MyHudHealth.AddMision(title, description);
}

function bool FinishQuest( int id )
{
	local int i;
	local bool exito;

	exito = false;

	for( i = 0; i < misiones.Length; i++ )
	{
		if( misiones[i]._id == id )
		{
			misiones[i].doIt = true;
			exito = true;	
			MyHud(myHUD).MyHudHealth.DelMision(misiones[i]._title);
		}
	}

	return exito;
}

function AddDanger(string text)
{
    local vector postexto;
    postexto = pawn.location;
    MyHud(MyHud).AddTexto( text, 1, postexto );
}

function UpdateRotation( float DeltaTime ) {} //Truncamos la rotacion

function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot ) {} //Truncamos la rotacion

event PlayerTick( float DeltaTime ) //Cada frame
{
	super.PlayerTick(DeltaTime);

	if( Pawn.Health <= 0 ) GotoState('Dead');

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

	UpdateHabilities(DeltaTime);
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

	Spawn(class'PointerActor',,,MouseHitWorldLocation,,,);

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
	
	bPawnNearDestination = DistanceRemaining < 15.0f;

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
/****************************************************/

/******** ESTADO CastingHability*************/
state CastingHability //extends PlayerWalking
{

Begin:

	ResetMove();
	
	DoorOfLiesPawn(Pawn).SetAnimationState(ST_Attack);
	
	if( hability_finished )
	{
		hability_finished = false;
		powers[Hability_active].manas--;
        powers[Hability_active].actual_cooldown = powers[Hability_active].cooldown;
        MyHud(myHUD).MyHudHealth.ColdownSkill(Hability_active, powers[Hability_active].actual_cooldown);

		GotoState('idle');
	}
}
/****************************************************/

/******** ESTADO Eating*************/
state Eating
{
	function StartFire(optional byte FireModeNum)
	{
		bRightMousePressed = false;
	}

	function StopFire(optional byte FireModeNum)
	{
		bRightMousePressed = false;
	}

	event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode, PlayerTime, ExcessTime);
        
        GotoState('idle');
    }

    event PlayerTick( float DeltaTime )
	{
		UpdateHabilities(DeltaTime);
	}

	function PlayerMove(float DeltaTime){ }

	Begin:
		bRightMousePressed = false;
		ResetMove();
		MoveTo(Pawn.Location, Pawn);
        DoorOfLiesPawn(Pawn).SetAnimationState(ST_Eating);
}

State Dead
{
	function StartFire(optional byte FireModeNum)
	{
		bRightMousePressed = false;
	}

	function StopFire(optional byte FireModeNum)
	{
		bRightMousePressed = false;
	}

	event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
    {
        super.OnAnimEnd(SeqNode, PlayerTime, ExcessTime);
        
        GotoState('idle');
    }

    event PlayerTick( float DeltaTime )
	{
		UpdateHabilities(DeltaTime);
	}

	function PlayerMove(float DeltaTime){ }

	Begin:
		bRightMousePressed = false;
		ResetMove();
		MoveTo(Pawn.Location, Pawn);
        DoorOfLiesPawn(Pawn).SetAnimationState(ST_Eating);
}
/***********************************************************************/

/*******************************************************************************************/
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
	if( !DoorOfLiesPawn(Pawn).inmune )
	{
		//Pawn.Health -= damage;
		MyHud(myHUD).MyHudHealth.SetDamage(damage);
	}
}

simulated function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,damageType,Momentum);

	 if( !DoorOfLiesPawn(Pawn).inmune ) MyHud(myHUD).MyHudHealth.SetDamage(Damage);
}

DefaultProperties
{
	hability_finished	= false;
	CameraClass			= class'DoorOfLiesPlayerCamera'
	InputClass 			= class'DoorOfLiesPlayerInput';
	RotationSpeed 		= 10;

	time_inmune = 3;
}