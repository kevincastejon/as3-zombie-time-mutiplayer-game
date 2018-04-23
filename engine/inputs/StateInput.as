package engine.inputs {
	import flash.events.Event;
	
	public class StateInput {
	
		public var inputID:int;
		public var top:Boolean;
		public var bot:Boolean;
		public var right:Boolean;
		public var left:Boolean;
		public var rotation:Number;
		public var sprinting:Boolean;
		
		public function StateInput(inputID:int,top:Boolean=false,bot:Boolean=false,right:Boolean=false,left:Boolean=false,rotation:Number=NaN,sprinting:Boolean=false) {
		this.inputID=inputID;
		this.top=top;
		this.bot=bot;
		this.right=right;
		this.left=left;
		this.rotation=rotation;
		this.sprinting=sprinting;
		}
		
		public function serialize():Array{
		return([inputID,top,bot,right,left,rotation,sprinting]);
		}
		
		public static function unserialize(obj:Array):StateInput{
		return(new StateInput(obj[0],obj[1],obj[2],obj[3],obj[4],obj[5],obj[6]));
		}

	}
	
}
