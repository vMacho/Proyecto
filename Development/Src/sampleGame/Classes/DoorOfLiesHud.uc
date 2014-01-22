 /* Victor Macho
	Clase HUD en Flash 
Se definen las funciones del flash
 */

Class DoorOfLiesHud extends GFxMoviePlayer;

var GFxObject MC_Root;
var GFxObject _HUDHealth;
var private vector2d _mousePosition;

event bool Start(optional bool StartPaused = false) //Constructor
{
	super.Start(StartPaused);
	Advance(0);

	return true;
}

function UpdateLife(int Health) //Se pone la vida igual a un valor
{
	MC_Root = GetVariableObject("root");

	if(MC_Root != none)
	{
		_HUDHealth = MC_Root.GetObject("_HUDHealth");

		if(_HUDHealth != none)
		{
			_HUDHealth.setFloat("currentHealth", Health);
		}
	}
}

function SetDamage(int damage) //Se resta a la vida un valor
{
	MC_Root = GetVariableObject("root");

	if(MC_Root != none)
	{
		_HUDHealth = MC_Root.GetObject("_HUDHealth");

		if(_HUDHealth != none)
		{
			_HUDHealth.setFloat("SetDamage", damage);
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

	PlayerController = GetPC();

	PlayerController.SetPause(mode);
}

function vector2d GetMouseCoordinates()
{
	return _mousePosition;
}

DefaultProperties
{
	MovieInfo = SwfMovie'pack_DoorOfLiesHud.HealthHud'
	bDisplayWithHudOff = false;
}