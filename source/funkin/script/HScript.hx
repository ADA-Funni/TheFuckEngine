package funkin.script;

import crowplexus.iris.Iris;
import flixel.FlxG;
import funkin.play.Funkin;
import funkin.ui.FunkinState;
import funkin.ui.FunkinUIState;

/**
 * A helper class used for adding Haxe scripting (HScript) to your games.
 */
class HScript {
	/**
	 * A list of every single script that is active right now.
	 */
    public static var scripts:Array<HScript> = [];

	/**
	 * This runs your code.
	 */
	public var iris:Iris;

    public function new(code:String) {
		iris = new Iris(code, {name: "My Script", autoRun: false, autoPreset: true});
		iris.execute();

		iris.set('game', cast(FlxG.state, FunkinState));
		iris.set('ui', (FlxG.state is FunkinUIState) ? cast(FlxG.state, FunkinUIState) : iris.get('game'));
		iris.set('Funkin', Funkin);

        scripts.push(this);
    }

	/**
	 * Sets field `name` to `value` in your `interp`.
	 * @param name String
	 * @param value Dynamic
	 */
    inline public function set(name:String, value:Dynamic) {
        iris.exists(name) ? iris.set(name, value) : null;
    }

	/**
	 * Gets field `name` from your `interp`.
	 * @param name String
	 * @return Null<Dynamic>
	 */
	inline public function get(name:String):Null<Dynamic>
	{
        return iris.exists(name) ? iris.get(name) : null;
    }

	/**
	 * Calls function `name` from your `interp`.
	 * @param name String
	 * @param args Null<Array<Dynamic>>
	 * @return Null<Dynamic>
	 */
	public function call(name:String, ?args:Dynamic):Null<Dynamic>
	{
        if (iris.exists(name)) {
            return iris.call(name, args);
        }

        return null;
    }

	/**
	 * Destroys your script.
	 */
    public function destroy() {
		scripts.remove(this);

        iris.destroy();
    }
}