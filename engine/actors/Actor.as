package engine.actors {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import piooas3Tools.fl.display.GeometricForm;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import events.ShootEvent;
	import events.SimpleEvent;
	import gameGUI.LifeBar;
	import engine.bullets.*
	import engine.muzzles.*;
	import engine.anims.*;
	
	public class Actor extends MovieClip {

	public var id:int;
	public var damage:int;	//TODO: replace with weapon system
	protected var _life:int;
	public var maxLife:int;
	public var speed:Number;
	public var fireRange:int;
	public var fireRate:int=15;
	public var bulletSpeed:int=35;
	public var fireFrameTem:int;
	public var dead:Boolean;
	public var _shooting:Boolean;
	public var dispersionPattern:Array=[0,-5,1,-2,3,-1,2,-2,-1,1,-2,2,-3,5,-1,2];
	public var numBulletsInARaw:int;
	public var constantMuzzle:Boolean;
	public var constantShot:Boolean;
	public var muzzle:MovieClip;
	public var shotAudioID:int=-1;
		
	public var stamina:Number=100;
	public var maxStamina:Number=100;
	public var sprintValue:Number=1;
	public var sprintCost:Number=0.3;
	
	public var sprinting:Boolean;
	public var inEffort:Boolean;
	private var effortTween:TweenMax;
		
	public var hitSprite:Sprite;
	public var charClip:MovieClip;
	public var flashPoint:MovieClip;
		
	public var lifeBar:LifeBar=new LifeBar();
	
	private var alwaysShow:Boolean=true;
	private var showWhenHit:Boolean=true;
		
		public function Actor(id:int) {
		this.id=id;
		hitSprite=GeometricForm.getCircle(10,false,0,0,1,true,0xFF0000);
		lifeBar.scaleX=0.8;
		lifeBar.scaleY=0.4;
		addChild(hitSprite);
		addChild(lifeBar);
		reLocateLifeBar();
		hitSprite.visible=false;
		
		this.addEventListener(Event.ADDED_TO_STAGE, added);
		this.addEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
		private function added(e:Event):void{
		this.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		private function removed(e:Event):void{
		this.removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		public function get life():int{
		return(_life);
		}
		public function removeLife(amount:int){
		_life-=amount;
			if(_life<=0){
			_life=0;
			dead=true;
			}
		lifeBar.setLifePercent(_life/maxLife);
		if(showWhenHit){
		lifeBar.visible=true;
			if(!alwaysShow)TweenMax.to(lifeBar,2,{visible:false});
		}
		}
		public function addLife(value:int):void{
		_life+=value;if(_life>0)dead=false;
		if(_life>maxLife)_life=maxLife;
		lifeBar.setLifePercent(_life/maxLife);
		if(showWhenHit && _life>value){
		lifeBar.visible=true;
			if(!alwaysShow)TweenMax.to(lifeBar,2,{visible:false});
		}
		}
		public function setRawLife(value:int):void{
		if(showWhenHit && _life>value){
		lifeBar.visible=true;
			if(!alwaysShow)TweenMax.to(lifeBar,2,{visible:false});
		}
		_life=value;
		lifeBar.setLifePercent(_life/maxLife);
		
		}	
		public function setMaxLife(value:int):void{
		maxLife=value;
			if(_life>maxLife)_life=maxLife;
		lifeBar.setLifePercent(_life/maxLife);
		}
		public function setLife(value:int):void{
		if(showWhenHit && _life>value){
		lifeBar.visible=true;
			if(!alwaysShow)TweenMax.to(lifeBar,2,{visible:false});
		}
		_life=value;
			if(_life<=0){
			_life=0;
			dead=true;
			}
			if(_life>0)dead=false;
		if(_life>maxLife)_life=maxLife;
		lifeBar.setLifePercent(_life/maxLife);
		
		}
		public function setFullLife():void{
		_life=maxLife;dead=false;
		lifeBar.setLifePercent(_life/maxLife);
		}
		public function setCharacter(charName:String):void{
		//Overrided in subclasses DON'T DELETE THIS!!!
		}
		public function hitSpriteTestObject(object:DisplayObject):Boolean{
		return(hitSprite.hitTestObject(object));
		}
		public function hitSpriteTestPoint(point:Point,shapeFlag:Boolean=false):Boolean{
		return(hitSprite.hitTestPoint(point.x,point.y,shapeFlag));
		}
		public function getBullet():Bullet{
		var b:Bullet=new SimpleBullet(this);
		numBulletsInARaw++;if(numBulletsInARaw>dispersionPattern.length-1)numBulletsInARaw=0;
		return(b);
		}
		public function getMuzzle():MovieClip{
		return(new DeagleFlash());
		}
		public function getShotAudioName():String{
		return("rifle01");
		}
		public function getImpactAnim():OneShotAnim{
		return(new BloodAnim());
		}
		public function getImpactAudioName():String{
		return("impactBlood01");
		}
		public function removeStamina(amount:Number){
		
		inEffort=true;
		stamina-=amount;
			if(stamina<=0){
			stamina=0;
			}
		if(effortTween)effortTween.kill();
		effortTween=TweenMax.delayedCall(1,effortDone);
		}
		
		public override function toString():String{
		return("[Player "+id+"]");
		}
		private function effortDone(){
		inEffort=false;effortTween=null;
		}	
		public function addStamina(value:Number):void{
		stamina+=value;if(stamina>maxStamina)stamina=maxStamina;
		}
		public function showLifeBar(alwaysShow:Boolean=true,showWhenHit:Boolean=true):void{
		this.alwaysShow=lifeBar.visible=alwaysShow;
		this.showWhenHit=showWhenHit;
		}
		public function get shooting():Boolean{return(_shooting);}
		public function set shooting(value:Boolean):void{
		_shooting=value;
		if(value==false)numBulletsInARaw=0;
		}
		private function recoverStamina():void{
		addStamina(0.25);
		}
		public function reLocateLifeBar():void{
		lifeBar.rotation=-this.rotation;
		var lpt:Point=this.localToGlobal(new Point(0,0));
		lpt.x-=80;
		lpt.y-=80;
		var gpt:Point=this.globalToLocal(lpt);
		lifeBar.x=gpt.x;
		lifeBar.y=gpt.y;
		}
		private function onFrame(e:Event):void{
		if(!inEffort)recoverStamina();
		
		}
	}
	
}
