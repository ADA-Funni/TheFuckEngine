package funkin.ui;

import flixel.FlxG;
import funkin.memory.Memory;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField {
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var times:Array<Float>;

	public var lagging:Bool = false;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
		super();

		background = true;
		backgroundColor = 0xA4000000;

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat('Times New Roman', 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		#if flash
		addEventListener(Event.ENTER_FRAME, e -> {
			__enterFrame();
		});
		#end

		times = [];
	}

	private var deltaTimeout:Float = 0.0;

	// Event Handlers
	private #if !flash override #end function __enterFrame(#if !flash deltaTime:Float #end):Void {
		final now:Float = haxe.Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 100) {
			deltaTimeout += #if !flash deltaTime #else 1 / FlxG.updateFramerate #end;
			return;
		}

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateText();
		deltaTimeout = 0.0;
	}

	public function updateText():Void {
		text = 'FPS: ${currentFPS}'
		+ '\nMemory: ${flixel.util.FlxStringUtil.formatBytes(Memory.getCurrentUsage())} / '
		+ '${flixel.util.FlxStringUtil.formatBytes(Memory.getPeakUsage())}'
		+ '\n${lime.app.Application.current.window.title} v${lime.app.Application.current.meta.get('version')}';

		lagging = currentFPS < FlxG.drawFramerate * .5;
		textColor = currentFPS < FlxG.drawFramerate * .5 ? flixel.util.FlxColor.RED : flixel.util.FlxColor.WHITE;
	}
}
