 /* Victor Macho
    Clase PAWN 
Define Modelo - Animaciones - Afecta Luz o no
 */

class DoorOfLiesPawn extends HumanoidPawn;

var (Player) SpotLightComponent flashlight;
var (Player) int strength;
var ParticleSystemComponent ParticlesFollowUs;

enum EAnimState
{
    ST_Normal,
    ST_Attack,
    ST_Die
};

function SetAnimationState(EAnimState eState)
{
    if(AnimNodeBlendList != none) AnimNodeBlendList.SetActiveChild(eState, 0.25f);
}

simulated event PostBeginPlay() //Al empezar
{
    super.PostBeginPlay();
    AddDefaultInventory();
}

simulated function name GetDefaultCameraMode( PlayerController RequestedBy ) // Tipo de camara por defecto
{
    return 'Isometric';
}

exec function SetFlashlight(bool mode)
{
    flashlight.SetEnabled(mode);
}

exec function SetParticles(bool mode)
{
   ParticlesFollowUs.SetActive(mode);
}

simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
   super.GetWeaponStartTraceLocation();

   return Weapon.Location;
}


function AddDefaultInventory()
{
    InvManager.DiscardInventory();
}

auto state Idle
{

    Begin:
        Controller.GotoState('Idle');
}

defaultproperties
{
    Components.Remove(Sprite)

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment //Como afecta la luz al modelo
        ModShadowFadeoutTime=0.25
        MinTimeBetweenFullUpdates=0.2
        AmbientGlow=(R=.01,G=.01,B=.01,A=1)
        AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
        bSynthesizeSHLight=TRUE
    End Object
    Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh // Modelo y animaciones
        CastShadow=true
        bCastDynamicShadow=true
        bOwnerNoSee=false
        LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
        PhysicsAsset=PhysicsAsset'Alice.SkeletalMesh.Player_base_Physics'

        SkeletalMesh=SkeletalMesh'Alice.SkeletalMesh.Player_base'
        AnimTreeTemplate=AnimTree'Alice.AnimSet.Player_AnimTree'
        AnimSets(0)=AnimSet'Alice.AnimSet.Player_anim'
        Translation = (Z=-50)
    End Object
    Mesh=InitialSkeletalMesh;
    Components.Add(InitialSkeletalMesh);
   

    Begin Object Name=CollisionCylinder
        CollisionRadius=+0034.000000
        CollisionHeight=+0120.000000
        
    End Object
    CylinderComponent=CollisionCylinder

    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow //Particulas que nos siguen
        Template = ParticleSystem'HumoGato.EjemploParticulas';
        bSuppressSpawning = true;
        bAutoActivate = false;
    End Object
    Components.Add(ParticlesFollow)
    ParticlesFollowUs = ParticlesFollow;

    Begin Object Class=SpotLightComponent Name=Linterna //Linterna del jugador
        bEnabled = false;
    End Object
    Components.Add(Linterna)
    flashlight = Linterna;

    Begin Object Class=SpotLightComponent Name=Foco //Foco Autoiluminacion
        InnerConeAngle=0;
        OuterConeAngle=180;
        Translation = (X=-200,Y=0.0,Z=300)
    End Object
    Components.Add(Foco)

    DrawScale = 1.5;
    bCanJump=false

    InventoryManagerClass=class'DoorOfLiesInventoryManager'

    bCanPickupInventory = true

    strength = 5;
    
    //GroundSpeed = 200
}

