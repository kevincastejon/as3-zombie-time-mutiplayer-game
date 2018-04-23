package network.netMessages.serverMessages {
	
	
	public class ServerPlayerInfoMessage extends ServerPlayerMessage{
		
		public static const NEW_PLAYER_INFOS:String="newPlayerInfos";
		
		public var nickName:String;
		public var color:uint;
		
		public function ServerPlayerInfoMessage(type:String,playerID:int,nickName:String,color:uint) {
		this.nickName=nickName;
		this.color=color;
		super(type,playerID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.nickName=nickName;
		msg.color=color;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerInfoMessage{
		return(new ServerPlayerInfoMessage(msg.type,msg.playerID,msg.nickName,msg.color));
		}

	}
	
}
