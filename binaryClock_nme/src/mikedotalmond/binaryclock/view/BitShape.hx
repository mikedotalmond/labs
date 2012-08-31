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

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Rectangle;
import mikedotalmond.binaryclock.utils.Colour;
import nme.display.DisplayObjectContainer;
import nme.display.StageQuality;
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


class BitShape extends Bitmap {
	
	private var _shape	:Shape;
	private var _matrix	:Matrix;
	
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
	public function new(container:DisplayObjectContainer, value:Int, colour:Int, size:Float=8, pad:Int=10):Void {
		super(null);
		
		if (colour == 0 || value == 60 || value == 0) return;
		
		_shape		= new Shape();
		_matrix 	= new Matrix();
		
		alpha 		= 0.1;
		_active 	= false;
		_timer 		= new Timer(100,1);
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, doDeactivate);
		
		drawBits(size, pad, colour, value);
		
		if (bitmapData != null) {
			smoothing = true;
			container.addChild(this);
		}
		
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
		alpha 	= 0.1;
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
	private function drawBits(size:Float = 8, pad:Int = 10, colour:Int = 0xFF0000, value:Int = 59):Void {
		
		var g:Graphics 	= _shape.graphics;
		var m:Matrix 	= _matrix;
		m.createGradientBox(size, size, 0, 0, 0);
		
		g.clear();
		g.beginGradientFill( GradientType.LINEAR,
							[Colour.adjustHSL(colour, 1 / 30), colour],
							[1, 1],
							[0, 0xFF],
							m );
		//g.beginFill(colour);
		
		var half	:Float 	= size / 2.0;
		var a		:Float 	= 0;
		var bitCount:Float 	= 0;
		
		if (value & 0x01 != 0) {
			g.drawRect( -half, a, size, size); bitCount = 1; // 1
		}
		
		a -= pad;
		if (value & 0x02 != 0)  {
			g.drawRect( -half / 2, a, size / 2, size); bitCount = 2;// 2
		}
		
		a -= pad;
		if (value & 0x04 != 0) {
			g.drawRect( -half / 4, a, size / 4, size / 1.125); bitCount = 3;// 4
		}
		
		a -= pad/1.25;
		if (value & 0x08 != 0)  {
			g.drawRect( -half / 8, a, size / 8, size / 1.25); bitCount = 4;// 8
		}
		
		a -= pad/1.5;
		if (value & 0x10 != 0) {
			g.drawRect( -half / 16, a, size / 16, size / 1.5); bitCount = 5;// 16
		}
		
		a -= pad/1.75;
		if (value & 0x20 != 0) {
			g.drawRect( -half / 16, a, size / 16, size / 2); bitCount = 6;// 32
		}
		
		g.endFill();
		
		m.identity();
		m.tx = half;
		
		var bd:BitmapData = new BitmapData(Std.int(size), Std.int(bitCount * size + size), true, 0);
		bd.draw(_shape, m, null, null, null, false);
		
		this.bitmapData = bd;
	}
}