class AreaAmistosa extends Area;

enum Estados
{
    Seleccion,
    Cargando,
    Inflige
};
var Estados actual;

var MaterialInterface ReticuleClickMaterial;
var ReticuleActor Reticule;
var ReticuleActor CastArea;
var Vector groundLocation;

var int outrangenext;
var vector locationShoot;
simulated event PostBeginPlay()
{
    super.PostBeginPlay();

}

simulated event Tick(float Deltatime)
{
    
    local Vector groundNormal;
    local vector mouseOri,MouseDir;
    local Vector newLocation, direccion;
    local vector correcionRotacion;
    
   // local int i;
    local PlayerController PlayerController;
   // for(i=0;i<colisionando.length;i++) { `log(""$i); `log(" "$colisionando[i]); }
   super.Tick(Deltatime);
     PlayerController = GetALocalPlayerController();
    mouseOri=myhud(PlayerController.myHUD).MouseOrigin_;
    mouseDir=myhud(PlayerController.myHUD).MouseDir_; 
    if(outrangenext>0)
    {
      outrangenext--;
    }
    switch (actual)
    {
        case Seleccion: //estado que se encarga de mover el decal con el raton y colocarnos el area de casteo alrededor nuestro

            Trace(groundLocation, groundNormal, mouseOri + (MouseDir * 100000), mouseOri, false);
            if(TypeOrigin==false)
            {
            SetLocation(groundLocation);
            }
            else
            {
              SetLocation(emitterPawn.Location);
            }
            correcionRotacion=RotateToPlayer(groundLocation);
            correcionRotacion.Z=0;
            SetRotation(Rotator(correcionRotacion*1));
            groundNormal.z=1;     // de esta manera no se bugean las areas que spawneamos
            Reticule.Decal.Width=anchoarea;
            Reticule.Decal.Height=largoarea;
           if(Reticule==none)
           {
               Reticule = Spawn(class'DoorOfLiesGame.ReticuleActor', , , groundLocation + (groundNormal* 48), Rotator(groundNormal * -1), , true);  ;
               if(Reticule != none)
                {
                Reticule.Decal.SetDecalMaterial(matTime);    
                }
           }
           if(Reticule!=none)
           {
                 if(TypeOrigin==false)
                  {
                  Reticule.SetLocation(groundLocation);
                  }
                  else
                  {
                  Reticule.SetLocation(emitterPawn.Location);
                  }
                 Reticule.SetRotation(Rotator(RotateToPlayer(groundLocation)*1));
           }
           if(CastArea==none)   // AREA DONDE PODRA CASTEAR EL PJ
           {
               CastArea = Spawn(class'DoorOfLiesGame.ReticuleActor', , , groundLocation + (groundNormal* 48), Rotator(groundNormal * -1), , true);  ;
               
               if(CastArea != none)
                {

                CastArea.Decal.SetDecalMaterial(ReticuleClickMaterial);
                CastArea.Decal.Width=distanciaCast*2;  
                CastArea.Decal.Height=distanciaCast*2;  
                }
           }
           if(CastArea!=none)
           {
                CastArea.SetLocation(emitterPawn.Location);
           }
           if(DoorOfLiesPlayerController(PlayerController).bLeftMousePressed==true  )
           {
            if(Distancia2points(groundLocation,emitterPawn.Location)<distanciaCast)
            {
           
              CastArea.Decal.ResetToDefaults();
              CastArea=none;
              setTim();
              actual=Cargando;
            }
            else
            {
              if(outrangenext==0)
              {
                outrangenext=75;
               AddDanger("Fuera de rango");
              }
            }
           }
           if(DoorOfLiesPlayerController(PlayerController).bRightMousePressed==true)
           {
             CastArea.Decal.ResetToDefaults();
              CastArea=none;
             Die();
           }
           
        break;
        case Cargando:
            DoorOfLiesPlayerController(PlayerController).GotoState('CastingHability');

            if(hurt==true)
            {
              DoorOfLiesPlayerController(PlayerController).hability_finished=true;
              actual=Inflige;
              locationShoot=emitterPawn.Location;
            }
            if(DoorOfLiesPlayerController(PlayerController).bRightMousePressed==true)  //Interrumpir casteo
            {
                DoorOfLiesPlayerController(PlayerController).GotoState('Idle');
                 CastArea.Decal.ResetToDefaults();
                  CastArea=none;
                 Die();
            }
            Charging(Deltatime);
        break;
        case Inflige:
        
          
          if(TypeOrigin==true)
            {
            direccion = Normal(groundLocation - locationShoot);
            newLocation = Location;
            newLocation += direccion * speed * Deltatime;
            SetLocation(newLocation);
            }

            DoDamage("-15",20);
            if(particlesON==false)
            {
              ActivarParticulas();
              particlesON=true;
              Action(TypeSecondaryEffect);  // ACCIONES SECUNDARIAS.
            }
           /* if(TypeSecondaryEffect==3)
             for(i=0;i<colisionando.length;i++)
              {
                pawn(colisionando[i]).GroundSpeed=150;
               }*/
        break;
    }
     
}
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
  super.Touch(Other, OtherComp, HitLocation, HitNormal);

}
event untouch(actor other)
{
  super.untouch(other);
}
simulated function Die()
{
  
  Reticule.Decal.ResetToDefaults();
  Reticule=none;
  Destroy();
  super.Die();
}

simulated function CancelCast()
{
  
  Reticule.Decal.ResetToDefaults();
  Reticule=none;

  if( actual == Seleccion ) Destroy();
}

function Action(int type)
{
//local PlayerController PlayerController;
//PlayerController = GetALocalPlayerController();
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
   // malla.SetRotation(Rotator(RotateToPlayer(groundLocation)*1));
    CylinderComponent.SetActorCollision(false, false);
    malla.SetActorCollision(true, true);
    CollisionComponent=malla;
    while(colisionando[0]!=none)
    {
    recolocarActoresColisionando();
    }
    bBlockActors=true;
    break;
    case 3: //RALENTIZAR
    break;
    case 4: //DERRIBAR
    break;
  }
}
function recolocarActoresColisionando() //para el spawn del bloque de hielo.
{
  local int i;
  local vector mov;
  for(i=0;i<colisionando.length;i++)
      {
        mov.x=colisionando[i].Location.X-Location.X;
        mov.y=colisionando[i].Location.Y-Location.Y;
        mov.x=colisionando[i].Location.X+ mov.x;
        mov.y=colisionando[i].Location.Y+ mov.y;
        mov.z=colisionando[i].Location.Z;
        colisionando[i].SetLocation(mov);
      }
}

DefaultProperties
{ 

  outrangenext=0;

  ReticuleClickMaterial=DecalMaterial'Decals.Materials.Area_Select'
  actual=Seleccion
}