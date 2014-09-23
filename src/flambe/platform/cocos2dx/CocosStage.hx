//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.cocos2dx;

import cc.Cocos2dx;

import flambe.display.Orientation;
import flambe.subsystem.StageSystem;
import flambe.util.Signal0;
import flambe.util.Value;

class CocosStage
    implements StageSystem
{
    public var width (get, null) :Int;
    public var height (get, null) :Int;
    public var orientation (default, null) :Value<Orientation>;
    public var fullscreen (default, null) :Value<Bool>;
    public var fullscreenSupported (get, null) :Bool;

    public var resize (default, null) :Signal0;

    public var scaleFactor (default, null) :Float;

    public function new ()
    {
        resize = new Signal0();
        fullscreen = new Value<Bool>(true);
        orientation = new Value<Orientation>(Orientation.Landscape);

//             Browser.window.addEventListener("orientationchange", onOrientationChange, false);
//             onOrientationChange(null);
//         }

//         fullscreen = new Value<Bool>(false);
//         HtmlUtil.addVendorListener(Browser.document, "fullscreenchange", function (_) {
//             updateFullscreen();
//         }, false);
// #if debug
//         HtmlUtil.addVendorListener(Browser.document, "fullscreenerror", function (_) {
//             // No useful error message since the event provides no reason. See the error conditions
//             // at http://dvcs.w3.org/hg/fullscreen/raw-file/tip/Overview.html#dom-element-requestfullscreen
//             Log.warn("Error when requesting fullscreen");
//         }, false);
// #end
//         updateFullscreen();
    }

    public function get_width () :Int
    {
        return Std.int(CC.director.getWinSize().width);
    }

    public function get_height () :Int
    {
        return Std.int(CC.director.getWinSize().height);
    }

    public function get_fullscreenSupported () :Bool
    {
        return false;
    }

    public function lockOrientation (orient :Orientation)
    {
        // var lockOrientation = HtmlUtil.loadExtension("lockOrientation", Browser.window.screen).value;
        // if (lockOrientation != null) {
        //     var htmlOrient = switch (orient) {
        //         case Portrait: "portrait";
        //         case Landscape: "landscape";
        //     };
        //     var allowed = Reflect.callMethod(Browser.window.screen, lockOrientation, [htmlOrient]);
        //     if (!allowed) {
        //         Log.warn("The request to lockOrientation() was refused by the browser");
        //     }
        // }
    }

    public function unlockOrientation ()
    {
    }

    public function requestResize (width :Int, height :Int)
    {
    }

    public function requestFullscreen (enable :Bool = true)
    {
    }

    private function onWindowResize (_)
    {
    }

    private function onOrientationChange (_)
    {
        // var value = HtmlUtil.orientation((untyped Browser.window).orientation);
        // orientation._ = value;
    }


}
