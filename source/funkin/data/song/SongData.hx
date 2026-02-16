package funkin.data.song;

import flixel.FlxG;
import moonchart.formats.fnf.FNFVSlice;
import moonchart.formats.fnf.legacy.FNFLegacy;
import openfl.Assets;
import openfl.media.Sound;

/**
 * A structure object used for song note data.
 */
typedef SongNoteData = {
    var t:Float;
    var d:Int;
    var l:Float;
    var k:String;
}

class SongData {
    public var speed:Float = 1;
    public var bpm:Float = 120;
    public var data:Array<Array<SongNoteData>> = [
        [], // Opponent
        [] // Player
    ];

    public var instrumental:Sound;
    public var playerVoices:Array<Sound> = [];
    public var opponentVoices:Array<Sound> = [];

    private static function suffix(str:String):String {
        return str != "" ? '-$str' : str;
    }

    public function new(id:String, difficulty:String = "hard", variation:String = "") {
        if (Assets.exists(Paths.path('songs/$id/$id-chart${suffix(variation)}.json', 'preload'))) initVSlice(id, difficulty, variation);
        else {
            initLegacy(id, difficulty, variation);
        }
    }

    function initLegacy(id:String, difficulty:String, variation:String) {
        var legacy = new FNFLegacy().fromJson(Assets.getText(Paths.path('songs/$id/$id${suffix(difficulty)}${suffix(variation)}.json', 'preload')));

        instrumental = Assets.getSound(Paths.path('songs/$id/Inst${suffix(variation)}.${Constants.SOUND_EXT}', 'preload'));

        if (Assets.exists(Paths.path('songs/$id/Voices-Player${suffix(variation)}.${Constants.SOUND_EXT}', 'preload'))) {
            playerVoices.push(Assets.getSound(Paths.path('songs/$id/Voices-Player${suffix(variation)}.${Constants.SOUND_EXT}', 'preload')));
            opponentVoices.push(Assets.getSound(Paths.path('songs/$id/Voices-Opponent${suffix(variation)}.${Constants.SOUND_EXT}', 'preload')));
        } else if (Assets.exists(Paths.path('songs/$id/Voices${suffix(variation)}.${Constants.SOUND_EXT}', 'preload'))) {
            playerVoices.push(Assets.getSound(Paths.path('songs/$id/Voices${suffix(variation)}.${Constants.SOUND_EXT}', 'preload')));
        }

		for (section in legacy.data.song.notes)
		{
			for (note in section.sectionNotes) { 
                if (section.mustHitSection ? (note.lane > 3) : (note.lane < 4)) {
                    // Opponent
                    data[0].push({t: note.time, d: note.lane % Constants.NOTE_COUNT, l: note.length, k: note.type});
                } else {
                    // Player
                    data[1].push({t: note.time, d: note.lane % Constants.NOTE_COUNT, l: note.length, k: note.type});
                }
            }
		}

        speed = legacy.data.song.speed;
        bpm = legacy.data.song.bpm; // TO-DO: Change this later!
    }

    function initVSlice(id:String, difficulty:String, variation:String) {
        var vslice = new FNFVSlice().fromJson(Assets.getText(Paths.path('songs/$id/$id-chart${suffix(variation)}.json', 'preload')), Assets.getText(Paths.path('songs/$id/$id-metadata${suffix(variation)}.json', 'preload')));

        instrumental = Assets.getSound(Paths.path('songs/$id/Inst${suffix(vslice.meta.playData.characters.instrumental)}.${Constants.SOUND_EXT}', 'preload'));

        for (variant in vslice.meta.playData.characters.playerVocals ?? [vslice.meta.playData.characters.player])
            playerVoices.push(Assets.getSound(Paths.path('songs/$id/Voices${suffix(variant)}${suffix(variation)}.${Constants.SOUND_EXT}', 'preload')));

        for (variant in vslice.meta.playData.characters.opponentVocals ?? [vslice.meta.playData.characters.opponent])
            opponentVoices.push(Assets.getSound(Paths.path('songs/$id/Voices${suffix(variant)}${suffix(variation)}.${Constants.SOUND_EXT}', 'preload')));

		for (note in vslice.data.notes.get(difficulty))
		{
			if (note.d > 3) {
                // Opponent
                data[0].push({t: note.t, d: note.d % Constants.NOTE_COUNT, l: note.l, k: note.k});
            } else {
                // Player
                data[1].push({t: note.t, d: note.d % Constants.NOTE_COUNT, l: note.l, k: note.k});
            }
		}

        speed = vslice.data.scrollSpeed.get(difficulty);
        bpm = vslice.meta.timeChanges[0].bpm; // TO-DO: Change this later!
    }
}