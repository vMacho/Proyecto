class MyWeaponAttachment extends UTWeaponAttachment;


defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshWeapon
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
	End Object
	Mesh=SkeletalMeshWeapon

	WeaponClass = class 'MyWeapon'

	MuzzleFlashSocket = MuzzleFlashSocket
}