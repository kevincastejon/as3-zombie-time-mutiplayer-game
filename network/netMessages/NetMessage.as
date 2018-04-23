package network.netMessages {
	import network.netMessages.clientsMessages.ClientMessage;
	import network.netMessages.clientsMessages.ClientCharMessage;
	import network.netMessages.clientsMessages.ClientChatMessage;
	import network.netMessages.clientsMessages.ClientPlayerInfoMessage;
	import network.netMessages.serverMessages.ServerMessage;
	import network.netMessages.serverMessages.ServerGameStatesMessage;
	import network.netMessages.serverMessages.ServerPlayerMessage;
	import network.netMessages.serverMessages.ServerPlayerCharMessage;
	import network.netMessages.serverMessages.ServerPlayerChatMessage;
	import network.netMessages.serverMessages.ServerPlayerInfoMessage;
	import network.netMessages.serverMessages.ServerPlayerLifeMessage;
	import network.netMessages.serverMessages.ServerPlayerListInfoMessage;
	import network.netMessages.serverMessages.ServerMobMessage;
	import network.netMessages.serverMessages.ServerPlayerPongMessage;
	import network.netMessages.clientsMessages.ClientStateInputMessage;
	import network.netMessages.clientsMessages.ClientActionInputMessage;
	import network.netMessages.serverMessages.ServerMobLifeMessage;
	import network.netMessages.serverMessages.ServerPlayerActionInputMessage;
	import network.netMessages.serverMessages.ServerMobActionInputMessage;

	
	public class NetMessage {
		
		public var type:String;
		
		public function NetMessage(type:String) {
		this.type=type;
		}
		
		public function serialize():Object{
		var msg:Object=new Object();
		msg.type=type;
		return(msg);
		}
		
		public static function unserialize(msg:Object):NetMessage{
		var netMsg:NetMessage;
			if(msg.type==ClientCharMessage.SELECTED_CHARACTER)return(ClientCharMessage.unserialize(msg));
			else if(msg.type==ClientChatMessage.CHAT)return(ClientChatMessage.unserialize(msg));
			else if(msg.type==ClientStateInputMessage.INPUTS)return(ClientStateInputMessage.unserialize(msg));
			else if(msg.type==ClientActionInputMessage.ACTION)return(ClientActionInputMessage.unserialize(msg));
			else if(msg.type==ClientPlayerInfoMessage.USER_INFOS)return(ClientPlayerInfoMessage.unserialize(msg));
			else if(msg.type==ClientMessage.READY || msg.type==ClientMessage.RETRY || msg.type==ClientMessage.UNREADY)return(ClientMessage.unserialize(msg));
			else if(msg.type==ServerMessage.GAME_OVER || msg.type==ServerMessage.NEXT_WAVE || msg.type==ServerMessage.START)return(ServerMessage.unserialize(msg));
			else if(msg.type==ServerGameStatesMessage.ACTOR_STATES)return(ServerGameStatesMessage.unserialize(msg));
			else if(msg.type==ServerMobMessage.MOB_DIED || msg.type==ServerMobMessage.MOB_SHOOT || msg.type==ServerMobMessage.MOB_STOPSHOOT)return(ServerMobMessage.unserialize(msg));
			else if(msg.type==ServerMobLifeMessage.MOB_MAX_LIFE_CHANGED )return(ServerMobLifeMessage.unserialize(msg));
			else if(msg.type==ServerPlayerActionInputMessage.PLAYER_ACTION)return(ServerPlayerActionInputMessage.unserialize(msg));
			else if(msg.type==ServerMobActionInputMessage.MOB_ACTION)return(ServerMobActionInputMessage.unserialize(msg));
			else if(msg.type==ServerPlayerCharMessage.PLAYER_SELECTED_CHARACTER)return(ServerPlayerCharMessage.unserialize(msg));
			else if(msg.type==ServerPlayerChatMessage.PLAYER_CHAT)return(ServerPlayerChatMessage.unserialize(msg));
			else if(msg.type==ServerPlayerInfoMessage.NEW_PLAYER_INFOS)return(ServerPlayerInfoMessage.unserialize(msg));
			else if(msg.type==ServerPlayerLifeMessage.PLAYER_MAX_LIFE_CHANGED)return(ServerPlayerLifeMessage.unserialize(msg));
			else if(msg.type==ServerPlayerListInfoMessage.PLAYERS_LIST_INFOS)return(ServerPlayerListInfoMessage.unserialize(msg));
			else if(msg.type==ServerPlayerMessage.ID_ASSIGNING || msg.type==ServerPlayerMessage.PLAYER_DIED || msg.type==ServerPlayerMessage.PLAYER_LEAVED || msg.type==ServerPlayerMessage.PLAYER_READY || msg.type==ServerPlayerMessage.PLAYER_UNREADY)return(ServerPlayerMessage.unserialize(msg));
			else if(msg.type==ServerPlayerPongMessage.PLAYER_PONG)return(ServerPlayerPongMessage.unserialize(msg));
		return(netMsg);
		}

	}
	
}
