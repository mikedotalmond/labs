/*
Binary Clock - haXe NME

Copyright (c) 2012 Mike Almond - @mikedotalmond

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Back;
import com.eclecticdesignstudio.motion.easing.Expo;
import com.eclecticdesignstudio.motion.easing.Quad;

import nme.display.GradientType;
import nme.display.Graphics;
import nme.display.Shape;
import nme.events.KeyboardEvent;
import nme.events.TimerEvent;
import nme.geom.Matrix;
import nme.ui.Keyboard;
import nme.utils.Timer;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.StageDisplayState;
import nme.errors.Error;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.system.System;
import nme.Vector;



/**
 * ...
 * Conversion of Binary Clock to haXe NME
 * 
 * Should work ok on all targets.. have tested flash, windows, android, html5
 * 
 * 
 * @author Mike Almond
 * 
 */
class BinaryClock extends Sprite {
	
	static public var FRAMERATE_ACTIVE	:Int = 30;
	static public var FRAMERATE_IDLE	:Int = 5;
	
	// change flags
	static public var SECOND			:Int = 0x01;
	static public var MINUTE			:Int = 0x02;
	static public var HOUR				:Int = 0x04;
	
	private var _lastH					:Int;
	private var _lastM					:Int;
	private var _lastS					:Int;
	private var _changed				:Int;
	
	private var _secondShapes			:Vector<BitShape>;
	private var _minuteShapes			:Vector<BitShape>;
	private var _hourShapes				:Vector<BitShape>;
	
	private var _seconds				:Sprite;
	private var _minutes				:Sprite;
	private var _hours					:Sprite;
	private var _firstrun				:Bool;
	private var _inverted				:Bool;
	
	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	/**
	 * 
	 * @param	e
	 */
	public function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		//alpha 		= 0.25;
		_seconds 		= cast(addChild(new Sprite()), Sprite);
		_minutes 		= cast(addChild(new Sprite()), Sprite);
		_hours	 		= cast(addChild(new Sprite()), Sprite);
		
		_seconds.mouseEnabled 	= 
		_minutes.mouseEnabled 	= 
		_hours.mouseEnabled 	=
		_inverted 				= false;
		opaqueBackground 		= 0x000000;
		
		stage.doubleClickEnabled = true;
		stage.addEventListener(Event.RESIZE, onResize);
		
		stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		stage.addEventListener(Event.ACTIVATE, onActivate);
		stage.addEventListener(MouseEvent.CLICK, onClick);
		stage.addEventListener(MouseEvent.DOUBLE_CLICK, onClick);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		reset();
	}
	
	private function onKeyDown(e:KeyboardEvent):Void {
		if (e.keyCode == Keyboard.ESCAPE) stage.displayState = StageDisplayState.NORMAL;
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function onClick(e:MouseEvent):Void {
		if (e.type == MouseEvent.DOUBLE_CLICK) {
			_inverted = !_inverted;
			reset();
		} else {
			try { // might not have permission to toggle fullscreen
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} catch (err:Error) {
				// oops!
			}
		}
	}
	
	/**
	 * 
	 */
	private function reset():Void {
		onDeactivate(null);
		
		while (_seconds.numChildren > 0) _seconds.removeChildAt(0);
		while (_minutes.numChildren > 0) _minutes.removeChildAt(0);
		while (_hours.numChildren > 0) _hours.removeChildAt(0);
		
		_secondShapes 	= getShapes(_seconds, _inverted?300:200, 60, 22, -32, true, getHueRange(hsl(0xFf0000), 60));
		_minuteShapes 	= getShapes(_minutes, _inverted?150:80, 60, 11, -22, false, getHueRange(hsl(0xFf0000, 0, 0.66, 0.66), 60));
		_hourShapes 	= getShapes(_hours, _inverted?50:12, 12, 10, -12, false, getHueRange(hsl(0xFf0000, 0, 0.33, 0.30), 12));
		
		onActivate(null);
		onResize(null);
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function onActivate(e:Event):Void {
		_firstrun		= true;
		_lastH 			=
		_lastM 			=
		_lastS 			= -1;
		stage.frameRate = 30;
		Actuate.reset();
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function onDeactivate(e:Event):Void {
		removeEventListener(Event.ENTER_FRAME, update);
		Actuate.reset();
		stage.frameRate = 5;
		System.gc();
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function onResize(e:Event):Void {
		
		var w:Int = stage.stageWidth;
		var h:Int = stage.stageHeight;
		
		graphics.clear();
		graphics.beginFill(0);
		graphics.drawRect(0, 0, w, h);
		graphics.endFill();
		
		_hours.scaleX =
		_hours.scaleY =
		_minutes.scaleX =
		_minutes.scaleY =
		_seconds.scaleX =
		_seconds.scaleY = Math.max(0.7, Math.min(Math.min(1, w / 768), h / 768));
		
		_minutes.x = _seconds.x = _hours.x 	 = w / 2;
		_hours.y   = _minutes.y = _seconds.y = h / 2;
		
		if (w < 768) {
			if (w > h) _hours.y = _minutes.y = _seconds.y = h;
		}
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function update(e:Event):Void {
		
		var d	:Date = Date.now();
		var h	:Int = d.getHours();
		var m	:Int = d.getMinutes();
		var s	:Int = d.getSeconds();
		
		_changed = HOUR | MINUTE | SECOND;
		
		if (_lastH != h) _lastH = h;
		else _changed &= ~HOUR;
		
		if (_lastM != m) _lastM = m;
		else _changed &= ~MINUTE;
		
		if (_lastS != s) _lastS = s;
		else _changed &= ~SECOND;
		
		if (_changed != 0) drawTime(h, m, s);
	}
	
	/**
	 * 
	 * @param	hours
	 * @param	mins
	 * @param	secs
	 */
	private function drawTime(hours:Int, mins:Int, secs:Int):Void {
		
		var i:Int;
		if(_changed & HOUR != 0){
			i 	  = -1;
			hours = hours > 11 ? hours - 12 : hours;
			while (++i < 12) {
				if (i <= hours) _hourShapes[i].activate();
				else _hourShapes[i].deactivate(_firstrun?0:(i/12)*750);
			}
			
			#if !flash
			i = -hours * 30;
			#else
			if (hours < 6) i = -hours * 30;
			else if (hours == 6 ) i = -181;
			else i = 360 - hours * 30;
			#end
			Actuate.tween(_hours, 1.0, { rotation:i } ).ease(Expo.easeInOut);
		}
		
		if(_changed & MINUTE != 0){
			i 	= -1;
			while (++i < 60) {
				if (i <= mins) _minuteShapes[i].activate();
				else _minuteShapes[i].deactivate(_firstrun?0:(i / 60) * 750);
			}
			
			#if !flash
			i = -mins * 6;
			#else
			if (mins < 30) i = -mins * 6;
			else if (mins == 30 ) i = -181;
			else i = 360 - mins * 6;
			#end
			Actuate.tween(_minutes, 1, { rotation:i } ).ease(Expo.easeInOut);
		}
		
		if (_changed & SECOND != 0) {
			i = -1;
			while (++i < 60) {
				if (i <= secs) _secondShapes[i].activate();
				else _secondShapes[i].deactivate(_firstrun?0:(i / 60) * 750);
			}
			
			#if !flash
			i = -secs * 6;
			#else
			if (secs < 30) i = -secs * 6;
			else if (secs == 30 ) i = -181;
			else i = 360 - secs * 6;
			#end
			stage.frameRate = FRAMERATE_ACTIVE;
			Actuate.tween(_seconds, secs == 0 ? 1 : 0.425, { rotation:i } ).ease(secs == 0 ? Expo.easeIn : Back.easeOut).onComplete(onTweenComplte);
		}
		
		_firstrun = false;
	}
	
	private function onTweenComplte():Void {
		stage.frameRate = FRAMERATE_IDLE;
	}
	
	/**
	 * 
	 * @param	container
	 * @param	radius
	 * @param	count
	 * @param	size
	 * @param	pad
	 * @param	round
	 * @param	colourRange
	 * @return
	 */
	private function getShapes(container:DisplayObjectContainer, radius:Float, count:Int, size:Float, pad:Int, round:Bool, colourRange:Vector<Int>):Vector<BitShape> {
		var out		:Vector<BitShape> = new Vector<BitShape>();
		var i		:Int = -1;
		var step	:Float =  Math.PI * 2 / count;
		var angle	:Float;
		var s		:BitShape;
		
		while (++i < count) {
			s 			= new BitShape(container, i, colourRange[i], size, pad, round);
			angle 		= step * i - Math.PI / 2;
			s.x 		= Math.cos( angle ) * radius;
			s.y 		= Math.sin( angle ) * radius;
			s.rotation 	= (angle * 180 / Math.PI) + (_inverted ? 90 : -90);
			out.push(s);
		}
		
		return out;
	}
	
	/**
	 * 
	 * @param	start
	 * @param	size
	 * @param	hueRange
	 * @return
	 */
	private static function getHueRange(start:Int, size:Int, hueRange:Float=1):Vector<Int> {
		var out	:Vector<Int> = new Vector<Int>();
		var i		:Int = -1;
		while (++i < size) out.push(hsl(start, hueRange * (i / size)));
		return out;
	}
	
	/**
	 * 
	 * @param	colour
	 * @param	hue
	 * @param	sat
	 * @param	lum
	 * @return
	 */
	public static function hsl(colour:Int, hue:Float = 0, sat:Float = 1.0, lum:Float = 1.0):Int {
		
		var r:Float = cast((colour >> 16) & 0xFF, Float) / 0xFF;
		var g:Float = cast((colour >> 8)  & 0xFF, Float) / 0xFF;
		var b:Float = cast(colour & 0xFF, Float) / 0xFF;
		
		var Cmax:Float = Math.max(r, Math.max(g, b));
		var Cmin:Float = Math.min(r, Math.min(g, b));
		
		var D:Float;
		var H:Float;
		var S:Float;
		var L:Float = (Cmax + Cmin) / 2.0;
		
		// it's grey
		if (Cmax == Cmin){
			H = S = 0.0;
		} else {
			D = Cmax - Cmin;
			
			// calculate Saturation
			if (L < 0.5) S = D / (Cmax + Cmin);
			else S = D / (2.0 - (Cmax + Cmin));

			// calculate Hue
			if (r == Cmax){
				H = (g - b) / D;
			} else {
				if (g == Cmax) H = 2.0 + (b - r) / D;
				else H = 4.0 + (r - g) / D;
			}
			H = H / 6.0;
		}
	
		// modify H/S/L values
		H -= hue;
		S *= sat;
		L *= lum;
		
		if (H < 0.0) H += 1.0; else if (H > 1.0) H -= 1.0;
		if (S < 0.0) S += 1.0; else if (S > 1.0) S -= 1.0;
		if (L < 0.0) L += 1.0; else if (L > 1.0) L -= 1.0;
		
		// hsl to rgb...
		var var_1:Float;
		var var_2:Float;
		
		if (S == 0.0){
			r = g = b = L;
		} else {
			if ( L < 0.5 ) var_2 = L * ( 1.0 + S );
			else var_2 = ( L + S ) - ( S * L );
			
			var_1 = 2.0 * L - var_2;
		
			var vH:Float;
			vH = H + ( 1.0 / 3.0 );
			//hue to r...
			if ( vH < 0.0 ) vH += 1.0;
			if ( vH > 1.0 ) vH -= 1.0;
			if ( ( 6.0 * vH ) < 1.0 ) r = ( var_1 + ( var_2 - var_1 ) * 6.0 * vH );
			else if ( ( 2.0 * vH ) < 1.0 ) r = ( var_2 );
			else if ( ( 3.0 * vH ) < 2.0 ) r = ( var_1 + ( var_2 - var_1 ) * ( ( 2.0 / 3.0 ) - vH ) * 6.0 );
			else r = var_1;
			
			vH = H;
			//hue to g...
			if ( vH < 0.0 ) vH += 1.0;
			if ( vH > 1.0 )	vH -= 1.0;
			if ( ( 6.0 * vH ) < 1.0 ) g = ( var_1 + ( var_2 - var_1 ) * 6.0 * vH );
			else if ( ( 2.0 * vH ) < 1.0 ) g = ( var_2 );
			else if ( ( 3.0 * vH ) < 2.0 ) g = ( var_1 + ( var_2 - var_1 ) * ( ( 2.0 / 3.0 ) - vH ) * 6.0 );
			else g = var_1;
			
			vH = H - ( 1.0 / 3.0 );
			//hue to b
			if ( vH < 0.0 ) vH += 1.0;
			if ( vH > 1.0 ) vH -= 1.0;
			if ( ( 6.0 * vH ) < 1.0 ) b = ( var_1 + ( var_2 - var_1 ) * 6.0 * vH );
			else if ( ( 2.0 * vH ) < 1.0 ) b = ( var_2 );
			else if ( ( 3.0 * vH ) < 2.0 ) b = ( var_1 + ( var_2 - var_1 ) * ( ( 2.0 / 3.0 ) - vH ) * 6.0 );
			else b = var_1;
		}
		
		return (Math.round(r * 0xFF) << 16) | (Math.round(g * 0xFF) << 8) | Math.round(b * 0xFF);
	}
}



class BitShape extends Shape {
	
	private var _timer	:Timer;
	private var _active	:Bool;
	
	/**
	 * 
	 * @param	container
	 * @param	value
	 * @param	colour
	 * @param	size
	 * @param	pad
	 * @param	doRound
	 */
	public function new(container:DisplayObjectContainer, value:Int, colour:Int, size:Float=8, pad:Int=10, doRound:Bool=false):Void {
		super();
		
		if (colour == 0 || value == 60) return;
		
		container.addChild(this);
		alpha 		= 0.15;
		_active 	= false;
		_timer 		= new Timer(100,1);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, doDeactivate);
		drawBits(graphics, size, pad, colour, value, doRound);
		
		cacheAsBitmap = true;
		
		activate();
		deactivate();
	}
	
	/**
	 * 
	 */
	public function activate():Void {
		if (!_active) {
			alpha 	= 1;
			_active = true;
		}
	}
	
	/**
	 * 
	 * @param	delay
	 */
	public function deactivate(delay:Float = 0):Void {
		if (parent==null || !_active) return;
		if (delay > 0) {
			_timer.reset();
			_timer.delay = delay;
			_timer.start();
		} else {
			doDeactivate();
		}
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function doDeactivate(e:Event = null):Void {
		alpha 	= 0.15;
		_active = false;
	}
	
	/**
	 * 
	 * @param	g
	 * @param	size
	 * @param	pad
	 * @param	colour
	 * @param	value
	 * @param	doRound
	 */
	private static function drawBits(g:Graphics, size:Float = 8, pad:Int = 10, colour:Int = 0xFF0000, value:Int = 59, doRound:Bool=false):Void {
		
		var m:Matrix = new Matrix();
		m.createGradientBox(size, size, 0, 0, 0);
		g.beginGradientFill( GradientType.LINEAR,
							[BinaryClock.hsl(colour, 1 / 30), colour],
							[1, 1],
							[0, 0xFF],
							m );

		var half	:Float 	= (size / 2);
		var round	:Float 	= doRound ? Math.round(size / 4) : 0;
		var a		:Float 	= 0;
		
		value & 0x01 != 0 ? g.drawRoundRect( -half, a, size, size, round, round): Void; // 1
		a -= pad;
		value & 0x02 != 0 ? g.drawRoundRect( -half / 2, a, size / 2, size, Math.round(round / 2), Math.round(round / 2)): Void; // 2
		a -= pad;
		value & 0x04 != 0 ? g.drawRoundRect( -half / 4, a, size / 4, size / 1.125, Math.round(round / 4), Math.round(round / 4)): Void; // 4
		a -= pad/1.25;
		value & 0x08 != 0 ? g.drawRect( -half / 8, a, size / 8, size / 1.25) : Void; // 8
		a -= pad/1.5;
		value & 0x10 != 0 ? g.drawRect( -half / 16, a, size / 16, size / 1.5) : Void; // 16
		a -= pad/1.75;
		value & 0x20 != 0 ? g.drawRect( -half / 16, a, size / 16, size / 2) : Void; // 32
		g.endFill();
	}
}