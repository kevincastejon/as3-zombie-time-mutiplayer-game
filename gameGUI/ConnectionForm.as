package gameGUI {
	import fl.controls.RadioButton;
	import fl.controls.Label;
	import fl.controls.ColorPicker;
	import fl.controls.TextInput;
	import fl.controls.Button;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import events.SimpleEvent;
	import fl.controls.ComboBox;
	import flash.net.NetworkInterface;
	import flash.filesystem.File;
	import piooas3Tools.air.nativeOps.ExternalIPFinder;
	import piooas3Tools.air.nativeOps.ProcessLauncher;
	import piooas3Tools.air.nativeOps.ProcessOutputEvent;
	import flash.desktop.NativeApplication;
	import flash.net.IPVersion;
	
	
	public class ConnectionForm extends Sprite {
		private var tiIP:TextInput;
		private var tiPort:TextInput;
		private var lbIP:Label;
		private var rbLAN:RadioButton;
		private var rbOnline:RadioButton;
		private var rbJoin:RadioButton;
		private var rbCreate:RadioButton;
		private var cbNetInterface:ComboBox;
		private var lbNetInterface:Label;
		private var labelColor:Label;
		private var cp:ColorPicker;
		private var tiNick:TextInput;
		private var bt:Button;
		
		private var extIP:String;
		
		public function ConnectionForm() {
			tiIP=s_tiIP;
			tiPort=s_tiPort;
			lbIP=s_lbIP;
			rbLAN=s_rbLAN;
			rbOnline=s_rbOnline;
			rbJoin=s_rbJoin;
			rbCreate=s_rbCreate;
			cbNetInterface=s_cbNetInterface;
			lbNetInterface=s_lbNetInterface;
			labelColor=s_labelColor;
			cp=s_cp;
			tiNick=s_tiNick;
			bt=s_bt;
		bt.label="Host";
		cbNetInterface.addEventListener(Event.CHANGE, netInterfaceSelected);
		rbCreate.addEventListener(Event.CHANGE, radioButtonsHandler);
		rbJoin.addEventListener(Event.CHANGE, radioButtonsHandler);
		rbOnline.addEventListener(Event.CHANGE, onlanHandler);
		rbLAN.addEventListener(Event.CHANGE, onlanHandler);
		bt.addEventListener(MouseEvent.CLICK, btnHandler);
		var CURLFile:File=File.applicationDirectory.resolvePath("curl.exe");
		ExternalIPFinder.addEventListener(Event.COMPLETE, IPRetrieved);
		ExternalIPFinder.findExternalIP(CURLFile);
		}
		private function netInterfaceSelected(e:Event):void{
			
			var ni:NetworkInterface=cbNetInterface.selectedItem.data;
			ni.addresses[0].ipVersion==IPVersion.IPV4;
			if(ni.addresses[0].ipVersion==IPVersion.IPV6){tiPort.text="0";}
			else{tiPort.text="26666";}
		}
		private function IPRetrieved(e:Event):void{
			this.extIP=ExternalIPFinder.externalIP;
			rbOnline.enabled=true;
		}
		
		public function init(netInterfaces:Vector.<NetworkInterface>):void{
		var max:int=netInterfaces.length;
			for(var i:int=0;i<max;i++){
				var itm:Object={label:netInterfaces[i].displayName+" "+netInterfaces[i].addresses[0].address,data:netInterfaces[i]};
				if(netInterfaces[i].addresses.length>1)itm.label=itm.label+">>>"+netInterfaces[i].addresses[1].address;
				cbNetInterface.addItem(itm);
			}
			cbNetInterface.selectedIndex=0;
		}
		private function onlanHandler(e:Event):void
		{
			if(rbCreate.selected)lbNetInterface.visible=cbNetInterface.visible=rbOnline.selected;
			if(rbOnline.selected==false){
				tiPort.text="8888";
				}
			else {
					if(rbCreate.selected)
				cbNetInterface.dispatchEvent(new Event(Event.CHANGE));
					else{
				tiPort.text="26666";		
					}
				
				}
		}
		private function radioButtonsHandler(e:Event):void
		{
		tiIP.visible=lbIP.visible=rbJoin.selected;
		lbNetInterface.visible=cbNetInterface.visible=rbCreate.selected;
		if(rbJoin.selected)bt.label="Connect";
		else bt.label="Host";
		
		}
		
		private function btnHandler(e:MouseEvent):void
		{
		var valid:Boolean=true;
			if(tiNick.text==""){valid=false;tiNick.filters=[new GlowFilter(0xFF0000,1,10,10,1)];}else tiNick.filters=[];
			if(rbCreate.selected==false && tiIP.text==""){valid=false; tiIP.filters=[new GlowFilter(0xFF0000,1,10,10,1)];}else tiIP.filters=[];
			if(valid){
				if(rbOnline.selected && tiPort.text!="0"){
				ProcessLauncher.addEventListener(ProcessOutputEvent.PROCESS_OUTPUT,complete);
				ProcessLauncher.launchBatch(File.applicationDirectory.resolvePath("portforward.bat"),[this.getNetworkInterface().addresses[0].address,getPort()]);
				}
				else{
				complete();
				}
				}
		}
		private function removePortForward(e:Event=null){
			ProcessLauncher.launchBatch(File.applicationDirectory.resolvePath("portdelete.bat"),[this.getPort()]);
		}
		private function complete(e:ProcessOutputEvent=null):void{
			if(e){
				ProcessLauncher.removeEventListener(ProcessOutputEvent.PROCESS_OUTPUT,complete);
				stage.nativeWindow.addEventListener(Event.CLOSE, removePortForward);
				}
			this.dispatchEvent(new SimpleEvent(SimpleEvent.CONNECTION_FORM_COMPLETED));
		}
		
		public function getNickName():String
		{
		return tiNick.text;
		}
		public function getColor():uint
		{
		return cp.selectedColor;
		}	
		
		public function getHost():Boolean
		{
		return rbCreate.selected;
		}
		public function getIP():String
		{
		return tiIP.text;
		}
		public function getConnectionAdress():String
		{
			if(rbOnline.selected && tiPort.text!="0")return this.extIP;
			
			return(cbNetInterface.selectedItem.data.addresses[0].address);
		}
		public function getPort():int
		{
		return(int(tiPort.text));
		}
		public function getNetworkInterface():NetworkInterface{
		return cbNetInterface.selectedItem.data;
		}
		public function displayWrongIPMessage():void{
		tiIP.text="connection failed:wrong IP";
		}
		public function reset():void{
		tiNick.text=tiIP.text="";
		rbCreate.selected=true;
		cp.selectedColor=0;
		}
	}
	
}
