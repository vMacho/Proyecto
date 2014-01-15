Class DoorOfLiesAnimNodeSequence extends AnimNodeSequence;

event OnBecomeRelevant()
{
	super.OnBecomeRelevant();
	SetPosition(0.0, false);
	bPlaying = true;
}

DefaultProperties
{
	bCallScriptEventOnBecomeRelevant = true;
}