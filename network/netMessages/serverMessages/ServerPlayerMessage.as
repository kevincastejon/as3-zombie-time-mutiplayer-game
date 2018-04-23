package network.netMessages.serverMessages {
	
	public class ServerPlayerMessage extends ServerMessage{
		
		public static const ID_ASSIGNING:String="IDAssigning";
		public static const PLAYER_READY:String="playerReady";
		public static const PLAYER_UNREADY:String="playerUnready";
		public static const PLAYER_LEAVED:String="playerLeaved";
		public static const PLAYER_DIED:String="playerDied";
		
		public var playerID:int;
		
		public function ServerPlayerMessage(type:String,playerID:int) {
		this.playerID=playerID;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.playerID=playerID;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerMessage{
		return(new ServerPlayerMessage(msg.type,msg.playerID));
		}

	}
	
}
