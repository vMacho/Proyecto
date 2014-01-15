 /* Victor Macho
    Clase PAWN 
Define Modelo - Animaciones - Afecta Luz o no
 */

class SamplePawn extends Pawn;

var SpotLightComponent flashlight;
var ParticleSystemComponent ParticlesFollowUs;
var AnimNodeBlendList AnimNodeBlendList;

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
    `Log("Custom Pawn up");
}

simulated function name GetDefaultCameraMode( PlayerController RequestedBy ) // Tipo de camara por defecto
{
    `Log("Requested Isometric");
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

defaultproperties
{
    Components.Remove(Sprite)

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment //Como afecta la luz al modelo
        ModShadowFadeoutTime=0.25
        MinTimeBetweenFullUpdates=0.2
        AmbientGlow=(R=.01,G=.01,B=.01,A=1)
        AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
        //LightShadowMode=LightShadow_ModulateBetter
        //ShadowFilterQuality=SFQ_High
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

     // Floating fix
    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
    CollisionRadius=+0021.000000
    CollisionHeight=+0048.000000
    End Object
    CylinderComponent=CollisionCylinder

    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow //Particulas que nos siguen
        Template = ParticleSystem'HumoGato.EjemploParticulas';
        bSuppressSpawning = true;
        bAutoActivate = false;
    End Object
    Components.Add(ParticlesFollow)
    ParticlesFollowUs = ParticlesFollow;
    //ParticlesFollowUs.SetStopSpawning(-1, true);
    //ParticlesFollowUs.DeactivateSystem();
    //ParticlesFollowUs.SetActive(false);

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
}
