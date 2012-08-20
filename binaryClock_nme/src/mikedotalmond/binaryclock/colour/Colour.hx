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

package mikedotalmond.binaryclock.colour;
import nme.Vector;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Colour {

	
	/**
	 * 
	 * @param	start
	 * @param	size
	 * @param	hueRange
	 * @return
	 */
	public static function getHueRange(start:Int, size:Int, hueRange:Float=1):Vector<Int> {
		var out	:Vector<Int> = new Vector<Int>();
		var i	:Int = -1;
		while (++i < size) out.push(Colour.adjustHSL(start, hueRange * (i / size)));
		return out;
	}
	
	/**
	 * 
	 * @param	colour
	 * @param	hue
	 * @param	sat
	 * @param	lum
	 * @return	rgb int
	 */
	public static function adjustHSL(colour:Int, hue:Float = 0, sat:Float = 1.0, lum:Float = 1.0):Int {
		
		var r:Float = cast((colour >> 16) & 0xFF, Float) / 0xFF;
		var g:Float = cast((colour >> 8)  & 0xFF, Float) / 0xFF;
		var b:Float = cast(colour & 0xFF, Float) / 0xFF;
		
		var Cmax:Float = Math.max(r, Math.max(g, b));
		var Cmin:Float = Math.min(r, Math.min(g, b));
		
		var D:Float;
		var H:Float;
		var S:Float;
		var L:Float = (Cmax + Cmin) / 2.0;
		
		// it's grey
		if (Cmax == Cmin){
			H = S = 0.0;
		} else {
			D = Cmax - Cmin;
			
			// calculate Saturation
			if (L < 0.5) S = D / (Cmax + Cmin);
			else S = D / (2.0 - (Cmax + Cmin));

			// calculate Hue
			if (r == Cmax){
				H = (g - b) / D;
			} else {
				if (g == Cmax) H = 2.0 + (b - r) / D;
				else H = 4.0 + (r - g) / D;
			}
			H = H / 6.0;
		}
	
		// modify H/S/L values
		H -= hue;
		S *= sat;
		L *= lum;
		
		if (H < 0.0) H += 1.0; else if (H > 1.0) H -= 1.0;
		if (S < 0.0) S += 1.0; else if (S > 1.0) S -= 1.0;
		if (L < 0.0) L += 1.0; else if (L > 1.0) L -= 1.0;
		
		// hsl to rgb...
		var var_1:Float;
		var var_2:Float;
		
		if (S == 0.0){
			r = g = b = L;
		} else {
			if ( L < 0.5 ) var_2 = L * ( 1.0 + S );
			else var_2 = ( L + S ) - ( S * L );
			
			var_1 = 2.0 * L - var_2;
		
			var vH:Float;
			vH = H + third;
			//hue to r...
			if ( vH < 0.0 ) vH += 1.0;
			if ( vH > 1.0 ) vH -= 1.0;
			if ( ( 6.0 * vH ) < 1.0 ) r = ( var_1 + ( var_2 - var_1 ) * 6.0 * vH );
			else if ( ( 2.0 * vH ) < 1.0 ) r = ( var_2 );
			else if ( ( 3.0 * vH ) < 2.0 ) r = ( var_1 + ( var_2 - var_1 ) * ( twoOverThree - vH ) * 6.0 );
			else r = var_1;
			
			vH = H;
			//hue to g...
			if ( vH < 0.0 ) vH += 1.0;
			if ( vH > 1.0 )	vH -= 1.0;
			if ( ( 6.0 * vH ) < 1.0 ) g = ( var_1 + ( var_2 - var_1 ) * 6.0 * vH );
			else if ( ( 2.0 * vH ) < 1.0 ) g = ( var_2 );
			else if ( ( 3.0 * vH ) < 2.0 ) g = ( var_1 + ( var_2 - var_1 ) * ( twoOverThree - vH ) * 6.0 );
			else g = var_1;
			
			vH = H - third;
			//hue to b
			if ( vH < 0.0 ) vH += 1.0;
			if ( vH > 1.0 ) vH -= 1.0;
			if ( ( 6.0 * vH ) < 1.0 ) b = ( var_1 + ( var_2 - var_1 ) * 6.0 * vH );
			else if ( ( 2.0 * vH ) < 1.0 ) b = ( var_2 );
			else if ( ( 3.0 * vH ) < 2.0 ) b = ( var_1 + ( var_2 - var_1 ) * ( twoOverThree - vH ) * 6.0 );
			else b = var_1;
		}
		
		return (Math.round(r * 0xFF) << 16) | (Math.round(g * 0xFF) << 8) | Math.round(b * 0xFF);
	}
	
	private static inline var twoOverThree	:Float =  2.0 / 3.0;
	private static inline var third			:Float =  1.0 / 3.0;
	
}