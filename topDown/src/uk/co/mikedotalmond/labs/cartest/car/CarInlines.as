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
	
	import apparat.inline.Macro;
	import apparat.math.FastMath;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.geom.Matrix;
	import wck.BodyShape;
	
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	
	public final class CarInlines extends Macro {
		
		// draw skid
		public static function drawSkid(g:Graphics, b:BodyShape, v:Number = 1, c:uint = 0x050506):void {
			
			//thickness
			b.t1 += 0.1 * (FastMath.max(15 * v, 5) - b.t1); // ease (fairly slowly) toward new r value
			
			//alpha
			b.a1 += 0.3 * (v - b.a1);
			
			g.lineStyle(b.t1, c, b.a1, true, "normal", CapsStyle.NONE);
			
			g.moveTo(b.x1, b.y1);
			b.x1 += 0.9 * ((b.parent.x + b.x) - b.x1);
			b.y1 += 0.9 * ((b.parent.y + b.y) - b.y1);
			g.lineTo(b.x1, b.y1);
		}
		
		/**
		 * This function applies a resistance in a direction orthogonal to the body's axis (stops bodies (like top-down wheels) sliding sideways)
		 *
		 * @param	targetBody				b2Body to modify
		 * @param	gripThreshold			above this threshold the body can start to loose orthagonal grip
		 * @param	gripStrength			how strong the grip is, after the threshold is passed
		 */
		public static function killOrthogonalVelocity(targetBody:b2Body, gripStrength:Number, velocity:V2, sidewaysAxis:V2, zero:V2):void {
			velocity 		= targetBody.GetLinearVelocityFromLocalPoint(zero);
			sidewaysAxis 	= targetBody.m_xf.R.col2.v2;
			sidewaysAxis.multiplyN(velocity.dot(sidewaysAxis)); // stop sideways slide
			
			// if gripStrength is not 1, allow some sideways slip - mix zero sideways grip with full grip, using gripStrength
			targetBody.SetLinearVelocity((gripStrength != 1.0) ? sidewaysAxis.multiplyN(gripStrength).add(velocity.multiplyN(1.0 - gripStrength)) : sidewaysAxis);
		}
	}
}