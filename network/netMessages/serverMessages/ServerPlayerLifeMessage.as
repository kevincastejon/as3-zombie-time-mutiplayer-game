package network.netMessages.serverMessages {
	
	
	public class ServerPlayerLifeMessage extends ServerPlayerMessage{
		
		public static const PLAYER_MAX_LIFE_CHANGED:String="playerMaxLifeChanged";
		
		public var life:int;
		
		public function ServerPlayerLifeMessage(type:String,playerID:int,life:int) {
		this.life=life;
		super(type,playerID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.life=life;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerLifeMessage{
		return(new ServerPlayerLifeMessage(msg.type,msg.playerID,msg.life));
		}


	}
	
}
