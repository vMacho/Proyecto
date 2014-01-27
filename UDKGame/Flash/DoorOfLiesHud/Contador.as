package  {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import fl.motion.Color;
	
	public class Contador extends MovieClip 
	{
		public var label:TextField;
		
		public function Contador() 
		{
			label = new TextField();
            label.autoSize = TextFieldAutoSize.CENTER;
			
			label.x -= 50;			
			label.y += 50;

            var format:TextFormat = new TextFormat();
            format.font = "Trajan Pro 3";
            format.color = 0xFF0000;
            format.size = 93;
			
            label.defaultTextFormat = format;
			label.embedFonts = true;
			addChild(label);
			
			SetLabel(0);
		}
		
		public function SetLabel(calabazas:Number):void 
		{
            label.text = String(calabazas);
        }
	}
	
}
