package piooas3Tools.fl.display {
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import fl.motion.Color;

	
	public class FX {

		public function FX() {
			
		}
		
		public static function tint(disp:DisplayObject,color:uint,tintAmount:Number=1){
		var col:Color=new Color();
		col.setTint(color,tintAmount);
		disp.transform.colorTransform=col;
		}
		public static function removeTint(disp:DisplayObject){
		disp.transform.colorTransform=new ColorTransform();
		}

	}
	
}
