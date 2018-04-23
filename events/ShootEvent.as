package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	import engine.Bullet;
	
	public class ShootEvent extends IDRelatedEvent {

		public static const SHOOT:String="shoot";

		public var bullet:Bullet;
		
		public function ShootEvent(type:String,id:int,bullet:Bullet,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.bullet=bullet;
		super(type,id,bubbles,cancelable);
		}

	}
	
}
