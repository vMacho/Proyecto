class Attackable extends Pawn;

var float time_burnning;
var (Humanoid) float  default_humanoid_GroundSpeed;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    default_humanoid_GroundSpeed = GroundSpeed;
}

function Burn(float damage)
{
	`log("EXPLOSION");
	SetDamage(damage);
	GoToState('Burnnig');
}

function SetDamage(float damage)
{
	Health -= damage;
}

state Burnnig
{
	function Tick(float DeltaTime)
	{
		super.Tick(DeltaTime);


		time_burnning -= DeltaTime;

	}
	Begin:
		`log("SE QUEMA");
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
    time_burnning = 3;
}