package piooas3Tools.air.net.udp {
	import flash.events.EventDispatcher;
	
	public class UDPChannel extends EventDispatcher {

	private var _guarantiesDelivery:Boolean;	//if true, asks for receipt and retry (if retryTime>0) until it cancels (if cancelTime>0). If retryTime and cancelTime = 0 it will wait for receipt possibly infinitely, if maintainOrder is true, the channel will be blocked then
	private var _maintainOrder:Boolean;			//don't send any more message until the last is or delivered or canceled
	private var _retryTime:Number;				//time in ms before retrying to send message (if it's not delivered yet)
	private var _cancelTime:Number;				//time in ms before canceling the sending (and go to the next if maintainOrder is true)
	private var _dataBuffer:Vector.<UDPDataInfo>=new Vector.<UDPDataInfo>();			//Array containing messages awaiting to be sent
	private var _dataWaitingReceipt:Vector.<UDPDataInfo>=new Vector.<UDPDataInfo>();	//Array containing messages awaiting for a receipt (to be delivered)
	private var _name:String;					//channel name
	private var _running:Boolean;				//if true messages are still being sent (dataBuffer is not empty)
	private var _closed:Boolean;
	
		public function UDPChannel(name:String, guarantiesDelivery:Boolean=false, maintainOrder:Boolean=false, retryTime:Number=50, cancelTime:Number=500) {
		this._name=name;this._maintainOrder=maintainOrder;this._guarantiesDelivery=guarantiesDelivery;this._retryTime=retryTime,this._cancelTime=cancelTime;
		if(this._guarantiesDelivery==false)this._maintainOrder=false;					//if guarantiesDelivery is false so is maintainOrder
		if(isNaN(_cancelTime))_cancelTime=0;if(isNaN(_retryTime))_retryTime=0;		//0 means no timer (no retry or no cancel)
		}
		
		internal function addDataToBuffer(dataInfo:UDPDataInfo){
		_dataBuffer.push(dataInfo);
			if(!_running)sendNextData();	//if there is no message currently being sent start the sending again
		}
		
		private function sendNextData():void{			//send next message in dataBuffer
			if(_closed==false){
		if(_dataBuffer.length>0){
		_running=true;			
		var dataInfo:UDPDataInfo=_dataBuffer.shift();	//retrieve next message and remove it from dataBufffer
		
			if(guarantiesDelivery){											//if delivery is guaranteed 
			_dataWaitingReceipt.push(dataInfo);								//retry handling
			dataInfo.addEventListener(UDPDataEvent.RETRIED, retryHandler);	//
			}
			if(_cancelTime>0){												//cancel handling
			dataInfo.addEventListener(UDPDataEvent.CANCELED, cancelHandler);
			}
		dataInfo.send(_retryTime,_cancelTime);			//notify the message that he is being sent
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.SEND_DATA, dataInfo));
			if(!_maintainOrder){	//if maintainOrder is false
			sendNextData();			//send next message on buffer right now (don't wait for nor delivery nor cancel)
			}
		}
		else _running=false;		//if the dataBuffer is empty stop sending, set running false
		}
		}
		
		private function retryHandler(e:UDPDataEvent){
			if(_closed==false){
			this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_RETRIED,e.currentTarget as UDPDataInfo));		//dispatch public event to UDPManager
			this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.SEND_DATA, e.currentTarget as UDPDataInfo));			//dispatch internal event to UDPManager
			}
		}
		
		private function cancelHandler(e:UDPDataEvent){
			if(_closed==false){
		e.currentTarget.setCanceled(true);		//notify the message that he is canceled
			if(_guarantiesDelivery)_dataWaitingReceipt.splice(_dataWaitingReceipt.indexOf(e.currentTarget as UDPDataInfo),1);	//remove from waiting receipt array
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_CANCELED,e.currentTarget as UDPDataInfo));			//dispatch public event to UDPManager
			if(_maintainOrder)sendNextData();		//send next message if order is maintained
			}
		}

		internal function getReceipt(ID:int){		//investigates the receipt to try to validate a message
			if(_guarantiesDelivery && _closed==false){
			var dataInfo:UDPDataInfo = getWaitingReceiptDataInfoByID(ID);
				if(dataInfo!=null){
				_dataWaitingReceipt.splice(_dataWaitingReceipt.indexOf(dataInfo),1);
				dataInfo.setReceived(true);		//notify the message that he is delivered
				dataInfo.removeEventListener(UDPManagerEvent.DATA_RETRIED, retryHandler);
					if(_cancelTime>0)dataInfo.removeEventListener(UDPManagerEvent.DATA_CANCELED, retryHandler);
				this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_DELIVERED,dataInfo));	//dispatch public event to UDPManager
				if(_maintainOrder)sendNextData();		//send next message is order is maintained
				}//else tracetrace("get receipt for canceled or already received data");
			}
		}

		private function getWaitingReceiptDataInfoByID(ID:int):UDPDataInfo{		//retrieve a message that is waiting for a receipt by his ID
		var max:int=_dataWaitingReceipt.length;
			for(var i:int=0;i<max;i++){
				if(_dataWaitingReceipt[i].ID==ID)return(_dataWaitingReceipt[i]);
			}
		return(null);
		}
		
		public function get name():String{
		return(this._name);
		}		
		public function get maintainOrder():Boolean{
		return(this._maintainOrder);
		}
		public function get guarantiesDelivery():Boolean{
		return(this._guarantiesDelivery);
		}
		public function get retryTime():Number{
		return(this._retryTime);
		}
		public function set retryTime(num:Number):void{
		this._retryTime=num;
		}
		public function get cancelTime():Number{
		return(this._cancelTime);
		}
		public function set cancelTime(num:Number):void{
		this._cancelTime=num;
		}
		internal function close(){
			_running=false;
			_closed=true;
		var max:int = _dataWaitingReceipt.length;
			for(var i:int=0;i<max;i++){
			var dataInf:UDPDataInfo=_dataWaitingReceipt[i];
			dataInf.removeEventListener(UDPDataEvent.RETRIED, retryHandler);
			if(dataInf.hasEventListener(UDPDataEvent.CANCELED))dataInf.removeEventListener(UDPDataEvent.CANCELED, cancelHandler);
			}
		}
	}
	
}
