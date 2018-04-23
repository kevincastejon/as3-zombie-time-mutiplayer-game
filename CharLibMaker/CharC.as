package  {
	
	import flash.display.MovieClip;
	
	
	public class CharC extends MovieClip {
		
		public var speed:int=4;
		public var life:int=85;
		public var damage:Number=3;
		public var sprintValue:int=4;
		public var sprintCost:int=2;
		public var stamina:Number=500;
		public var fireRate:int=35;
		public var fireRange:int=500;
		public var bulletSpeed:int=20;
		public var constantMuzzle:Boolean;
		
		public var constantShot:Boolean=false;
		
		public function CharC() {
			// constructor code
		}
	}
	
}
