 /* Victor Macho
    Clase PAWN del Enemigo
Define Modelo - Animaciones - Afecta Luz o no
 */

class PlantaLuz extends Pawn
  ClassGroup(EnemyBabosa)
  placeable;
   
var AnimNodeBlendList AnimNodeBlendList;
var (PlantaFoco) int ActivateRange;
var (PlantaFoco) color color_foco;

enum EAnimState
{
    ST_Born,
    ST_Idle,
    ST_Do_Nothing
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

    //if(DoorOfliesPawn(Other) != none) controller.GotoState('Explode');
}

function TurnOnLight()
{
    local SpotLightComponent foco;
    local Vector NewPosition;

    foco = new class 'SpotLightComponent';
    NewPosition.Y -= 50;
    foco.SetTranslation(NewPosition);
   
    foco.SetLightProperties(20.0, color_foco);

    Mesh.AttachComponentToSocket( foco, 'head_socket' );
}

DefaultProperties
{ 
    Components.Remove(Sprite)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
        SkeletalMesh        = SkeletalMesh'PlantaLuz.SkeletalMesh.PlantLuz_Rig'
        AnimTreeTemplate    = AnimTree'PlantaLuz.animaciones.PlantaLuz_AnimTree'
        AnimSets(0)         = AnimSet'PlantaLuz.animaciones.AnimSet_PlantaLuz'
        Translation = (Z=-2500)

        HiddenGame      = FALSE
        HiddenEditor    = FALSE
    End Object
    Mesh=InitialSkeletalMesh
    Components.Add(InitialSkeletalMesh)

    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
        CollisionRadius = 100
        CollisionHeight = 100
    End Object
    CylinderComponent=CollisionCylinder
 
    bJumpCapable = false
    bCanJump     = false
 
    GroundSpeed = 0 //Para que no se mueva
    DrawScale   = 0.04
    ControllerClass=class'PlantaLuzController'

    ActivateRange = 800;

    color_foco = (R=100,G=100,B=205,A=255)
}