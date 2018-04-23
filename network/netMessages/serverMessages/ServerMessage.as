package network.netMessages.serverMessages {
	import network.netMessages.NetMessage;
	
	public class ServerMessage extends NetMessage {

		public static const START:String="start";
		public static const NEXT_WAVE:String="nextWave";
		public static const GAME_OVER:String="gameOver";
		
		public function ServerMessage(type:String) {
		super(type);
		}
		
		public override function serialize():Object{
		return(super.serialize());
		}
		
		public static function unserialize(msg:Object):ServerMessage{
		return(new ServerMessage(msg.type));
		}


	}
	
}
