package engine.anims {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class OneShotAnim extends Sprite {
		
		private var anim:MovieClip;
		private var tem:int;
		private var max:int;
		
		public function OneShotAnim() {
		anim=getChildAt(0) as MovieClip;
		anim.gotoAndStop(1);
		max=anim.totalFrames;
		this.addEventListener(Event.ADDED_TO_STAGE,added);
		}
		private function added(e:Event):void{
		this.removeEventListener(Event.ADDED_TO_STAGE,added);
		this.addEventListener(Event.ENTER_FRAME,onFrame);
		anim.play();
		}
		private function onFrame(e:Event):void{
		tem++;
		y--;
			if(tem==max){
			anim.stop();
			this.removeEventListener(Event.ENTER_FRAME,onFrame);
			parent.removeChild(this);
			}
		}
	}
	
}
