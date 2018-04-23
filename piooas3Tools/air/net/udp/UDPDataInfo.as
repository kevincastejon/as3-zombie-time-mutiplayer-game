package piooas3Tools.air.net.udp {
	import flash.utils.Timer;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	
	public class UDPDataInfo extends EventDispatcher {

	private var _channelName:String;
	private var _remoteAddress:String;
	private var _remotePort:int;
	private var _ID:int;
	private var _data:Object;
	private var _retryTimer:Timer;
	private var _cancelTimer:Timer;
	private var _ping:int;
		
	private var _received:Boolean;
	private var _canceled:Boolean;
	private var _numRetry:int;
	
		public function UDPDataInfo(channelName:String,remoteAddress:String,remotePort:int,data:Object,ID:int) {
		this._channelName=channelName;this._ID=ID;this._data=data;this._remoteAddress=remoteAddress;this._remotePort=remotePort;
		}

		internal function send(retryTime:Number,cancelTime:Number){
		_retryTimer=new Timer(retryTime,1);
		_retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, retryTimerHandler,false,0,true);
		_retryTimer.start();
		_ping=getTimer();
			
			if(cancelTime>0){
			_cancelTimer=new Timer(cancelTime,1);
			_cancelTimer.addEventListener(TimerEvent.TIMER_COMPLETE, cancelTimerHandler,false,0,true);
			_cancelTimer.start();
			}
		this.dispatchEvent(new UDPDataEvent(UDPDataEvent.SENT));
		}
		
		private function retryTimerHandler(e:TimerEvent){
		_retryTimer.reset();_retryTimer.start();
		_numRetry++;
		this.dispatchEvent(new UDPDataEvent(UDPDataEvent.RETRIED));
		}
		
		private function cancelTimerHandler(e:TimerEvent){
		_retryTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, retryTimerHandler);
		_cancelTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, cancelTimerHandler);
		_cancelTimer.stop();_retryTimer.stop();
		_cancelTimer=null;_retryTimer=null;
		this.dispatchEvent(new UDPDataEvent(UDPDataEvent.CANCELED));
		}
		
		public function get channelName():String{
		return(this._channelName);
		}
		public function get remoteAddress():String{
		return(this._remoteAddress);
		}
		public function get remotePort():int{
		return(this._remotePort);
		}
		public function get data():Object{
		return(this._data);
		}
		public function get ID():int{
		return(this._ID);
		}
		public function get received():Boolean{
		return(this._received);
		}
		internal function setReceived(bool:Boolean):void{
		_cancelTimer.stop();_retryTimer.stop();
		_ping=getTimer()-_ping;
		_cancelTimer=null;_retryTimer=null;
		this._received=bool;
		this.dispatchEvent(new UDPDataEvent(UDPDataEvent.DELIVERED));
		}
		public function get canceled():Boolean{
		return(this._canceled);
		}
		public function setCanceled(bool:Boolean):void{
		this._canceled=bool;
		}
		public function get numRetry():int{
		return(this._numRetry);
		}
		public function get ping():int{
		return(this._ping);
		}

	}
	
}