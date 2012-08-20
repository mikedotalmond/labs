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

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Back;
import com.eclecticdesignstudio.motion.easing.Expo;
import com.eclecticdesignstudio.motion.easing.Quad;

import mikedotalmond.binaryclock.colour.Colour;
import mikedotalmond.binaryclock.model.Time;

import nme.display.DisplayObjectContainer;
import nme.display.DisplayObject;
import nme.display.GradientType;
import nme.display.Graphics;
import nme.display.Shape;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.TimerEvent;
import nme.geom.Matrix;
import nme.system.System;
import nme.utils.Timer;
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
	
	private var animateChange	:Bool->Void;
	
	private var secondShapes	:Vector<BitShape>;
	private var minuteShapes	:Vector<BitShape>;
	private var hourShapes		:Vector<BitShape>;
	
	private var seconds			:Sprite;
	private var minutes			:Sprite;
	private var hours			:Sprite;
	private var firstrun		:Bool;
	private var activeTweens	:Int;
	
	public function new(onAnimateChange:Bool->Void) {
		super();
		activeTweens 	= 0;
		animateChange 	= onAnimateChange;
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	/**
	 * 
	 * @param	e
	 */
	public function init(e:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		visible 				= false;
		seconds 				= cast(addChild(new Sprite()), Sprite);
		minutes					= cast(addChild(new Sprite()), Sprite);
		hours					= cast(addChild(new Sprite()), Sprite);
		
		opaqueBackground 		= 0x000000;
		seconds.mouseEnabled 	= 
		minutes.mouseEnabled 	= 
		hours.mouseEnabled 		= false;
		seconds.mouseChildren 	=
		minutes.mouseChildren 	= 
		hours.mouseChildren 	= false;
		
		reset();
	}
	
	
	/**
	 * 
	 */
	private function reset():Void {
		
		while (seconds.numChildren > 0) seconds.removeChildAt(0);
		while (minutes.numChildren > 0) minutes.removeChildAt(0);
		while (hours.numChildren > 0) hours.removeChildAt(0);
		
		secondShapes 	= getBitShapes(seconds, 200, 60, 22, -32, true, Colour.getHueRange(Colour.adjustHSL(0xFf0000), 60));
		minuteShapes 	= getBitShapes(minutes, 80, 60, 11, -22, false, Colour.getHueRange(Colour.adjustHSL(0xFf0000, 0, 0.66, 0.66), 60));
		hourShapes 		= getBitShapes(hours, 12, 12, 10, -12, false, Colour.getHueRange(Colour.adjustHSL(0xFf0000, 0, 0.33, 0.30), 12));
		
		minutes.cacheAsBitmap = true;
		hours.cacheAsBitmap = true;
		
		activate();
	}
	
	/**
	 * 
	 * @param	e
	 */
	public function activate():Void {
		alpha 			= 0;
		visible 		=
		firstrun		= true;
		Actuate.tween(this, 3, { alpha:1 } ).ease(Quad.easeIn);
	}
	
	/**
	 * 
	 * @param	e
	 */
	public function deactivate():Void {
		visible = false;
	}
	
	/**
	 * 
	 * @param	time
	 */
	public function update(time:Time):Void {
		
		var i:Int;
		var val:Int;		
		
		if(time.hour.changed){
			i 	  	= -1;
			val 	= time.hour.value > 11 ? time.hour.value - 12 : time.hour.value;
			while (++i < 12) {
				if (i <= val) hourShapes[i].activate();
				else hourShapes[i].deactivate(firstrun?0:(i/12)*750);
			}
			
			
			#if !flash
			i = -val * 30;
			#else
			if (val < 6) i = -val * 30;
			else if (val == 6 ) i = -181;
			else i = 360 - val * 30;
			#end
			if (firstrun) {
				hours.rotation = i;
			} else {
				onTweenStart(null);
				Actuate.tween(hours, 1.5, { rotation:i } ).ease(Expo.easeIn).onComplete(onTweenComplete, [null]);
			}
			
		}
		
		if(time.minute.changed){
			i 	= -1;
			val = time.minute.value;
			while (++i < 60) {
				if (i <= val) minuteShapes[i].activate();
				else minuteShapes[i].deactivate(firstrun?0:(i / 60) * 750);
			}
			
			#if !flash
			i = -val * 6;
			#else
			if (val < 30) i = -val * 6;
			else if (val == 30 ) i = -181;
			else i = 360 - val * 6;
			#end
			if (firstrun) {
				minutes.rotation = i;
			} else {
				onTweenStart(null);
				Actuate.tween(minutes, 1, { rotation:i } ).ease(Expo.easeIn).onComplete(onTweenComplete, [null]);
			}
		}
		
		if (time.second.changed) {
			i = -1;
			val = time.second.value;
			while (++i < 60) {
				if (i <= val) secondShapes[i].activate();
				else secondShapes[i].deactivate(firstrun?0:(i / 60) * 750);
			}
			
			#if !flash
			i = -val * 6;
			#else
			if (val < 30) i = -val * 6;
			else if (val == 30 ) i = -181;
			else i = 360 - val * 6;
			#end
			
			if (firstrun) {
				seconds.rotation = i;
				onTweenComplete(seconds);				
			} else {
				onTweenStart(seconds);
				Actuate.tween(seconds, val == 0 ? 1 : 0.425, { rotation:i } ).ease(val == 0 ? Expo.easeIn : Back.easeOut).onComplete(onTweenComplete, [seconds]);
			}
		}
		
		firstrun = false;
	}
	
	/**
	 * 
	 * @param	target
	 */
	private function onTweenStart(target:DisplayObject=null) {
		if (activeTweens == 0) animateChange(true);
		if(target != null) target.cacheAsBitmap = false;
		activeTweens++;
	}
	
	/**
	 * 
	 * @param	target
	 */
	private function onTweenComplete(target:DisplayObject):Void {
		activeTweens -= activeTweens == 0 ? 0 : 1;
		if(target != null) target.cacheAsBitmap = true;
		if (activeTweens == 0) animateChange(false);		
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
	private static function getBitShapes(container:DisplayObjectContainer, radius:Float, count:Int, size:Float, pad:Int, round:Bool, colourRange:Vector<Int>):Vector<BitShape> {
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
			s.rotation 	= (angle * 180 / Math.PI) + -90;
			out.push(s);
		}
		
		return out;
	}
	
	
}