 /* Victor Macho
    Clase PAWN del Objeto Calabaza
Define Modelo - Animaciones - Afecta Luz o no
 */

class CalabazaPawn extends Pawn
  placeable;
   
var (calabaza) int life;
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
    End Object
    //HitComponent=CalabazaMesh
    Components.Add(CalabazaMesh)
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'HumoGato.EjemploParticulas';
    End Object
    Components.Add(ParticlesFollow)

    DrawScale = 10; //Scale del Mesh
    
    life = 5;
    speed = 2;
    speedRotator = 20;
    amplitude = 0.5;
}