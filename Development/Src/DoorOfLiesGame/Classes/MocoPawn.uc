class MocoPawn extends Attackable;

var (Moco) float  distanceTosee;
var (Moco) float AttackRange;
var (Moco) float AttackTime;
var (Moco) class<Actor> bulletClass;


DefaultProperties
{
	AttackRange = 400
    distanceTosee = 1000
    AttackTime = 3;

    bCollideActors = true;
    bBlockActors = true;
}