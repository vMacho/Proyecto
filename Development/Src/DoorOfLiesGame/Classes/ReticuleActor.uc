class ReticuleActor extends DecalActorMovable;

static function PreInitialize( MaterialInstanceConstant matTime )
{
  default.Decal.SetDecalMaterial(matTime);
}

defaultproperties
{
	bNoDelete=false

}