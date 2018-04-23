package network.netMessages.serverMessages {
	import engine.PlayerInfo;
	
	public class ServerPlayerListInfoMessage extends ServerMessage{
		
		public static const PLAYERS_LIST_INFOS:String="playersListInfos";
		
		public var playersListInfos:Vector.<PlayerInfo>;
		
		public function ServerPlayerListInfoMessage(type:String,playersListInfos:Vector.<PlayerInfo>) {
		this.playersListInfos=playersListInfos;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.playersListInfos=[];
		var max:int=playersListInfos.length;
			for(var i:int=0;i<max;i++){
			msg.playersListInfos.push(playersListInfos[i].serialize());
			}
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerListInfoMessage{
		var infos:Vector.<PlayerInfo>=new Vector.<PlayerInfo>();
		var max:int=msg.playersListInfos.length;
			for(var i:int=0;i<max;i++){
			infos.push(PlayerInfo.unserialize(msg.playersListInfos[i]));
			}
		return(new ServerPlayerListInfoMessage(msg.type,infos));
		}

	}
	
}
