﻿package com.saia.starlingPunk.utils
{
	import com.saia.starlingPunk.SP;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Static class updated by Engine. Use for defining and checking keyboard input.
	 */
	public class SPInput
	{
		/**
		 * An updated string containing the last 100 characters pressed on the keyboard.
		 * Useful for creating text input fields, such as highscore entries, etc.
		 */
		public static var keyString:String = "";
		
		/**
		 * The last key pressed.
		 */
		public static var lastKey:int;
		
		/**
		 * X position of the mouse on the screen.
		 */
		public static var mouseX:int = 0;
		
		/**
		 * Y position of the mouse on the screen.
		 */
		public static var mouseY:int = 0;
		
		/**
		 * If the mouse button is down.
		 */
		public static var mouseDown:Boolean = false;
		
		/**
		 * If the mouse button is up.
		 */
		public static var mouseUp:Boolean = true;
		
		/**
		 * If the mouse button was pressed this frame.
		 */
		public static var mousePressed:Boolean = false;
		
		/**
		 * The Starling touch object
		 */
		public static var touch:Touch;
		
		/**
		 * A list of Starling touch objects over the Stage
		 */
		static public var touches:Vector.<Touch>;
		
		/**
		 * If the mouse button was released this frame.
		 */
		public static var mouseReleased:Boolean = false;
		
		/**
		 * If the mouse wheel was moved this frame.
		 */
		public static var mouseWheel:Boolean = false; 
		
		/**
		 * If the mouse wheel was moved this frame, this was the delta.
		 */
		public static function get mouseWheelDelta():int
		{
			if (mouseWheel)
			{
				mouseWheel = false;
				return _mouseWheelDelta;
			}
			return 0;
		}  
		
		/**
		 * Defines a new input.
		 * @param	name		String to map the input to.
		 * @param	...keys		The keys to use for the Input.
		 */
		public static function define(name:String, keys:Array):void
		{
			_control[name] = Vector.<int>(keys);
		}
		
		/**
		 * If the input or key is held down.
		 * @param	input		An input name or key to check for.
		 * @return	True or false.
		 */
		public static function check(input:*):Boolean
		{
			if (input is String)
			{
				var v:Vector.<int> = _control[input],
					i:int = v.length;
				while (i --)
				{
					if (v[i] < 0)
					{
						if (_keyNum > 0) return true;
						continue;
					}
					if (_key[v[i]]) return true;
				}
				return false;
			}
			return input < 0 ? _keyNum > 0 : _key[input];
		}
		
		/**
		 * If the input or key was pressed this frame.
		 * @param	input		An input name or key to check for.
		 * @return	True or false.
		 */
		public static function pressed(input:*):Boolean
		{
			if (input is String)
			{
				var v:Vector.<int> = _control[input],
					i:int = v.length;
				while (i --)
				{
					if ((v[i] < 0) ? _pressNum : _press.indexOf(v[i]) >= 0) return true;
				}
				return false;
			}
			return (input < 0) ? _pressNum : _press.indexOf(input) >= 0;
		}
		
		/**
		 * If the input or key was released this frame.
		 * @param	input		An input name or key to check for.
		 * @return	True or false.
		 */
		public static function released(input:*):Boolean
		{
			if (input is String)
			{
				var v:Vector.<int> = _control[input],
					i:int = v.length;
				while (i --)
				{
					if ((v[i] < 0) ? _releaseNum : _release.indexOf(v[i]) >= 0) return true;
				}
				return false;
			}
			return (input < 0) ? _releaseNum : _release.indexOf(input) >= 0;
		}
		
		/**
		 * Returns the keys mapped to the input name.
		 * @param	name		The input name.
		 * @return	A Vector of keys.
		 */
		public static function keys(name:String):Vector.<int>
		{
			return _control[name] as Vector.<int>;
		}
		
		/** @private Called by Engine to enable keyboard input on the stage. */
		public static function enable():void
		{
			if (!_enabled && SP.stage)
			{
				SP.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				SP.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				SP.stage.addEventListener(TouchEvent.TOUCH, onTouch);
				Starling.current.nativeStage.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
				_enabled = true;
			}
		}
		
		/** @private Called by Engine to update the input. */
		public static function update():void
		{
			while (_pressNum --) _press[_pressNum] = -1;
			_pressNum = 0;
			while (_releaseNum --) _release[_releaseNum] = -1;
			_releaseNum = 0;
			if (mousePressed) mousePressed = false;
			if (mouseReleased) mouseReleased = false;
		}
		
		/**
		 * Clears all input states.
		 */
		public static function clear():void
		{
			_press.length = _pressNum = 0;
			_release.length = _releaseNum = 0;
			var i:int = _key.length;
			while (i --) _key[i] = false;
			_keyNum = 0;
		}
		
		/** @private Event handler for key press. */
		private static function onKeyDown(e:KeyboardEvent = null):void
		{
			// get the keycode
			var code:int = lastKey = e.keyCode;
			
			// update the keystring
			if (code == Key.BACKSPACE) keyString = keyString.substring(0, keyString.length - 1);
			else if ((code > 47 && code < 58) || (code > 64 && code < 91) || code == 32)
			{
				if (keyString.length > KEYSTRING_MAX) keyString = keyString.substring(1);
				var char:String = String.fromCharCode(code);
				if (e.shiftKey || Keyboard.capsLock) char = char.toLocaleUpperCase();
				else char = char.toLocaleLowerCase();
				keyString += char;
			}
			
			// update the keystate
			if (!_key[code])
			{
				_key[code] = true;
				_keyNum ++;
				_press[_pressNum ++] = code;
			}
		}
		
		/** @private Event handler for key release. */
		private static function onKeyUp(e:KeyboardEvent):void
		{
			// get the keycode and update the keystate
			var code:int = e.keyCode;
			if (_key[code])
			{
				_key[code] = false;
				_keyNum --;
				_release[_releaseNum ++] = code;
			}
		}
		
		static private function onTouch(e:TouchEvent):void 
		{
			touches = e.getTouches(SP.stage);
			touch = e.getTouch(SP.stage);
			if (!touch) return;
			
			mouseX = touch.globalX;
			mouseY = touch.globalY;
			
			if (touch.phase == TouchPhase.MOVED || touch.phase == TouchPhase.BEGAN)
			{
				if (!mouseDown)
				{
					mouseDown = true;
					mouseUp = false;
					mousePressed = true;
				}
			}
			else
			{
				mouseDown = false;
				mouseUp = true;
				mouseReleased = true;
			}
		}
		
		/** @private Event handler for mouse wheel events */
		private static function onMouseWheel(e:MouseEvent):void
		{
		    mouseWheel = true;
		    _mouseWheelDelta = e.delta;
		}
		
		// Max amount of characters stored by the keystring.
		/** @private */ private static const KEYSTRING_MAX:uint = 100;
		
		// Input information.
		/** @private */ private static var _enabled:Boolean = false;
		/** @private */ private static var _key:Vector.<Boolean> = new Vector.<Boolean>(256);
		/** @private */ private static var _keyNum:int = 0;
		/** @private */ private static var _press:Vector.<int> = new Vector.<int>(256);
		/** @private */ private static var _release:Vector.<int> = new Vector.<int>(256);
		/** @private */ private static var _pressNum:int = 0;
		/** @private */ private static var _releaseNum:int = 0;
		/** @private */ private static var _control:Object = { };
		/** @private */ private static var _mouseWheelDelta:int = 0;
	}
}