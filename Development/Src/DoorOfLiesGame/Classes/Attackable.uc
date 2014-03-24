class Attackable extends Pawn;

var float time_burnning;

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

DefaultProperties
{
    time_burnning = 3;
}