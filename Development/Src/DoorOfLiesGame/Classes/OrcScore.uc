 /* Victor Macho
	Clase HUD del Contador de calabazas en Flash 
Se definen las funciones del flash
 */

Class OrcScore extends GFxMoviePlayer;

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

function SetContador(int calabazas) //Se pone la cantidad de calabazas igual a un valor (Otra forma)
{
	local GFxObject MC_Root;
	local GFxObject _contador;

	MC_Root = GetVariableObject("root");

	if(MC_Root != none)
	{
		_contador = MC_Root.GetObject("_contador");

		if(_contador != none)
		{
			_contador.SetFloat("SetLabel", calabazas);
		}
	}
}

DefaultProperties
{
	MovieInfo = SwfMovie'pack_Contador.contador'
	bDisplayWithHudOff = false;

	RenderTexture = TextureRenderTarget2D'cotadorMaterial.Texture.cotadorTexture'

	RenderTextureMode = RTM_AlphaComposite;
}