class Attackable extends Pawn;

var bool inmune;
var (Humanoid) float  default_humanoid_GroundSpeed;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    default_humanoid_GroundSpeed = GroundSpeed;
}

function SetDamage(float damage)
{
	Health -= damage;
}

function SlowGroud(float speedModifier, float time)
{
	ClearAllTimers();
	GroundSpeed -= speedModifier;
	SetTimer(time, false, 'RestartSpeed');
}

function RestartSpeed()
{
	GroundSpeed = default_humanoid_GroundSpeed;
}

DefaultProperties
{
    inmune = false;
}