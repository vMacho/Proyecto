
class AreaEnemiga extends Area;

enum Estados
{
    Cargando,
    Inflige
};
var Estados actual;

var MaterialInterface ReticuleClickMaterial;
var ReticuleActor Reticule;
var Vector groundLocation,groundNormal;

var int outrangenext;
var vector locationShoot;

simulated event PostBeginPlay()
{
    From = false;
    super.PostBeginPlay();
    SetTimer(duration, false, 'Die');
}

simulated event Tick(float Deltatime)
{
  local Attackable other;
  local bool existe;
  local int i;
  super.Tick(Deltatime);

  switch (actual)
  {
      case Cargando:

          

          groundNormal.x=0;
          groundNormal.y=0;
          groundNormal.z=1;     // de esta manera no se bugean las areas que spawneamos

          if( Reticule == none )
          {
              Class'DoorOfLiesGame.ReticuleActor'.static.PreInitialize( matTime );
              Reticule = Spawn(class'DoorOfLiesGame.ReticuleActor', , , Location + (groundNormal* 48), Rotator(groundNormal * -1), , true);  

              if(Reticule != none)
              {
                Reticule.Decal.SetDecalMaterial( matTime );   
                Reticule.Decal.Width  = anchoarea;
                Reticule.Decal.Height = largoarea;
              }
          }

          if( hurt ) actual = Inflige;

          Charging( Deltatime );
      break;
      case Inflige:

          foreach CollidingActors(class'Attackable', other, 200, Location + (groundNormal* 48) ) 
          {
            if( emitterPawn != none )
            {
              if( Other != none && emitterPawn != Other )
              {
                existe = false;

                for( i = 0; i < colisionando.length; i++ ) if( colisionando[i] == other ) existe = true; //Si ya esta en el array no le volvemos a meter
                
                if( !existe ) colisionando.AddItem( other );
              }
            }
          }

          DoDamage( "-"$damage, damage );
            
          if( !particlesON )
          {
              ActivarParticulas();
              Action( TypeSecondaryEffect );  // ACCIONES SECUNDARIAS.
          }

      break;
    }
     
}

simulated function Die()
{
  
  Reticule.Decal.ResetToDefaults();
  Reticule = none;
  Destroy();
  super.Die();
}

function Action(int type)
{
  local int i;

  switch(type)
  {
    case 0:
    break;
    case 1: //TELEPORT
      emitterPawn.SetLocation(groundLocation); 
    break;
    case 2:  // MURO
      malla.SetHidden(false);
      malla.SetStaticMesh(StaticMesh'PowerUpMaxCalabazas.muro');
     
      CylinderComponent.SetActorCollision(false, false);
      malla.SetActorCollision(true, true);
      CollisionComponent = malla;

      while( colisionando.length > 0 ) recolocarActoresColisionando();

      bBlockActors = true;
    break;
    case 3: //RALENTIZAR
      
      for( i = 0; i < colisionando.length; i++ )
      {
        if(Attackable(colisionando[i]) != none  && Attackable(colisionando[i]).GroundSpeed == Attackable(colisionando[i]).default_humanoid_GroundSpeed) Attackable(colisionando[i]).SlowGroud(100, 2);
      }
    break;
    case 4: //DERRIBAR
    break;
  }
}

function recolocarActoresColisionando() //para el spawn del bloque de hielo.
{
  local int i;
  local vector mov;
 
  for(i = 0; i < colisionando.length; i++ )
  {
    mov.x = colisionando[i].Location.X - Location.X;
    mov.y = colisionando[i].Location.Y - Location.Y;
    mov.x = colisionando[i].Location.X + mov.x;
    mov.y = colisionando[i].Location.Y + mov.y;
    mov.z = colisionando[i].Location.Z;

    colisionando[i].SetLocation( mov );
  }
}

DefaultProperties
{ 
  outrangenext  = 0;
  distanciaCast = 300;
  ReticuleClickMaterial = DecalMaterial'Decals.Materials.Area_Select'
  actual        = Cargando
}