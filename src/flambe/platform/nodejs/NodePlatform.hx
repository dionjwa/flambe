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

using StringTools;

enum UpdateType {
    Immediate;
    Timer;
}

class NodePlatform
    implements Platform
{
    public static var instance (default, null) :NodePlatform = new NodePlatform();

    public var mainLoop (default, null) :MainLoop;
    public var musicPlaying :Bool;

    public var isRenderingEveryFrame :Bool = true;
    public var isCanvasRendererEnabled (get, set) :Bool;
    public var isCanvasRendererAvailable (default, null) :Bool;
    public var renderedFramesFolder : String = 'frames';
    public var renderedFramesPrefix : String = 'frame_';
    public var lastFrameName : String = '_frame_last.png';
    public var updateType :UpdateType;
    public var FPS :Int = 30;
    private var _currentTime :Float;

    private function new ()
    {
        _isPaused = true;
        _isCanvasRendererEnabled = false;
        isCanvasRendererAvailable = false;
        updateType = UpdateType.Timer;
        _currentTime = getTime();

        try {
            var canvas = Node.require('canvas');
            isCanvasRendererAvailable = true;
            isRenderingEveryFrame = false;
        } catch (e :Dynamic){
            isCanvasRendererAvailable = false;
        }
    }

    public function startMainLoop()
    {
        if (!_isPaused) {//Already running
            Log.info("Already running, not starting main loop");
            return;
        }
        _isPaused = false;
        _currentTime = getTime();
        switch(updateType) {
            case Timer: _stepUpdateId = Node.setTimeout(tick, Std.int(1000 / FPS));
            case Immediate: _stepUpdateId = Node.setImmediate(tick);
        }
    }

    public function stopMainLoop()
    {
        Node.clearImmediate(_stepUpdateId);
        Node.clearTimeout(_stepUpdateId);
        _stepUpdateId = null;
        _isPaused = true;
    }

    public function step()
    {
        update(1.0 / FPS);
    }

    function tick()
    {
#if node_flambe_server_enabled
        //If we have the server enabled, but there aren't any
        //connections, don't update until we have a connection
        if (!_server.isConnections) {
            _currentTime = getTime();
            switch(updateType) {
                case Timer:
                    _stepUpdateId = Node.setTimeout(tick, Std.int(1000 / FPS));
                case Immediate:
                    _stepUpdateId = Node.setImmediate(tick);
            }
            return;
        }
#end
        switch(updateType) {
            case Timer:
                var dt = getTime() - _currentTime;
                _currentTime = getTime();
                _stepUpdateId = Node.setTimeout(tick, Std.int(1000 / FPS));
                update(dt);
            case Immediate:
                _stepUpdateId = Node.setImmediate(tick);
                update(1.0 / FPS);
        }
    }

    public function init ()
    {
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

        if (isCanvasRendererAvailable) {
            _renderer = new NodeCanvasRenderer(_stage.width, _stage.height);
            _stage.resize.connect(function() {
                cast(_renderer.graphics, NodeCanvasGraphics).onResize(_stage.width, _stage.height);
            });

            // _isCanvasRendererEnabled = true;

            if (!FileSystem.exists(renderedFramesFolder)) {
                FileSystem.createDirectory(renderedFramesFolder);
            }

            for (file in FileSystem.readDirectory(renderedFramesFolder)) {
                if (file.endsWith(".png")){// || file == lastFrameName) {
                    FileSystem.deleteFile(FileSystem.join(renderedFramesFolder, file));
                }
            }
            Log.info("Using node canvas");
        } else {
            Log.info("node canvas not found, ignoring the renderer");
            _renderer = new DummyRenderer();
        }
        mainLoop = new MainLoop();
        _skipFrame = false;
        _lastUpdate = getTime();

#if debug
        // _catapult = NodeCatapultClient.canUse() ? new NodeCatapultClient() : null;
#end

#if node_flambe_server_enabled
        if (isCanvasRendererAvailable) {
            _server = new NodePlatformServer(this);
            Log.info("STARTING MAIN LOOP");
            startMainLoop();
        } else {
        }
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
        return untyped __js__('Date.now() / 1000');
    }

    public function getCatapultClient ()
    {
        return null;//_catapult;
    }

    private function update (dt :Float)
    {
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
        if (isCanvasRendererEnabled && isRenderingEveryFrame) {
            var canvasRenderer :NodeCanvasRenderer = cast _renderer;
            var outputPngFileName = Node.path.join(renderedFramesFolder, renderedFramesPrefix + canvasRenderer.frame + ".png");
            renderFrame(outputPngFileName);
        }
        var now = getTime();
        _lastUpdate = now;

#if node_flambe_server_enabled
        _server.sendCanvasBufferToClients();
#end
    }

    public function renderFrame(fileName :String)
    {
        if (!isCanvasRendererEnabled) {
            Log.error("node canvas not available");
            return;
        }
        var canvasRenderer :NodeCanvasRenderer = cast _renderer;
        if (!fileName.endsWith(".png")) {
            fileName += ".png";
        }
        Log.info("rendering " + fileName);
        Node.fs.writeFileSync(fileName,
            cast(canvasRenderer.graphics, flambe.platform.nodejs.NodeCanvasGraphics).canvas.toBuffer());
    }

    public function getPointer () :PointerSystem
    {
        if (_pointer == null) {
            _pointer = new flambe.platform.BasicPointer();
        }
        return _pointer;
    }

    public function getMouse () :MouseSystem
    {
        if (_mouse == null) {
            getPointer();
            _mouse = new flambe.platform.BasicMouse(_pointer);
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

    public function getRenderer () :InternalRenderer<Dynamic>
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
    private var _renderer :InternalRenderer<Dynamic>;
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

#if node_flambe_server_enabled
    private var _server :NodePlatformServer;
#end
    //Catapult client is not really needed for headless clients?
    // private var _catapult :NodeCatapultClient;
}
