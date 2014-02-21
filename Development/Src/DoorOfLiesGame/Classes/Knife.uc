class Knife extends Weapon 
placeable;

var array<SoundCue> WeaponFireSnd;

simulated function TimeWeaponEquipping()
{
    AttachWeaponTo( Instigator.Mesh, 'WeaponPoint' );
    super.TimeWeaponEquipping();
}
 
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
 
    MeshCpnt.AttachComponentToSocket(Mesh, SocketName);
}

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
  super.ProcessInstantHit(FiringMode, Impact, NumHits);
  Instigator.PlaySound(WeaponFireSnd[0]);
  /*WorldInfo.MyDecalManager.SpawnDecal (DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak', // UMaterialInstance used for this decal.
                                         playerpos, // Decal spawned at the hit location.
                                         Rotator(vect(0.0f,0.0f,-1.0f)), // Orient decal into the surface.
                                         254, 254, // Decal size in tangent/binormal directions.
                                         512, // Decal size in normal direction.
                                         false, // If TRUE, use "NoClip" codepath.
                                         FRand() * 360, // random rotation
                                         ,true ,true, //bProjectOnTerrain y bProjectOnSkeletalMeshes
                                         ,,,MocoPawn(Pawn).AttackTime + 1
                            );*/
}

simulated state WeaponEquipping
{

  Begin:
    SetHidden(false);
}

simulated state WeaponPuttingDown
{
 Begin:
    SetHidden(true);
}

simulated function DetachWeapon()
{
  SetHidden(true);
}

simulated function Rotator GetAdjustedAim( vector StartFireLoc )
{
  return super.GetAdjustedAim(StartFireLoc);
}

simulated function StartFire( byte FireModeNum )
{
  super.StartFire(0);
  `log("ATACANDO CON CUCHILLO");
}

defaultproperties
{
   Begin Object class=SkeletalMeshComponent Name=FirstPersonMesh
      SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
      AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'      
   End Object
   Components.add(FirstPersonMesh)
   Mesh = FirstPersonMesh

   bHidden=true

   WeaponFireTypes(0) = EWFT_InstantHit
   WeaponFireSnd(0)=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue'
   FireInterval[0] = 2

   WeaponRange=16384
}