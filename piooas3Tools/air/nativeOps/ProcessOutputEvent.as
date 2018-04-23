package piooas3Tools.air.nativeOps {	
	import flash.events.Event;
	import flash.utils.IDataInput;

	public class ProcessOutputEvent extends Event{
		public static const PROCESS_OUTPUT:String="processOutput";
		public var data:IDataInput;
		public function ProcessOutputEvent(type:String,data:IDataInput,bubbles:Boolean=false,cancelable:Boolean=false){
			super(type,bubbles,cancelable);
			this.data=data;
		}
	}
}