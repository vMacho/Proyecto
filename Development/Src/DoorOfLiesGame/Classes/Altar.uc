 /* Victor Macho
    Clase PAWN de la base
Define Modelo - Animaciones - Afecta Luz o no
 */

class Altar extends Pawn
  ClassGroup(Altar)
  placeable;
   
enum TipoAltar
{
    AL_Fuego,
    AL_Agua,
    AL_Tierra,
    AL_Viento
};

var (Altar) TipoAltar type;
var (Altar) ParticleSystem particulas;
var bool activado;
var (Altar) float distance_activate;
var bool show_advise;

var ParticleSystemComponent sistema_particulas;

simulated event PostBeginPlay()
{
    local Vector NewPosition;
    super.PostBeginPlay();

    sistema_particulas = new class 'ParticleSystemComponent';

    sistema_particulas.SetTemplate(particulas);
    NewPosition.Z = 125;
    sistema_particulas.SetTranslation(NewPosition);

    AttachComponent(sistema_particulas);
}

event Tick(float deltatime)
{
    local DoorOfLiesPlayerController Player;
    local float distance_to_player;
    local bool finish_quest;
    local int i;

    super.Tick(deltatime);   

    if( !activado )
    {
        Player = DoorOfLiesPlayerController(GetALocalPlayerController());
        distance_to_player = ABS( VSize( Location - Player.Pawn.Location ) );

        finish_quest = true;

        if( distance_to_player <= distance_activate )
        {
            if( Player.use_button )
            {
                Player.powers[type].activable = true;
                activado = true;
                sistema_particulas.DeactivateSystem();

                for( i = 0; i < Player.powers.length; i++ ) if( !Player.powers[i].activable ) finish_quest = false;

                if( finish_quest ) Player.FinishQuest(1);
            }
            else if( show_advise )
            {
                show_advise = false;
                Player.AddDanger("Pulsa la tecla F");
            }
        }
        else if( distance_to_player > distance_activate + 150 ) show_advise = true;
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
        StaticMesh=StaticMesh'pedestal.Mesh.Pedestal_Final'

        Scale = 3.5;
    End Object
    Components.Add(InitialSkeletalMesh);

    CollisionType=COLLIDE_BlockAll
    Begin Object Name=CollisionCylinder //Colisiones modificadas del modelo
    CollisionRadius=+100.000000
    CollisionHeight=+200.000000

    BlockActors = true;
    End Object
    CylinderComponent=CollisionCylinder

    Begin Object Class=SpotLightComponent Name=Foco //Foco Autoiluminacion
        InnerConeAngle=0;
        OuterConeAngle=180;
        Translation = (X=-200,Y=0.0,Z=300)
    End Object
    Components.Add(Foco)

    DrawScale = 1; //Scale del Mesh
    
    bCollideActors = true;
    bBlockActors = true;

    activado = false;
    distance_activate = 250
    show_advise = true;
}