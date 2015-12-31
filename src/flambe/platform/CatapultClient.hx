//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import haxe.Json;

import flambe.util.Assert;

using StringTools;

/** Handles communication with the Catapult server run by `flambe serve`, for live reloading. */
class CatapultClient
{
    private function new ()
    {
        _loaders = [];
    }

    public function add (loader :BasicAssetPackLoader)
    {
#if !flambe_disable_reloading
        // Only care about packs loaded from the assets directory
        if (loader.manifest.localBase == "assets") {
            _loaders.push(loader);
        }
#end
    }

    public function remove (loader :BasicAssetPackLoader)
    {
        _loaders.remove(loader);
    }

    private function onError (cause :String)
    {
        Log.warn("Unable to connect to Catapult", ["cause", cause]);
    }

    private function onMessage (message :String)
    {
        trace("on catapult message: " + Std.string(message));
        var messageJson = Json.parse(message);
        switch (messageJson.type) {
        case "catapult.file_changed":
            var url = messageJson.name + "?v=" + messageJson.md5;
            url = url.replace("\\", "/"); // Handle backslash paths in Windows
            for (loader in _loaders) {
                loader.reload(url);
            }
        case "catapult.restart":
            onRestart();
        }
    }

    private function onRestart ()
    {
        Assert.fail(); // See subclasses
    }

    private var _loaders :Array<BasicAssetPackLoader>;
}
