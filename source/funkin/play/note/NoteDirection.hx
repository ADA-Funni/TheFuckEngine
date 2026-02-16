package funkin.play.note;

import funkin.input.Controls;

/**
 * An enum abstract used for note directions.
 */
enum abstract NoteDirection(Int) to Int from Int
{
    var LEFT = 0;
    var DOWN = 1;
    var UP = 2;
    var RIGHT = 3;

	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;

    @:from
    public static function fromInt(value:Int):NoteDirection
    {
        return switch (value % Constants.NOTE_COUNT)
        {
            case 0: LEFT;
            case 1: DOWN;
            case 2: UP;
            case 3: RIGHT;
            default: LEFT;
        }
    }

	function get_pressed():Bool
	{
		var controls:Controls = Controls.instance;

		return switch (abstract)
		{
			case LEFT: controls.note_left.pressed;
			case DOWN: controls.note_down.pressed;
			case UP: controls.note_up.pressed;
			case RIGHT: controls.note_right.pressed;
		}
	}

	function get_justPressed():Bool
	{
		var controls:Controls = Controls.instance;

		return switch (abstract)
		{
			case LEFT: controls.note_left.justPressed;
			case DOWN: controls.note_down.justPressed;
			case UP: controls.note_up.justPressed;
			case RIGHT: controls.note_right.justPressed;
		}
	}
}