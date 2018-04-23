package engine.server {
	import flash.display.Sprite;
	import engine.inputs.StateInput;
	import engine.inputs.ActionInput;
	import engine.actors.Player;
	import engine.actors.ActorState;
	import engine.MapElement;
	import engine.anims.*;
	import engine.bullets.*;
	import engine.muzzles.*;
	import engine.mobs.*;
	import engine.PlayerSpawn;
	import engine.MobSpawn;
	import piooas3Tools.fl.utils.IterableTools;
	import engine.actors.Actor;
	import engine.actors.ActorType;
	import engine.inputs.ActionType;
	import events.IDRelatedEvent;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import com.greensock.TweenLite;
	import utils.IDGeneratorChannels;
	import piooas3Tools.fl.utils.MathSup;
	import events.ActionInputEvent;
	import events.SimpleEvent;
	import events.StateInputEvent;
	import flash.events.Event;
	import piooas3Tools.fl.utils.IDGenerator;
	import piooas3Tools.fl.sounds.Magneto;
	import engine.PixelPerfectCollisionDetection;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import com.greensock.events.TweenEvent;
	import flash.geom.Rectangle;
	import utils.AudioBank;
	import utils.Calculator;
	import piooas3Tools.fl.display.GeometricForm;
	import piooas3Tools.fl.pathfinding.Node;
	import piooas3Tools.fl.pathfinding.AStar;
	import engine.Map;
	
	public class ServerMap extends Map {

		private var border:MovieClip;
		private var mapElements:Vector.<MapElement>=new Vector.<MapElement>();
		private var playerSpawns:Vector.<PlayerSpawn>=new Vector.<PlayerSpawn>();
		private var mobSpawns:Vector.<MobSpawn>=new Vector.<MobSpawn>();
		private var mobSpawnsOccupied:Vector.<MobSpawn>=new Vector.<MobSpawn>();
		private var bullets:Vector.<Bullet>=new Vector.<Bullet>();
		private var players:Vector.<Player>=new Vector.<Player>();
		private var mobs:Vector.<Mob>=new Vector.<Mob>();

		private var tileSize:int=50;
		private var nodeMap:Array=[];
		
		public var currentWave:int;
		
		public function ServerMap() {
		var max:int=this.numChildren;
			for(var i:int=0;i<max;i++){
				if(this.getChildAt(i) == s_border){border=s_border;}
				else if(this.getChildAt(i) is MapElement){
				mapElements.push(this.getChildAt(i));
				mapElements[mapElements.length-1].mouseChildren=mapElements[mapElements.length-1].mouseEnabled=false;
				}
				else if(this.getChildAt(i) is PlayerSpawn){
				this.getChildAt(i).visible=false;
				playerSpawns.push(this.getChildAt(i));	
				}
				else if(this.getChildAt(i) is MobSpawn){
				this.getChildAt(i).visible=false;
				mobSpawns.push(this.getChildAt(i));
				}
			}
		
		
		}
		public function start(players:Vector.<Player>):void{
		this.players=players;
		var max:int=border.height/tileSize;
			for(i=0;i<max;i++){
			var max2:int=border.width/tileSize;
			var line:Array=[];
				for(var j:int=0;j<max2;j++){
				var pt:Point=new Point(j*tileSize,i*tileSize);
				var node:Node=new Node(pt.x+tileSize/2,pt.y+tileSize/2,j,i);
				node.walkable=!isColliding(node);
				line.push(node);
				}
			nodeMap.push(line);
			}
		
		max=players.length;
			for(var i:int=0;i<max;i++){
			addChild(players[i]);
			players[i].x=playerSpawns[i].x;
			players[i].y=playerSpawns[i].y;
			}
		startNextWaveCountDown();
		Magneto.playAudio(AudioBank.MAP_MUSIC,"musics",0.5,0,true);

		}
		
		public function setActorStateInput(actorType:int,id:int,stateInput:StateInput):void{
		var actor:Actor;
			if(actorType==ActorType.PLAYER)actor=IterableTools.getElementByProperties(players,[["id",id]]) as Player;
			else if(actorType==ActorType.MOB)actor=IterableTools.getElementByProperties(mobs,[["id",id]]) as Mob;
		var speed:Number=actor.speed;
			if(stateInput.sprinting){
				if(actor.stamina>0)speed+=actor.sprintValue;
				else speed+=0.25;
			}
			if(actor is Player){
			if(stateInput.top){actor.y-=speed;if(isColliding(actor))actor.y+=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			else if(stateInput.bot){actor.y+=speed;if(isColliding(actor))actor.y-=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			if(stateInput.left){actor.x-=speed;if(isColliding(actor))actor.x+=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			else if(stateInput.right){actor.x+=speed;if(isColliding(actor))actor.x-=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			}
			else if(actor is Mob){
			if(stateInput.top){actor.y-=speed;if(isColliding(actor))actor.y+=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			else if(stateInput.bot){actor.y+=speed;if(isColliding(actor))actor.y-=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			if(stateInput.left){actor.x-=speed;if(isColliding(actor))actor.x+=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			else if(stateInput.right){actor.x+=speed;if(isColliding(actor))actor.x-=speed;else if(stateInput.sprinting)actor.removeStamina(actor.sprintCost);}
			}
		if(!isNaN(stateInput.rotation) && stateInput.rotation!=actor.rotation){
		actor.rotation=stateInput.rotation;
		actor.reLocateLifeBar();
		}
		if(actorType==ActorType.PLAYER && actor.id>0)(actor as Player).lastStateInputID=stateInput.inputID;
		}
		public function setActorActionInput(actorType:int,id:int,actionInput:ActionInput):void{
		var actor:Actor;
			if(actorType==ActorType.PLAYER)actor=IterableTools.getElementByProperties(players,[["id",id]]) as Player;
			else if(actorType==ActorType.MOB)actor=IterableTools.getElementByProperties(mobs,[["id",id]]) as Mob;
			
			if(actionInput.type==ActionType.SHOOT){
			actor.shooting=Boolean(actionInput.value);
				if(actor.constantMuzzle==true){
					if(actor.shooting){
					actor.muzzle=actor.getMuzzle();
					actor.muzzle.x=actor.flashPoint.x;
					actor.muzzle.y=actor.flashPoint.y;
					actor.addChild(actor.muzzle);
					}
					else{
					actor.removeChild(actor.muzzle);
					actor.muzzle=null;
					}
				}
				if(actor.constantShot==true){
					if(actor.shooting){
					actor.shotAudioID=Magneto.playAudio(actor.getShotAudioName(),"fx",Calculator.getVolumeForHero(actor),Calculator.getPanForHero(actor),true);
					}
					else{
					Magneto.stopAudio(actor.shotAudioID);
					actor.shotAudioID=-1;
					}
				}
			}
		this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,actionInput,actorType,id));
		}
		public function makeActorsShoot():void{
		var max:int=players.length;
		var bullet:Bullet;
			for(var i:int=0;i<max;i++){
				if(players[i].shooting && players[i].fireFrameTem==players[i].fireRate){
				bullet=players[i].getBullet();
				var gpt:Point=players[i].localToGlobal(new Point(players[i].flashPoint.x,players[i].flashPoint.y));
				var lpt:Point=this.globalToLocal(gpt);
				bullet.x=lpt.x;
				bullet.y=lpt.y;
				bullets.push(bullet);
				addChild(bullet);
				players[i].fireFrameTem=-1;
					if(players[i].constantMuzzle==false){
					var muzzle:MovieClip=players[i].getMuzzle();
					muzzle.x=players[i].flashPoint.x;
					muzzle.y=players[i].flashPoint.y;
					players[i].addChild(muzzle);
					TweenMax.to(muzzle,0.1,{}).addEventListener(TweenEvent.COMPLETE, removeMuzzle);
					}
					if(players[i].constantShot==false)Magneto.playAudio(players[i].getShotAudioName(),"fx");
				}
				if(players[i].fireFrameTem<players[i].fireRate)players[i].fireFrameTem++;
			}
		max=mobs.length;
			for(i=0;i<max;i++){
				if(mobs[i].shooting && mobs[i].fireFrameTem==mobs[i].fireRate){
				bullet=mobs[i].getBullet();
				bullet.x=mobs[i].x;
				bullet.y=mobs[i].y;
				bullets.push(bullet);
				bullet.visible=false;
				addChild(bullet);
				mobs[i].fireFrameTem=-1;
				}
				if(mobs[i].fireFrameTem<mobs[i].fireRate)mobs[i].fireFrameTem++;
			}
		
		}
		public function moveBullets():void{
		var max:int=bullets.length;
		var anim:OneShotAnim;
		var impactAudio:String;
			for(var i:int=0;i<max;i++){
				var cos:Number=Math.cos(bullets[i].angleRadian);
				var sin:Number=Math.sin(bullets[i].angleRadian);
				var op:Point=new Point(bullets[i].x,bullets[i].y);
				bullets[i].x = bullets[i].x + bullets[i].owner.bulletSpeed * cos;
				bullets[i].y = bullets[i].y + bullets[i].owner.bulletSpeed * sin;
				var np:Point=new Point(bullets[i].x,bullets[i].y);
				bullets[i].distance+=Point.distance(op,np);
				var disp:DisplayObject=isColliding(bullets[i]);
				if(disp){
				var rect:Rectangle=PixelPerfectCollisionDetection.getCollisionRect(disp,bullets[i],this,true);
					if(disp is Mob){
					var mob:Mob=disp as Mob; 
					mob.removeLife(bullets[i].owner.damage);
					
						if(mob.dead){
						mob.shooting=mob.visible=false;
						mob.removeEventListener(StateInputEvent.STATE_INPUT,IAHandler);
						mob.removeEventListener(ActionInputEvent.ACTION_INPUT,IAHandler);
						this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.DEAD,0),ActorType.MOB,mob.id));
							if(isAllMobsDead()){
							startNextWaveCountDown();
							}
						}
					
					anim=mob.getImpactAnim();
					impactAudio=mob.getImpactAudioName();
					}
					else if(disp is Player){
					var player:Player=disp as Player;
					player.removeLife(bullets[i].owner.damage);
					anim=new BloodAnim();
					impactAudio=player.getImpactAudioName();
						if(player.dead){
						player.visible=false;
						player.shooting=false;
						this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.DEAD,0),ActorType.PLAYER,player.id));
							if(isAllPlayersDead()){
							this.dispatchEvent(new SimpleEvent(SimpleEvent.GAME_OVER));
							}
						}
					}
					else if((bullets[i].owner is Mob)==false && disp is MapElement){
					anim=(disp as MapElement).getImpactAnim();
					impactAudio=(disp as MapElement).getImpactAudioName();
					}
					if(anim){
					anim.x=rect.x+rect.width/2;
					anim.y=rect.y+rect.height/2;
					addChild(anim);
					}
					if(impactAudio)
					Magneto.playAudio(impactAudio,"fx",Calculator.getVolumeForHero(bullets[i]),Calculator.getPanForHero(bullets[i]));
				removeChild(bullets[i]);
				bullets.removeAt(i);
				max--;
				}
				else if(bullets[i].owner.fireRange>0 && bullets[i].distance>=bullets[i].owner.fireRange){
				removeChild(bullets[i]);
				bullets.removeAt(i);
				max--;
				}
				//trace("bulletDistanceOnRange",bullets[i].distance,"/",bullets[i].owner.fireRange);
			}
		}
		public function removePlayer(player:Player):void{
		//ALREADY REMOVED FROM ARRAY BY MAIN !!!
		removeChild(player);
		}
		public function IAOnFrame():void{
		var max:int=mobs.length;
			for(var i:int=0;i<max;i++){
			if(!mobs[i].dead)mobs[i].onFrame();
			}
		}
		public function getMobByID(id:int):Mob{
		return(IterableTools.getElementByProperties(mobs,[["id",id]])as Mob);
		}
		public function getActorStates():Vector.<ActorState>{
		var vec:Vector.<ActorState>=new Vector.<ActorState>();
		var max:int=mobs.length;
			for(var i:int=0;i<max;i++){
			vec.push(new ActorState(1,mobs[i].id,mobs[i].x,mobs[i].y,mobs[i].rotation,mobs[i].life));
			}
		max=players.length;
			for(i=0;i<max;i++){
			vec.push(new ActorState(0,players[i].id,players[i].x,players[i].y,players[i].rotation,players[i].life));
			}
		return(vec);
		}
		public function startNextWaveCountDown():void{
		currentWave++;
		var max:int = mobSpawnsOccupied.length;
			for(var i:int=0;i<max;i++){
			mobSpawns.push(mobSpawnsOccupied[i]);
			}
		mobSpawnsOccupied=new Vector.<MobSpawn>();
		max=mobs.length;
			for(i=0;i<max;i++){
			removeChild(mobs[i]);
			}
		mobs=new Vector.<Mob>();
		max=players.length;
			for(i=0;i<max;i++){
			players[i].setFullLife();
			players[i].dead=false;
			players[i].visible=true;
			}
		TweenLite.delayedCall(5,startNextWave);
		this.dispatchEvent(new SimpleEvent(SimpleEvent.NEW_WAVE));
		var coin:Boolean=Boolean(MathSup.randomRange(0,1));
		if(coin)Magneto.playAudio(AudioBank.ZOMBIE_YELL01,"fx");
		else Magneto.playAudio(AudioBank.ZOMBIE_YELL02,"fx");
		}
		private function startNextWave():void{
		
		var max:int;
		
		
		max=4;
		var mob:Mob;
		var randomSpawner:MobSpawn;
		var ID:int;
			for(var i:int=0;i<max;i++){
			ID=IDGenerator.getNextID(IDGeneratorChannels.MOBS);
			mob=new MobA(ID,currentWave,players,nodeMap,tileSize) as Mob;
			mobs.push(mob);
			randomSpawner=mobSpawns.removeAt(MathSup.randomRange(0,mobSpawns.length-1)) as MobSpawn;
			mobSpawnsOccupied.push(randomSpawner);
			mob.x=randomSpawner.x;
			mob.y=randomSpawner.y;
			addChild(mob);
			mob.addEventListener(StateInputEvent.STATE_INPUT,IAHandler);
			mob.addEventListener(ActionInputEvent.ACTION_INPUT,IAHandler);
			}
		max=3;
			for(i=0;i<max;i++){
			ID=IDGenerator.getNextID(IDGeneratorChannels.MOBS);
			mob=new MobB(ID,currentWave,players,nodeMap,tileSize) as Mob;
			mobs.push(mob);
			randomSpawner=mobSpawns.removeAt(MathSup.randomRange(0,mobSpawns.length-1)) as MobSpawn;
			mobSpawnsOccupied.push(randomSpawner);
			mob.x=randomSpawner.x;
			mob.y=randomSpawner.y;
			addChild(mob);
			mob.addEventListener(StateInputEvent.STATE_INPUT,IAHandler);
			mob.addEventListener(ActionInputEvent.ACTION_INPUT,IAHandler);
			}
		max=2;
			for(i=0;i<max;i++){
			ID=IDGenerator.getNextID(IDGeneratorChannels.MOBS);
			mob=new MobC(ID,currentWave,players,nodeMap,tileSize) as Mob;
			mobs.push(mob);
			randomSpawner=mobSpawns.removeAt(MathSup.randomRange(0,mobSpawns.length-1)) as MobSpawn;
			mobSpawnsOccupied.push(randomSpawner);
			mob.x=randomSpawner.x;
			mob.y=randomSpawner.y;
			addChild(mob);
			mob.addEventListener(StateInputEvent.STATE_INPUT,IAHandler);
			mob.addEventListener(ActionInputEvent.ACTION_INPUT,IAHandler);
			}
		max=1;
			for(i=0;i<max;i++){
			ID=IDGenerator.getNextID(IDGeneratorChannels.MOBS);
			mob=new MobD(ID,currentWave,players,nodeMap,tileSize) as Mob;
			mobs.push(mob);
			randomSpawner=mobSpawns.removeAt(MathSup.randomRange(0,mobSpawns.length-1)) as MobSpawn;
			mobSpawnsOccupied.push(randomSpawner);
			mob.x=randomSpawner.x;
			mob.y=randomSpawner.y;
			addChild(mob);
			mob.addEventListener(StateInputEvent.STATE_INPUT,IAHandler);
			mob.addEventListener(ActionInputEvent.ACTION_INPUT,IAHandler);
			}
		}
		private function isColliding(object:DisplayObject):DisplayObject{
		var max:int;
		var i:int;
		var gpt:Point=localToGlobal(new Point(object.x,object.y));
			if(object is Bullet){
				if((object as Bullet).owner is Player){
				max=mobs.length;
					for(i=0;i<max;i++){
						if(!mobs[i].dead && PixelPerfectCollisionDetection.isColliding(mobs[i],object,this,true)){
						return(mobs[i]);						
						}
					}
				}
				else if((object as Bullet).owner is Mob){
				max=players.length;
					for(i=0;i<max;i++){
						if(!players[i].dead && PixelPerfectCollisionDetection.isColliding(players[i],object,this,true)){
						return(players[i]);						
						}
					}	
				}
			max=mapElements.length;
				for(i=0;i<max;i++){
					if(PixelPerfectCollisionDetection.isColliding(mapElements[i],object,this,true)){
					return(mapElements[i]);
					}
				}
			}
			else if(object is Node){
			max=mapElements.length;
				for(i=0;i<max;i++){
					if(mapElements[i].hitTestPoint(gpt.x,gpt.y,true)){
					return(mapElements[i]);
					}
				}
			}
			else{
				/*if(object is Mob){
				max=mobs.length;
				var mob:Mob=object as Mob;
					for(i=0;i<max;i++){
						if(mobs[i]!=object && !mobs[i].dead && PixelPerfectCollisionDetection.isColliding(mobs[i].hitSprite,mob.hitSprite,this,true)){
						return(mobs[i]);						
						}
					}
				}*/
			max=mapElements.length;
				for(i=0;i<max;i++){
					if(mapElements[i].hitTestPoint(gpt.x,gpt.y,true)){
					return(mapElements[i]);
					}
				}
			}
		return(null);
		}
		private function IAHandler(e:Event):void
		{
		var mob:Mob = e.currentTarget as Mob;
			if(e is StateInputEvent){
			var se:StateInputEvent = e as StateInputEvent;
			setActorStateInput(ActorType.MOB,mob.id,se.stateInputs[0]);
			}
			else if(e is ActionInputEvent){
			var ae:ActionInputEvent = e as ActionInputEvent;
			setActorActionInput(ActorType.MOB,mob.id,ae.actionInput);
			}
		}
		private function onPlayerRotationUpdate(player:Player):void{
		player.reLocateLifeBar();
		}
		private function removeMuzzle(e:TweenEvent):void{
		(e.currentTarget.target as MovieClip).parent.removeChild(e.currentTarget.target as DisplayObject);
		}
		private function isAllPlayersDead():Boolean{
		var max:int=players.length;
			for(var i:int=0;i<max;i++){
			if(players[i].dead==false)return(false);
			}
		return(true);
		}
		private function isAllMobsDead():Boolean{
		var max:int=mobs.length;
			for(var i:int=0;i<max;i++){
			if(mobs[i].dead==false)return(false);
			}
		return(true);
		}
	}
	
}
