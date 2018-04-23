package piooas3Tools.air.nativeOps {
	import flash.filesystem.File;
	import flash.events.ProgressEvent;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.desktop.NativeApplication;
	
	public class ProcessLauncher {

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
		public static function launchBatch(batchFile:File, ...args){
		var process:NativeProcess;
		var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo(); 
		var file: File = File.userDirectory.parent.parent.resolvePath("Windows").resolvePath("System32").resolvePath("cmd.exe");
		nativeProcessStartupInfo.executable = file; 
		nativeProcessStartupInfo.workingDirectory=batchFile.parent;
		var processArgs:Vector.<String> = new Vector.<String>();
		var processArg:String='cmd /c ';
		processArg+=batchFile.name+' ';
		var max:int=args.length;
			for(var i:int=0;i<max;i++){
			processArg+=args[i]+" ";
			}
		if(max>0)processArg+=" fakeLastArg";
		processArgs.push(processArg);
		nativeProcessStartupInfo.arguments = processArgs; 
		process = new NativeProcess();
		process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, handler);
		process.start(nativeProcessStartupInfo);
			function handler(e:ProgressEvent){
			ProcessLauncher.dispatchEvent(new ProcessOutputEvent(ProcessOutputEvent.PROCESS_OUTPUT,process.standardOutput));
			}
		}
		
		public static function launchProcess(processFile:File, workingDir:File=null, ...args){
		var process:NativeProcess;
		var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo(); 
		nativeProcessStartupInfo.executable = processFile;
			if(workingDir)nativeProcessStartupInfo.workingDirectory=workingDir;
		var processArgs:Vector.<String> = new Vector.<String>();
		var max:int=args.length;
			for(var i:int=0;i<max;i++){
			processArgs.push(args[i]);
			}		
		nativeProcessStartupInfo.arguments = processArgs; 
		process = new NativeProcess();
		process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, handler);
		process.start(nativeProcessStartupInfo);
			function handler(e:ProgressEvent){
			ProcessLauncher.dispatchEvent(new ProcessOutputEvent(ProcessOutputEvent.PROCESS_OUTPUT,process.standardOutput));
			}
		}
		
		public static function rebootApp(){
		var process:NativeProcess;
		var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo(); 
		nativeProcessStartupInfo.executable = File.applicationDirectory.resolvePath("DeadAnyway.exe");
		nativeProcessStartupInfo;
		process = new NativeProcess();
		process.start(nativeProcessStartupInfo);
		NativeApplication.nativeApplication.exit();
		}

	}
	
}