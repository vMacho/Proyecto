

class GetWeapon extends Pawn
ClassGroup(Weapon)
placeable
;

var (Weapon) class<Weapon> WeaponClass;
var (Weapon) const EditInline Instanced array<PrimitiveComponent> PrimitiveComponents;

function PostBeginPlay()
{
  local int i;
  
  if (PrimitiveComponents.Length > 0)
  {
    for (i = 0; i < PrimitiveComponents.Length; ++i)
    {
      if (PrimitiveComponents[i] != None)
      {
        AttachComponent(PrimitiveComponents[i]);
      }
    }
  }

  Super.PostBeginPlay();
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if(HumanoidPawn(Other) != none)
    {
        HumanoidPawn(Other).SetWeapon(WeaponClass);
        Other.PlaySound(SoundCue'KismetGame_Assets.Sounds.S_Blast_05_Cue');
        Destroy();
    }
}


DefaultProperties
{     
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
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'ParticlePumpkin.Particles.ParticlePumpkin'
    End Object
    Components.Add(ParticlesFollow)
    
    bCollideActors = true;
    bBlockActors = false;
}