 /* Victor Macho
    Clase PAWN 
Define Modelo - Animaciones - Afecta Luz o no
 */

class DoorOfLiesPawn extends Pawn;

var (Player) SpotLightComponent flashlight;
var ParticleSystemComponent ParticlesFollowUs;
var AnimNodeBlendList AnimNodeBlendList;
var (Player) int maxCalabazas;
var (Player) array<CalabazaActor> calabazas;

enum EAnimState
{
    ST_Normal,
    ST_Sleeping,
    ST_Die,
    ST_Attack
};

simulated event PostBeginPlay() //Al empezar
{
    super.PostBeginPlay();

    maxCalabazas = DoorOfLiesGame(WorldInfo.Game).MaxCalabazasPlayer;
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

function SetAnimationState(EAnimState eState)
{
    if(AnimNodeBlendList != none)
    {
        if(eState == ST_Normal)
        {
            if(Velocity.X != 0)  SetParticles(true);
            else SetParticles(false);
        }

        AnimNodeBlendList.SetActiveChild(eState,0.25);
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

/* 
 * Called after initializing the AnimTree for the given SkeletalMeshComponent that has this Actor as its Owner
 * this is a good place to cache references to skeletal controllers, etc that the Actor modifies
 */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
  AnimNodeBlendList = AnimNodeBlendList(SkelComp.FindAnimNode('AnimNodeBlendList'));
}

simulated event Destroyed()
{
  Super.Destroyed();

  AnimNodeBlendList = None;
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local CalabazaActor calabaza;
    local Vector NewPosition;
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    //Si chocamos con una calabaza y no hemos superado el limite de calabazas que podemos llevar
    if(Other.Tag == 'CalabazaPawn' && calabazas.length < maxCalabazas)
    {
        calabaza = new class'CalabazaActor';

        NewPosition.Z = 50 * calabazas.length;
        calabaza.SetTranslation(NewPosition);
        
        Mesh.AttachComponentToSocket(calabaza, 'sk_head');

        Other.destroy();
        calabazas.AddItem(calabaza);

        PlaySound(SoundCue'KismetGame_Assets.Sounds.S_Blast_05_Cue');
    }
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
        PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'

        SkeletalMesh=SkeletalMesh'Orco.SkeletalMesh.micro_orc';
        AnimTreeTemplate=AnimTree'Orco.AnimTree';
        AnimSets(0)=AnimSet'Orco.SkeletalMesh.Idle';

    End Object
    Mesh=InitialSkeletalMesh;
    Components.Add(InitialSkeletalMesh);

    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
    CollisionRadius=+0021.000000
    //CollisionHeight=+0048.000000
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

    DrawScale = 0.75;
    bCanJump=false

    bCollideActors = true;
    bBlockActors = true;

    Tag = "Player";
}

