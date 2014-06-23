 /* Victor Macho
    Clase PAWN del Enemigo
Define Modelo - Animaciones - Afecta Luz o no
 */

class Comestible extends HumanoidPawn
  ClassGroup(Comestibles)
  placeable;

enum TipoComestible
{
    Com_Fuego,
    Com_Tierra,
    Com_Agua,
    Com_Viento
};

enum EAnimState
{
    ST_Normal,
    ST_Die,
    ST_Flee
};

var PointLightComponent headlight;
var (Comestible) TipoComestible type;
var (Comestible) Material Material_Fuego;
var (Comestible) Material Material_Agua;
var (Comestible) Material Material_Tierra;
var (Comestible) Material Material_Viento;

simulated event PostBeginPlay()
{
    local color head_Color;
    local Material new_mat;

    super.PostBeginPlay();
    
    switch (type)
    {
        case Com_Fuego:
            head_Color = MakeColor( 205, 162, 162, 255 );
            new_mat = Material_Fuego;
        break;
        case Com_Agua:
            head_Color = MakeColor( 127, 205, 205, 255 );
            new_mat = Material_Agua;
        break;
        case Com_Tierra:
            head_Color = MakeColor( 205, 205, 153, 255 );
            new_mat = Material_Tierra;
        break;
        case Com_Viento:
            head_Color = MakeColor( 205, 205, 205, 255 );
            new_mat = Material_Viento;
        break;           
    }

    Mesh.SetMaterial(0, new_mat);

    headlight.SetLightProperties( 1.0, head_Color );
}

function SetAnimationState(EAnimState eState)
{
    if(AnimNodeBlendList != none) AnimNodeBlendList.SetActiveChild(eState, 0.1f);
}

simulated event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{ 
    super.Bump(Other, OtherComp, HitNormal);

    if(DoorOfliesPawn(Other) != none)
    {
        DoorOfliesPawn(Other).controller.GotoState('Eating');
        controller.GotoState('Explode');
    }
}

DefaultProperties
{ 
    Components.Remove(Sprite)
    
    Begin Object Class=SkeletalMeshComponent Name=EnemySkeletalMesh
        SkeletalMesh     = SkeletalMesh'Comestible.SkeletalMesh.Comestible_Rig'
        AnimTreeTemplate = AnimTree'Comestible.animationset.AnimTree'
        AnimSets(0)      = AnimSet'Comestible.animationset.ComestibleAnim'
        Translation      = ( Z = -10 )

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

    Begin Object Class=PointLightComponent Name=Foco //Foco Autoiluminacion
        Brightness      = 1.0;
        LightColor      = ( R=0, G=0, B=0 )
        Translation     = ( X = 0, Y = 0.0, Z = 50 )
        Radius          = 100        
    End Object
    Components.Add(Foco)
    headlight = Foco

    bJumpCapable = false
    bCanJump     = false
 
    GroundSpeed = 300.0 //Para hacerlo mas rapido que el player
    DrawScale   = 0.5
    ControllerClass = class'Comestible_Controller'

    AttackRange = 0

    Material_Fuego = Material'Comestible.Material.Mat_ComestibleFuego';
    Material_Tierra = Material'Comestible.Material.Mat_ComestibleTierra';
    Material_Agua = Material'Comestible.Material.Mat_ComestibleHielo';
    Material_Viento = Material'Comestible.Material.Mat_ComestibleViento';
}