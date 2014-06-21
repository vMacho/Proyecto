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
    ST_Die
};

var PointLightComponent headlight;
var (Comestible) TipoComestible type;

simulated event PostBeginPlay()
{
    local color head_Color;
    super.PostBeginPlay();
    
    switch (type)
    {
        case Com_Fuego:
            head_Color = MakeColor( 255, 0, 0, 255 );
        break;
        case Com_Tierra:
            head_Color = MakeColor( 255, 125, 0, 255 );
        break;
        case Com_Agua:
            head_Color = MakeColor( 0, 0, 255, 255 );
        break;
        case Com_Viento:
            head_Color = MakeColor( 255, 255, 255, 255 );
        break;           
    }

    headlight.SetLightProperties( 1.0, head_Color );
}

function SetAnimationState(EAnimState eState)
{
    if(AnimNodeBlendList != none) AnimNodeBlendList.SetActiveChild(eState, 0.1f);
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
 
    GroundSpeed = 50.0 //Para hacerlo mas rapido que el player
    DrawScale   = 0.5
    ControllerClass = class'Comestible_Controller'

    AttackRange = 0
}