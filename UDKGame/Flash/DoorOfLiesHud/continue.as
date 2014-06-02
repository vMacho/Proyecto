package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
    import flash.events.Event;
	
	public class continuar extends MovieClip {
		
		
		public function continuar() {
			// constructor code
		this.addEventListener(MouseEvent.CLICK, mouse_click);   		
		}
		
		private function mouse_click(e:MouseEvent):void
		{
		(MovieClip(parent) as HUD).changeState(1);
		};
	}
	
}
