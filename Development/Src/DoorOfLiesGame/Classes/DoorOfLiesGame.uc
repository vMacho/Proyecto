class DoorOfLiesGame extends GameInfo;

var MU_Minimap GameMinimap;

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

DefaultProperties
{
	bDelayedStart=false
	PlayerControllerClass=class'DoorOfLiesPlayerController'
	DefaultPawnClass=class'DoorOfLiesPawn'
	HUDType=class'MyHud'
}