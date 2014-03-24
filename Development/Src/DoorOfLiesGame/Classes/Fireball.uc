 /* 
 	Victor Macho
    
 */

class Fireball extends Pawn;
   
var (Hability) float speed;
var (Hability) float damage;
var (Hability) float duration;
var Vector targetPoint;
var bool bPawnNearDestination;
var Actor emitterPawn;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    bPawnNearDestination = false;

    SetTimer(duration, false, 'Die');
}

simulated event Tick(float Deltatime)
{
    local float DistanceRemaining;
    local Vector2D DistanceCheckMove;
    local Vector newLocation;
    super.Tick(Deltatime);

    DistanceCheckMove.X = targetPoint.X - Location.X;
    DistanceCheckMove.Y = targetPoint.Y - Location.Y;
    DistanceRemaining = Sqrt((DistanceCheckMove.X*DistanceCheckMove.X) + (DistanceCheckMove.Y*DistanceCheckMove.Y));

    if( DistanceRemaining < 100.0f ) Die();

    newLocation = Location;
    newLocation += Normal(targetPoint - Location) * speed * Deltatime;
    SetLocation(newLocation);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if(Attackable(Other) != none && emitterPawn != none && emitterPawn != Other)
    {
    	Attackable(Other).Burn(damage);
        `log("FIREBALL EXPLOTA CON " $Other.name);
        Die();
    }
}

function Die()
{
    `log("MUERE FIREBALL");
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
        Scale = 5   
    End Object
    Components.Add(CalabazaMesh)
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'ParticlePumpkin.Particles.ParticlePumpkin'
    End Object
    Components.Add(ParticlesFollow)
    
    bCollideActors = true;
    bBlockActors = false;

    speed = 500
    damage = 5
    duration = 2
}