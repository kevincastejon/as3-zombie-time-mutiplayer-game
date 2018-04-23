package events {
	import flash.events.Event;
	import engine.inputs.ActionInput;
	
	public class ActionInputEvent extends IDRelatedEvent {

		public static const ACTION_INPUT:String="actionInput";
	
		public var actorType:int;
		public var actionInput:ActionInput;
		
		public function ActionInputEvent(type:String,actionInput:ActionInput, actorType:int=-1, id:int=-1, bubbles:Boolean=false,cancelable:Boolean=false) {
		this.actionInput=actionInput;
		this.actorType=actorType;
		super(type,id,bubbles,cancelable);
		}
		
		public override function clone():Event{
		return(new ActionInputEvent(type,actionInput,actorType,id,bubbles,cancelable));
		}

	}
	
}
