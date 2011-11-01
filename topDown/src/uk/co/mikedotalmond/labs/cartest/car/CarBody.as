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

package uk.co.mikedotalmond.labs.cartest.car {
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	
	import apparat.math.FastMath;
	import flash.display.Sprite;
	
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.Joints.b2RevoluteJoint;
	
	import flash.display.Graphics;
	import flash.display.MovieClip;
	
	import uk.co.mikedotalmond.enum.KeyboardPlus;
	
	import wck.BodyShape;
	
	public final class CarBody extends Sprite {
		
		// Stage objects
		public var shell:Box40;
		
		public var w0	:Box40;
		public var w1	:Box40;
		public var w2	:Box40;
		public var w3	:Box40;
		
		public var j0	:Joint1;
		public var j1	:Joint1;
		public var j2	:Joint1;
		public var j3	:Joint1;
		
		//
		private var _steerSpeed		:Number = 4.5;
		public function get steerSpeed():Number { return _steerSpeed; }
		public function set steerSpeed(value:Number):void { _steerSpeed = value; }
		
		private var _maxVelocity	:Number = 20;
		public function get maxVelocity():Number { return _maxVelocity; }
		public function set maxVelocity(value:Number):void { _maxVelocity = value; }
		
		private var _hBreakStrength	:Number = 1.5;
		public function get hBreakStrength():Number { return _hBreakStrength; }
		public function set hBreakStrength(value:Number):void { _hBreakStrength = value; }
		
		private var _engineSpeed	:Number = 0;
		public function get engineSpeed():Number { return _engineSpeed; }
		
		private var _steeringAngle	:Number = 0;
		public function get steeringAngle():Number { return _steeringAngle; }
		
		private var _drawSkidThreshold:Number = 0.2;
		public function get drawSkidThreshold():Number { return _drawSkidThreshold; }
		public function set drawSkidThreshold(value:Number):void { _drawSkidThreshold = value; }
		
		private var _skidColour:uint = 0x050506;
		public function get skidColour():uint { return _skidColour; }
		public function set skidColour(value:uint):void { _skidColour = value; }
		
		private var _linearVelocityX:Number;
		public function get linearVelocityX():Number { return _linearVelocityX; }
		
		private var _linearVelocityY:Number;
		public function get linearVelocityY():Number { return _linearVelocityY; }
		
		private var _skids			:Graphics;
		
		//reference to the key isDown function in KeyboardPlus - a fast lookup class
		private static const KID:Function = KeyboardPlus.isDown;
		
		private var _shell	:b2Body;
		private var _w0		:b2Body;
		private var _w1		:b2Body;
		private var _w2		:b2Body;
		private var _w3		:b2Body;
		private var _wj0	:b2RevoluteJoint;
		private var _wj1	:b2RevoluteJoint;
		private var _wj2	:b2RevoluteJoint;
		private var _wj3	:b2RevoluteJoint;
		
		public function CarBody():void {
			super();
		}
		
		public function prepare(skidDisplay:Graphics):void {
			
			mouseChildren	 = false;
			mouseEnabled	 = false;
			
			_skids			= skidDisplay;
			_shell	 		= shell.b2body;
			_w0 	 		= w0.b2body;
			_w1 	 		= w1.b2body;
			_w2 	 		= w2.b2body;
			_w3 	 		= w3.b2body;
			_wj0	   		= b2RevoluteJoint(j0.b2joint);
			_wj1	   		= b2RevoluteJoint(j1.b2joint);
			_wj2	   		= b2RevoluteJoint(j2.b2joint);
			_wj3 	 		= b2RevoluteJoint(j3.b2joint);
		}
		
		public function update():void {
			
			var hBreak		:Boolean = KID(KeyboardPlus.SPACE);
			var lv			:V2 	 = _shell.GetLinearVelocity();
			var lvm			:Number  = lv.length();
			
			// limit max speed (smooth)
			if (lvm > _maxVelocity) _shell.SetLinearVelocity(lv.multiplyN(_maxVelocity / lvm));
			else if(lvm < 0.05) _shell.SetLinearVelocity(lv.multiplyN(0));
			
			var llv			:V2 	= _shell.GetLocalVector(lv);
			var direction	:int 	= int(FastMath.sign(-llv.y));
			var aVelY		:Number	= -llv.y * direction;
			var aVelX		:Number	= FastMath.abs(llv.x);
			var moving		:Boolean = aVelY > 0.025;
			
			var vx0:Number = FastMath.abs(_w0.GetLocalVector(_w0.GetLinearVelocity()).x) / _maxVelocity;
			var vx1:Number = FastMath.abs(_w1.GetLocalVector(_w1.GetLinearVelocity()).x) / _maxVelocity;
			var vx2:Number = FastMath.abs(_w2.GetLocalVector(_w2.GetLinearVelocity()).x) / _maxVelocity;
			var vx3:Number = FastMath.abs(_w3.GetLocalVector(_w3.GetLinearVelocity()).x) / _maxVelocity;
			
			vx0 = vx0 < _drawSkidThreshold ? 0 : vx0;
			vx1 = vx1 < _drawSkidThreshold ? 0 : vx1;
			vx2 = vx2 < _drawSkidThreshold ? 0 : vx2;
			vx3 = vx3 < _drawSkidThreshold ? 0 : vx3;
			
			_linearVelocityY = -llv.y;
			_linearVelocityX = llv.x;
			
			var _gripRear			:Number = 0.60;// 55;
			var _gripRearHandBreak	:Number = 0.14;
			var _gripFront			:Number = 0.92;
		
			var rearGrip	:Number	= aVelY > 	(_maxVelocity * (hBreak ? _gripRearHandBreak : _gripRear)) ?
												(_maxVelocity * (hBreak ? _gripRearHandBreak : _gripRear)) / aVelY : 1;
												
			var frontGrip	:Number	= aVelY > 	(_maxVelocity * _gripFront) ? (_maxVelocity * _gripFront)  / aVelY : 1;
			
			// random jitter
			frontGrip += (0.20 * (Math.random() - 0.5));
			rearGrip  += (0.35 * (Math.random() - 0.5));
			
			// add sideways 'friction' on the wheels (at 90 degrees to direction of drive) so we go, mainly, in straight lines.
			// front grip reduces as speed increases - so steering is not too extreme, and we slide in a somewhat cool way :)
			// less grip on the rear, so we can slide a bit as speed increases. even less grip when the hand-break is applied
			var b:b2Body; var v0:V2 = new V2(); var v1:V2 = new V2(); var v2:V2 = new V2(); // some local vars for the inlines
			b = _w0; CarInlines.killOrthogonalVelocity(b, frontGrip, v0, v1, v2);
			b = _w1; CarInlines.killOrthogonalVelocity(b, frontGrip, v0, v1, v2);
			b = _w2; CarInlines.killOrthogonalVelocity(b, rearGrip, v0, v1, v2);
			b = _w3; CarInlines.killOrthogonalVelocity(b, rearGrip, v0, v1, v2);
			
			// random jitter
			_engineSpeed += (0.2 * (Math.random() - 0.5));
			
			//
			// get key inputs and ease toward the desired engine speed.
			if (KID(KeyboardPlus.UP) || KID(KeyboardPlus.W)) {
				_engineSpeed += 0.15 * (-_maxVelocity - _engineSpeed);
			}else if (KID(KeyboardPlus.DOWN) || KID(KeyboardPlus.S)) {
				_engineSpeed += 0.15 * ((_maxVelocity / 2.5) - _engineSpeed);
			} else {
				_engineSpeed *= 0.33;
			}
			
			if (FastMath.abs(_engineSpeed) < 0.05) _engineSpeed = 0;
			
			// Driving - FWD - apply the driving force
			_w0.ApplyForce(_w0.m_xf.R.col2.v2.multiplyN(_engineSpeed), _w0.GetPosition());
			_w1.ApplyForce(_w1.m_xf.R.col2.v2.multiplyN(_engineSpeed), _w1.GetPosition());
			
			// Hand break?
			if (hBreak && moving) { // apply a breaking force in the direction oposite to direction of travel...
				var hb		:Number = _hBreakStrength * direction;
				var hbJitter:Number = 0.2;
				_w2.ApplyForce(_w2.m_xf.R.col2.v2.multiplyN(hb+(hbJitter * (Math.random() - 0.5))), _w2.GetPosition());
				_w3.ApplyForce(_w3.m_xf.R.col2.v2.multiplyN(hb+(hbJitter * (Math.random() - 0.5))), _w3.GetPosition());
			}
			
			// Steering - FWS
			// udlr and wsad
			var a:Number = (KID(KeyboardPlus.LEFT) || KID(KeyboardPlus.A)) ? 1 : (KID(KeyboardPlus.RIGHT)|| KID(KeyboardPlus.D)) ? -1 : 0;
			if (a != 0) {
				a = _steeringAngle + 0.05 * (a - _steeringAngle);
				if (FastMath.abs(a) < 0.01) a = 0;
			}
			
			_steeringAngle = a;
			_wj0.SetMotorSpeed((_steeringAngle - _wj0.GetJointAngle()) * _steerSpeed); // left front wheel joint
			_wj1.SetMotorSpeed((_steeringAngle - _wj1.GetJointAngle()) * _steerSpeed); // right front wheel joint
			
			
			// Skidding?
			var bs	:BodyShape;
			var g	:Graphics 	= _skids;
			var c	:uint 		= _skidColour;
			
			//front left
			if (vx0 > 0) {
				_engineSpeed *= 0.98; // loose a bit of engine speed as we skid.
				bs = w0; CarInlines.drawSkid(g, bs, vx0, c); // draw skid
			} else {
				w0.x1 = x + w0.x; w0.y1 = y + w0.y; w0.t1 = 5; w0.a1 = 0.1; //reset skid values
			}
			//front right
			if (vx1 > 0) {
				_engineSpeed *= 0.98; // loose a bit of engine speed as we skid.
				bs = w1; CarInlines.drawSkid(g, bs, vx1, c); // draw skid
			} else {
				w1.x1 = x+w1.x; w1.y1 = y+w1.y; w1.t1 = 5; w1.a1 = 0.1; //reset skid values
			}
			//rear left
			if (hBreak || vx2 > 0) {
				_engineSpeed *= (hBreak) ? 0.98 : 0.96; // loose a bit of engine speed as we skid.
				vx2 = hBreak ? FastMath.max(vx2, 0.4) : vx2;
				bs 	= w2; CarInlines.drawSkid(g, bs, vx2, c); // draw skid
			} else {
				w2.x1 = x + w2.x; w2.y1 = y + w2.y; w2.t1 = 5; w2.a1 = 0.1;
			}
			//rear right
			if (hBreak || vx3 > 0) {
				_engineSpeed *= (hBreak) ? 0.98 : 0.96; // loose a bit of engine speed as we skid.
				vx3 = hBreak ? FastMath.max(vx3, 0.4) : vx3;
				bs 	= w3; CarInlines.drawSkid(g, bs, vx3, c); // draw skid
			} else {
				w3.x1 = x+w3.x; w3.y1 = y+w3.y; w3.t1 = 5; w3.a1 = 0.1;
			}
		}
	}
}