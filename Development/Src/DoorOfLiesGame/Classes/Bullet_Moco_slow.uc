 /* 
 	Victor Macho
    
 */

class Bullet_Moco_slow extends Pawn;
   
var (WeaponMoco) float modSpeed;
var (WeaponMoco) float timeSlowing;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    SetTimer(health, false, 'Die');
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if(Attackable(Other) != none) Attackable(Other).SlowGroud(modSpeed, timeSlowing);
}

function Die()
{
	Destroy();
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
        CollisionHeight = 44.000000
        CollisionRadius = 75.000000
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
    
    bCollideActors = true;
    bBlockActors = false;

    health = 5
    modSpeed = 100
    timeSlowing = 2
}