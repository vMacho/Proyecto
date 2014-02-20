class MyWeapon extends UTWeapon;

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
    WorldInfo.MyDecalManager.SpawnDecal (   DecalMaterial'HU_Deck.Decals.M_Decal_GooLeak', // UMaterialInstance used for this decal.
                        Impact.HitLocation, // Decal spawned at the hit location.
                        rotator(-Impact.HitNormal), // Orient decal into the surface.
                        128, 128, // Decal size in tangent/binormal directions.
                        256, // Decal size in normal direction.
                        false, // If TRUE, use "NoClip" codepath.
                        FRand() * 360, // random rotation
                        Impact.HitInfo.HitComponent // If non-NULL, consider this component only.
    );
}

simulated function TimeWeaponEquipping()
{
    AttachWeaponTo( Instigator.Mesh,'sk_head' );
    super.TimeWeaponEquipping();
}
 
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
    MeshCpnt.AttachComponentToSocket(Mesh,SocketName);
}

defaultproperties
{
   Begin Object class=AnimNodeSequence Name=MeshSequenceA
      bCauseActorAnimEnd=true
   End Object

   // Weapon SkeletalMesh
   Begin Object Name=FirstPersonMesh
      SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
      AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
      Animations=MeshSequenceA
      Scale=0.9
      FOV=60.0
   End Object
   
   AttachmentClass = class 'MyWeaponAttachment'

   // Pickup SkeletalMesh
   Begin Object Name=PickupMesh
      SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
   End Object

   WeaponFireTypes(0) = EWFT_InstantHit
   WeaponFireTypes(1) = EWFT_None

   InstantHitDamage(0) = 50
   ShotCost(0) = 0

   AmmoCount = 1
   MaxAmmoCount = 1

   WeaponFireAnim(0) = Idle

   //WeaponProjectiles(0)=class'UTProj_LinkPlasma'
   
   //WeaponEquipSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_RaiseCue'
   WeaponPutDownSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_LowerCue'
   WeaponFireSnd(0)=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_FireCue'
   
   PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Link_Cue'

   MuzzleFlashSocket=MuzzleFlashSocket
   MuzzleFlashPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
   
   CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs'
   CrossHairCoordinates=(U=384,V=0,UL=64,VL=64)
}