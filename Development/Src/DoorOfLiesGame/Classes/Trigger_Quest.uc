class Trigger_Quest extends Trigger;

enum acctions
{
	Start,
	Finish,
	Do_Nothing
};

var (Quest) acctions action;
var (Quest) int _id;
var (Quest) string _title;
var (Quest) string _description;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local DoorOfLiesPlayerController player;
	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if( DoorOfLiesPawn(Other) != none)
	{
		player = DoorOfLiesPlayerController( DoorOfLiesPawn(Other).Controller );
		switch (action)
		{
			case Start:
				player.CreateQuest( _id, _title, _description );
				Destroy();
			break;
			case Finish:
				if( player.FinishQuest( _id ) ) Destroy();
			break;
			default:
				
		}
	}
}

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'Icons.Icons_Quest.Quest'
		scale=0.2
	End Object
	Components.Add(Sprite)
}