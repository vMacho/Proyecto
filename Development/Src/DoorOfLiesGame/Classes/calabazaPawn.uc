 /* Victor Macho
    Clase PAWN del Objeto Calabaza
Define Modelo - Animaciones - Afecta Luz o no
 */

class CalabazaPawn extends Pawn
  placeable;
   
var (calabaza) int speed;
var (calabaza) int speedRotator;
var (calabaza) float amplitude;
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}

event Tick(float DeltaTime)
{
    local Vector NewPosition;
    local rotator NewRotation;

    super.Tick(DeltaTime);

    NewPosition = Location;
    NewPosition.Z += Sin(WorldInfo.TimeSeconds * speed) * amplitude;

    NewRotation = Rotation;
    NewRotation.Yaw += DeltaTime * 1000 * speedRotator;

    SetLocation(NewPosition);
    SetRotation(NewRotation);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local CalabazaActor calabaza;
    local Vector NewPosition;
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    //Si chocamos con una calabaza y no hemos superado el limite de calabazas que podemos llevar
    if(Other.Tag == 'Player')
    {
        if(DoorOfLiesPawn(Other).calabazas.length < DoorOfLiesPawn(Other).maxCalabazas)
        {
            calabaza = new class'CalabazaActor';

            NewPosition.Z = 25 * DoorOfLiesPawn(Other).calabazas.length;
            calabaza.SetTranslation(NewPosition);
            
            DoorOfLiesPawn(Other).Mesh.AttachComponentToSocket(calabaza, 'sk_head');
            DoorOfLiesPawn(Other).calabazas.AddItem(calabaza);

            Other.PlaySound(SoundCue'KismetGame_Assets.Sounds.S_Blast_05_Cue');

            Destroy();
        }
    }
    else if(Other.Tag == 'EnemyPawn')
    {
        if(EnemyPawn(Other).calabazas.length < EnemyPawn(Other).maxCalabazas)
        {
            calabaza = new class'CalabazaActor';

            NewPosition.Z = 25 * EnemyPawn(Other).calabazas.length;
            calabaza.SetTranslation(NewPosition);
            
            EnemyPawn(Other).Mesh.AttachComponentToSocket(calabaza, 'sk_head');
            EnemyPawn(Other).calabazas.AddItem(calabaza);

            Other.PlaySound(SoundCue'KismetGame_Assets.Sounds.S_Blast_05_Cue');

            Destroy();
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

    Begin Object Name=CollisionCylinder
        CollisionHeight=+44.000000
    End Object

    Begin Object Class=StaticMeshComponent Name=CalabazaMesh
        LightEnvironment=MyLightEnvironment;
        StaticMesh=StaticMesh'Calabaza.StaticMesh.pumpkin_01_01_a'
        Scale = 10   
    End Object
    Components.Add(CalabazaMesh)
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'ParticlePumpkin.Particles.ParticlePumpkin'
    End Object
    Components.Add(ParticlesFollow)
    
    speed = 2;
    speedRotator = 20;
    amplitude = 2;

    bCollideActors = true;
    bBlockActors = false;
}