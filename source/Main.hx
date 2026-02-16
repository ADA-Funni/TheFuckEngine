package;

import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.util.typeLimit.NextState.InitialState;
import funkin.Paths;
import funkin.play.PlayState;
import funkin.ui.FPSCounter;
import lime.app.Application;
import openfl.display.Sprite;

/**
 * The main project class where Flixel is initialized.
 */
class Main extends Sprite
{
	public static var fpsCounter:FPSCounter;

	public function new()
	{
		super();

		Paths.init();

		// Starts the game
		final gameWidth:Int = 0;
		final gameHeight:Int = 0;
		final initialState:InitialState = funkin.InitState;
		final framerate:Int = Application.current.window.displayMode.refreshRate;
		final skipSplash:Bool = true;
		final startFullscreen:Bool = false;

		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		// Adds an FPS counter
		fpsCounter = new FPSCounter(10, 10, 0xFFFFFF);
		addChild(fpsCounter);
	}
}
