/*Copyright (c) 2011 Mike Almond

Permission is hereby granted, free of charge, to any person 
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, .modify,
merge, publish, distribute, sublicense, and/or sell copies of 
the Software, and to permit persons to whom the Software 
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.*/

package mikedotalmond.labs.seachange.audio {
	
	import flash.display.Graphics;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	/*
	 *  Copyright (c) 2007 - 2008 by Damien Di Fede <ddf@compartmental.net>
	 *
	 *   This program is free software; you can redistribute it and/or modify
	 *   it under the terms of the GNU Library General Public License as published
	 *   by the Free Software Foundation; either version 2 of the License, or
	 *   (at your option) any later version.
	 *
	 *   This program is distributed in the hope that it will be useful,
	 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
	 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 *   GNU Library General Public License for more details.
	 *
	 *   You should have received a copy of the GNU Library General Public
	 *   License along with this program; if not, write to the Free Software
	 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
	 */

	/**
	 * The BeatDetect class allows you to analyze an audio stream for beats
	 * (rhythmic onsets). <a
	 * href="http://www.gamedev.net/reference/programming/features/beatdetection">Beat
	 * Detection Algorithms</a> by Fr�d�ric Patin describes beats in the following
	 * way: <blockquote> The human listening system determines the rhythm of music
	 * by detecting a pseudo � periodical succession of beats. The signal which is
	 * intercepted by the ear contains a certain energy, this energy is converted
	 * into an electrical signal which the brain interprets. Obviously, The more
	 * energy the sound transports, the louder the sound will seem. But a sound will
	 * be heard as a <em>beat</em> only if his energy is largely superior to the
	 * sound's energy history, that is to say if the brain detects a
	 * <em>brutal variation 
	 *   in sound energy</em>. Therefore if the ear intercepts
	 * a monotonous sound with sometimes big energy peaks it will detect beats,
	 * however, if you play a continuous loud sound you will not perceive any beats.
	 * Thus, the beats are big variations of sound energy. </blockquote> In fact,
	 * the two algorithms in this class are based on two algorithms described in
	 * that paper.
	 * <p>
	 * To use this class, inside of <code>draw()</code> you must first call
	 * <code>detect()</code>, passing the <code>AudioBuffer</code> you want to
	 * analyze. You may then use the <code>isXXX</code> functions to find out what
	 * beats have occurred in that frame. For example, you might use
	 * <code>isKick()</code> to cause a circle to pulse.
	 * <p>
	 * BeatDetect has two modes: sound energy tracking and frequency energy
	 * tracking. In sound energy mode, the level of the buffer, as returned by
	 * <code>level()</code>, is used as the instant energy in each frame. Beats,
	 * then, are spikes in this value, relative to the previous one second of sound.
	 * In frequency energy mode, the same process is used but instead of tracking
	 * the level of the buffer, an FFT is used to obtain a spectrum, which is then
	 * divided into average bands using <code>logAverages()</code>, and each of
	 * these bands is tracked individually. The result is that it is possible to
	 * track sounds that occur in different parts of the frequency spectrum
	 * independently (like the kick drum and snare drum).
	 * <p>
	 * In sound energy mode you use <code>isOnset()</code> to query the algorithm
	 * and in frequency energy mode you use <code>isOnset(int i)</code>,
	 * <code>isKick()</code>, <code>isSnare()</code>, and
	 * <code>isRange()</code> to query particular frequnecy bands or ranges of
	 * frequency bands. It should be noted that <code>isKick()</code>,
	 * <code>isSnare()</code>, and <code>isHat()</code> merely call
	 * <code>isRange()</code> with values determined by testing the algorithm
	 * against music with a heavy beat and they may not be appropriate for all kinds
	 * of music. If you find they are performing poorly with your music, you should
	 * use <code>isRange()</code> directly to locate the bands that provide the
	 * most meaningful information for you.
	 * 
	 * @author Damien Di Fede
	 * 
	 */
	
	/**
	 * AS3 port by @mikedotalmond
	 * Only ported sound energy detection, freq energy not implemented. 
	 */
	public final class BeatDetect {
		
		private var	sampleRate		:int;
		private var	timeSize		:int;
		private var	valCnt			:int;
		private var	valGraph		:Vector.<Number>;
		private var	sensitivity		:int;
		
		private var	insertAt		:int;
		
		private var	_isOnset		:Boolean;
		private var	_averageDt		:Number = 0.0;
		private var	dtBuffer		:Vector.<int>;
		private var	eBuffer			:Vector.<Number>;
		private var	dBuffer			:Vector.<Number>;
		private var	timer			:Number;
		
		private var varGraph		:Vector.<Number>;
		private var	varCnt			:int;
		private var _intensity		:Number = 0;
		public var 	isAverageBeat	:Boolean;
		private var _lastAverageBeat:int;
		
		public var numAvg			:uint;

		/**
		 * @param timeSize
		 *           the size of the buffer
		 * @param sampleRate
		 *           the sample rate of the samples in the buffer
		 */
		public function BeatDetect(timeSize:uint = 2048, sampleRate:Number = 44100) {
			sensitivity 	= 5;
			this.sampleRate = int(sampleRate);
			this.timeSize 	= timeSize;
			this.initSEResources();
			this.initGraphs();
		}

		private function initGraphs():void {
			valCnt   = varCnt = 0;
			valGraph = new Vector.<Number>(512, true); // 512
			varGraph = new Vector.<Number>(512, true); // 512
		}
		
		private function initSEResources():void {
			_isOnset = false;
			
			var n:int = int(sampleRate / timeSize);
			
			dtBuffer = new Vector.<int>(n, true);
			eBuffer = new Vector.<Number>(n, true);
			dBuffer = new Vector.<Number>(n, true);
			
			while (--n > -1) {
				dtBuffer[n] = 0;
				eBuffer[n] = 0.0;
				dBuffer[n] = 0.0;
			}
			
			timer 	= getTimer();
			insertAt = 0;
		}
		
		/**
		 * Analyze the samples in <code>buffer</code>. This is a cumulative
		 * process, so you must call this function every frame.
		 * 
		 * @param buffer
		 *           the buffer to analyze
		 */
		public function detect(samples:ByteArray):void {
			// compute the energy level
			var level:Number = 0;
			var value:Number;
			var i:int = -1;
			samples.position = 0;
			while (++i<2048) {
				value = (samples.readFloat() + samples.readFloat()) * 0.5;
				level += (value * value);
			}
			
			level 				= Math.sqrt(level/2048);
			var instant:Number 	= level * 100;
			
			// compute the average local energy
			var E:Number = average(eBuffer);
			// compute the variance of the energies in eBuffer
			var V:Number = variance(eBuffer, E);
			// compute C using a linear digression of C with V
			var C:Number = (-0.0025714 * V) + 1.5142857;
			// filter negaive values
			var diff:Number = Math.max(instant - C * E, 0);
			pushVal(diff);
			// find the average of only the positive values in dBuffer
			var dAvg:Number = specAverage(dBuffer);
			// filter negative values
			var diff2:Number = Math.max(diff - dAvg, 0);
			pushVar(diff2);
			// report false if it's been less than 'sensitivity'
			// milliseconds since the last true value
			const clock:int = getTimer();
			const dt:int = clock - timer;
			if (dt < sensitivity) {
				_isOnset = false;
				_intensity = 0;
			}
			// if we've made it this far then we're allowed to set a new
			// value, so set it true if it deserves to be, restart the timer
			else if (diff2 > 0 && instant > 2) {
				_isOnset = true;
				_intensity = diff2;
				timer = clock;
				dtBuffer[insertAt] = dt;
				_averageDt = i_average(dtBuffer);
			} else {
				_isOnset = false;
				_intensity = 0;
			}
			
			if (clock - _lastAverageBeat >= _averageDt) {
				isAverageBeat 	 = true;
				_lastAverageBeat = clock;
			}
			
			eBuffer[insertAt] = instant;
			dBuffer[insertAt] = diff;
			insertAt++;
			if (insertAt == eBuffer.length) insertAt = 0;
		}

		public function get isOnset():Boolean { return _isOnset; }
		
		public function get averageDt():Number {
			return _averageDt;
		}
		
		public function get intensity():Number {
			return _intensity;
		}

		/**
		 * Sets the sensitivity of the algorithm. After a beat has been detected, the
		 * algorithm will wait for <code>s</code> milliseconds before allowing
		 * another beat to be reported. You can use this to dampen the algorithm if
		 * it is giving too many false-positives. The default value is 10, which is
		 * essentially no damping. If you try to set the sensitivity to a negative
		 * value, an error will be reported and it will be set to 10 instead.
		 * 
		 * @param s
		 *           the sensitivity in milliseconds
		 */
		public function setSensitivity(s:int):void {
			if (s < 0) {
				sensitivity = 10;
			} else {
				sensitivity = s;
			}
		}

		/**
		 * DrawDraws some debugging visuals in the passed PApplet. The visuals drawn when
		 * in frequency energy mode are a good way to determine what values to use
		 * with <code>inRange()</code> if the provided drum detecting functions
		 * aren't what you need or aren't working well.
		 * 
		 * @param p
		 *           the PApplet to draw in
		 */
		public function drawGraph(g:Graphics, height:int):void {
			var i:int = 0;
			g.clear();
			g.lineStyle(1, 0xff0000);
			// draw valGraph
			for (i = 0; i < valCnt; i++) {
				g.moveTo(i, (height >> 1) - valGraph[i]);
				g.lineTo(i, (height >> 1) + valGraph[i]);
			}
			g.lineStyle(1, 0xff00ff);
			// draw varGraph
			for (i = 0; i < varCnt - 1; i++) {
				g.moveTo(i, height + varGraph[i]);
				g.lineTo(i + 1, height + varGraph[i + 1]);
			}
		}
		
		private function pushVal(v:Number):void {
			if (valCnt == valGraph.length) {
				valCnt   = 0;
			}
			valGraph[valCnt] = v;
			valCnt++;
		}

		private function pushVar(v:Number):void {
			if (varCnt == varGraph.length) {
				varCnt 		= 0;
			}
			varGraph[varCnt] = v;
			varCnt++;
		}
		
		
		private static function i_average(arr:Vector.<int>):Number {
			var avg	:Number = 0;
			var n	:int 	= arr.length;
			while (--n > -1) avg += arr[n];
			return avg / Number(arr.length);
		}
		
		private static function average(arr:Vector.<Number>):Number {
			var avg	:Number = 0;
			var n	:int 	= arr.length;
			while (--n > -1) avg += arr[n];
			return avg / Number(arr.length);
		}

		private static function specAverage(arr:Vector.<Number>):Number {
			var avg	:Number = 0;
			var num	:int = 0;
			var n	:int = arr.length;
			
			while (--n > -1){
				if (arr[n] > 0) {
					avg += arr[n];
					num++;
				}
			}
			
			return (num > 0) ? avg / num : avg;
		}

		private static function variance(arr:Vector.<Number>, val:Number):Number {
			var V	:Number = 0;
			var n	:int = arr.length;
			while(--n > -1) {
				V += ((arr[n] - val) * (arr[n] - val));
			}
			
			return V / Number(arr.length);
		}
	}
}