package funkin.play;

import flixel.FlxG;
import funkin.ui.FunkinState;

/**
 * A state where the gameplay occurs. Kinda like a "play" state. Hah! I said the thing!
 */
class PlayState extends FunkinState
{
	override public function create() {
		FlxG.camera.bgColor = 0xFF252525;

		super.create();
	}
}
