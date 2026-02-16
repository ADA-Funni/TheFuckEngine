package funkin.input;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

/**
 * A class for handling input controls.
 */
class Controls extends FlxActionSet
{
    public static var instance:Controls;

    public var note_left(default, null) = new FunkinAction('note_left');
    public var note_down(default, null) = new FunkinAction('note_down');
    public var note_up(default, null) = new FunkinAction('note_up');
    public var note_right(default, null) = new FunkinAction('note_right');

    public var accept(default, null) = new FunkinAction('accept');

    public function new()
    {
        super('controls');

        // Adds the actions
        add(note_left);
        add(note_down);
        add(note_up);
        add(note_right);
        add(accept);

        // Sets the keys
        // Arrow keys suck, dude. Teach the right handed kids to use IJKL instead.
        note_left.setKeys([J, A]);
        note_down.setKeys([K, S]);
        note_up.setKeys([I, W]);
        note_right.setKeys([L, D]);
        accept.setKeys([ENTER, Z]);
    }
}

/**
 * An extension of `FlxActionDigital` used for `Controls`.
 */
class FunkinAction extends FlxActionDigital
{
    public var justPressed(get, never):Bool;
        function get_justPressed():Bool return checkFiltered(JUST_PRESSED);

    public var pressed(get, never):Bool;
        function get_pressed():Bool return checkFiltered(PRESSED);

    public var justReleased(get, never):Bool;
        function get_justReleased():Bool return checkFiltered(JUST_RELEASED);

    public function new(id:String)
    {
        super(id);

        //var controls = new FunkinSave('controls');
        //setKeys(controls.data[id].keyboard);
        //setGamepad(controls.data[id].gamepad);
    }

    public function setKeys(keys:Array<FlxKey>)
    {
        // Clears any set keys
        removeDevice(KEYBOARD);

        // Adds the keys
        for (key in keys)
        {
            addKey(key, JUST_RELEASED);
            addKey(key, PRESSED);
            addKey(key, JUST_PRESSED);
        }
    }

    public function setGamepad(keys:Array<FlxGamepadInputID>)
    {
        // Clears any set keys
        removeDevice(GAMEPAD);

        // Adds the keys
        for (key in keys)
        {
            addGamepad(key, JUST_RELEASED);
            addGamepad(key, PRESSED);
            addGamepad(key, JUST_PRESSED);
        }
    }

    public function removeDevice(device:FlxInputDevice)
    {
        for (input in inputs)
        {
            if (input.device != device) continue;

            input.destroy();
        }
    }

    function checkFiltered(trigger:FlxInputState):Bool
    {
        // Borrowed from FlxActionDigital hehehe
        _x = null;
		_y = null;
		
		_timestamp = FlxG.game.ticks;
		triggered = false;
		
		var i = inputs != null ? inputs.length : 0;
		while (i-- > 0) // Iterate backwards, since we may remove items
		{
			final input = inputs[i];
			
			if (input.destroyed)
			{
				inputs.remove(input);
				continue;
			}

            // Skip the input if it doesn't match the specified trigger
            if (input.trigger != trigger) continue;
			
			input.update();
			
			if (input.check(this))
				triggered = true;
		}
		
		return triggered;
    }
}