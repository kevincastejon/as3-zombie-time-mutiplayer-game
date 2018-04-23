package piooas3Tools.fl.display {
	import flash.display.Sprite;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	
	public class GeometricForm {

		public function GeometricForm() {
			
		}
		
		public static function getSquare(width:Number=50,height:Number=50,border:Boolean=true,borderThick:Number=0,borderColor:uint=0, borderAlpha:Number=1,background:Boolean=true,backgroundColor:uint=0xFFFFFF,backgroundAlpha:Number=1,pixelHinting:Boolean=false,scaleMode:String=LineScaleMode.NORMAL,caps:String=CapsStyle.ROUND,joints:String=JointStyle.ROUND):Sprite{
		var square:Sprite=new Sprite();
		if(background)square.graphics.beginFill(backgroundColor,backgroundAlpha);
		if(!border)borderThick=NaN;
		square.graphics.lineStyle(borderThick,borderColor,borderAlpha,pixelHinting,scaleMode,caps,joints);
		square.graphics.drawRect(0,0,width,height);
		square.graphics.endFill();
		return(square);
		}
		public static function getCircle(radius:Number=50,border:Boolean=true,borderThick:Number=0,borderColor:uint=0, borderAlpha:Number=1,background:Boolean=true,backgroundColor:uint=0xFFFFFF,backgroundAlpha:Number=1,pixelHinting:Boolean=false,scaleMode:String=LineScaleMode.NORMAL):Sprite{
		var circle:Sprite=new Sprite();
		if(background)circle.graphics.beginFill(backgroundColor,backgroundAlpha);
		if(!border)borderThick=NaN;
		circle.graphics.lineStyle(borderThick,borderColor,borderAlpha,pixelHinting,scaleMode);
		circle.graphics.drawCircle(0,0,radius);
		circle.graphics.endFill();
		return(circle);
		}

	}
	
}
