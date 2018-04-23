package network.netMessages.serverMessages {
	
	public class ServerPlayerCharMessage extends ServerPlayerMessage{
		
		public static const PLAYER_SELECTED_CHARACTER:String="playerSelectedCharacter";
		
		public var character:String;
		
		public function ServerPlayerCharMessage(type:String,playerID:int,character:String) {
		this.character=character;
		super(type,playerID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.character=character;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerCharMessage{
		return(new ServerPlayerCharMessage(msg.type,msg.playerID,msg.character));
		}

	}
	
}
