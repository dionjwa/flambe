//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import flambe.display.Orientation;
import flambe.subsystem.StageSystem;
import flambe.util.Signal0;
import flambe.util.Value;

class NodeStage
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
        scaleFactor = 1;
        orientation = new Value<Orientation>(null);
        fullscreen = new Value<Bool>(false);
        _width = 300;
        _height = 300;
    }

    public function get_width () :Int
    {
        return _width;
    }

    public function get_height () :Int
    {
        return _height;
    }

    public function get_fullscreenSupported () :Bool
    {
        return false;
    }

    public function lockOrientation (orient :Orientation)
    {
    }

    public function unlockOrientation ()
    {
    }

    public function requestResize (width :Int, height :Int)
    {
        _width = width;
        _height = height;
        resize.emit();//The NodeCanvasRenderer listens to this
    }

    public function requestFullscreen (enable :Bool = true)
    {
    }

    private var _width :Int;
    private var _height :Int;
}
