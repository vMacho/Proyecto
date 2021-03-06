class Area extends Pawn; 
var (Hability) float speed;
var (Hability) int damage;
var (Hability) float duration;
var float durationcarga;
var vector dimensiones;
var Vector targetPoint;
var Vector inicialLocation;
var Actor emitterPawn;
var public myHUD myHUDx;  
var DecalComponent Area;
var DecalMaterial TypeAttack;
var MaterialInstanceConstant matTime;
var float carga;
var float changetime;
var bool From;
var bool particlesON;
var bool Hurt;
var ParticleSystemComponent particula;
var StaticMeshComponent malla;
var array<actor> colisionando;
var int danioagain;
var int anchoarea,largoarea,Shape;
var CylinderComponent colision;
var public bool TypeOrigin; //Nos dice si el origen es desde el emisor o puede castearla desde donde quiera
var float distanciaCast;
var int TypeSecondaryEffect;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    colisionando.length = 0;
}

simulated event Tick(float Deltatime)
{ 
    if( matTime == none ) CreateArea(0);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
  local int i ;
  local bool existe;
  
  super.Touch(Other, OtherComp, HitLocation, HitNormal);

  if( emitterPawn != none )
  {
    if( Attackable(Other) != none && emitterPawn != Pawn(Other))
    {
      existe = false;

      for( i = 0; i < colisionando.length; i++ ) if( colisionando[i] == other ) existe = true; //Si ya esta en el array no le volvemos a meter
      
      if( !existe ) colisionando.AddItem(other);
    }
  }
}

