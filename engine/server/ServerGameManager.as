package engine.server{
	import flash.display.Sprite;
	import engine.inputs.StateInput;
	import engine.inputs.ActionInput;
	import engine.actors.Player;
	import gameGUI.HUD;
	import gameGUI.GameOverScreen;
	import gameGUI.NewWaveScreen;
	import flash.events.Event;
	import engine.inputs.HeroInputManager;
	import events.StateInputEvent;
	import events.ActionInputEvent;
	import engine.actors.ActorType;
	import events.IDRelatedEvent;
	import events.SimpleEvent;
	import events.ActorStateEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import engine.mobs.Mob;
	import com.greensock.TweenLite;
	import piooas3Tools.fl.utils.IterableTools;
	import flash.geom.Point;
	
	
	public class ServerGameManager extends Sprite{

	private var heroInputManager:HeroInputManager=new HeroInputManager();
	private var map:ServerMap=new ServerMap();
		
	private var players:Vector.<Player>;
	private var hero:Player;
		
	private var hud:HUD=new HUD();
	private var gameOverScreen:GameOverScreen=new GameOverScreen();
	private var newWaveScreen:NewWaveScreen=new NewWaveScreen();
		
	private var gameStatesSendRate:int=200;
	private var gameStatesSendTimer:Timer;
	
		public function ServerGameManager(){
		
		}
		
		public function start(players:Vector.<Player>,hero:Player):void{
		this.hero=hero;
		this.players=players;
		hero.showLifeBar(false,false);
		addChild(map);
		addChild(hud);
		this.addEventListener(Event.ENTER_FRAME,onFrame);
		map.addEventListener(ActionInputEvent.ACTION_INPUT,mapEventRedispatcher);
		map.addEventListener(SimpleEvent.GAME_OVER,mapEventRedispatcher);
		map.addEventListener(SimpleEvent.NEW_WAVE,mapEventRedispatcher);
		map.start(players);
		hud.start(hero);
		heroInputManager.start();
		heroInputManager.addEventListener(ActionInputEvent.ACTION_INPUT, heroActionInputHandler);		
		gameStatesSendTimer=new Timer(gameStatesSendRate);
		gameStatesSendTimer.addEventListener(TimerEvent.TIMER, sendGameStates);
		gameStatesSendTimer.start();
		}
		
		private function setActorStateInput(actorType:int,id:int,stateInput:StateInput):void{
		map.setActorStateInput(actorType,id,stateInput);
		}
		public function setPlayerStateInputBuffer(id:int,stateInputs:Vector.<StateInput>):void{
		var player:Player=IterableTools.getElementByProperties(players,[["id",id]]);
		var max:int=stateInputs.length;
			for(var i:int=0;i<max;i++){
			player.stateInputsBuffer.push(stateInputs[i]);
			}
		}
		public function setActorActionInput(actorType:int,id:int,actionInput:ActionInput):void{
		map.setActorActionInput(actorType,id,actionInput);
		}
		public function removePlayer(player:Player):void{
		map.removePlayer(player);
		}
		public function getMobByID(id:int):Mob{
		return(map.getMobByID(id));
		}
		private function onFrame(e:Event):void{
		heroStateInputHandler();
		playersBufferInputsHandler();
		map.makeActorsShoot();
		map.moveBullets();
		map.IAOnFrame();
		centerMapOnHero();
		}
		private function centerMapOnHero():void{
		/*map.x=this.localToGlobal(this.globalToLocal(new Point(stage.stageWidth/2-hero.x))).x;
		map.y=this.localToGlobal(this.globalToLocal(new Point(0,stage.stageHeight/2-hero.y))).y;*/
		map.x=stage.stageWidth/2-hero.x;
		map.y=stage.stageHeight/2-hero.y;
		}
		private function heroStateInputHandler():void{
			if(heroInputManager.hasActiveStateInput() && !hero.dead)
			setActorStateInput(ActorType.PLAYER,hero.id,heroInputManager.getStateInput());
		}
		private function heroActionInputHandler(e:ActionInputEvent):void{
		if(!hero.dead)setActorActionInput(ActorType.PLAYER,hero.id,e.actionInput);
		}
		private function playersBufferInputsHandler():void{
		var max:int=players.length;
			for(var i:int=0;i<max;i++){
			if(players[i].stateInputsBuffer.length>0)setActorStateInput(ActorType.PLAYER,players[i].id, players[i].stateInputsBuffer.shift());
			}
		}
		private function mapEventRedispatcher(e:Event):void{
			if(e.type==SimpleEvent.NEW_WAVE){
			addChild(newWaveScreen);
			newWaveScreen.setWave(map.currentWave);
			TweenLite.delayedCall(5,removeNewWaveScreen);
			}
			else if(e.type==SimpleEvent.GAME_OVER){
			addChild(gameOverScreen);
			}
		
		dispatchEvent(e);	//Dispatch map events (actors action inputs,game over,next wave signals,...) to Main for sending to clients
		}
		private function removeNewWaveScreen():void{
		removeChild(newWaveScreen);
		}
		private function sendGameStates(e:Event):void{
		var max:int=players.length;
			for(var i:int;i<max;i++){
			if(players[i]!=hero)this.dispatchEvent(new ActorStateEvent(ActorStateEvent.ACTOR_STATES,map.getActorStates(),players[i].id,players[i].lastStateInputID));
			}
		
		}
		
	}
	
}
