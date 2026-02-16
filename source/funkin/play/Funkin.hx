package funkin.play;

import flixel.FlxG;
import flixel.group.FlxContainer;
import flixel.sound.FlxSound;
import funkin.audio.SoundGroup;
import funkin.data.song.SongData;
import funkin.play.note.NoteDirection;
import funkin.play.note.NoteSprite;
import funkin.play.note.Strumline;
import funkin.script.HScript;
import openfl.Assets;

/**
 * The container that actually contains Friday Night Funkin'.
 */
class Funkin extends FlxContainer {
    public var loadedSong:Bool = false;
    public var startedSong:Bool = false;
    public var startedCountdown:Bool = false;

	public var opponentStrumline:Strumline;
	public var playerStrumline:Strumline;

	public var songData:SongData;

	public var inst:FlxSound;
	public var playerVoices:SoundGroup;
	public var opponentVoices:SoundGroup;

    public var onFinish:Void->Void = () -> {};

    public var songId:String;
    public var songDifficulty:String;
    public var songVariation:String;

    public var scripts:Array<HScript> = [];

	public function new()
	{
        super();

		inst = new FlxSound();
		FlxG.sound.list.add(inst);

		opponentVoices = new SoundGroup();
		playerVoices = new SoundGroup();

		opponentStrumline = new Strumline();
		opponentStrumline.offset = 0.25;
		add(opponentStrumline);

		playerStrumline = new Strumline();
		playerStrumline.offset = 0.75;
		add(playerStrumline);

        Conductor.instance.stepHit.add(stepHit);
        Conductor.instance.beatHit.add(beatHit);
        Conductor.instance.sectionHit.add(sectionHit);
	}

    function stepHit(curStep:Int) {
        for (script in scripts) script.call('onStepHit', [curStep]);
    }

    function beatHit(curBeat:Int) {
        for (script in scripts) script.call('onBeatHit', [curBeat]);
    }

    function sectionHit(curSection:Int) {
        for (script in scripts) script.call('onSectionHit', [curSection]);
    }

	override public function draw() {
		opponentStrumline.process(false);
		playerStrumline.process(!Preferences.botplay);

		processInput();

		super.draw();
	}

	override public function update(elapsed:Float)
	{
		// DO NOT PAUSE THE INST, IT'LL THROW OFF THE PLAYER!
		if (Math.abs(inst.time - (playerVoices?.time ?? opponentVoices.time)) > 9)
			resyncVocals();

		if (loadedSong && startedSong)
		{
			Conductor.instance.time = inst.time;
			Conductor.instance.update();
		} else if (startedCountdown) {
            Conductor.instance.time += elapsed * Constants.MS_PER_SEC;
			Conductor.instance.update();

            if (Conductor.instance.time > -1) {
                loadedSong = true;

                startSong();
            }
        }
        
        for (script in scripts) script.call('onUpdate', elapsed);

		super.update(elapsed);
        
        for (script in scripts) script.call('onUpdatePost', elapsed);
    }

	override public function destroy() {
		super.destroy();

        for (script in scripts) script.call('onDestroy');

        for (script in scripts) script.destroy();
        scripts.resize(0);

		FlxG.sound.list.remove(inst, true);

        Conductor.instance.time = 0;
        Conductor.instance.update();

        inst.destroy();
        playerVoices.destroy();
        opponentVoices.destroy();

        Conductor.instance.stepHit.remove(stepHit);
        Conductor.instance.beatHit.remove(beatHit);
        Conductor.instance.sectionHit.remove(sectionHit);
	}

    public static function quickLoad(id:String, ?difficulty:String, ?variation:String, state:FlxContainer, onFinish:Void->Void):Funkin {
        var funkin = new Funkin();
		state.add(funkin);

		funkin.onFinish = onFinish;
		funkin.loadSong(id, difficulty, variation);

        return funkin;
    }

    public function startCountdown() {
        startedCountdown = true;
    }

	public function loadSong(id:String, ?difficulty:String, ?variation:String)
	{
        songId = id;
        songDifficulty = difficulty;
        songVariation = variation;

        var fileSystem:Array<String> = Paths.readScripts('songs/$id/scripts${variation != "" ? '/$variation' : variation}', 'preload');

        for (file in Paths.readScripts('songs/$id/scripts/global', 'preload'))
            fileSystem.push(file);

        if (fileSystem.length != 0) {
            for (file in fileSystem) {
                var script = new HScript(Assets.getText(Paths.path(file, 'preload')));
                scripts.push(script);
            }
        }
        fileSystem.resize(0);
        fileSystem = null;
        
        for (script in scripts) script.call('onCreate');

		songData = new SongData(id, difficulty, variation);
		
		inst.loadEmbedded(songData.instrumental);
        inst.onComplete = () -> onFinish();

		for (sound in songData.opponentVoices) {
			var snd = new FlxSound().loadEmbedded(sound);
			opponentVoices.add(snd);
		}

		for (sound in songData.playerVoices) {
			var snd = new FlxSound().loadEmbedded(sound);
			playerVoices.add(snd);
		}

		Conductor.instance.bpm = songData.bpm;

        Conductor.instance.time = Conductor.instance.crotchet * -4;
        Conductor.instance.update();

		playerStrumline.speed = songData.speed;
		playerStrumline.data = songData.data[1];
		playerStrumline.spawnNotes();

		opponentStrumline.data = songData.data[0];
		opponentStrumline.speed = songData.speed;
		opponentStrumline.spawnNotes();

        for (script in scripts) script.call('onCreatePost');

        loadedSong = true;
	}

	public function startSong() {
        Conductor.instance.time = 0;
        Conductor.instance.update();

        startedSong = true;

		inst.play();
		opponentVoices.play();
		playerVoices.play();

        resyncVocals();

        for (script in scripts) script.call('onSongStart');
	}

	public function processInput()
	{
		// Player input
		var directionNotes:Array<Array<NoteSprite>> = [[], [], [], []];

		for (note in playerStrumline.getMayHitNotes()) directionNotes[note.direction].push(note);

		for (i in 0...directionNotes.length)
		{
			var note:NoteSprite = directionNotes[i][0];
			var direction:NoteDirection = NoteDirection.fromInt(i);
			var pressed:Bool = direction.justPressed || Preferences.botplay;

			if (!pressed || note == null) continue;

			playerStrumline.hitNote(note);
			playerStrumline.playSplash(direction);
		}

		// Opponent input
		for (note in opponentStrumline.getMayHitNotes())
			opponentStrumline.hitNote(note);
	}
	
	public function resyncVocals() {
		playerVoices.pause();
		opponentVoices.pause();

		playerVoices.time = inst.time;
		opponentVoices.time = inst.time;

		playerVoices.resume();
		opponentVoices.resume();

		#if debug
		trace("Resynced vocals at: " + inst.time);
		#end
	}
}