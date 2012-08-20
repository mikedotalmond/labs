/*
Binary Clock - Haxe NME

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

package mikedotalmond.binaryclock.view;

import mikedotalmond.binaryclock.colour.Colour;
import nme.display.DisplayObjectContainer;
import nme.display.GradientType;
import nme.display.Graphics;
import nme.display.Shape;
import nme.events.Event;
import nme.events.TimerEvent;
import nme.geom.Matrix;
import nme.utils.Timer;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */


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
		
		alpha 		= 0.15;
		_active 	= false;
		_timer 		= new Timer(100,1);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, doDeactivate);
		drawBits(graphics, size, pad, colour, value, doRound);
		container.addChild(this);
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
							[Colour.adjustHSL(colour, 1 / 30), colour],
							[1, 1],
							[0, 0xFF],
							m );

		var half	:Float 	= size / 2.0;
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