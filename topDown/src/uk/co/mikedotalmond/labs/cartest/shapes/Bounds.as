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
	
	import Box2DAS.Dynamics.b2Body;
	import flash.events.Event;
	import uk.co.mikedotalmond.labs.cartest.CarTest;
	import wck.BodyShape;
	import wck.World;
	
	public final class Bounds {
		
		private var _world	:wck.World;
		private var _left	:CustomBox;
		private var _right	:CustomBox;
		private var _top	:CustomBox;
		private var _bottom	:CustomBox;
		
		public function Bounds(world:wck.World):void {
			_world = world;
			_world.stage.addEventListener(Event.RESIZE, resize, false, 0, true);
			resize(null);
		}
		
		public function bodyIsBounds(b:b2Body):Boolean {
			return 	b == _left.b2body || 
					b == _right.b2body || 
					b == _top.b2body || 
					b == _bottom.b2body;
		}
		
		private function resize(e:Event):void {
			
			const w:uint = CarTest.WORLD_WIDTH;
			const h:uint = CarTest.WORLD_HEIGHT;
			
			if(_left)	{ _left.destroy(); _left.remove(); _left = null; }
			if(_right)	{ _right.destroy(); _right.remove(); _right = null; }
			if(_top)	{ _top.destroy(); _top.remove(); _top = null; }
			if(_bottom)	{ _bottom.destroy(); _bottom.remove(); _bottom = null; }
			
			const bw	:uint = 20;
			const hbw	:uint = 10;
			_world.addChild(_left 	= new CustomBox(-hbw, h / 2, bw, h, 0));
			_world.addChild(_right 	= new CustomBox(w+hbw, h / 2, bw, h, 0));
			_world.addChild(_top 	= new CustomBox(w/2, -hbw, w, bw, 0));
			_world.addChild(_bottom	= new CustomBox(w / 2, h + hbw, w, bw, 0));
			_left.visible = _right.visible = _top.visible = _bottom.visible = false;
		}
	}
}