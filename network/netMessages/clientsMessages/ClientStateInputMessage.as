package network.netMessages.clientsMessages {

	import engine.inputs.StateInput;
	
	public class ClientStateInputMessage extends ClientMessage{
		
		public static const INPUTS:String="inputs";
		
		public var stateInputs:Vector.<StateInput>;
		
		public function ClientStateInputMessage(type:String,stateInputs:Vector.<StateInput>) {
		this.stateInputs=stateInputs;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		var max:int=stateInputs.length;
		msg.stateInputs=[];
			for(var i:int=0;i<max;i++){
			msg.stateInputs.push(stateInputs[i].serialize());
			}		
		return(msg);
		}
		
		public static function unserialize(msg:Object):ClientStateInputMessage{
		var max:int=msg.stateInputs.length;
		var inputs:Vector.<StateInput>=new Vector.<StateInput>();
			for(var i:int=0;i<max;i++){
			inputs.push(StateInput.unserialize(msg.stateInputs[i]));
			}		
		return(new ClientStateInputMessage(msg.type,inputs));
		}


	}
	
}
