package Box2DAS.Dynamics.Joints {
	import Box2DAS.Common.b2Vec2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2World;
	import flash.events.IEventDispatcher;

	public class ConstantVolumeJoint extends b2Joint {
		
		internal var bodies			:Vector.<b2Body>;// Body[] ;
		internal var targetLengths	:Vector.<Number>;// float[] ;
		internal var targetVolume	:Number;
		//float relaxationFactor;//1.0 is perfectly stiff (but doesn't work, unstable)
		
		internal var normals		:Vector.<b2Vec2>;// Body[] ;
		
		private var m_impulse		:Number = 0.0;
		
		internal var distanceJoints	:Vector.<b2DistanceJoint>;// DistanceJoint[] distanceJoints;
		
		public function getBodies():Vector.<b2Body> {
			return bodies;
		}
		
		public function inflate(factor:Number):void {
			targetVolume *= factor;
		}
		
		// djm this is not a hot method, so no pool. no one wants
		// to swim when it's cold out.  except when you have a hot
		// tub.....then its amazing.....hmmmm......
		public function ConstantVolumeJoint(w:b2World, d:ConstantVolumeJointDef, ed:IEventDispatcher = null):void {
			super(w, d, ed);
			if (d.bodies.length <= 2) {
				throw new ArgumentError("You cannot create a constant volume joint with less than three bodies.");
			}
			bodies = d.bodies;
			//relaxationFactor = def.relaxationFactor;
			var n:int = bodies.length;
			var i:int;
			var next:int;
			targetLengths = new Vector.<Number>(n, true);
			for (i=0; i<n; ++i) {
				next = (i == targetLengths.length - 1) ? 0 : i + 1;
				targetLengths[i] = bodies[i].GetWorldCenter().subtract(bodies[next].GetWorldCenter()).length();
			}
			targetVolume = getArea();
			n = targetLengths.length;
			distanceJoints = new DistanceJoint[bodies.length];
			for (i=0; i<n; ++i) {
				next = (i == n-1)?0:i+1;
				var djd:b2DistanceJointDef  = new b2DistanceJointDef();
				djd.frequencyHz = d.frequencyHz;//20.0f;
				djd.dampingRatio = d.dampingRatio;//50.0f;
				djd.Initialize(bodies[i], bodies[next], bodies[i].GetWorldCenter(), bodies[next].GetWorldCenter());
				distanceJoints[i] = b2DistanceJoint(m_world.CreateJoint(djd));
			}
			
			n = bodies.length;
			normals = new Vector.<b2Vec2>(n, true);
			for (i=0; i<n; ++i) {
				normals[i] = new b2Vec2();
			}
			
			this.m_bodyA = bodies[0];
			this.m_bodyB = bodies[1];
			this.m_collideConnected = false;
		}

		override public function destroy():void {
			for (var i:int=0; i<distanceJoints.length; ++i) {
				m_world.DestroyJoint(distanceJoints[i]);
			}
			super.destroy();
		}

		private function getArea():Number {
			var area:Number = 0.0;
			// i'm glad i changed these all to member access
			area += bodies[bodies.length-1].GetWorldCenter().x * bodies[0].GetWorldCenter().y -
			bodies[0].GetWorldCenter().x * bodies[bodies.length-1].GetWorldCenter().y;
			for (int i=0; i<bodies.length-1; ++i){
				area += bodies[i].GetWorldCenter().x * bodies[i+1].GetWorldCenter().y -
				bodies[i+1].GetWorldCenter().x * bodies[i].GetWorldCenter().y;
			}
			area *= .5f;
			return area;
		}

		/**
		 * Apply the position correction to the particles.
		 * @param step
		 */
		public function constrainEdges():Boolean {
			float perimeter = 0.0;
			for (int i=0; i<bodies.length; ++i) {
				var next:int = (i==bodies.length-1)?0:i+1;
				var dx:Number = bodies[next].GetWorldCenter().x-bodies[i].GetWorldCenter().x;
				var dy:Number = bodies[next].GetWorldCenter().y-bodies[i].GetWorldCenter().y;
				float dist = Math.sqrt(dx*dx+dy*dy);
				if (dist < Settings.EPSILON) {
					dist = 1.0f;
				}
				normals[i].x = dy / dist;
				normals[i].y = -dx / dist;
				perimeter += dist;
			}

			final float deltaArea = targetVolume - getArea();
			final float toExtrude = 0.5f*deltaArea / perimeter; //*relaxationFactor
			//float sumdeltax = 0.0f;
			boolean done = true;
			for (int i=0; i<bodies.length; ++i) {
				final int next = (i==bodies.length-1)?0:i+1;
				final Vec2 delta = new Vec2(toExtrude * (normals[i].x + normals[next].x),
											toExtrude * (normals[i].y + normals[next].y));
				//sumdeltax += dx;
				final float norm = delta.length();
				if (norm > Settings.maxLinearCorrection){
					delta.mulLocal(Settings.maxLinearCorrection/norm);
				}
				if (norm > Settings.linearSlop){
					done = false;
				}
				bodies[next].m_sweep.c.x += delta.x;
				bodies[next].m_sweep.c.y += delta.y;
				bodies[next].synchronizeTransform();
				//bodies[next].m_linearVelocity.x += delta.x * step.inv_dt;
				//bodies[next].m_linearVelocity.y += delta.y * step.inv_dt;
			}
			//System.out.println(sumdeltax);
			return done;
		}

		// djm pooled
		private static final Vec2Array tlD = new Vec2Array();
		@Override
		public void initVelocityConstraints(final TimeStep step) {
			m_step = step;
			
			final Vec2[] d = tlD.get(bodies.length);
			
			for (int i=0; i<bodies.length; ++i) {
				final int prev = (i==0)?bodies.length-1:i-1;
				final int next = (i==bodies.length-1)?0:i+1;
				d[i].set(bodies[next].GetWorldCenter());
				d[i].subLocal(bodies[prev].GetWorldCenter());
			}

			if (step.warmStarting) {
				m_impulse *= step.dtRatio;
				//float lambda = -2.0f * crossMassSum / dotMassSum;
				//System.out.println(crossMassSum + " " +dotMassSum);
				//lambda = MathUtils.clamp(lambda, -Settings.maxLinearCorrection, Settings.maxLinearCorrection);
				//m_impulse = lambda;
				for (int i=0; i<bodies.length; ++i) {
					bodies[i].m_linearVelocity.x += bodies[i].m_invMass * d[i].y * .5f * m_impulse;
					bodies[i].m_linearVelocity.y += bodies[i].m_invMass * -d[i].x * .5f * m_impulse;
				}
			} else {
				m_impulse = 0.0f;
			}
		}

		//@Override
		public function solvePositionConstraints():Boolean {
			return constrainEdges();
		}

		@Override
		public void solveVelocityConstraints(final TimeStep step) {
			float crossMassSum = 0.0f;
			float dotMassSum = 0.0f;
			
			final Vec2 d[] = tlD.get(bodies.length);

			for (int i=0; i<bodies.length; ++i) {
				final int prev = (i==0)?bodies.length-1:i-1;
				final int next = (i==bodies.length-1)?0:i+1;
				d[i].set(bodies[next].GetWorldCenter());
				d[i].subLocal(bodies[prev].GetWorldCenter());
				dotMassSum += (d[i].lengthSquared())/bodies[i].getMass();
				crossMassSum += Vec2.cross(bodies[i].getLinearVelocity(),d[i]);
			}
			final float lambda = -2.0f * crossMassSum / dotMassSum;
			//System.out.println(crossMassSum + " " +dotMassSum);
			//lambda = MathUtils.clamp(lambda, -Settings.maxLinearCorrection, Settings.maxLinearCorrection);
			m_impulse += lambda;
			//System.out.println(m_impulse);
			for (int i=0; i<bodies.length; ++i) {
				bodies[i].m_linearVelocity.x += bodies[i].m_invMass * d[i].y * .5f * lambda;
				bodies[i].m_linearVelocity.y += bodies[i].m_invMass * -d[i].x * .5f * lambda;
			}
		}

		@Override
		public Vec2 getAnchor1() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public Vec2 getAnchor2() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public Vec2 getReactionForce() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public float getReactionTorque() {
			// TODO Auto-generated method stub
			return 0;
		}

	}
}
