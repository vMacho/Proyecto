class AreaEnemiga extends Area;

enum Estados
{
    Cargando,
    Inflige
};
var Estados actual;

var MaterialInterface ReticuleClickMaterial;
var ReticuleActor Reticule;
//var ReticuleActor CastArea;
var Vector groundLocation,groundNormal;

var int outrangenext;
var vector locationShoot;
simulated event PostBeginPlay()
{
    From=false;
    super.PostBeginPlay();
    SetTimer(duration, false, 'Die');
}

simulated event Tick(float Deltatime)
{
    
    //local Vector groundNormal;
    //local vector mouseOri,MouseDir;
    //local Vector newLocation, direccion;
   // local int i;
   // local PlayerController PlayerController;
   // for(i=0;i<colisionando.length;i++) { `log(""$i); `log(" "$colisionando[i]); }
   //  PlayerController = GetALocalPlayerController();
   // mouseOri=myhud(PlayerController.myHUD).MouseOrigin_;
   // mouseDir=myhud(PlayerController.myHUD).MouseDir_; 
   // if(outrangenext>0)
   // {
   //   outrangenext--;
   // }
   super.Tick(Deltatime);

    switch (actual)
    {
        /*case Seleccion:

            Trace(groundLocation, groundNormal, mouseOri + (MouseDir * 100000), mouseOri, false);
            if(TypeOrigin==false)
            {
            SetLocation(groundLocation);
            }
            else
            {
                  Reticule.Decal.Width=400;
                  Reticule.Decal.Height=1200;
              SetLocation(emitterPawn.Location);
            }
            SetRotation(Rotator(RotateToPlayer(groundLocation)*1));
            groundNormal.z=1;     // de esta manera no se bugean las areas que spawneamos
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
           
        break;*/
        case Cargando:
            //DoorOfLiesPlayerController(PlayerController).GotoState('CastingHability');
            groundNormal.x=0;
            groundNormal.y=0;
            groundNormal.z=1;     // de esta manera no se bugean las areas que spawneamos
            
           if(Reticule==none)
           {
               Reticule = Spawn(class'DoorOfLiesGame.ReticuleActor', , , Location + (groundNormal* 48), Rotator(groundNormal * -1), , true);  

               if(Reticule != none)
                {
                Reticule.Decal.SetDecalMaterial(matTime);   
                Reticule.Decal.Width=anchoarea;
                Reticule.Decal.Height=largoarea;
                }
           }
           if(Reticule!=none)
           {

           }
            if(hurt==true)
            {
              //DoorOfLiesPlayerController(PlayerController).hability_finished=true;
              actual=Inflige;
              //locationShoot=emitterPawn.Location;
            }
            /* if(DoorOfLiesPlayerController(PlayerController).bRightMousePressed==true)  //Interrumpir casteo
            {
                DoorOfLiesPlayerController(PlayerController).GotoState('Idle');
                 CastArea.Decal.ResetToDefaults();
                  CastArea=none;
                 Die();
            }*/
            Charging(Deltatime);
        break;
        case Inflige:
        
   
         /* if(TypeOrigin==true)
            {
            direccion = Normal(groundLocation - locationShoot);
            newLocation = Location;
            newLocation += direccion * speed * Deltatime;
            SetLocation(newLocation);
            }*/

            DoDamage("-15",20);
            if(particlesON==false)
            {
            ActivarParticulas();
            }
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



DefaultProperties
{ 
 
  outrangenext=0;
  distanciaCast=300;
  ReticuleClickMaterial=DecalMaterial'Decals.Materials.Area_Select'
  actual=Cargando
}