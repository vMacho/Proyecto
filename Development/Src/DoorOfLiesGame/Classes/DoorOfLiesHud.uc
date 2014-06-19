 /* Victor Macho
	Clase HUD en Flash 
Se definen las funciones del flash
 */

Class DoorOfLiesHud extends GFxMoviePlayer;

var GFxObject MC_Root;
var private vector2d _mousePosition;
var bool IsGamePaused;

var MU_Minimap GameMinimap;
event bool Start(optional bool StartPaused = false) //Constructor
{
	super.Start(StartPaused);
	Advance(0);
	SetTimingMode(TM_Real);

	return true;
}

function UpdateLife(int Health) //Se pone la vida igual a un valor
{
	local GFxObject _HUDHealth;

	MC_Root = GetVariableObject("root");

	if(MC_Root != none)
	{
		_HUDHealth = MC_Root.GetObject("_HUDHealthtop");

		if(_HUDHealth != none)
		{
			_HUDHealth = _HUDHealth.GetObject("_HUDHealth");

			if(_HUDHealth != none)
			{
				_HUDHealth.setFloat("currentHealth", Health);
			}
		}
	}
}

function SetDamage(int damage) //Se resta a la vida un valor
{
	local GFxObject _HUDHealth;
	MC_Root = GetVariableObject("root");

	if(MC_Root != none)
	{
		_HUDHealth = MC_Root.GetObject("_HUDHealthtop");

		if(_HUDHealth != none)
		{
			_HUDHealth = _HUDHealth.GetObject("_HUDHealth");

			if(_HUDHealth != none)
			{
				_HUDHealth.setFloat("SetDamage", damage);
			}
		}
	}
}

function OnMouseMove(int X, int Y)
{
	_mousePosition.X = X;
	_mousePosition.Y = Y;
}

function PauseGameControl(bool mode)
{
	local PlayerController PlayerController;
	
	IsGamePaused = mode;

	PlayerController = GetPC();
	PlayerController.SetPause(IsGamePaused);
    
}

function PauseGameControlPlayer()
{
	local PlayerController PlayerController;

	ActionScriptVoid("_root._btnPause.PauseGame");

	IsGamePaused = !IsGamePaused;

	PlayerController = GetPC();
	PlayerController.SetPause(IsGamePaused);
	

}

function MainMenu()
{
	ConsoleCommand("open MainMenu");
}

function vector2d GetMouseCoordinates()
{
	return _mousePosition;
}


DefaultProperties
{
	MovieInfo = SwfMovie'DoorOfLiesHud_gabas.HealthHud'
	bDisplayWithHudOff = false;
 

}
