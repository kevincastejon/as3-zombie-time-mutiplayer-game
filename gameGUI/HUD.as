package gameGUI {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import engine.actors.Player;
	
	
	public class HUD extends Sprite {
		
		private var lifeBar:LifeBar;
		private var staminaBar:LifeBar;
		private var hero:Player;
		
		public function HUD() {
		lifeBar=s_lifeBar;
		staminaBar=s_staminaBar;
		staminaBar.setColors(0x00FFFF,0x0000FF);
		}
		
		public function start(hero:Player):void{
		this.hero=hero;
		this.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		public function onFrame(e:Event):void{
		lifeBar.setLifePercent(hero.life/hero.maxLife);
		staminaBar.setLifePercent(hero.stamina/hero.maxStamina);
		}
	}
	
}
