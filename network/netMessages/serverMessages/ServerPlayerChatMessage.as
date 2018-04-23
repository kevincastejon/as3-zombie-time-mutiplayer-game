package network.netMessages.serverMessages {
	
	public class ServerPlayerChatMessage extends ServerPlayerMessage{
		
		public static const PLAYER_CHAT:String="playerChat";
		
		public var chat:String;
		
		public function ServerPlayerChatMessage(type:String,playerID:int,chat:String) {
		this.chat=chat;
		super(type,playerID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.chat=chat;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerChatMessage{
		return(new ServerPlayerChatMessage(msg.type,msg.playerID,msg.chat));
		}

	}
	
}
