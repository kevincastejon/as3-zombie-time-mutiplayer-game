package engine.actors {
	import engine.inputs.StateInput;
	import engine.bullets.SimpleBullet;
	import engine.bullets.Bullet;
	import engine.bullets.Flame;
	import flash.display.MovieClip;
	import engine.muzzles.*
	
	public class Player extends Actor {
		
	public var nickName:String;
	public var color:uint;
	public var isReady:Boolean;
	public var isHost:Boolean;
	public var character:String;
	public var lastStateInputID:int=-1;
	public var stateInputsBuffer:Vector.<StateInput>= new Vector.<StateInput>();
		
		public function Player(id:int,nickName:String,color:uint) {
		super(id);
		this.nickName=nickName;
		this.color=color;
		
		}
		public override function setCharacter(charName:String):void{
			if(charClip){
			removeChild(charClip)
			charClip=null;character=null;
			}
			
			if(charName){
			charClip=NativeCharLib.getChar(charName);
			addChild(charClip);
			character=charName;
			speed=charClip.speed;
			_life=maxLife=charClip.life;
			sprintValue=charClip.sprintValue;
			sprintCost=charClip.sprintCost;
			fireRange=charClip.fireRange;
			fireRate=charClip.fireRate;
			bulletSpeed=charClip.bulletSpeed;
			maxStamina=stamina=charClip.stamina;
			damage=charClip.damage;
			constantMuzzle=charClip.constantMuzzle;
			constantShot=charClip.constantShot;
			flashPoint=charClip.flashPoint;
			}
		}
		public override function getBullet():Bullet{
		var b:Bullet;
		if(character=="charA")b=new Flame(this);
		else if(character=="charD"){b=new SimpleBullet(this);if(flashPoint.y<0)flashPoint.y+=32;else flashPoint.y-=32;}		//charD 2 guns trick
		else b=new SimpleBullet(this);
		numBulletsInARaw++;if(numBulletsInARaw>dispersionPattern.length-1)numBulletsInARaw=0;
		return(b);
		}
		public override function getMuzzle():MovieClip{
		if(character=="charA")return(new FlameMuzzle());
		else return(new DeagleFlash());
		}
		public override function getShotAudioName():String{
		if(character=="charA")return("flame01");
		else if(character=="charB")return("rifle01");
		else if(character=="charC")return("deagle01");
		else return("glock01");
		}
		
	}
	
}
