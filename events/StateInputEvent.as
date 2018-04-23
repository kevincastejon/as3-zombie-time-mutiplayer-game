package events {
	import flash.events.Event;
	import engine.inputs.StateInput;
	
	public class StateInputEvent extends Event {

		public static const STATE_INPUT:String="stateInput";
	
		public var stateInputs:Vector.<StateInput>;
		
		public function StateInputEvent(type:String,stateInputs:Vector.<StateInput>, bubbles:Boolean=false,cancelable:Boolean=false) {
		this.stateInputs=stateInputs;
		super(type,bubbles,cancelable);
		}

	}
	
}
