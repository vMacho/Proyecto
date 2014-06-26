 /* Victor Macho
	Clase HUD en Flash 
Se definen las funciones del flash
 */

Class DoorOfLiesHud extends GFxMoviePlayer;

var GFxObject MC_Root;
var private vector2d _mousePosition;
var bool IsGamePaused;
var MU_Minimap GameMinimap;
struct Mision
{
  var string MinTit;
  var string MinDesc;
};
var array<Mision> Misiones;
event bool Start(optional bool StartPaused = false) //Constructor
{
	super.Start(StartPaused);
	
	Advance(0);
	SetTimingMode(TM_Real);
	Actualizar();

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

function ActiveSkill(int i)
{
	switch (i)
	{
		case 1:
			ActionScriptVoid("_root._POWER_FIRE.ActiveSkill");
			break;
		case 2:
			ActionScriptVoid("_root._POWER_WATER.ActiveSkill");
			break;
		case 3:
			ActionScriptVoid("_root._POWER_WIND.ActiveSkill");
			break;
	
		case 4:
			ActionScriptVoid("_root._POWER_EARTH.ActiveSkill");
			break;
		default:
			
	}
}

function ColdownSkill(int i,int cooldown)
{
	local GFxObject _HUDspell;
	switch (i)
	{
		case 1:
		
		MC_Root = GetVariableObject("root");
       
		if(MC_Root != none)
		{

			_HUDspell = MC_Root.GetObject("_POWER_FIRE");
			if(_HUDspell != none)
			{
					_HUDspell.SetInt("cooldown",cooldown);
			}
		}
		ActionScriptVoid("_root._POWER_FIRE.shoot_spell");
			break;
		case 2:

		MC_Root = GetVariableObject("root");
       
		if(MC_Root != none)
		{

			_HUDspell = MC_Root.GetObject("_POWER_WATER");
			if(_HUDspell != none)
			{
					_HUDspell.SetInt("cooldown",cooldown);
			}
		}
		ActionScriptVoid("_root._POWER_WATER.shoot_spell");
			break;
		case 3:

		MC_Root = GetVariableObject("root");
       
		if(MC_Root != none)
		{

			_HUDspell = MC_Root.GetObject("_POWER_WIND");
			if(_HUDspell != none)
			{
					_HUDspell.SetInt("cooldown",cooldown);
			}
		}
		ActionScriptVoid("_root._POWER_WIND.shoot_spell");
			break;
		case 4:

		MC_Root = GetVariableObject("root");
       
		if(MC_Root != none)
		{

			_HUDspell = MC_Root.GetObject("_POWER_EARTH");
			if(_HUDspell != none)
			{
					_HUDspell.SetInt("cooldown",cooldown);
			}
		}
		ActionScriptVoid("_root._POWER_EARTH.shoot_spell");
			break;
		default:	
	}
}
function AddMision(string Descripcion,string Detalles)
{
		local Mision temp;
		temp.MinTit=Descripcion;
		temp.MinDesc=Detalles;
		Misiones.AddItem(temp);
		
}
function DelMision(string titulo)
{
	local int i;
		for (i = 0; i < Misiones.Length; i++)
	  	{
	  		if(Misiones[i].MinTit==titulo)
	  		{
	  			Misiones.RemoveItem(Misiones[i]);
	  		}
	  	}   
}
function Actualizar()
{
	local int i;
	local GFxObject _HUDQuest;
	local GFxObject Mis,temp;
	Mis = CreateArray();
   
	  for (i = 0; i < Misiones.Length; i++)
	  {        
	    Temp = CreateObject("Object");
	    Temp.SetString("MinTit", Misiones[i].MinTit);
	    Temp.SetString("MinDesc", Misiones[i].MinDesc);
	    Mis.SetElementObject(i, Temp);

	  }
		MC_Root = GetVariableObject("root");
       
		if(MC_Root != none)
		{

			_HUDQuest = MC_Root.GetObject("_HUDQuestMenu");
			if(_HUDQuest != none)
			{
					_HUDQuest.SetObject("misiones",Mis);
			}
		}
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
	bDisplayWithHudOff = false
}
