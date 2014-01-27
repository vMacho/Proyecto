 /* Victor Macho
	Clase HUD en Flash 
Se definen las funciones del flash
 */

Class DoorOfLiesHudMenu extends GFxMoviePlayer;

event bool Start(optional bool StartPaused = false) //Constructor
{
	super.Start(StartPaused);
	Advance(0);
	SetTimingMode(TM_Real);

	return true;
}

function StartGame()
{
	ConsoleCommand("open IsometricTest");
}

DefaultProperties
{
	MovieInfo = SwfMovie'pack_MenuPrincipal.MenuPrincipal'
	bDisplayWithHudOff = false;
}