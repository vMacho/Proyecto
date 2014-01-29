class PowerUp_MaxCalabazas extends PowerUp
						   placeable;

var bool IsUsing;
var Actor ActiveActor;
var StaticMeshComponent MeshPowerUp;

function PlayFuncion(Actor Other) 
{
	if(Other.tag == 'Player' && !IsUsing)
	{
		IsUsing = true;
		ActiveActor = Other;

		DoorOfLiesPawn(ActiveActor).maxCalabazas ++;
		SetTimer(duration, false, 'ResetPowerUp');

		MeshPowerUp.SetMaterial(0, MaterialOFF);
		PlaySound(PowerON);
	}
}

function ResetPowerUp()
{
	DoorOfLiesPawn(ActiveActor).maxCalabazas --;
	IsUsing = false;
	
	MeshPowerUp.SetMaterial(0, MaterialON);
	ActiveActor.PlaySound(PowerOFF);
}

DefaultProperties
{ 
	 Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment //Como afecta la luz al modelo
        ModShadowFadeoutTime=0.25
        MinTimeBetweenFullUpdates=0.2
        AmbientGlow=(R=.01,G=.01,B=.01,A=1)
        AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
        bSynthesizeSHLight=TRUE
    End Object
    Components.Add(MyLightEnvironment)

    Begin Object Class=StaticMeshComponent Name=PowerUpMesh
        LightEnvironment=MyLightEnvironment;
        StaticMesh=StaticMesh'LT_Light.SM.Mesh.S_LT_Light_SM_Light01'
    End Object
    Components.Add(PowerUpMesh)
    MeshPowerUp = PowerUpMesh;

    Begin Object Name=CollisionCylinder
        CollisionHeight=+44.000000
        CollisionRadius=+100.000000
    End Object

    IsUsing = false;

    PowerOn = SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_EnemyFlagGrab01Cue';
    PowerOFF = SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_BladeBreakOff';

    MaterialON = Material'PowerUpMaxCalabazas.Material.M_LT_Light_SM_Light01';
    MaterialOFF = Material'PowerUpMaxCalabazas.Material.M_LT_Light_SM_OFF';

    duration = 5;

    DrawScale = 2;
}