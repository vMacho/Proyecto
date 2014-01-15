package  {
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	public class CustomMouse extends MovieClip {
		
		public function CustomMouse() {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, OnMouseDown);
			Mouse.hide();
		}
		
		public function OnMouseMove(Event:MouseEvent)
		{
			this.x = root.mouseX;
			this.y = root.mouseY;
			
			ExternalInterface.call("OnMouseMove", this.x, this.y);
		}
		
		public function OnMouseUp(Event:MouseEvent)
		{
			ExternalInterface.call("OnMouseUp", this.x, this.y);
		}
		
		public function OnMouseDown(Event:MouseEvent)
		{
			ExternalInterface.call("OnMouseDown", this.x, this.y);
		}
	}
	
}
