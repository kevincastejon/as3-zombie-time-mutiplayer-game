package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	
	public class SimpleEvent extends Event {

		public static const CONNECTION_FORM_COMPLETED:String="connectionFormCompleted";
		public static const CONNECTED_TO_SERVER:String="connectedToServer";
		public static const CONNECTION_FAILED:String="connectionFailed";
		public static const SERVER_TIMED_OUT:String="serverTimedOut";
		public static const START:String="start";
		public static const GAME_OVER:String="gameOver";
		public static const READY:String="ready";
		public static const UNREADY:String="unready";
		public static const NEW_WAVE:String="newWave";
		public static const ACTOR_DEAD:String="actorDead";
		
		public function SimpleEvent(type:String,bubbles:Boolean=false,cancelable:Boolean=false) {
		super(type,bubbles,cancelable);
		}

	}
	
}
