 /* Victor Macho
	Clase HUD del Contador de calabazas en Flash 
Se definen las funciones del flash
 */

Class OrcScore extends GFxMoviePlayer;

var Material MatInst;

event bool Start(optional bool StartPaused = false) //Constructor
{
	super.Start(StartPaused);
	Advance(0);

	return true;
}

function UpdateContador(int calabazas) //Se pone la cantidad de calabazas igual a un valor
{
	ActionScriptVoid("_root._contador.SetLabel");
}

DefaultProperties
{
	MovieInfo = SwfMovie'pack_Contador.contador';
	bDisplayWithHudOff = false;

	RenderTextureMode = RTM_AlphaComposite;
}