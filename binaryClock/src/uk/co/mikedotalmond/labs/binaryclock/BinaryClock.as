/*
Binary Clock

Copyright (c) 2011 Mike Almond - @mikedotalmond

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

package uk.co.mikedotalmond.labs.binaryclock {
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;
	import com.greensock.easing.FastEase;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenLite;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	
	public final class BinaryClock extends Sprite {
		
		// change flags
		static public const SECOND	:uint = 0x01;
		static public const MINUTE	:uint = 0x02;
		static public const HOUR	:uint = 0x04;
		
		private var _lastH			:int;
		private var _lastM			:int;
		private var _lastS			:int;
		private var _changed		:uint;
		
		private var _secondShapes	:Vector.<BitShape>;
		private var _minuteShapes	:Vector.<BitShape>;
		private var _hourShapes		:Vector.<BitShape>;
		
		private var _seconds		:Sprite;
		private var _minutes		:Sprite;
		private var _hours			:Sprite;
		private var _firstrun		:Boolean = true;
		private var _timer			:Timer;
		private var _inverted:Boolean;
		
		public function BinaryClock():void {
			if (!stage) addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			else init(null);
		}
		
		public function init(e:Event):void {
			if (e) removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.frameRate = 5;
			stage.align 	= StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality   = StageQuality.HIGH;
			stage.showDefaultContextMenu = false;
			
			_seconds 		= Sprite(addChild(new Sprite()));
			_minutes 		= Sprite(addChild(new Sprite()));
			_hours	 		= Sprite(addChild(new Sprite()));
			
			alpha 			= 0.25;
			
			_seconds.mouseEnabled = _minutes.mouseEnabled = _hours.mouseEnabled = false;
			
			FastEase.activate([Quad, Back]);
			TweenPlugin.activate([ShortRotationPlugin]);
			
			_inverted 			= false;
			opaqueBackground 	= 0x000000;
			
			stage.doubleClickEnabled = true;
			stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			stage.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, onClick, false, 0, true);
			
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);
			stage.addEventListener(Event.ACTIVATE, onActivate);
			
			_timer = new Timer(1000/15); // 15/second
			_timer.addEventListener(TimerEvent.TIMER, update);
			
			reset();
		}
		
		private function reset():void {
			onDeactivate(null);
			
			while (_seconds.numChildren) _seconds.removeChildAt(0);
			while (_minutes.numChildren) _minutes.removeChildAt(0);
			while (_hours.numChildren) _hours.removeChildAt(0);
			
			_secondShapes 	= getShapes(_seconds, _inverted?300:200, 60, 22, -32, true, getHueRange(hsl(0xFf0000), 60));
            _minuteShapes 	= getShapes(_minutes, _inverted?150:80, 60, 11, -22, false, getHueRange(hsl(0xFf0000, 0, 0.66, 0.66), 60));
            _hourShapes 	= getShapes(_hours, _inverted?50:12, 12, 10, -12, false, getHueRange(hsl(0xFf0000, 0, 0.33, 0.30), 12));
			
			onActivate(null);
			onResize(null);
		}
		
		
		private function onActivate(e:Event):void {
			_firstrun		= true;
			_lastH 			=
			_lastM 			=
			_lastS 			= -1;
			
			_timer.start();
			stage.frameRate = 30;
			TweenLite.killTweensOf(this);
			TweenLite.to(this, 1, { alpha:1, ease:Quad.easeOut } );
		}
		
		private function onDeactivate(e:Event):void {
			_timer.reset();
			TweenLite.killTweensOf(this);
			alpha = 0.25;
			stage.frameRate = 5;
			System.gc();
		}
		
		private function onClick(e:MouseEvent):void {
			if (e.type == MouseEvent.DOUBLE_CLICK) {
				_inverted = !_inverted;
				reset();
			} else {
				try { // might not have permission to toggle fullscreen
					stage.displayState = StageDisplayState.FULL_SCREEN;
				} catch (err:Error) {
					//oops!
				}
			}
		}
		
		private function onResize(e:Event):void {
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			_hours.scaleX =
			_hours.scaleY =
			_minutes.scaleX =
			_minutes.scaleY =
			_seconds.scaleX =
			_seconds.scaleY = Math.max(0.7, Math.min(1, stage.stageWidth / 768, stage.stageHeight / 768));
			
			_minutes.x = _seconds.x = _hours.x 	 = stage.stageWidth / 2;
			_hours.y   = _minutes.y = _seconds.y = stage.stageHeight / 2;
			
			if (stage.stageWidth < 768) {
				if (stage.stageWidth > stage.stageHeight) _hours.y = _minutes.y = _seconds.y = stage.stageHeight;
			}
		}
		
		private function update(e:Event):void {
			
			const d	:Date = new Date();
			const h	:uint = uint(d.getHours());
			const m	:uint = uint(d.getMinutes());
			const s	:uint = uint(d.getSeconds());
			
			_changed = HOUR | MINUTE | SECOND;
			
			if (_lastH != h) _lastH = h;
			else _changed &= ~HOUR;
			
			if (_lastM != m) _lastM = m;
			else _changed &= ~MINUTE;
			
			if (_lastS != s) _lastS = s;
			else _changed &= ~SECOND;
			
			if (_changed != 0) drawTime(h, m, s);
		}
		
		private function drawTime(hours:uint, mins:uint, secs:uint):void {
			
			var i:int;
			if(_changed & HOUR){
				i 	  = -1;
				hours = hours > 11 ? hours - 12 : hours;
				while (++i < 12) {
					if (i <= hours) _hourShapes[i].activate();
					else _hourShapes[i].deactivate(_firstrun?0:(i/12)*750);
				}
				
				if (hours == 0) i = 360;
				else if (hours < 6) i = -hours * 30;
				else i = 360 - hours * 30;
				if (hours == 6) i = -181;
				TweenLite.to(_hours, 1, {rotation:i, ease:Expo.easeInOut} );
			}
			
			if(_changed & MINUTE){
				i 	= -1;
				while (++i < 60) {
					if (i <= mins) _minuteShapes[i].activate();
					else _minuteShapes[i].deactivate(_firstrun?0:(i/60)*750);
				}
				
				if (mins == 0) i = 360;
				else if (mins < 30) i = -mins * 6;
				else i = 360 - mins * 6;
				if (mins == 30) i = -181;
				TweenLite.to(_minutes, 1, {rotation:i, ease:Expo.easeInOut} );
			}
			
			if (_changed & SECOND) {
				i = -1;
				while (++i < 60) {
					if (i <= secs) _secondShapes[i].activate();
					else _secondShapes[i].deactivate(_firstrun?0:(i/60)*750);
				}
				
				if (secs == 0) i = 360;
				else if (secs < 30) i = -secs * 6;
				else i = 360 - secs * 6;
				if (secs == 30) i = -181;
				
				TweenLite.to(_seconds, secs == 0 ? 1 : 0.425, { rotation:i, ease:secs == 0 ? Expo.easeIn : Back.easeOut } );
			}
			
			_firstrun = false;
		}
		
		
		private function getShapes(container:DisplayObjectContainer, radius:Number, count:uint, size:Number, pad:int, round:Boolean, colourRange:Vector.<uint>):Vector.<BitShape> {
			const out	:Vector.<BitShape> = new Vector.<BitShape>(count, true);
			var i		:int = -1;
			
			const step	:Number =  Math.PI * 2 / count;
			var angle	:Number;
			var s		:BitShape;
			
			while (++i < count) {
				s 			= new BitShape(container, i, colourRange[i], size, pad, round);
				angle 		= step * i - Math.PI / 2;
				s.x 		= Math.cos( angle ) * radius;
				s.y 		= Math.sin( angle ) * radius;
				s.rotation 	= (angle * 180 / Math.PI) + (_inverted ? 90 : -90);
				out[i] 		= s;
			}
			
			return out;
		}
		
		private static function getHueRange(start:uint, size:uint, hueRange:Number=1):Vector.<uint> {
			const out	:Vector.<uint> = new Vector.<uint>(size, true);
			var i		:int = -1;
			while (++i < size) out[i] = hsl(start, hueRange * (i / size));
			return out;
		}
		
		public static function hsl(colour:uint, hue:Number = 0, sat:Number = 1.0, lum:Number = 1.0):uint {
			
			var r:Number = Number((colour >> 16) & 0xFF) / 0xFF;
			var g:Number = Number((colour >> 8)  & 0xFF) / 0xFF;
			var b:Number = Number(colour & 0xFF) / 0xFF;
			
			const Cmax:Number = Math.max(r, Math.max(g, b));
			const Cmin:Number = Math.min(r, Math.min(g, b));
			
			var D:Number;
			var H:Number;
			var S:Number;
			var L:Number = (Cmax + Cmin) / 2.0;
			
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
			var var_1:Number;
			var var_2:Number;
			
			if (S == 0.0){
				r = g = b = L;
			} else {
				if ( L < 0.5 ) var_2 = L * ( 1.0 + S );
				else var_2 = ( L + S ) - ( S * L );
				
				var_1 = 2.0 * L - var_2;
			
				var vH:Number;
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
			
			return (uint(r * 0xFF) << 16) | (uint(g * 0xFF) << 8) | uint(b * 0xFF);
		}
	}
}


import flash.display.DisplayObjectContainer;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.utils.Timer;
import uk.co.mikedotalmond.labs.binaryclock.BinaryClock;

internal final class BitShape extends Shape {
	
	private var _timer	:Timer;
	private var _active	:Boolean;
	
	public function BitShape(container:DisplayObjectContainer, value:uint, colour:uint, size:Number=8, pad:uint=10, doRound:Boolean=false):void {
		if (colour == 0 || value == 60) return;
		
		container.addChild(this);
		alpha 		= 0.15;
		_active 	= false;
		_timer 		= new Timer(100,1);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, doDeactivate, false, 0, true);
		drawBits(graphics, size, pad, colour, value, doRound);
		
		// The all-important cacheAsBitmapMatrix for mobile devices (Air 2.6+)
		CONFIG::mobile {
			cacheAsBitmapMatrix = new Matrix();
			cacheAsBitmap 		= true;
		}
		
		activate();
		deactivate();
	}
	
	public function activate():void {
		if (!_active) {
			alpha 	= 1;
			_active = true;
		}
	}
	
	public function deactivate(delay:Number = 0):void {
		if (!parent || !_active) return;
		if (delay > 0) {
			_timer.reset();
			_timer.delay = delay;
			_timer.start();
		} else {
			doDeactivate();
		}
	}
	
	private function doDeactivate(e:Event = null):void {
		alpha 	= 0.150;
		_active = false;
	}
	
	private static function drawBits(g:Graphics, size:Number = 8, pad:int = 10, colour:uint = 0xFF0000, value:uint = 59, doRound:Boolean=false):void {
		
		const m:Matrix = new Matrix();
		m.createGradientBox(size, size, 0, 0, 0);
		g.beginGradientFill( GradientType.LINEAR,
							[BinaryClock.hsl(colour, 1 / 30), colour],
							[1, 1],
							[0, 0xFF],
							m );

		const half	:Number 	= (size / 2);
		const round	:Number 	= doRound ? int(size / 4) : 0;
		const d		:Function 	= g.drawRoundRect;
		var a		:int 		= 0;
		
		value & 0x01 ? d( -half, a, size, size, round): void; // 1
		a -= pad;
		value & 0x02 ? d( -half / 2, a, size / 2, size, int(round/2)): void; // 2
		a -= pad;
		value & 0x04 ? d( -half / 4, a, size / 4, size/1.125, int(round/4)): void; // 4
		a -= pad/1.25;
		value & 0x08 ? d( -half / 8, a, size / 8, size/1.25, 0): void; // 8
		a -= pad/1.5;
		value & 0x10 ? d( -half / 16, a, size / 16, size/1.5, 0): void; // 16
		a -= pad/1.75;
		value & 0x20 ? d( -half / 16, a, size / 16, size/2, 0): void; // 32
		g.endFill();
	}
}