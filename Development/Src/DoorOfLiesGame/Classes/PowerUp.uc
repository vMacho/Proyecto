class PowerUp extends Pawn
  ClassGroup(PowerUp);

var (PowerUp) int speed;
var (PowerUp) int speedRotator;
var (PowerUp) float amplitude;
var (PowerUp) int duration;

var (PowerUp) SoundCue PowerON, PowerOFF;
var (PowerUp) Material MaterialON, MaterialOFF;

event Tick(float DeltaTime)
{
    local Vector NewPosition;
    local rotator NewRotation;

    super.Tick(DeltaTime);

    NewPosition = Location;
    NewPosition.Z += Sin(WorldInfo.TimeSeconds * speed) * amplitude;

    NewRotation = Rotation;
    NewRotation.Yaw += DeltaTime * 1000 * speedRotator;

    SetLocation(NewPosition);
    SetRotation(NewRotation);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    PlayFuncion(Other);
}

function PlayFuncion(Actor Other) {}

DefaultProperties
{ 
    Components.Remove(Sprite)

    speed = 2;
    speedRotator = 20;
    amplitude = 0.5;

    duration = 10;

    bCollideActors = true;
    bBlockActors = false;
}