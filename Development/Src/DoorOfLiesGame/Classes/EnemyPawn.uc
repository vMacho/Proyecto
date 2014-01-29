 /* Victor Macho
    Clase PAWN del Enemigo
Define Modelo - Animaciones - Afecta Luz o no
 */

class EnemyPawn extends RecolectorPawn
  ClassGroup(EnemyPumpkin)
  placeable;
   
var(EnemyPumpkin) class<AIController> NPCController;
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    maxCalabazas = DoorOfLiesGame(WorldInfo.Game).MaxCalabazasPlayer;
}

DefaultProperties
{
    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
        CollisionRadius=+50
        CollisionHeight=+20
    End Object
    CylinderComponent=CollisionCylinder
 
    Begin Object Class=SkeletalMeshComponent Name=EnemySkeletalMesh
        //PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
        SkeletalMesh=SkeletalMesh'Orco.SkeletalMesh.micro_orc';
        AnimTreeTemplate=AnimTree'Orco.AnimTree';
        AnimSets(0)=AnimSet'Orco.SkeletalMesh.Idle';
        HiddenGame=FALSE
        HiddenEditor=FALSE
    End Object
    Mesh=EnemySkeletalMesh
    Components.Add(EnemySkeletalMesh)
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'HumoGato.EjemploParticulas';
    End Object
    Components.Add(ParticlesFollow)

    bJumpCapable=false
    bCanJump=false
 
    GroundSpeed=150.0 //Para hacerlo mas lento que el player
    DrawScale = 1.5;
    ControllerClass=class'EnemyController'

    Tag = "EnemyPawn";
}