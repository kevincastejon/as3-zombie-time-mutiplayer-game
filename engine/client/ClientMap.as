package engine.client {
	import flash.display.Sprite;
	import engine.actors.Player;
	import engine.MapElement;
	import engine.anims.*;
	import engine.bullets.*;
	import engine.muzzles.*;
	import engine.mobs.*;
	import engine.PlayerSpawn;
	import engine.MobSpawn;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import piooas3Tools.fl.utils.IterableTools;
	import engine.inputs.ActionInput;
	import engine.actors.ActorState;
	import com.greensock.TweenLite;
	import engine.actors.ActorType;
	import com.greensock.easing.Linear;
	import engine.actors.Actor;
	import engine.inputs.ActionType;
	import engine.inputs.StateInput;
	import utils.IDGeneratorChannels;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import piooas3Tools.fl.utils.MathSup;
	import piooas3Tools.fl.utils.IDGenerator;
	import piooas3Tools.fl.sounds.Magneto;
	import engine.PixelPerfectCollisionDetection;
	import com.greensock.TweenMax;
	import com.greensock.events.TweenEvent;
	import flash.geom.Rectangle;
	import utils.AudioBank;
	import utils.Calculator;
	import engine.Map;
	import flash.display.MovieClip;
	
	public class ClientMap extends Map {
	
	private var border:MovieClip;
	private var mapElements:Vector.<MapElement>=new Vector.<MapElement>();
	private var playerSpawns:Vector.<PlayerSpawn>=new Vector.<PlayerSpawn>();
	private var bullets:Vector.<Bullet>=new Vector.<Bullet>();
	private var players:Vector.<Player>=new Vector.<Player>();
	private var mobs:Vector.<Mob>=new Vector.<Mob>();
	private var delayedHero:Player=new Player(-1,"delayedHero",0xFFFFFF);
	private var hero:Player;
	private var heroMoves:Vector.<ActorState>=new Vector.<ActorState>();
		
	public var currentWave:int;
		
		public function ClientMap() {
		var max:int=this.numChildren;
			for(var i:int=0;i<max;i++){
			if(this.getChildAt(i) == s_border){border=s_border;}
			else if(this.getChildAt(i) is MapElement){(this.getChildAt(i) as MapElement).mouseChildren=(this.getChildAt(i) as MapElement).mouseEnabled=false;mapElements.push(this.getChildAt(i));}
			else if(this.getChildAt(i) is PlayerSpawn){this.getChildAt(i).visible=false;playerSpawns.push(this.getChildAt(i));}
			else if(this.getChildAt(i) is MobSpawn)this.getChildAt(i).visible=false;
			}
		Magneto.playAudio("mapMusic","musics",1,0,true);
		}
		
		public function start(players:Vector.<Player>,hero:Player):void{
		this.players=players;
		this.hero=hero;
		var max:int=players.length;
			for(var i:int=0;i<max;i++){
			addChild(players[i]);
			players[i].x=playerSpawns[i].x;
			players[i].y=playerSpawns[i].y;
			
				if(players[i]==hero){
				delayedHero.alpha=0.5;
				delayedHero.setCharacter(players[i].character);
				delayedHero.x=players[i].x;
				delayedHero.y=players[i].y;
				delayedHero.visible=false;
				delayedHero.showLifeBar(false,false);
				delayedHero.rotation=players[i].rotation;
				addChild(delayedHero);
				}
			}
		stage.addEventListener(KeyboardEvent.KEY_DOWN,showDelayedHero);
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
					anim=mob.getImpactAnim();
					impactAudio=mob.getImpactAudioName();
					}
					else if(disp is Player){
					var player:Player=disp as Player;
					anim=new BloodAnim();
					impactAudio=player.getImpactAudioName();
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
						if(impactAudio)Magneto.playAudio(impactAudio,"fx");
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
		
		public function setActorStates(actorStates:Vector.<ActorState>,lastInputID:int):void{
		var max:int = actorStates.length;
			for(var i:int=0;i<max;i++){
			var dist:Number;
			var rot:Number;
				if(actorStates[i].actorType == ActorType.PLAYER){
				var player:Player=IterableTools.getElementByProperties(players,[["id",actorStates[i].id]]) as Player;
					if(player==hero){
					delayedHero.x=actorStates[i].posX;delayedHero.y=actorStates[i].posY;delayedHero.rotation=actorStates[i].rotation;
					
					 var lastState:ActorState=IterableTools.getElementByProperties(heroMoves,[["id",lastInputID]]);
					if(lastState){
						
						var offsetX:Number=delayedHero.x-lastState.posX;
						var offsetY:Number=delayedHero.y-lastState.posY;
						var offsetRot:int=delayedHero.rotation-lastState.rotation;
						var coordTolerance:Number=3;
						var rotTolerance:int=1;
							if(Math.abs(offsetX)>coordTolerance){hero.x+=offsetX;trace("corrected X : ",offsetX);}
							if(Math.abs(offsetY)>coordTolerance){hero.y+=offsetY;trace("corrected Y : ",offsetY);}
							if(Math.abs(offsetRot)>rotTolerance){hero.rotation+=offsetRot;trace("corrected ROTATION");}
						
						var ind:int=heroMoves.indexOf(lastState);
						heroMoves.splice(0,ind+1);
						var max2:int=heroMoves.length;
							for(var j:int=0;j<max2;j++){
							heroMoves[j].posX+=offsetX;
							heroMoves[j].posY+=offsetY;
							heroMoves[j].rotation+=offsetRot;
							}
						}
						else {//trace("no predicted input to correct, lastInputID:",lastInputID);
						}
					}
					else{
					dist=Point.distance(new Point(player.x,player.y),new Point(actorStates[i].posX,actorStates[i].posY));
					rot=actorStates[i].rotation;
						if(rot>player.rotation){
							if(Math.abs(rot-player.rotation)>180)rot-=360;
						}
						else if(rot<player.rotation){
							if(Math.abs(rot-player.rotation)>180)rot+=360;
						}
					if(dist>0)TweenLite.to(player,0.2/*dist/(player.speed*stage.frameRate)*/,{x:actorStates[i].posX,y:actorStates[i].posY,ease:Linear.easeNone});
					if(rot!=player.rotation)TweenLite.to(player,0.1,{rotation:rot,ease:Linear.easeNone, onUpdate:onActorRotationUpdate, onUpdateParams:[player]});
					}
				player.setRawLife(actorStates[i].life);
				}
				else if(actorStates[i].actorType == ActorType.MOB){
				var mob:Mob = IterableTools.getElementByProperties(mobs,[["id",actorStates[i].id]]) as Mob;
					if(mob){
					dist=Point.distance(new Point(mob.x,mob.y),new Point(actorStates[i].posX,actorStates[i].posY));
					rot=actorStates[i].rotation;
						if(rot>mob.rotation){
							if(Math.abs(rot-mob.rotation)>180)rot-=360;
						}
						else if(rot<mob.rotation){
							if(Math.abs(rot-mob.rotation)>180)rot+=360;
						}
					if(dist>0)TweenLite.to(mob,0.2/*dist/(player.speed*stage.frameRate)*/,{x:actorStates[i].posX,y:actorStates[i].posY,ease:Linear.easeNone});
					if(rot!=mob.rotation)TweenLite.to(mob,0.1,{rotation:rot,ease:Linear.easeNone, onUpdate:onActorRotationUpdate, onUpdateParams:[mob]});
					mob.setRawLife(actorStates[i].life);
					}
				}	
			}
		}
		public function setActorActionInput(actorType:int,id:int,actionInput:ActionInput):void{
		var actor:Actor;
			if(actorType==ActorType.PLAYER)actor=IterableTools.getElementByProperties(players,[["id",id]]) as Player;
			else if(actorType==ActorType.MOB)actor=IterableTools.getElementByProperties(mobs,[["id",id]]) as Mob;
			
			if(actor){
				if(actor==hero && (actionInput.type==ActionType.SHOOT || actionInput.type==ActionType.TAUNT || actionInput.type==ActionType.NADE))actor=delayedHero;
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
				else if(actionInput.type==ActionType.MAXLIFE){
				actor.setMaxLife(actionInput.value);
				}
				else if(actionInput.type==ActionType.DEAD){
				actor.dead=true;
				actor.visible=actor.shooting=false;
				}
				else if(actionInput.type==ActionType.REVIVE){
				actor.dead=false;
				actor.visible=true;
				}
				else if(actionInput.type==ActionType.PLAY_SHORT){
				(actor as Mob).short(actionInput.value);
				}
			}
		}
		public function setPredictedStateInput(stateInput:StateInput):void{
		var speed:Number=hero.speed;
			if(stateInput.sprinting){
				if(hero.stamina>0)speed+=hero.sprintValue;
				else speed+=0.25;
				}
		if(stateInput.top){hero.y-=speed;if(isColliding(hero))hero.y+=speed;else if(stateInput.sprinting)hero.removeStamina(hero.sprintCost);}
		else if(stateInput.bot){hero.y+=speed;if(isColliding(hero))hero.y-=speed;else if(stateInput.sprinting)hero.removeStamina(hero.sprintCost);}
		if(stateInput.left){hero.x-=speed;if(isColliding(hero))hero.x+=speed;else if(stateInput.sprinting)hero.removeStamina(hero.sprintCost);}
		else if(stateInput.right){hero.x+=speed;if(isColliding(hero))hero.x-=speed;else if(stateInput.sprinting)hero.removeStamina(hero.sprintCost);}
		if(!isNaN(stateInput.rotation))hero.rotation=stateInput.rotation;
		heroMoves.push(new ActorState(ActorType.PLAYER,stateInput.inputID,hero.x,hero.y,hero.rotation,-1));
		}
		public function setPredictedActionInput(actionInput:ActionInput):void{
			if(actionInput.type==ActionType.SHOOT){
			hero.shooting=Boolean(actionInput.value);
			}
		}
		public function startNextWaveCountDown():void{
		currentWave++;
		var max:int=players.length;
			for(var i:int=0;i<max;i++){
			players[i].setFullLife();
			players[i].dead=false;
			players[i].visible=true;
			}
		max=mobs.length;
			for(i=0;i<max;i++){
			removeChild(mobs[i]);
			}
		mobs=new Vector.<Mob>();
		TweenLite.delayedCall(5,startNextWave);
		var coin:Boolean=Boolean(MathSup.randomRange(0,1));
		if(coin)Magneto.playAudio(AudioBank.ZOMBIE_YELL01,"fx");
		else Magneto.playAudio(AudioBank.ZOMBIE_YELL02,"fx");
		}
		private function startNextWave():void{
		
		var max:int;
		
		
		max=4;
		var mob:Mob;
		var randomSpawner:MobSpawn;
			for(var i:int=0;i<max;i++){
			mob=new MobA(IDGenerator.getNextID(IDGeneratorChannels.MOBS),currentWave) as Mob;
			mobs.push(mob);
			addChild(mob);
			}
		max=3;
			for(i=0;i<max;i++){
			mob=new MobB(IDGenerator.getNextID(IDGeneratorChannels.MOBS),currentWave) as Mob;
			mobs.push(mob);
			addChild(mob);
			}
		max=2;
			for(i=0;i<max;i++){
			mob=new MobC(IDGenerator.getNextID(IDGeneratorChannels.MOBS),currentWave) as Mob;
			mobs.push(mob);
			addChild(mob);
			}
		max=1;
			for(i=0;i<max;i++){
			mob=new MobD(IDGenerator.getNextID(IDGeneratorChannels.MOBS),currentWave) as Mob;
			mobs.push(mob);
			addChild(mob);
			}
		}
		public function removePlayer(player:Player):void{
		//ALREADY REMOVED FROM ARRAY BY MAIN !!!
		removeChild(player);
		}
		public function getMobByID(id:int):Mob{
		return(IterableTools.getElementByProperties(mobs,[["id",id]])as Mob);
		}
		private function onActorRotationUpdate(actor:Actor):void{
		actor.reLocateLifeBar();
		}
		private function removeMuzzle(e:TweenEvent):void{
		(e.currentTarget.target as MovieClip).parent.removeChild(e.currentTarget.target as DisplayObject);
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
			else{
			max=mapElements.length;
				for(i=0;i<max;i++){
					if(mapElements[i].hitTestPoint(gpt.x,gpt.y,true)){
					return(mapElements[i]);
					}
				}
			}
		return(null);
		}
		private function showDelayedHero(e:KeyboardEvent):void{
		if(e.keyCode==Keyboard.G){
		delayedHero.visible=!delayedHero.visible;
		var max:int=bullets.length;
			for(var i:int=0;i<max;i++){
			if(bullets[i].owner==delayedHero)bullets[i].visible=!bullets[i].visible;
			}
		}
		}
	}
	
}
