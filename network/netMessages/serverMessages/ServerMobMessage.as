package network.netMessages.serverMessages {
	
	public class ServerMobMessage extends ServerMessage{
		
		public static const MOB_SHOOT:String="mobShoot";
		public static const MOB_STOPSHOOT:String="mobStopShoot";
		public static const MOB_DIED:String="mobDied";
		
		public var mobID:int;
		
		public function ServerMobMessage(type:String,mobID:int) {
		this.mobID=mobID;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.mobID=mobID;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerMobMessage{
		return(new ServerMobMessage(msg.type,msg.mobID));
		}

	}
	
}
