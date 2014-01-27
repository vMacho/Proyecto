 /* Victor Macho
    Clase HUD en unreal
Posicion del raton y debug de variables
 */

class HUDMENU extends UTHUD;

var DoorOfLiesHudMenu MyHudMenu;


simulated event PostBeginPlay() //Al empezar
{
    super.PostBeginPlay();
    `Log("The custom hud is alive !");

    MyHudMenu = new class'DoorOfLiesHudMenu';
    MyHudMenu.Start();
}

function PreCalcValues()
{
    super.PreCalcValues();

    if(MyHudMenu != none)
    {
        MyHudMenu.SetViewport(0,0,SizeX, SizeY);
        MyHudMenu.SetViewScaleMode(SM_NoScale);
        MyHudMenu.SetAlignment(Align_TopLeft);
    }
}

DefaultProperties
{
    bShowScores = false;
}