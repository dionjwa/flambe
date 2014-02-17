//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.subsystem.*;
import flambe.util.Assert;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;

import sys.FileSystem;

import js.Node;

class NodePlatform
    implements Platform
{
    public static var instance (default, null) :NodePlatform = new NodePlatform();

    public var mainLoop (default, null) :MainLoop;
    public var isCanvasRendererEnabled (get, set) :Bool;
    public var isCanvasRendererAvailable (default, null) :Bool;
    public var renderedFramesFolder : String = 'frames';

    private function new ()
    {
        _isPaused = false;
        _isCanvasRendererEnabled = false;
        isCanvasRendererAvailable = false;
    }

    public function startMainLoop()
    {
        _isPaused = false;
        _stepUpdateId = Node.setImmediate(tick);
    }

    public function stopMainLoop()
    {
        Node.clearImmediate(_stepUpdateId);
        _stepUpdateId = null;
        _isPaused = true;
    }

    public function step(?dt :Float = 0.03)
    {
        update(_lastUpdate + dt);
    }

    function tick()
    {
        update(_lastUpdate + 30);
        _stepUpdateId = Node.setImmediate(tick);
    }

    public function init ()
    {
        //# sourceMappingURL=path/to/source.map
        try {
            var sourceMapSupport = Node.require('source-map-support');
            if (sourceMapSupport != null) {
                untyped sourceMapSupport.install();
            }
        } catch (e :Dynamic){}

#if mconsole
        try {
            untyped Console.start();
        } catch (e :Dynamic) {
            Log.error(e);
        }
#end
        _stage = new NodeStage();
        try {
            _renderer = new NodeCanvasRenderer(_stage.width, _stage.height);
            _stage.resize.connect(function() {
                cast(_renderer.graphics, NodeCanvasGraphics).onResize(_stage.width, _stage.height);
            });

            isCanvasRendererAvailable = true;
            _isCanvasRendererEnabled = true;

            if (!FileSystem.exists("frames")) {
                FileSystem.createDirectory("frames");
            }
            Log.info("Using node canvas");
        } catch(e :Dynamic) {
            Log.info("node canvas not found, ignoring the renderer");
            _renderer = new DummyRenderer();
        }
        mainLoop = new MainLoop();
        _skipFrame = false;
        _lastUpdate = haxe.Timer.stamp();

        //Don't start the mainLoop automatically
        // startMainLoop();
#if debug
        // _catapult = NodeCatapultClient.canUse() ? new NodeCatapultClient() : null;
#end
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        return new NodeAssetPackLoader(this, manifest).promise;
    }

    public function getStage () :StageSystem
    {
        return _stage;
    }

    public function getStorage () :StorageSystem
    {
        if (_storage == null) {
            _storage = new flambe.platform.DummyStorage();
        }
        return _storage;
    }

    public function getLocale () :String
    {
        return null;
    }

    public function createLogHandler (tag :String) :LogHandler
    {
        return new NodeLogHandler(tag);
    }

    inline public function getTime () :Float
    {
        return haxe.Timer.stamp();
    }

    public function getCatapultClient ()
    {
        return null;//_catapult;
    }

    private function update (now :Float)
    {
        var dt = (now - _lastUpdate) / 1000;
        _lastUpdate = now;

        if (System.hidden._) {
            return; // Prevent updates while hidden
        }
        if (_skipFrame) {
            _skipFrame = false;
            return;
        }

        mainLoop.update(dt);
        mainLoop.render(_renderer);

        //Maybe render the frames
        if (isCanvasRendererEnabled) {
            var canvasRenderer :NodeCanvasRenderer = cast _renderer;
            var outputPngFileName = Node.path.join(renderedFramesFolder, "frame_" + canvasRenderer.frame + ".png");
            Log.info("rendering " + outputPngFileName);
            Node.fs.writeFileSync(outputPngFileName,
                cast(canvasRenderer.graphics, flambe.platform.nodejs.NodeCanvasGraphics).canvas.toBuffer());

            var symlinkPath = Node.path.join(renderedFramesFolder, "last_frame.png");
            if (Node.fs.existsSync(symlinkPath)) {
                Node.fs.unlinkSync(symlinkPath);
            }
            Node.fs.symlinkSync("frame_" + canvasRenderer.frame + ".png", symlinkPath);
        }
    }

    public function getPointer () :PointerSystem
    {
        return _pointer;
    }

    public function getMouse () :MouseSystem
    {
        if (_mouse == null) {
            _mouse = new flambe.platform.DummyMouse();
        }
        return _mouse;
    }

    public function getTouch () :TouchSystem
    {
        if (_touch == null) {
            _touch = new flambe.platform.DummyTouch();
        }
        return _touch;
    }

    public function getKeyboard () :KeyboardSystem
    {
        if (_keyboard == null) {
            _keyboard = new flambe.platform.BasicKeyboard();
        }
        return _keyboard;
    }

    public function getWeb () :WebSystem
    {
        if (_web == null) {
            _web = new flambe.platform.DummyWeb();
        }
        return _web;
    }

    public function getExternal () :ExternalSystem
    {
        if (_external == null) {
            _external = new flambe.platform.DummyExternal();
        }
        return _external;
    }

    public function getMotion () :MotionSystem
    {
        if (_motion == null) {
            _motion = new flambe.platform.DummyMotion();
        }
        return _motion;
    }

    public function getRenderer () :Renderer
    {
        return _renderer;
    }

    private function get_isCanvasRendererEnabled() :Bool
    {
        return _isCanvasRendererEnabled;
    }

    private function set_isCanvasRendererEnabled(val :Bool) :Bool
    {
        if (val && !isCanvasRendererAvailable) {
            throw "Canvas renderer is not available: install via 'npm install canvas'";
        }
        _isCanvasRendererEnabled = val;
        return val;
    }

    // Statically initialized subsystems
    private var _mouse :MouseSystem;
    private var _pointer :BasicPointer;
    private var _renderer :Renderer;
    private var _stage :StageSystem;
    private var _touch :TouchSystem;

    // Lazily initialized subsystems
    private var _external :ExternalSystem;
    private var _keyboard :BasicKeyboard;
    private var _motion :MotionSystem;
    private var _storage :StorageSystem;
    private var _web :WebSystem;

    //Controlling updates
    private var _lastUpdate :Float;
    private var _skipFrame :Bool;
    private var _isPaused :Bool;
    private var _stepUpdateId :Dynamic;


    private var _isCanvasRendererEnabled :Bool;
    //Catapult client is not really needed for headless clients?
    // private var _catapult :NodeCatapultClient;
}
