class DoorOfLiesMenu extends GameInfo;

function InitGame( string Options, out string ErrorMessage )
{
	Super.InitGame(Options,ErrorMessage);
}

DefaultProperties
{
	bDelayedStart=false
	PlayerControllerClass=class'MenuController'
	DefaultPawnClass=class'MenuPawn'
	HUDType=class'HUDMenu'
}