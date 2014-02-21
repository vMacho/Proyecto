class HumanoidPawn extends Attackable;

var (Humanoid) float  distanceTosee;


function SlowGroud(float speedModifier)
{

	GroundSpeed += speedModifier;
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