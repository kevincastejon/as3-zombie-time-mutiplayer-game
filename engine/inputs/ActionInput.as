package engine.inputs {
	
	public class ActionInput {
	
		public var type:String;
		public var value:int;
		
		public function ActionInput(type:String,value:int) {
		this.type=type;
		this.value=value;
		}
		
		public function serialize():Object{
		return({type:type,value:value});
		}
		
		public static function unserialize(obj:Object):ActionInput{
		return(new ActionInput(obj.type,obj.value));
		}

	}
	
}
