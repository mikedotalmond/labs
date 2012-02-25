package ;

import haxe.Firebug;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.StageQuality;
import nme.Lib;

/**
 * ...
 * @author Mike Almond - https://github.com/mikedotalmond
 */

class Main {
	
	static public function main() {
		
		var stage 		= Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align 	= StageAlign.TOP_LEFT;
		stage.quality 	= StageQuality.HIGH;
		// entry point
		
		#if flash
		stage.showDefaultContextMenu = false;
		#end
		
		if (Firebug.detect()) Firebug.redirectTraces();
		
		stage.addChild(new BinaryClock());
	}
}