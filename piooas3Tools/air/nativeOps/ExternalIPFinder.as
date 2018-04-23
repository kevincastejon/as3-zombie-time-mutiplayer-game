package piooas3Tools.air.nativeOps {
	
	import flash.filesystem.File;
	import piooas3Tools.air.nativeOps.ProcessLauncher;
	import piooas3Tools.air.nativeOps.ProcessOutputEvent;
	import flash.net.NetworkInfo;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class ExternalIPFinder{
		
		private static var _externalIP:String;
		private static var tem:int=0;
		
		private static var dispatcher:EventDispatcher = new EventDispatcher();
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
		   dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
		   dispatcher.removeEventListener(type, listener, useCapture);
		}

		public static function dispatchEvent(event:Event):Boolean {
		   return dispatcher.dispatchEvent(event);
		}

		public static function hasEventListener(type:String):Boolean {
		   return dispatcher.hasEventListener(type);
		}
		private static function handler(e:ProcessOutputEvent):void{
			var reg:RegExp=new RegExp("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))|((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(([0-9A-Fa-f]{1,4}:){0,5}:((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|(::([0-9A-Fa-f]{1,4}:){0,5}((b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b).){3}(b((25[0-5])|(1d{2})|(2[0-4]d)|(d{1,2}))b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$");
			var outPut:String=String(e.data.readUTFBytes(e.data.bytesAvailable));
			var bool:Boolean=reg.test(outPut);
			if(bool){trace(outPut);
				ExternalIPFinder._externalIP=outPut;
				ProcessLauncher.removeEventListener(ProcessOutputEvent.PROCESS_OUTPUT, handler);
				ExternalIPFinder.dispatchEvent(new Event(Event.COMPLETE));
			}
			else{
				tem++;
				if(tem==5){
					ExternalIPFinder.dispatchEvent(new Event(Event.COMPLETE));
					ProcessLauncher.removeEventListener(ProcessOutputEvent.PROCESS_OUTPUT, handler);
				}
			}
		}
		public static function get externalIP():String{
			return(ExternalIPFinder._externalIP);
		}
		public static function findExternalIP(compiledCURLFile:File):void{
			ProcessLauncher.addEventListener(ProcessOutputEvent.PROCESS_OUTPUT, handler);
			ProcessLauncher.launchProcess(compiledCURLFile,null,["ipecho.net/plain;"]);
			ProcessLauncher.launchProcess(compiledCURLFile,null,["icanhazip.com"]);
			ProcessLauncher.launchProcess(compiledCURLFile,null,["curlmyip.com"]);
			ProcessLauncher.launchProcess(compiledCURLFile,null,["l2.io/ip"]);
			ProcessLauncher.launchProcess(compiledCURLFile,null,["ifconfig.me/ip"]);
			ProcessLauncher.launchProcess(compiledCURLFile,null,["eth0.me"]);	
		}
		
	}
	
}
