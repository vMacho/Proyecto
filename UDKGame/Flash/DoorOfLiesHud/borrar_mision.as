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
	import Quests;
	
	public class borrar_mision extends MovieClip {
		
		
		public function borrar_mision() {
			
			 this.addEventListener(MouseEvent.CLICK, mouse_click);
		}
		private function mouse_click(e:MouseEvent):void
		{		
			
			MovieClip(parent).BorrarMis();
		}
	}
	
}
