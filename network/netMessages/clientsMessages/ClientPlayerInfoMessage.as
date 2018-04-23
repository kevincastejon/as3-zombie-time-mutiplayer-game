package network.netMessages.clientsMessages {
	
	public class ClientPlayerInfoMessage extends ClientMessage{
		
		public static const USER_INFOS:String="userInfos";
		
		public var nickName:String;
		public var color:uint;
		
		public function ClientPlayerInfoMessage(type:String,nickName:String,color:uint) {
		this.nickName=nickName;
		this.color=color;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.nickName=nickName;
		msg.color=color;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ClientPlayerInfoMessage{
		return(new ClientPlayerInfoMessage(msg.type,msg.nickName,msg.color));
		}


	}
	
}
