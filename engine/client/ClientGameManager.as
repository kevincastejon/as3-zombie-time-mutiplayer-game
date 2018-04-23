package engine.client{
	import flash.display.Sprite;
	import engine.actors.Player;
	import engine.inputs.HeroInputManager;
	import gameGUI.HUD;
	import gameGUI.GameOverScreen;
	import gameGUI.NewWaveScreen;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import events.ActionInputEvent;
	import events.StateInputEvent;
	import engine.inputs.StateInput;
	import engine.actors.ActorState;
	import engine.inputs.ActionInput;
	import engine.mobs.Mob;
	import engine.actors.ActorType;
	import com.greensock.data.TweenLiteVars;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	
	public class ClientGameManager extends Sprite{

		private var heroInputManager:HeroInputManager=new HeroInputManager();
		private var map:ClientMap=new ClientMap();
		private var players:Vector.<Player>=new Vector.<Player>();		//MAYBE DELETE ?
		private var hero:Player;
		private var hud:HUD=new HUD();
		private var gameOverScreen:GameOverScreen=new GameOverScreen();
		private var newWaveScreen:NewWaveScreen=new NewWaveScreen();
		private var inputsSendRate:int=100;
		private var inputsSendTimer:Timer;
		private var inputsBuffer:Vector.<StateInput>=new Vector.<StateInput>();
		public function ClientGameManager(){
		
		}
		
		public function start(players:Vector.<Player>,hero:Player):void{
		var max:int=players.length;
		this.players=players;
		this.hero=hero;
		hero.showLifeBar(false,false);
		addChild(map);
		this.addEventListener(Event.ENTER_FRAME,onFrame);
		map.start(players,hero);
		heroInputManager.start();
		heroInputManager.addEventListener(ActionInputEvent.ACTION_INPUT, heroActionInputHandler);
		hud.start(hero);
		addChild(hud);
		inputsSendTimer=new Timer(inputsSendRate);
		inputsSendTimer.addEventListener(TimerEvent.TIMER, sendInputs);
		inputsSendTimer.start();
		}
		
		public function setActorActionInput(actorType:int,id:int,actionInput:ActionInput):void{
		map.setActorActionInput(actorType,id,actionInput);
		}
		public function setActorStates(actorStates:Vector.<ActorState>, lastInputID:int):void{
		map.setActorStates(actorStates, lastInputID);
		}
		public function removePlayer(player:Player):void{
		map.removePlayer(player);
		}
		public function getMobByID(id:int):Mob{
		return(map.getMobByID(id));
		}
		public function setGameOver():void{
		addChild(gameOverScreen);
		}
		public function setNextWave():void{
		map.startNextWaveCountDown();
		newWaveScreen.setWave(map.currentWave);
		addChild(newWaveScreen);
		TweenLite.delayedCall(5,removeNewWaveScreen);
		}
		private function onFrame(e:Event):void{
		heroStateInputHandler();
		map.makeActorsShoot();
		map.moveBullets();
		centerMapOnHero();
		}
		private function centerMapOnHero():void{var tv:TweenLiteVars;
		map.x=stage.stageWidth/2-hero.x;
		map.y=stage.stageHeight/2-hero.y;
		}
		private function heroStateInputHandler():void{
			if(heroInputManager.hasActiveStateInput() && !hero.dead){
			var stateInput:StateInput=heroInputManager.getStateInput();
			map.setPredictedStateInput(stateInput);
			inputsBuffer.push(stateInput);
			}
		}
		private function heroActionInputHandler(e:ActionInputEvent):void{
			if(!hero.dead){
			map.setPredictedActionInput(e.actionInput);
			dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT, e.actionInput));
			}
		}
		private function sendInputs(e:Event):void{
		dispatchEvent(new StateInputEvent(StateInputEvent.STATE_INPUT,inputsBuffer));
		inputsBuffer=new Vector.<StateInput>();
		}
		private function removeNewWaveScreen():void{
		removeChild(newWaveScreen);
		}
		
	}
	
}
