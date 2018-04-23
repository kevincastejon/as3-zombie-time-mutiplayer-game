package piooas3Tools.air {
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.desktop.NativeApplication;
	import fl.controls.TextArea;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class TraceWindow {

		private static var _devWindow:NativeWindow;
		private static var _textArea:TextArea;
		private static var _textBackup:String="";
		private static var _firstTem:Boolean=true;
		
		public static var opened:Boolean;
		
		public static function openWindow():void{
			if(_devWindow){
			_devWindow.close();
			var timer:Timer=new Timer(0,1);timer.addEventListener(TimerEvent.TIMER,open);timer.start();
			}
			else open();
			
		}
		public static function closeWindow():void{
			_devWindow.close();
			_textArea=null;
			opened=false;
		}
		public static function trace(...args):void{
			var max:int=args.length;
			var str:String="";
			for(var i:int=0;i<max;i++){
				str+=args[i]+" ";
			}
		if(_textArea)_textArea.appendText(str+"\n");
		_textBackup+=str+"\n";
		}
		public static function get window():NativeWindow{
			return(_devWindow);
		}
		private static function open(e:Event=null):void{
			var opt:NativeWindowInitOptions=new NativeWindowInitOptions();
			opt.owner=NativeApplication.nativeApplication.activeWindow;
			_devWindow=new NativeWindow(opt);
			_devWindow.title="Runtime Console Output by LePioo";
			_textArea=new TextArea();
			_textArea.editable=false;
			_devWindow.activate();
			_devWindow.stage.scaleMode=StageScaleMode.NO_SCALE;
			_devWindow.stage.align=StageAlign.TOP_LEFT;
			_devWindow.stage.addChild(_textArea);
			_devWindow.width=650;
			_devWindow.height=250;
			_textArea.width=_devWindow.stage.stageWidth;
			_textArea.height=_devWindow.stage.stageHeight;
			_devWindow.addEventListener(Event.RESIZE, resized);
			_devWindow.addEventListener(Event.CLOSE, closed);
			_textArea.text=_textBackup;
			opened=true;
		}
		private static function closed(e:Event){
			_devWindow.removeEventListener(Event.CLOSE, closed);
			_devWindow=null;
			}
		private static function resized(e:Event):void{
			_textArea.width=_devWindow.stage.stageWidth;
				_textArea.height=_devWindow.stage.stageHeight;
		}

	}
	
}
