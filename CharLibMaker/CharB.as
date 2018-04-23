package  {
	
	import flash.display.MovieClip;
	
	
	public class CharB extends MovieClip {
		
		public var speed:int=3;
		public var life:int=100;
		public var damage:Number=1;
		public var sprintValue:int=3;
		public var sprintCost:int=1;
		public var stamina:Number=500;
		public var fireRate:int=8;
		public var fireRange:int=500;
		public var bulletSpeed:int=20;
		public var constantMuzzle:Boolean;
		
		public var constantShot:Boolean=false;
		
		public function CharB() {
			// constructor code
		}
	}
	
}
