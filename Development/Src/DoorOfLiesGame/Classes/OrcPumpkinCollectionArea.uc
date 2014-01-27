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
var ContadorHud _contadorHUD;
 
simulated event PostBeginPlay()
{
    local Vector NewPosition;

    super.PostBeginPlay();
    calabazas = DoorOfLiesGame(WorldInfo.Game).MaxCalabazas;
    setCollision(true,true);

    NewPosition.Z = 600;
    contador.SetTranslation(NewPosition);
    
    contador.SetMaterial(0, Material'cotadorMaterial.Material.cotadorMaterial');

    _contadorHUD = new class'ContadorHud';
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
        if(DoorOfLiesPawn(Other).calabazas.length > 0)
        {
            calabazas -= DoorOfLiesPawn(Other).calabazas.length;
            
            for(i = 0; i < DoorOfLiesPawn(Other).calabazas.length; i++) DoorOfLiesPawn(Other).Mesh.DetachComponent(DoorOfLiesPawn(Other).calabazas[i]);
            DoorOfLiesPawn(Other).calabazas.length = 0;

            PlaySound(SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_WarningCue');

            _contadorHUD.UpdateContador(calabazas);

            if(calabazas <= 0)
            {
                TriggerGlobalEventClass(class'SeqEvent_FinishLevel',none);
            }
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