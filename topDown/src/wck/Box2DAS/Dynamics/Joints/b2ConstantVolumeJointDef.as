package Box2DAS.Dynamics.Joints{

	import Box2DAS.Dynamics.b2Body;

	public class ConstantVolumeJointDef extends b2JointDef {
		
		internal var bodies:Vector.<b2Body>;
		public var frequencyHz:Number;
		public var dampingRatio:Number;
		//public var relaxationFactor:Number;//1.0 is perfectly stiff (but doesn't work, unstable)
		
		public ConstantVolumeJointDef() {
			//type = JointType.CONSTANT_VOLUME_JOINT;
			bodies = new Vector.<b2Body>();
			//relaxationFactor = 0.9f;
			collideConnected = false;
			frequencyHz = 0.0;
			dampingRatio = 0.0;
		}
		
		public function addBody(b:b2Body):void {
			bodies.push(b);
			if (bodies.length == 1) body1 = b;
			else if (bodies.length == 2) body2 = b;
		}
	}
}
