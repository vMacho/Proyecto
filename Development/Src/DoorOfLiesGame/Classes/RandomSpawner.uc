class RandomSpawner extends Volume
					placeable;

var Box BoundingBox;
var (Spawners) class<Actor> SpawnActor;
var (Spawners) int MaxActorInScene;
var (Spawners) int SecondsSpawn;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	GetComponentsBoundingBox(BoundingBox);

	if(SpawnActor != none) SetTimer(SecondsSpawn, true, 'SpawnActors');
}

function SpawnActors()
{	
	local Actor checkActor;
	if(MaxActorInScene > 0)
	{
		checkActor = Spawn(SpawnActor, , , RandomLocation());
		if(checkActor != none) MaxActorInScene--;
	}
}

function vector RandomLocation()
{
	local vector result;
	
	result.X = RandRange(BoundingBox.Min.X, BoundingBox.Max.X);
	result.Y = RandRange(BoundingBox.Min.Y, BoundingBox.Max.Y);
	//result.Z = RandRange(BoundingBox.Min.Z, (BoundingBox.Max.Z/2));
	result.Z = BoundingBox.Max.Z/2;
	
	//`Log("Spawner -> "$result.X$", "@result.Y);

	return result;
}

DefaultProperties
{
	bStatic=false;
	bNoDelete=true;

	MaxActorInScene = 5; //Numero max de Actores Spawneables(Si, me he inventado la palabra) que hay en escena
	SecondsSpawn = 10; //Cada cuanto se crea un actor
}