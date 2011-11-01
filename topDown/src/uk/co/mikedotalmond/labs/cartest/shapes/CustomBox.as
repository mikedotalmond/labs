/*
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

package uk.co.mikedotalmond.labs.cartest.shapes {
		
	/**
	 * ...
	 * @author Mike Almond
	 */

	import Box2DAS.Common.V2;

	import wck.BodyShape;

	public final class CustomBox extends BodyShape{
	
		private var _p:V2;
		private var _w:uint;
		private var _h:uint;
		private var _a:Number;
		
		public function CustomBox(x:int, y:int, w:uint, h:uint, a:Number):void {
			
			super();
			
			_p = new V2(x, y);
			_w = w;
			_h = h;
			_a = a;
			
			friction 	= 0.4;
			density 	= 0;
			type 		= "Static";
			
			graphics.beginFill(0xaa, 1);
			graphics.drawRect(_p.x - _w / 2, _p.y - _h / 2, _w, _h);
			graphics.endFill();
		}
		
		override public function shapes():void {
			box(_w, _h, _p, _a);
		}
	}
}