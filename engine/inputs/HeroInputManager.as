package engine.inputs{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.MouseEvent;
	import piooas3Tools.fl.utils.MathSup;
	import flash.geom.Point;
	import flash.events.EventDispatcher;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.desktop.NativeApplication;
	import events.ActionInputEvent;
	import utils.IDGeneratorChannels;
	import piooas3Tools.fl.utils.IDGenerator;
	
	public class HeroInputManager extends EventDispatcher{

	private var stage:Stage;
	public var top:Boolean;
	public var bot:Boolean;
	public var left:Boolean;
	public var right:Boolean;
	public var sprinting:Boolean;
	public var rotating:Boolean;
	public var rotation:Number;
		
	private var shooting:Boolean;
	
		public function HeroInputManager(){

		}
		
		public function start():void{
		stage=NativeApplication.nativeApplication.activeWindow.stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyboardHandler);
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, mouseHandler);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
		stage.addEventListener(FocusEvent.FOCUS_OUT, reFocus);
		stage.focus=stage;
		}
		private function reFocus(e:FocusEvent):void{
		stage.focus=stage;
		}
		public function hasActiveStateInput():Boolean{
		return((top||bot||right||left||rotating||sprinting));
		}
		public function getStateInput():StateInput{
		return(new StateInput(IDGenerator.getNextID(IDGeneratorChannels.INPUTS),top,bot,right,left,rotation,sprinting));
		}
		public function stop():void{
		if(stage.hasEventListener(KeyboardEvent.KEY_DOWN))stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
		if(stage.hasEventListener(KeyboardEvent.KEY_UP))stage.removeEventListener(KeyboardEvent.KEY_UP, keyboardHandler);
		if(stage.hasEventListener(MouseEvent.RIGHT_MOUSE_DOWN))stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, mouseHandler);
		if(stage.hasEventListener(MouseEvent.MOUSE_DOWN))stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
		if(stage.hasEventListener(MouseEvent.RIGHT_MOUSE_UP))stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseHandler);
		if(stage.hasEventListener(MouseEvent.MOUSE_MOVE))stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseHandler);
		if(stage.hasEventListener(MouseEvent.MOUSE_UP))stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
		stage=null;
		}
		private function onFrame(e:Event):void{
		if(rotating)rotation=MathSup.getAngle(new Point(stage.stageWidth/2,stage.stageHeight/2),new Point(stage.mouseX,stage.mouseY));
		else rotation=NaN;
		}
		private function keyboardHandler(e:KeyboardEvent):void{
			if(e.type==KeyboardEvent.KEY_DOWN){
			if(!top && e.keyCode==Keyboard.Z)top=true;
			else if(!right && e.keyCode==Keyboard.D)right=true;
			else if(!bot && e.keyCode==Keyboard.S)bot=true;
			else if(!left && e.keyCode==Keyboard.Q)left=true;
			else if(!sprinting && e.keyCode==Keyboard.SHIFT)sprinting=true;
			}
			else{
			if(top && e.keyCode==Keyboard.Z)top=false;
			else if(right && e.keyCode==Keyboard.D)right=false;
			else if(bot && e.keyCode==Keyboard.S)bot=false;
			else if(left && e.keyCode==Keyboard.Q)left=false;
			else if(sprinting && e.keyCode==Keyboard.SHIFT)sprinting=false;
			}
		}
		
		private function mouseHandler(e:Event):void{
			if(e.type==MouseEvent.RIGHT_MOUSE_DOWN){
			rotating=true;
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseHandler);
			}
			else if(e.type==MouseEvent.RIGHT_MOUSE_UP){
			rotating=false;
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseHandler);
			}
			else if(e.type==MouseEvent.MOUSE_DOWN){
				if(!shooting)this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.SHOOT,1)));
			shooting=true;
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
			}
			else if(e.type==MouseEvent.MOUSE_UP){
				if(shooting)this.dispatchEvent(new ActionInputEvent(ActionInputEvent.ACTION_INPUT,new ActionInput(ActionType.SHOOT,0)));
			shooting=false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
			}
		}
		
	}
	
}
