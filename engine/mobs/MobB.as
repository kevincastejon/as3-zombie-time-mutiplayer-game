package engine.mobs {
	import engine.actors.Player;
	
	
	public class MobB extends Mob {
		
		
		public function MobB(id:int,level:int,players:Vector.<Player>=null,nodeMap:Array=null,tileSize:Number=NaN) {
		super(id,level,players,nodeMap,tileSize);
		this.speed=4;
		this._life=this.maxLife=7;
		this.damage=4;
		}
	}
	
}
