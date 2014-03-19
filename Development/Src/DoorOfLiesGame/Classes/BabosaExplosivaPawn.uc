 /* Victor Macho
    Clase PAWN del Enemigo
Define Modelo - Animaciones - Afecta Luz o no
 */

class BabosaExplosivaPawn extends MocoPawn
  ClassGroup(EnemyBabosa)
  placeable;
   
var AnimNodeBlendList AnimNodeBlendList;

enum EAnimState
{
    ST_Normal,
    ST_Attack,
    ST_Die
};

function SetAnimationState(EAnimState eState)
{
    if(AnimNodeBlendList != none)
    {
        AnimNodeBlendList.SetActiveChild(eState, 0.25f);
    }
}

event OnAnimEnd(AnimNodeSequence SeqNode, float PlayerTime, float ExcessTime)
{
    super.OnAnimEnd(SeqNode,PlayerTime,ExcessTime);

    //bAnimationEnded=true;

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

simulated event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
    super.Bump(Other, OtherComp, HitNormal);

    if(DoorOfliesPawn(Other) != none) controller.GotoState('Explode');
}

DefaultProperties
{ 
    Begin Object Class=SkeletalMeshComponent Name=EnemySkeletalMesh
        //PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
        SkeletalMesh=SkeletalMesh'Orco.SkeletalMesh.micro_orc'
        AnimTreeTemplate=AnimTree'Orco.AnimTree'
        AnimSets(0)=AnimSet'Orco.SkeletalMesh.Idle'
        
        HiddenGame=FALSE
        HiddenEditor=FALSE
    End Object
    Mesh=EnemySkeletalMesh
    Components.Add(EnemySkeletalMesh)

    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
        CollisionRadius=+75
        CollisionHeight=+50
    End Object
    CylinderComponent=CollisionCylinder
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'HumoGato.EjemploParticulas';
    End Object
    Components.Add(ParticlesFollow)

    bJumpCapable=false
    bCanJump=false
 
    GroundSpeed=200.0 //Para hacerlo mas lento que el player
    DrawScale = 0.5
    ControllerClass=class'BabosaExplosivaController'

    AttackRange = 600
    AttackTime = 1;
    distanceTosee = 1000
    bulletClass = class'Bullet_Moco_slow'
}