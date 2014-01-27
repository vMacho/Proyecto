 /* Victor Macho
    Clase Pointer del suelo
 */

class PointerActor extends StaticMeshActor
				   placeable;
 

DefaultProperties
{ 
	Begin Object Class=StaticMeshComponent Name=StaticMeshPointer
		StaticMesh=StaticMesh'NodeBuddies.3D_Icons.NodeBuddy_PopUp'
		Scale = 2; //Scale del Mesh
		CollideActors=false
		BlockActors=false
	End Object
	StaticMeshComponent=StaticMeshPointer
	Components.Add(StaticMeshPointer)

	bStatic = false;
	bNoDelete = false;
}