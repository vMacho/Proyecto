 /* Victor Macho
    Clase PAWN 
Define Modelo - Animaciones - Afecta Luz o no
 */

class MenuPawn extends Pawn;

simulated function name GetDefaultCameraMode( PlayerController RequestedBy ) // Tipo de camara por defecto
{
    return 'Isometric';
}

defaultproperties
{
    Components.Remove(Sprite)
    Tag = "Player";
}

