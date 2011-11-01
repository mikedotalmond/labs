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

package uk.co.mikedotalmond.labs.cartest {
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	
	import Box2DAS.Collision.b2WorldManifold;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.Joints.b2DistanceJointDef;
	import Box2DAS.Dynamics.Joints.b2JointDef;
	import Box2DAS.Dynamics.Joints.b2RopeJointDef;
	import Box2DAS.Dynamics.StepEvent;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import uk.co.mikedotalmond.enum.KeyboardPlus;
	import uk.co.mikedotalmond.labs.cartest.car.CarBody;
	import uk.co.mikedotalmond.labs.cartest.shapes.Bounds;
	import wck.BodyShape;
	import wck.Joint;
	import wck.World;
	
	
	public final class CarTestWorld extends wck.World {
		
		public var car0				:CarBody;
		
		private var _worldBounds	:Bounds;
		private var _stage			:Stage;
		
		public function CarTestWorld() {
			super();
		}
		
		override public function get stage():Stage {
			if (!super.stage && _stage) return _stage;
			return super.stage;
		}
		
		override public function create():void {
			
			scrolling 	= true;
			focus 		= car0;
			_stage		= stage;
			
			super.create();
			
			timeStep 		= 1.0 / stage.frameRate;// 0.01;
			_worldBounds 	= new Bounds(this);
			
			KeyboardPlus.keyboardPlus.init(stage);
			
			/**
			 *
			 */
			stopListening(stage, Event.ENTER_FRAME, step); // defer enterframe-step listener until we've setup the world objects.
			stopListening(this, StepEvent.STEP, applyGravityToWorld); // no gravity... for now - perhaps add in radial or other (varying?) gravities later to simulate ramp / bowl areas
			stopListening(this, MouseEvent.MOUSE_DOWN, handleDragStart); // no dragging
			listenOnceWhileVisible(this, Event.ENTER_FRAME, initWorldObjects); // wait a frame and set up the world
			
			visible = false;
		}
		
		override public function updateScroll(e:Event = null):void {
			var tx:Number = x;
			var ty:Number = y;
			
			super.updateScroll(e);
			
			// ease
			tx = x = tx + ((x - tx) * 0.1);
			ty = y = ty + ((y - ty) * 0.1);
		}
		
		private function initWorldObjects(e:Event):void {
			// car phys is set up by now, so lets prepare some things before running...
			
			//car0.shell.reportBeginContact = true;
			//addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			
			// starting world
			dispatchEvent(new Event("initWorld"));
		}
		
		override public function step(e:Event = null):void {
			super.step(e);
			
			car0.update();
			//trace(car0.linearVelocityX, car0.linearVelocityY);
		}
		
		public function get worldBounds():Bounds { return _worldBounds; }
	}
}