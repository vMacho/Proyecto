 /* Victor Macho
    Clase PAWN del Enemigo
Define Modelo - Animaciones - Afecta Luz o no
 */

class AnfibioPantano_Pawn extends HumanoidPawn
  ClassGroup(Enemy)
  placeable;

enum EAnimState
{
    ST_Normal,
    ST_Attack_distancia,
    ST_Die,
    ST_Attack_cerca
};

function SetAnimationState(EAnimState eState)
{
    if(AnimNodeBlendList != none) AnimNodeBlendList.SetActiveChild(eState, 0.1f);
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
}

DefaultProperties
{ 
    Components.Remove(Sprite)
    
    Begin Object Class=SkeletalMeshComponent Name=EnemySkeletalMesh
        SkeletalMesh     = SkeletalMesh'Anfibio_Pantano.SkeletalMesh.Modelo'
        AnimTreeTemplate = AnimTree'Anfibio_Pantano.SkeletalMesh.AnimTree'
        AnimSets(0)      = AnimSet'Anfibio_Pantano.SkeletalMesh.NewAnimSet'
        Translation      = (Z=-10)

        HiddenGame       = FALSE
        HiddenEditor     = FALSE
    End Object
    Mesh=EnemySkeletalMesh
    Components.Add(EnemySkeletalMesh)

    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
        CollisionRadius=50
        CollisionHeight=+50
    End Object
    CylinderComponent=CollisionCylinder
    Components.Add(CollisionCylinder) 

    bJumpCapable = false
    bCanJump     = false
 
    GroundSpeed = 200.0 //Para hacerlo mas lento que el player
    DrawScale   = 6
    ControllerClass = class'AnfibioPantano_Controller'

    AttackRange = 500
}