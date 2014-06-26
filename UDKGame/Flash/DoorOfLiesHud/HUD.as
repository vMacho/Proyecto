package  {
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.SimpleButton;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	
	public class HUD extends MovieClip {
		
		private var estado:int;
		public function HUD() {
			estado=1;
			changeState(1);
		}
		public function changeState(state:int)
		{
			estado=state;
			switch(state)
			{
				case 1:   // MODO DE JUEGO
					
						getChildByName("_HUDQuestMenu").visible= false;
						getChildByName("_btnMainMenu").visible = false;
				
						ExternalInterface.call("PauseGameControl", false);
										
					break;
				case 2:  // MODO MISIONES
						
						getChildByName("_HUDQuestMenu").visible= true;
						getChildByName("_btnMainMenu").visible = false;
						ExternalInterface.call("PauseGameControl", false);
						(getChildByName("_btnPause")as BotonPause).reiniciar();
						//(getChildByName("_close")as close).reiniciar();
				
					break;
				case 3:  // MODO OPCIONES
						getChildByName("_HUDQuestMenu").visible= false;
						getChildByName("_btnMainMenu").visible = true;
						ExternalInterface.call("PauseGameControl", true);
						//(getChildByName("_HUDQuestsButton")as BotonMisiones).reiniciar();
						//(getChildByName("_close")as close).reiniciar();
				
					break;
				case 4:
					break;
			}
			
			
		}
		public function getState():int
		{
		return estado;
		}
		
		
		
	}
	
}
