 /* Victor Macho
    Clase PAWN del Enemigo
Define Modelo - Animaciones - Afecta Luz o no
 */

class Boss extends HumanoidPawn
  ClassGroup(Enemy)
  placeable;

enum EAnimState
{
    ST_Normal,
    ST_Spawn,
    ST_Die,
    ST_Attack_cerca
};

function SetAnimationState(EAnimState eState)
{
    if(AnimNodeBlendList != none) AnimNodeBlendList.SetActiveChild(eState, 0.1f);
}

DefaultProperties
{ 
    Components.Remove(Sprite)
    
    Begin Object Class=SkeletalMeshComponent Name=EnemySkeletalMesh
        SkeletalMesh     = SkeletalMesh'Boss_Final_Pantano.SkeletalMesh.boss_rig'
        AnimTreeTemplate = AnimTree'Boss_Final_Pantano.animaciones.AnimTree'
        AnimSets(0)      = AnimSet'Boss_Final_Pantano.animaciones.AnimationSet_BossFinal'
        Translation      = (Z=-1800)

        HiddenGame       = FALSE
        HiddenEditor     = FALSE
    End Object
    Mesh=EnemySkeletalMesh
    Components.Add(EnemySkeletalMesh)

    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
        CollisionRadius=100
        CollisionHeight=150
    End Object
    CylinderComponent=CollisionCylinder
    Components.Add(CollisionCylinder) 

    bJumpCapable = false
    bCanJump     = false
 
    GroundSpeed = 400.0 //Para hacerlo mas lento que el player
    DrawScale   = 0.06
    ControllerClass = class'Boss_Controller'

    AttackRange = 500
}