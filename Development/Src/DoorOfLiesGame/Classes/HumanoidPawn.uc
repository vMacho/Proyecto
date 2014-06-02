class HumanoidPawn extends Attackable;

var (Humanoid) AnimNodeBlendList AnimNodeBlendList;
var (Humanoid) float  distanceTosee;
var (Moco) float AttackRange;
var (Moco) float AttackTime;

function SetWeapon(class <Weapon> arma)
{
	InvManager.CreateInventory(arma); //InvManager is the pawn's InventoryManager	
}

event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
{
    super.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);

    if(Controller != none)
    {
        Controller.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);
    }
}

simulated event Destroyed()
{
  Super.Destroyed();

  AnimNodeBlendList = None;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
  AnimNodeBlendList = AnimNodeBlendList(SkelComp.FindAnimNode('AnimNodeBlendList'));
}

DefaultProperties
{
    AttackRange = 400
    distanceTosee = 1000
    AttackTime = 3

    bCollideActors = true;
    bBlockActors = true;
}