package piooas3Tools.air.net.udp {
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public class UDPPeer {

		private var _address:String;
		private var _port:int;
		private var _lastPing:int;
		private var _averagePing:int;		
		
		private var numPings:int;
		private var pingTimer:Timer=new Timer(1000);
		private var listeners:Vector.<Function>=new Vector.<Function>();
		
		public function UDPPeer(address:String,port:int) {
		this._address=address;this._port=port;
		pingTimer.addEventListener(TimerEvent.TIMER, timerHandler,false,0,true);
		}
		public function get address():String{
		return(_address);
		}
		public function get port():int{
		return(_port);
		}
		public function get lastPing():int{
		return(_lastPing);
		}
		public function get averagePing():int{
		return(_averagePing);
		}
		internal function startPingTimer(){
		pingTimer.start();
		}
		internal function stopPingTimer(){
		pingTimer.reset();
		}
		
		internal function listenToPing(functionCallBack:Function){
		listeners.push(functionCallBack);
		}
		internal function stopListenToPing(functionCallBack:Function){
		listeners.splice(listeners.indexOf(functionCallBack),1);
		}
		internal function setPing(ping:int){
		_lastPing=ping;
		_averagePing=((_averagePing*numPings)+ping)/(numPings+1);
		numPings++;
		}
		internal function close(){
		pingTimer.stop();
		pingTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
		listeners=null;
		}
		private function timerHandler(e:Event){
		var max:int=listeners.length;
			for(var i:int=0;i<max;i++){
			listeners[i](this);
			}
		}

	}
	
}
