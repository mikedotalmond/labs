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

package mikedotalmond.labs.seachange.flint {
	
	import flash.utils.getTimer;
	import org.flintparticles.common.activities.FrameUpdatable;
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.threeD.particles.Particle3D;
	import mikedotalmond.labs.seachange.audio.AudioAnalysis;
	import mikedotalmond.labs.seachange.audio.BeatDetect;
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	public final class AudioActivity implements FrameUpdatable {
		
		static public var AA:AudioAnalysis;
		
		/* INTERFACE org.flintparticles.common.activities.FrameUpdatable */
		public function frameUpdate(emitter:Emitter, time:Number):void {
			
			if (!AA.processed) return;
			
			const b	:BeatDetect = AA.beatDetect;
			var p	:Particle3D;
			var e	:Vector.<Particle> = emitter.particles;
			var i	:int = e.length;
			
			var beatIntensity	:Number = b.intensity * 32;
			var spect			:Vector.<Number> = AA.bands;
			var nSpect			:int = spect.length;
			var j				:int = 1;
			
			while (--i > -1) {
				p = e[i] as Particle3D;
				p.velocity.z += (0.1 + (spect[j] * -1500) - p.velocity.z) * 0.1;
				//p.position.y += ((p.position.y < 0 ? spect[j] * 500 : -spect[j] * 500) - p.position.y) * 0.2;
				
				if (b.isOnset) {
					if (p.position.y < 0) {
						p.velocity.y -= ((p.position.y < beatIntensity * 8 ? beatIntensity : -beatIntensity) - p.velocity.y) * 0.1;
					} else {
						p.velocity.y -= ((p.position.y < -beatIntensity * 8 ? beatIntensity : -beatIntensity) - p.velocity.y) * 0.1;
					}
				}
				
				if (++j == nSpect) j = 1;
			}
		}
	}
}