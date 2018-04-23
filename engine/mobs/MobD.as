package engine.mobs {
	import engine.actors.Player;
	

	public class MobD extends Mob {
		
		
		public function MobD(id:int,level:int,players:Vector.<Player>=null,nodeMap:Array=null,tileSize:Number=NaN) {
		super(id,level,players,nodeMap,tileSize);
		this.speed=2;
		this._life=this.maxLife=15;
		this.damage=10;
		}
	}
	
}
