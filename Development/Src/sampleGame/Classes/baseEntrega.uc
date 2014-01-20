 /* Victor Macho
    Clase PAWN de la base
Define Modelo - Animaciones - Afecta Luz o no
 */

class baseEntrega extends Pawn
  placeable;
   
var (Base) int life;
var (Base) int calabazas;
var (Base) Name tagPlayer;
 
simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}

event Tick(float DeltaTime)
{
    
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if(Other.Tag == tagPlayer)
    {
        if(SamplePawn(Other).nCalabazas > 0)
        {
            calabazas += SamplePawn(Other).nCalabazas;
            `Log("SUMO CALABAZA "$calabazas);

            SamplePawn(Other).nCalabazas = 0;
        }
    }
}

DefaultProperties
{ 
    Components.Remove(Sprite)

    Begin Object Name=CollisionCylinder
        CollisionHeight=+44.000000
    End Object

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh // Modelo y animaciones
        CastShadow=true
        bCastDynamicShadow=true
        bOwnerNoSee=false
        BlockRigidBody=true;
        CollideActors=true;

        SkeletalMesh=SkeletalMesh'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard'

    End Object

    Mesh=InitialSkeletalMesh;
    Components.Add(InitialSkeletalMesh);
 
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

    DrawScale = 3; //Scale del Mesh
    
    life = 5;
    calabazas = 0;

    tagPlayer = "Player";
}