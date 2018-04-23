package network.netMessages.serverMessages {
	
	
	public class ServerPlayerPongMessage extends ServerPlayerMessage{
		
		public static const PLAYER_PONG:String="playerPong";
		
		public var time:Number;
		
		public function ServerPlayerPongMessage(type:String,playerID:int,time:Number) {
		this.time=time;
		super(type,playerID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.time=time;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerPongMessage{
		return(new ServerPlayerPongMessage(msg.type,msg.playerID,msg.time));
		}

	}
	
}
