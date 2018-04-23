package  {
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	
	public class CharA extends MovieClip {
		
		public var speed:int=2;
		public var life:int=120;
		public var damage:Number=3;
		public var sprintValue:int=2;
		public var sprintCost:int=1;
		public var stamina:Number=500;
		public var fireRate:int=1;
		public var fireRange:int=45;
		public var bulletSpeed:int=4;
		public var constantMuzzle:Boolean=true;
		public var constantShot:Boolean=true;
		
		public function CharA() {
		
		}
	}
	
}
