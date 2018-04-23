package engine.bullets {
	
	import flash.display.MovieClip;
	import piooas3Tools.fl.utils.MathSup;
	import engine.actors.Actor;
	
	
	public class Bullet extends MovieClip {
		
		public var owner:Actor;
		public var angleRadian:Number;
		public var distance:Number=0;
		
		public function Bullet(owner:Actor) {
		this.owner=owner;
		rotation=owner.rotation;
		var dispersedRot:int=rotation+owner.dispersionPattern[owner.numBulletsInARaw];
		angleRadian=MathSup.degreeToRadian(dispersedRot);
		}
	}
	
}
