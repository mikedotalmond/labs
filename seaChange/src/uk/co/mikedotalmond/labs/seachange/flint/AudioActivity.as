package uk.co.mikedotalmond.labs.seachange.flint {
	
	import flash.utils.getTimer;
	import org.flintparticles.common.activities.FrameUpdatable;
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.threeD.particles.Particle3D;
	import uk.co.mikedotalmond.labs.seachange.audio.AudioAnalysis;
	import uk.co.mikedotalmond.labs.seachange.audio.BeatDetect;
	
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