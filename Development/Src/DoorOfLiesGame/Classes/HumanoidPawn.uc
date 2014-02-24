class HumanoidPawn extends Attackable;

var (Humanoid) float  distanceTosee;
var (Humanoid) float  default_humanoid_GroundSpeed;


simulated event PostBeginPlay()
{
    super.PostBeginPlay();

	default_humanoid_GroundSpeed = GroundSpeed;
}

function SlowGroud(float speedModifier, float time)
{

	GroundSpeed -= speedModifier;
	SetTimer(time, false, 'RestartSpeed');

}

function RestartSpeed()
{
	GroundSpeed = default_humanoid_GroundSpeed;
}

function SetWeapon(class <Weapon> arma)
{
	InvManager.CreateInventory(arma); //InvManager is the pawn's InventoryManager	
}

DefaultProperties
{
    distanceTosee = 1000

    bCollideActors = true;
    bBlockActors = true;
}