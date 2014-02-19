 /* Victor Macho
    Clase PAWN de la base
Define Modelo - Animaciones - Afecta Luz o no
 */

class OrcPumpkinCollectionArea extends Pawn
  ClassGroup(Base)
  placeable;
   
var (Base) int life;
var (Base) int calabazas;
var (Base) int calabazasWin;
var (Base) Name tagPlayer;
var (Base) StaticMeshComponent contador;
var OrcScore _contadorHUD;
 
simulated event PostBeginPlay()
{
    local Vector NewPosition;
    local MaterialInstanceConstant OrcScore_mat;
    local TextureRenderTarget2D RenderTexture;

    super.PostBeginPlay();

    calabazas = DoorOfLiesGame(WorldInfo.Game).MaxCalabazas;

    RenderTexture = class'TextureRenderTarget2D'.static.Create(512, 512);

    OrcScore_mat = new(None) Class'MaterialInstanceConstant';
    OrcScore_mat.SetParent( Material'cotadorMaterial.Material.cotadorMaterial' );
    OrcScore_mat.SetTextureParameterValue('myTexture', RenderTexture);

    NewPosition.Z = 600;
    contador.SetTranslation(NewPosition);
    contador.SetMaterial(0, OrcScore_mat);
        
    _contadorHUD = new class'OrcScore';
    _contadorHUD.RenderTexture = RenderTexture;
    _contadorHUD.Start();
    _contadorHUD.UpdateContador(calabazas);
}

event Tick(float DeltaTime)
{
    local rotator NewRotation;

    NewRotation = contador.Rotation;
    NewRotation.Yaw += DeltaTime * 1000 * 20;
    contador.SetRotation(NewRotation);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local int i;
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if(Other.Tag == tagPlayer)
    {
        if(RecolectorPawn(Other).calabazas.length > 0)
        {
            `Log(Other.Tag$" Entrega "$RecolectorPawn(Other).calabazas.length);
            calabazas -= RecolectorPawn(Other).calabazas.length;
            
            for(i = 0; i < RecolectorPawn(Other).calabazas.length; i++) RecolectorPawn(Other).Mesh.DetachComponent(RecolectorPawn(Other).calabazas[i]);
            RecolectorPawn(Other).calabazas.length = 0;

            PlaySound(SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_WarningCue');

            _contadorHUD.UpdateContador(calabazas);

            if(calabazas <= 0) TriggerGlobalEventClass(class'SeqEvent_FinishLevel',Other);
        }
    }
}

DefaultProperties
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

    Begin Object Class=StaticMeshComponent Name=InitialSkeletalMesh
        CastShadow=true
        bCastDynamicShadow=true
        bOwnerNoSee=false
        BlockRigidBody=true;
        CollideActors=true;
        BlockActors = true;
        LightEnvironment=MyLightEnvironment;
        StaticMesh=StaticMesh'OrcPumpkinCollectionAreaTower.StaticMesh.OrcPumpkinCollectionArea_guard_tower'
    End Object
    Components.Add(InitialSkeletalMesh);
    CollisionComponent = InitialSkeletalMesh;

    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
    CollisionRadius=+500.000000
    CollisionHeight=+200.000000

    BlockActors = false;
    End Object
    CylinderComponent=CollisionCylinder
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'Envy_Level_Effects_2.CTF_Crisis_Energy.Falling_Leaf'
    End Object
    Components.Add(ParticlesFollow)

    Begin Object Class=SpotLightComponent Name=Foco //Foco Autoiluminacion
        InnerConeAngle=0;
        OuterConeAngle=180;
        Translation = (X=-200,Y=0.0,Z=300)
    End Object
    Components.Add(Foco)

    Begin Object Class=StaticMeshComponent Name=ContadorSkeletalMesh
        LightEnvironment=MyLightEnvironment;
        StaticMesh=StaticMesh'EngineMeshes.Cube'
       Scale = 0.5
    End Object
    Components.Add(ContadorSkeletalMesh);
    contador = ContadorSkeletalMesh;

    DrawScale = 1; //Scale del Mesh
    
    life = 5;

    bCollideActors = true;
    bBlockActors = true;

    tagPlayer = "Player";
}