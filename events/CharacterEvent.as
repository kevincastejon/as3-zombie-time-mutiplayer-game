package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	
	public class CharacterEvent extends Event {

		public static const SELECTED_CHARACTER:String="selectedCharacter";

		public var character:String;
		
		public function CharacterEvent(type:String,character:String,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.character=character;
		super(type,bubbles,cancelable);
		}

	}
	
}
