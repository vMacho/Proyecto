 /* Victor Macho
    Clase PAWN de la base
Define Modelo - Animaciones - Afecta Luz o no
 */

class baseEntrega extends Pawn
  placeable;
   
var (calabaza) int life;
var (calabaza) int calabazas;
var (calabaza) Name tagPlayer;
 
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

    if(Other.Tag == 'Player')
    {
        calabazas++;
        `Log("SUMO CALABAZA "$calabazas);
    }
}

DefaultProperties
{ 
    Begin Object Name=CollisionCylinder
        CollisionHeight=+44.000000
    End Object

    Begin Object Class=StaticMeshComponent Name=TowerMesh
        StaticMesh=StaticMesh'Calabaza.StaticMesh.pumpkin_01_01_a'        
    End Object
    Components.Add(TowerMesh)
 
    Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
        Template = ParticleSystem'HumoGato.EjemploParticulas';
    End Object
    Components.Add(ParticlesFollow)

    DrawScale = 1; //Scale del Mesh
    
    life = 5;
    calabazas = 0;
}