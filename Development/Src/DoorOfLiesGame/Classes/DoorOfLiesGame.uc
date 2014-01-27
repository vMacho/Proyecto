class DoorOfLiesGame extends GameInfo
					 config(DoorOfLiesGame);

var MU_Minimap GameMinimap;
var globalconfig int MaxCalabazas;
var globalconfig int MaxCalabazasPlayer;

function InitGame( string Options, out string ErrorMessage )
{
	local MU_Minimap ThisMinimap;
   	Super.InitGame(Options,ErrorMessage);

	foreach AllActors(class'MU_Minimap',ThisMinimap)
	{
		GameMinimap = ThisMinimap;
		break;
	}
}

event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
}

DefaultProperties
{
	bDelayedStart=false
	PlayerControllerClass=class'DoorOfLiesPlayerController'
	DefaultPawnClass=class'DoorOfLiesPawn'
	HUDType=class'MyHud'
}