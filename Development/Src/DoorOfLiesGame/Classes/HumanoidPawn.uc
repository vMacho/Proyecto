class HumanoidPawn extends Pawn;

var (Humanoid) float  distanceTosee;
var (Humanoid) float WeaponRange;


DefaultProperties
{
	WeaponRange = 400
    distanceTosee = 1000

    bCollideActors = true;
    bBlockActors = true;
}