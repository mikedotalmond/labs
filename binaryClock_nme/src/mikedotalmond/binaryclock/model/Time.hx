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

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Time {
	
	public var year			:Digit;
	public var month		:Digit;
	public var date			:Digit;
	public var hour			:Digit;
	public var minute		:Digit;
	public var second		:Digit;
	
	public function new() {
		year 		= new Digit();
		month 		= new Digit();
		date 		= new Digit();
		hour 		= new Digit();
		minute 		= new Digit();
		second 		= new Digit();
	}
	
	public function update(d:Date):Time {
		year.value 			= d.getFullYear();
		month.value 		= d.getMonth();
		date.value 			= d.getDate() -1;
		hour.value 			= d.getHours();
		minute.value 		= d.getMinutes();
		second.value 		= d.getSeconds();
		return this;
	}
	
	public var changed(get_changed, never):Bool;
	private function get_changed():Bool {
		return second.changed || minute.changed || hour.changed || date.changed || month.changed || year.changed;
	}
}