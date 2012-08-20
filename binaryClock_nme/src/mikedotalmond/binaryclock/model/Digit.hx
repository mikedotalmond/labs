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

class Digit {
	
	private var _changed:Bool;
	private var _value	:Int;
	
	public function new() {
		reset();
	}
	
	public function reset() {
		_changed 	= false;
		_value 		= -1;
	}	
	
	public var changed(get_changed, never):Bool;
	private function get_changed() { return _changed; }
	
	public var value(get_value, set_value):Int;
	private function get_value():Int { return _value; }
	private function set_value(value:Int):Int {
		_changed = _value != value;
		return _value = value;
	}	
}