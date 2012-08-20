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

package;

import com.eclecticdesignstudio.motion.Actuate;
import mikedotalmond.binaryclock.model.ClockTimer;
import mikedotalmond.binaryclock.model.Digit;
import mikedotalmond.binaryclock.model.Time;
import mikedotalmond.binaryclock.view.BinaryClock;
import nme.system.System;

import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageQuality;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.Lib;
import nme.ui.Multitouch;
import nme.ui.MultitouchInputMode;


/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Main extends Sprite {
	
	// framerate
	static public inline var FRAMERATE_ACTIVE	:Int = 60;
	static public inline var FRAMERATE_IDLE		:Int = 30;
	
	private var clock		:BinaryClock;
	private var clockTimer	:ClockTimer;
	
	public function new() {
		super();
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
		#end
	}
	
	private function init(e:Event):Void {
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		stage.addEventListener(Event.ACTIVATE, onActivate);
		
		clock 		= new BinaryClock(onClockAnimateChange);
		clockTimer 	= new ClockTimer(onTimeChange);
		
		addChild(clock);
		clockTimer.activate();
		onResize(null);
	}
	
	private function onClockAnimateChange(animating:Bool):Void {
		stage.frameRate = animating ? FRAMERATE_ACTIVE : FRAMERATE_IDLE;
	}
	
	
	/**
	 * 
	 * @param	e
	 */
	private function onResize(e:Event):Void {
		
		var w:Int = stage.stageWidth;
		var h:Int = stage.stageHeight;
		
		clock.x = w / 2;
		clock.y = h / 2;
	}
	
	
	/**
	 * 
	 * @param	e
	 */
	public function onActivate(e:Event):Void {
		Actuate.reset();
		clock.activate();
		stage.frameRate = FRAMERATE_ACTIVE;
	}
	
	
	/**
	 * 
	 * @param	e
	 */
	public function onDeactivate(e:Event):Void {
		stage.frameRate = FRAMERATE_IDLE;
		clock.deactivate();
		Actuate.reset();
		System.gc();
	}
	
	
	/**
	 * 
	 * @param	time
	 */
	private function onTimeChange(time:Time):Void {
		clock.update(time);
	}
	
	static public function main() {
		
		var stage 				= Lib.current.stage;
		stage.scaleMode 		= nme.display.StageScaleMode.NO_SCALE;
		stage.align 			= nme.display.StageAlign.TOP_LEFT;
		stage.quality 			= StageQuality.HIGH;
		Multitouch.inputMode 	= MultitouchInputMode.TOUCH_POINT;
		
		Lib.current.addChild(new Main());
	}
}