class SacoAttackablePawn extends Attackable
  ClassGroup(Enemy)
  placeable;

  DefaultProperties
  {
	Begin Object Class=SkeletalMeshComponent Name=EnemySkeletalMesh
		SkeletalMesh=SkeletalMesh'Orco.SkeletalMesh.micro_orc'
		AnimTreeTemplate=AnimTree'Orco.AnimTree'
		AnimSets(0)=AnimSet'Orco.SkeletalMesh.Idle'
		Translation = (Z=-50)
	End Object
	Mesh=EnemySkeletalMesh
	Components.Add(EnemySkeletalMesh)

	Begin Object Name=CollisionCylinder
        CollisionRadius=+0034.000000
        CollisionHeight=+0120.000000
        
    End Object
    CylinderComponent=CollisionCylinder

  }
   