event untouch(actor other)
{
  if( Attackable(Other) != none && emitterPawn != Pawn(Other))
  {
    colisionando.RemoveItem(other);
    `log("SACO "$ other.Name);
  }
}

function Die()
{
    Area.ResetToDefaults();
    Area = none;
    matTime = none;
	  Destroy();
}

function setTim()
{
    SetTimer(duration, false, 'Die');
}

function CreateArea(int d)
{
    if(TypeOrigin) TypeAttack = DecalMaterial'Decals.Materials.Area_lanzamiento';
    else TypeAttack = DecalMaterial'Decals.Materials.Area_Ciruclar';

    inicialLocation = Location;
    Area = WorldInfo.MyDecalManager.SpawnDecal (TypeAttack, // UMaterialInstance used for this decal.
                                             inicialLocation, // Decal spawned at the hit location.
                                             Rotator(vect(0.0f,0.0f,1.0f)), // Orient decal into the surface.
                                             200,200, // Decal size in tangent/binormal directions.
                                             512, // Decal size in normal direction.
                                             false, // If TRUE, use "NoClip" codepath.
                                             FRand() * 360, // random rotation
                                             ,true ,true, //bProjectOnTerrain y bProjectOnSkeletalMeshes
                                             ,,,d);
    
    Area.bMovableDecal = true;

    matTime = new(none) Class'MaterialInstanceConstant';
    matTime.SetParent(Area.GetDecalMaterial());
    Area.SetDecalMaterial(matTime);
    matTIme.SetScalarParameterValue('Time_Charging',carga);
    
    if( From ) matTime.SetScalarParameterValue('Area_From',1); // AREA ALIADA O ENEMIGA
    else matTIme.SetScalarParameterValue('Area_From',0);

    matTIme.SetScalarParameterValue('Type_Area',Shape);  // AREA CIRCULAR O CUADRAD
}

function ActivarParticulas()
{
    particula.SetActive(true);
    particula.SetHidden(false);
    particlesON = true;
}

function Charging(float deltatime)
{
  changetime  = 0.5 / ( durationcarga / deltatime );
  carga       += changetime;

  matTIme.SetScalarParameterValue( 'Time_Charging', carga );
  
  if( carga > 0.5 - changetime ) hurt = true;
}

function float Distancia2points(vector pos1,vector pos2)
{
  local float Y,X;

  X = pos1.X - pos2.X;
  Y = pos1.Y - pos2.Y;
  X = X * X;
  Y = Y * Y;
  
  return sqrt( X + Y );
}

function DoDamage(string text,int danio)
{
    local vector postexto;
    local PlayerController PlayerController;
    local int i;
    
    PlayerController = GetALocalPlayerController();

    if( hurt )
    {
      for( i = 0; i < colisionando.length; i++ )
      {
        if( colisionando[i] != none && Area(colisionando[i]) == none && colisionando[i] != emitterpawn)
        {
          if( !Attackable(colisionando[i]).inmune )
          {
            postexto=Attackable(colisionando[i]).location;
            MyHud(PlayerController.myHUD).AddTexto( text, 2, postexto );
            
            if( DoorOfLiesPawn(colisionando[i]) == none) Attackable(colisionando[i]).SetDamage( danio );
            else DoorOfLiesPawn(colisionando[i]).SetDamage( danio );
            
          }
        }
      }
      
      danioagain = 50;
      hurt = false;
    }
    else
    {
      danioagain--;
      if( danioagain < 0 ) hurt = true;
    }
}

function AddDanger(string text)
{
  local vector postexto;
  local PlayerController PlayerController;
    
  PlayerController  = GetALocalPlayerController();
  postexto          = emitterPawn.location;

  MyHud(PlayerController.myHUD).AddTexto( text, 1, postexto );
}

function vector RotateToPlayer(vector ClickLocation)
{
  local vector posicionpj,lookat;
  local float translation;
  
  ClickLocation.z = 0;
  posicionpj      = emitterpawn.Location;
  posicionpj.z    = 0;
  
  lookat    = ClickLocation - posicionpj;
  lookat.Z  = -200;

  if( Abs( lookat.X ) > abs( lookat.Y ) )
  {
    translation = Abs( lookat.X ) / 10;
    lookat.X = lookat.X / translation;
    lookat.Y = lookat.Y / translation;
  }

  if( abs( lookat.X ) < abs( lookat.Y ) )
  {
    translation = abs( lookat.Y ) / 10;
    lookat.Y = lookat.Y / translation;
    lookat.X = lookat.X / translation;
  }

  return lookat;
}

function Constructor(int ancho,int largo,bool fromi,bool Origin,int shap,float timecharge,float duracion,DecalMaterial dibujo,float CastDist, ParticleSystem typePart,int Efect, int danio_hace)
{
  anchoarea = ancho;
  largoarea = largo;

  colision.SetCylinderSize( anchoarea / 2, 50 );

  From          = fromi;
  TypeOrigin    = Origin;
  Shape         = Shap;
  durationcarga = timecharge;
  duration      = duracion;
  TypeAttack    = dibujo;
  distanciaCast = CastDist;

  particula.SetTemplate(typePart);
  TypeSecondaryEffect = Efect;
  damage = danio_hace;
}

DefaultProperties
{ 
  Shape         = 0;
  particlesON   = false;
  TypeOrigin    = false;
  hurt          = false;
  from          = true;
  carga         = 0.001
  durationcarga = 2;
  distanciaCast = 0;

  TypeSecondaryEffect = 3;

  Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment //Como afecta la luz al modelo
    ModShadowFadeoutTime      = 0.25
    MinTimeBetweenFullUpdates = 0.2
    AmbientGlow               = (R=.01,G=.01,B=.01,A=1)
    AmbientShadowColor        = (R=0.15,G=0.15,B=0.15)
    bSynthesizeSHLight        = TRUE
  End Object
  Components.Add(MyLightEnvironment) 

  Begin Object Name=CollisionCylinder
    CollisionHeight = 50.000000
    CollisionRadius = 100.000000

    HiddenGame = FALSE 
  End Object
  Components.Add(CollisionCylinder)  
  colision = CollisionCylinder

  Begin Object Class=StaticMeshComponent Name=CalabazaMesh
      LightEnvironment    = MyLightEnvironment;
      BlockNonZeroExtent  = True;
      //StaticMesh=StaticMesh'Calabaza.StaticMesh.pumpkin_01_01_a'
      Scale       = 5
      HiddenGame  = true
  End Object
  Components.Add(CalabazaMesh)
  malla = CalabazaMesh
  
  Begin Object Class=ParticleSystemComponent Name=ParticlesFollow
    //Template = ParticleSystem'fuego2.ParticleSystem.ParticleFireFlame'
    Scale = 3
    bAutoActivate = false
  End Object
  Components.Add(ParticlesFollow)
  particula = ParticlesFollow
  
  bCollideActors = true;
  bBlockActors = false;

  speed = 300
  damage = 5
  duration = 5
}