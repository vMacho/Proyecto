 /* Victor Macho
	Clase HUD en Flash 
Se definen las funciones del flash
 */

Class ExternalInterfaceGFX extends GFxMoviePlayer;

var GFxObject _Mouse;
var private vector2D mousePosition;

event bool Start(optional bool StartPaused = false) //Constructor
{
	super.Start(StartPaused);
	Advance(0);

	return true;
}


function OnMouseMove(int X, int Y)
{
	mousePosition.X = X;
	mousePosition.Y = Y;
}

function OnMouseUp(int X, int Y)
{

}

function OnMouseDown(int X, int Y)
{
	
}

function vector2D GetMouseCoordinates()
{
	return mousePosition;
}

DefaultProperties
{
	MovieInfo = SwfMovie'EsneHUD.EsneHUD';
}