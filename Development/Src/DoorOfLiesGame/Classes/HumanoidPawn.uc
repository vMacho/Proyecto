class HumanoidPawn extends Pawn;

var (Humanoid) float  distanceTosee;


function SlowGroud(float speedModifier)
{

	GroundSpeed += speedModifier;
}

DefaultProperties
{
    distanceTosee = 1000

    bCollideActors = true;
    bBlockActors = true;
}