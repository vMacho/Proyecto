class Compass extends actor 
	placeable;

// Return the yaw of the actor
function int GetYaw()
{
   return Rotation.Yaw;
}

function Rotator GetRotator()
{
   return Rotation;
}

function vector GetVectorizedRotator()
{
   return vector(Rotation);
}

function float GetRadianHeading()
{
	local Vector v;
	local Rotator r;
	local float f;

	r.Yaw = GetYaw();
	v = vector(r);
	f = GetHeadingAngle(v);
	f = UnwindHeading(f);

	while (f < 0) f += PI * 2.0f;

	return f;
}

function float GetDegreeHeading()
{
   local float f;

   f = GetRadianHeading();

   f *= RadToDeg;

   return f;
}

event PostBeginPlay()
{      
   `log("===================================",,'UTBook');
    `log("Compass Heading"@GetRadianHeading()@GetDegreeHeading(),,'UTBook');
   `log("===================================",,'UTBook');
}

DefaultProperties
{
	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor = (B=80,G=80,R=200,A=255);
		ArrowSize = 1.000000;
		Name = "North Heading";
	End Object
	Components(0) = Arrow;

	Begin Object Class=SpriteComponent Name=Sprite 
		Sprite=Texture2D'CompassContent.Compass';
		HiddenGame = True;
		AlwaysLoadOnClient = False;
		AlwaysLoadOnServer = False;
	End Object
	Components(1) = Sprite;

	bStatic = True;
	bHidden = True;
	bNoDelete = True;
	bMovable  = False;
}