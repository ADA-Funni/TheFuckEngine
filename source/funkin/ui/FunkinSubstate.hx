package funkin.ui;

import flixel.FlxSubState;
import funkin.input.Controls;
import funkin.script.HScript;
import openfl.Assets;

/**
 * A class used as the base for all the game's substates.
 */
class FunkinSubstate extends FlxSubState
{
    var scripts:Array<HScript> = [];
    var conductor(get, never):Conductor;
    var controls(get, never):Controls;

    public function new()
    {
        super(0x00000000);

        // Adds conductor callbacks
        conductor.stepHit.add(stepHit);
        conductor.beatHit.add(beatHit);
        conductor.sectionHit.add(sectionHit);
    }

    public override function create() {
        for (file in Paths.readScripts('scripts/substates/${Type.getClassName(Type.getClass(this))}', 'preload')) {
			var script = new HScript(Assets.getText(Paths.path(file, 'preload')));
			scripts.push(script);
		}

		for (script in scripts) script.call('onCreate');
        
        super.create();

        for (script in scripts) script.call('onCreatePost');
    }

    public override function draw() {
        for (script in scripts) script.call('onDraw');
        super.draw();
        for (script in scripts) script.call('onDrawPost');
    }

    override public function update(elapsed:Float) {
		for (script in scripts) script.call('onUpdate', [elapsed]);
		
		super.update(elapsed);

		for (script in scripts) script.call('onUpdatePost', [elapsed]);
	}

    override public function destroy()
    {
        for (script in scripts) script.call('onDestroy');

        super.destroy();

        // Removes conductor callbacks
        conductor.stepHit.remove(stepHit);
        conductor.beatHit.remove(beatHit);
        conductor.sectionHit.remove(sectionHit);

        for (script in scripts) script.call('onDestroyPost');

        for (script in scripts) script.destroy();
        scripts.resize(0);
    }
    
    function stepHit(step:Int) {
        for (script in scripts) script.call('onStepHit', [step]);
    }

    function beatHit(beat:Int) {
        for (script in scripts) script.call('onBeatHit', [beat]);
    }
    
    function sectionHit(section:Int) {
        for (script in scripts) script.call('onSectionHit', [section]);
    }

    inline function get_conductor():Conductor
        return Conductor.instance;

    inline function get_controls():Controls
        return Controls.instance;
}