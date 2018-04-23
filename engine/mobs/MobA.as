package engine.mobs {
	import engine.actors.Player;
	
	
	public class MobA extends Mob {
		
		
		public function MobA(id:int,level:int,players:Vector.<Player>=null,nodeMap:Array=null,tileSize:Number=NaN) {
		super(id,level,players,nodeMap,tileSize);
		this.speed=3;
		this._life=this.maxLife=10;
		this.damage=5;
		}
	}
	
}
