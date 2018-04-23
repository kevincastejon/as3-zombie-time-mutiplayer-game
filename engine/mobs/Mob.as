package engine.mobs {
	import flash.geom.Point;
	import flash.events.Event;
	import piooas3Tools.fl.utils.MathSup;
	import engine.actors.Actor;
	import engine.actors.Player;
	import engine.inputs.StateInput;
	import events.StateInputEvent;
	import events.ActionInputEvent;
	import engine.inputs.ActionInput;
	import engine.inputs.ActionType;
	import engine.bullets.ZombieHit;
	import engine.bullets.Bullet;
	import com.greensock.TweenLite;
	import piooas3Tools.fl.sounds.Magneto;
	import utils.AudioBank;
	import utils.Calculator;
	import engine.server.ServerMap;
	import piooas3Tools.fl.pathfinding.Node;
	import piooas3Tools.fl.pathfinding.AStar;
	import engine.actors.ActorType;
	
	public class Mob extends Actor {

		public var players:Vector.<Player>=new Vector.<Player>();
		public var nodeMap:Array;
		public var tileSize:Number;
		public var level:int;
		
		private var attacking:Boolean;
		private var wandering:Boolean;
		private var grunts:Array=[AudioBank.ZOMBIE_GRUNT01,AudioBank.ZOMBIE_GRUNT04,AudioBank.ZOMBIE_GRUNT06];
		private var shorts:Array=[AudioBank.ZOMBIE_SHORT01,AudioBank.ZOMBIE_SHORT02,AudioBank.ZOMBIE_SHORT03];
		
		private var currentTarget:Player;
		private var currentGoal:Node;
		private var currentPath:Array;
		
		private var detectionRadius:Number=300;
		private var shootRadius:Number=50;
		
		public function Mob(id:int,level:int=0,players:Vector.<Player>=null,nodeMap:Array=null,tileSize:Number=NaN) {
		super(id);
		this.level=level;
		this.players=players;
		this.nodeMap=nodeMap;
		this.tileSize=tileSize;
		maxLife=_life=_life+(_life*(level/10));
		speed=speed+(speed*(level/10));
		damage=damage+(damage*(level/10));
		fireRange=55;
		fireRate=60;
		bulletSpeed=10;
		lifeBar.setColors(0xFF00FF,0x0000FF);
		showLifeBar(false,true);
		TweenLite.delayedCall(MathSup.randomRange(2,5),grunt);
		}
		public function addPlayer(player:Player):void{
		players.push(player);
		}
		private function startWandering():void{
		var startNode:Node=AStar.getClosestNodeFromPoint(new Point(x,y),nodeMap,tileSize,tileSize/2);
		var nodeAround:Array=AStar.getNeighbours(startNode,nodeMap,true,5);
		var endNode:Node=nodeAround[MathSup.randomRange(0,nodeAround.length-1)];
		
		currentPath=AStar.findPath(nodeMap,startNode,endNode);
		setNextWanderGoal();
		}
		private function setNextWanderGoal():void{
			if(wandering==false || currentPath.length==0)
			{
			currentGoal=null;
			currentPath=null;
			wandering=false;
			}
			else{
			currentGoal=currentPath.shift();
				//else{currentGoal=null;currentPath=null;trace("attack now!");startAttacking(currentTarget);}
			}
		}
		private function startAttacking(player:Player):void{
		var startNode:Node=AStar.getClosestNodeFromPoint(new Point(x,y),nodeMap,tileSize,tileSize/2);
		var endNode:Node=AStar.getClosestNodeFromPoint(new Point(player.x,player.y),nodeMap,tileSize,tileSize/2);
		var nodeAround:Array;
			while(endNode.walkable==false){
			nodeAround=AStar.getNeighbours(endNode,nodeMap,true);
			endNode=nodeAround[MathSup.randomRange(0,nodeAround.length-1)];
			}
			if(startNode!=endNode){
			currentPath=AStar.findPath(nodeMap,startNode,endNode);
			currentTarget=player;
			setNextAttackGoal();
			}
		}
		private function setNextAttackGoal():void{
			//if target has moved or no target anymore cancel the path
			if(currentTarget==null || currentPath.length==0  || AStar.getClosestNodeFromPoint(new Point(currentTarget.x,currentTarget.y),nodeMap,tileSize,tileSize/2)!=currentPath[currentPath.length-1])
			{
			currentTarget=null;
			currentGoal=null;
			currentPath=null;
			attacking=false;
			}
			else{
			currentGoal=currentPath.shift();
				//else{currentGoal=null;currentPath=null;trace("attack now!");startAttacking(currentTarget);}
			}
			
		}
		private function walkToCurrentGoal():void{//trace(currentGoal);
		//if(AStar.getClosestNodeFromPoint(new Point(currentTarget.x,currentTarget.y),nodeMap,tileSize,tileSize/2)!=currentPath[currentPath.length-1])startAttacking(currentTarget);
			if(currentGoal){
			var stateInput:StateInput=new StateInput(-1);
				if(wandering){
				rotation=MathSup.getAngle(new Point(x,y),new Point(currentGoal.x,currentGoal.y));
				reLocateLifeBar();
				}
				
				if(currentGoal.x>x){stateInput.right=true;stateInput.left=false;}
				else if(currentGoal.x<x){stateInput.right=false;stateInput.left=true;}
				else if(currentGoal.x==x){stateInput.right=false;stateInput.left=false;}
				
				if(currentGoal.y>y){stateInput.bot=true;stateInput.top=false;}
				else if(currentGoal.y<y){stateInput.bot=false;stateInput.top=true;}
				else if(currentGoal.y==y){stateInput.bot=false;stateInput.top=false;}
				
				if(Point.distance(new Point(currentGoal.x,currentGoal.y),new Point(x,y))<speed){
				x=currentGoal.x;
				y=currentGoal.y;
					if(attacking)
					setNextAttackGoal();
					else if(wandering)
					setNextWanderGoal();
				}
			this.dispatchEvent(new StateInputEvent(StateInputEvent.STATE_INPUT,Vector.<StateInput>([stateInput])));
			}
		}
		public function onFrame(){
		var player:Player=getClosestPlayer(detectionRadius);
			if(player){
				if(attacking==false){
				var random:int=MathSup.randomRange(0,1);
					if(random==1){
					random=MathSup.randomRange(0,shorts.length-1);
					Magneto.playAudio(shorts[random],"fx",Calculator.getVolumeForHero(this),Calculator.getPanForHero(this));
					}
				attacking=true;wandering=false;
				startAttacking(player);
				}
				else{
				if(player!=currentTarget)startAttacking(player);
				}
			rotation=MathSup.getAngle(new Point(x,y),new Point(player.x,player.y));
			reLocateLifeBar();
			if(Point.distance(new Point(player.x,player.y),new Point(x,y))<shootRadius && !shooting)this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.SHOOT,1)));
			else if(Point.distance(new Point(player.x,player.y),new Point(x,y))>=shootRadius && shooting)this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.SHOOT,0)));
			}
			else{
			
				if(wandering==false){
				currentTarget=null;currentGoal=null;currentPath=null;
				wandering=true;attacking=false;
				startWandering();
				}
				else{
				
				}
			}
		walkToCurrentGoal();
		/*var player:Player=getClosestPlayer(200);
			if(player){
				if(attacking==false){
				Magneto.playAudio(shorts[MathSup.randomRange(0,2)],"fx",Calculator.getVolumeForHero(this),Calculator.getPanForHero(this));
				}
			attacking=true;
			var stateInput:StateInput=new StateInput(-1);
			if(player.x>x){stateInput.right=true;stateInput.left=false;}
			else if(player.x<x){stateInput.right=false;stateInput.left=true;}
			else if(player.x==x){stateInput.right=false;stateInput.left=false;}
			
			if(player.y>y){stateInput.bot=true;stateInput.top=false;}
			else if(player.y<y){stateInput.bot=false;stateInput.top=true;}
			else if(player.y==y){stateInput.bot=false;stateInput.top=false;}
			rotation=MathSup.getAngle(new Point(x,y),new Point(player.x,player.y));
			reLocateLifeBar();
			this.dispatchEvent(new StateInputEvent(StateInputEvent.STATE_INPUT,Vector.<StateInput>([stateInput])));
			if(Point.distance(new Point(player.x,player.y),new Point(x,y))<35 && !shooting)this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.SHOOT,1)));
			else if(Point.distance(new Point(player.x,player.y),new Point(x,y))>=35 && shooting)this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.SHOOT,0)));
			}
			else{
			attacking=false;
			this.dispatchEvent(new StateInputEvent(StateInputEvent.STATE_INPUT,Vector.<StateInput>([new StateInput(-1,Boolean(MathSup.randomRange(0,1)),Boolean(MathSup.randomRange(0,1)),Boolean(MathSup.randomRange(0,1)),Boolean(MathSup.randomRange(0,1)),MathSup.randomRange(-180,180))])));
			if(shooting)this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.SHOOT,0)));
			}
				*/
		}
		public override function getBullet():Bullet{
		var b:ZombieHit=new ZombieHit(this);
		numBulletsInARaw++;if(numBulletsInARaw>dispersionPattern.length-1)numBulletsInARaw=0;
		return(b);
		}
		private function getClosestPlayer(range:Number=NaN):Player{
		var max:int=players.length;
		var distance:Number=Number.MAX_VALUE;
		var closestPlayer:Player;
			for(var i:int=0;i<max;i++){
				if(!players[i].dead){
				var newDistance:Number=Point.distance(new Point(players[i].x,players[i].y),new Point(x,y));
				if(newDistance<distance && (isNaN(range)||(!isNaN(range)&&newDistance<range))){distance=newDistance;closestPlayer=players[i];}
				}
			}
		return(closestPlayer);
		}
		private function grunt():void{
			if(!dead){
			var random:int=MathSup.randomRange(0,grunts.length-1);
			Magneto.playAudio(grunts[random],"fx",Calculator.getVolumeForHero(this),Calculator.getPanForHero(this));
			this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.PLAY_GRUNT,random),ActorType.MOB,id));
			TweenLite.delayedCall(MathSup.randomRange(2,5),grunt);
			}
		}
		public function short(index:int=-1):void{
			if(!dead){
			var random:int=index;
			if(index==-1)random=MathSup.randomRange(0,shorts.length-1);
			Magneto.playAudio(shorts[random],"fx",Calculator.getVolumeForHero(this),Calculator.getPanForHero(this));
			}
		}
		public override function toString():String{
		return("[Mob id="+id+"]");
		}
	}
	
}
