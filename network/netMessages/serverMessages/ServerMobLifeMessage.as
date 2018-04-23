package network.netMessages.serverMessages {
	
	
	public class ServerMobLifeMessage extends ServerMobMessage{
		
		public static const MOB_MAX_LIFE_CHANGED:String="mobMaxLifeChanged";
		
		public var life:int;
		
		public function ServerMobLifeMessage(type:String,mobID:int,life:int) {
		this.life=life;
		super(type,mobID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.life=life;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerMobLifeMessage{
		return(new ServerMobLifeMessage(msg.type,msg.mobID,msg.life));
		}


	}
	
}
