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
package mikedotalmond.binaryclock.model;

import mikedotalmond.binaryclock.model.Time;

import nme.events.Event;
import nme.events.TimerEvent;
import nme.utils.Timer;
import nme.Vector;



/**
 * .
 * @author Mike Almond
 * 
 */
class ClockTimer {
	
	private var change	:Time->Void;
	private var timer	:Timer;
	private var time	:Time;
	
	/**
	 * 
	 * @param	?autoStart
	 * @param	?updateDelay, defaults to 40ms
	 */
	public function new(changeCallback:Time->Void, ?autoStart:Bool = false, ?updateInterval:Float = 20) {
		
		change 	= changeCallback;
		
		time 	= new Time();
		timer 	= new Timer(updateInterval);
		
		timer.addEventListener(TimerEvent.TIMER, update);
		
		if(autoStart) activate();
	}
	
	/**
	 * 
	 */
	public function activate():Void {
		timer.reset();
		timer.start();
	}
	
	/**
	 * 
	 */
	public function deactivate():Void {
		timer.stop();
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function update(e:TimerEvent):Void {
		if(time.update(Date.now()).changed) change(time);
	}
}