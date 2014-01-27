 /* Victor Macho
    Clase PAWN del Enemigo
Define Modelo - Animaciones - Afecta Luz o no
 */

class EnemyPawn extends Pawn
  ClassGroup(EnemyPumpkin)
  placeable;
   
var(EnemyPumpkin) SkeletalMeshComponent NPCMesh;
var(EnemyPumpkin) class<AIController> NPCController;

function AddDefaultInventory()
{
    //InvManager.CreateInventory(class'SandboxPaintballGun');
    //For those in the back who don't follow, SandboxPaintballGun is a custom weapon
    //I've made in an earlier article, don't look for it in your UDK build.
}
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    AddDefaultInventory(); //GameInfo calls it only for players, so we have to do it ourselves for AI.
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

DefaultProperties
{
    Begin Object Name=CollisionCylinder
        CollisionHeight=+44.000000
    End Object
 
    Begin Object Class=SkeletalMeshComponent Name=GatoSkeletalMesh
        //PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
        SkeletalMesh=SkeletalMesh'Orco.SkeletalMesh.micro_orc';
        AnimTreeTemplate=AnimTree'Orco.AnimTree';
        AnimSets(0)=AnimSet'Orco.SkeletalMesh.Idle';
        HiddenGame=FALSE
        HiddenEditor=FALSE
    End Object
    Mesh=GatoSkeletalMesh
    Components.Add(GatoSkeletalMesh)

    ControllerClass=class'GatoBot'
    //InventoryManagerClass=class'SandboxInventoryManager'
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'HumoGato.EjemploParticulas';
    End Object
    Components.Add(ParticlesFollow)

    bJumpCapable=false
    bCanJump=false
 
    GroundSpeed=150.0 //Making the bot slower than the player
    DrawScale = 1.5; //Scale del Mesh
}