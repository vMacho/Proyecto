package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	public class botonVolum extends MovieClip {
		
		
		public function botonVolum() {
			// constructor code
		stop();
		this.addEventListener(MouseEvent.CLICK, mouse_click); 
		this.addEventListener(MouseEvent.MOUSE_OVER, mouse_over);
		this.addEventListener(MouseEvent.MOUSE_OUT, mouse_out); 
		}
		
		private function mouse_click(e:MouseEvent):void
		{
		
	
		};
		private function mouse_over(e:MouseEvent):void
		{
		gotoAndStop(2);
		};
		private function mouse_out(e:MouseEvent):void
		{
		gotoAndStop(1);
		};
	}
	
}
