package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import mision;
	
	public class Quests extends MovieClip {
		
		var names:Array = new Array();
		var mis_activa:int=-1;
		var posx:int=0;
		var questes:Array = [mision];
		var LeerMision:int=-1;
		public var texto:String;
		var miTexto2:TextField = new TextField();
		public function Quests() {
			
			visible = false;
			names.push("Mision rescatar");
			names.push("Mision desencantar");
			Descripcion_mis.text = "No hay mision seleccionada";
			BorrarMenu();
		}
		public function UploadQuests(namesCargar:Array)
		{
			names=namesCargar;
		}
		
		public function BorrarMenu()
		{
				//trace(questes.length);

				while(questes.length>0)
				{
				var questi:mision=questes.pop();
				removeChild(questi);
				delete questes[questes.length];	
				}
				posx=0;

		}
		public function UpdateMenu()
		{
			names.sort();
			var i:int;
			posx=0;
			questes.splice(0);
			for(var value:String in names)
			{
				
				trace(questes.length);
				var quest:mision=new mision(names[value],questes.length);
				quest.x=-7;
				quest.y=40*questes.length;
				
				addChild(quest);
				questes.push(quest);
				
				
				posx=posx+1;
			}
			
		}
		public function DetallesMision(texto:String,num:int)
		{
			if(texto=="0")
			{
				mis_activa=-1;
				Descripcion_Tit.text = "No hay mision seleccionada";
				Descripcion_mis.text = "No hay mision seleccionada";
				
			}
			else
			{
				mis_activa=num;
				Descripcion_Tit.text = texto;
				Descripcion_mis.text = texto;
			}
		}
		public function BorrarMis()
		{

			delete names[mis_activa];
			DetallesMision("0",0)
			BorrarMenu();
			UpdateMenu();
		}
		
	}
}
	

