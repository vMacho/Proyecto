package  {
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	
	public class Boton extends MovieClip 
	{		
		public var label:TextField;
        private var labelText:String = "Boton";
		private var espera:Timer;
		
		public function Boton() {
			addEventListener(MouseEvent.CLICK, OnClick);
			ConfigureLabel();
		}
		
		public function OnClick(event:MouseEvent): void
		{
			SetLabel("GO");
			espera = new Timer(200, 1); //Delay para el click
			espera.addEventListener(TimerEvent.TIMER, ControlaClick);
			espera.start();
			
		}
		
		public function ControlaClick(event:TimerEvent):void{}
		
		public function ConfigureLabel():void 
		{
            label = new TextField();
            label.autoSize = TextFieldAutoSize.CENTER;
			label.x += 150;
			label.y += 200;

            var format:TextFormat = new TextFormat();
            format.font = "Trajan Pro 3";
            format.color = 000;
            format.size = 93;

            label.defaultTextFormat = format;
            addChild(label);
        }
		
		public function ChangeFormat(format:TextFormat) : void
		{
			label.defaultTextFormat = format;
		}		
		
		public function SetLabel(str:String):void {
            label.text = str;
        }
	}
	
}
