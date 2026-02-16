package funkin;

import flixel.graphics.FlxGraphic;
import haxe.io.Bytes;
import haxe.io.Path;
import lime.utils.Assets as LimeAssets;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetLibrary;
import openfl.utils.ByteArray;

typedef FunkinAssetLibrary = {
    var path:String;
    var assetLibrary:Null<AssetLibrary>;
}

/**
 * A class for retrieving the game's asset paths.
 */
class Paths
{
    public static var assetBundles:Map<String, FunkinAssetLibrary> = [
        'default' => {path: 'assets', assetLibrary: null},
        'shared' => {path: 'assets/shared', assetLibrary: null},
        'preload' => {path: 'assets/preload', assetLibrary: null}
    ];

    static final USE_CACHE:Bool = true;

    public static function init() {
        for (key in assetBundles.keys()) {
            var assetLibrary = Assets.loadLibrary(key).result();
            assetBundles.set(key, {
                path: assetBundles[key].path,
                assetLibrary: assetLibrary
            });
        }
    }

    public static function path(id:String, ?library:String):String {
        for (key=>bundle in assetBundles) {
            if (Assets.exists('$key:${bundle.path}/$id') && library == null) {
                return '$key:${bundle.path}/$id';
            }
        }
        
        return '$library:${assetBundles[library].path}/$id';
    }

    public static inline function image(id:String, ?library:String, ?cache:Bool, ?unique:Bool = false, ?key:String):FlxGraphic
        return FlxGraphic.fromBitmapData(Assets.getBitmapData(path('$id.${Constants.IMAGE_EXT}', library), cache ?? USE_CACHE), unique, key, cache ?? USE_CACHE);

    public static inline function getText(id:String, ?library:String):String {
        return Assets.getText(path(id, library));
    }

    public static inline function sound(id:String, ?library:String, ?cache:Bool):Sound
        return Assets.getSound(path('$id.${Constants.SOUND_EXT}', library), cache ?? USE_CACHE);

    public static function getBytes(id:String, ?library:String):Bytes {
        return cast(Assets.getBytes(path(id, library)), ByteArrayData);
    }

    public static function read(id:String, ?lib:String):Array<String> {
        var list = Assets.list().filter(f -> return f.contains(assetBundles[lib ?? 'default'].path + '/$id'));

        var assetPath:String = lib ?? 'default' + ':' + assetBundles[lib ?? 'default'].path + '/';
        
        for (i in 0... list.length) {
            list[i] = list[i].substr((assetBundles[lib ?? 'default'].path + '/').length);
        }

        return list;
    }

    inline public static function readScripts(id:String, ?lib:String):Array<String> {
        return read(id, lib).filter(f -> return f.endsWith('.hx') || f.endsWith('.hxs') || f.endsWith('.hscript'));
    }
}