//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.cocos2dx;

import cc.Cocos2dx;

import cocos.dispatcher.NativeDispatcher;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.subsystem.*;
import flambe.platform.MouseCodes;
import flambe.util.Assert;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;
import flambe.util.Signal0;
import flambe.util.Value;

class CocosPlatform
    implements Platform
{
    public static function trace(v:Dynamic, ?infos:haxe.PosInfos = null) :Void
    {
        CC.log(infos.className + ":" + infos.lineNumber + " " + v);
    }

    public static var instance (default, null) :CocosPlatform = new CocosPlatform();

    public var mainLoop (default, null) :MainLoop;

    /** Root node for adding the the Cocos */
    public var rootCocosNode (default, null):CCNode;

    /** The Cocos2dx platorm is asynchronously initialized. */
    public var isCocosInitialized (default, null):Promise<Bool>;
    public var writablePath (default, null) :Promise<String>;
    public var shutdown (default, null):Signal0;

    private function new ()
    {
        haxe.Log.trace = CocosPlatform.trace;
        _cocosListeners = [];
        isCocosInitialized = new Promise();
        writablePath = new Promise();
        shutdown = new Signal0();
        shutdown.connect(handleShutdown).once();
    }

    //Required when reloading
    function handleShutdown ()
    {
        if (_scene == null) {
            Log.error('CocosPlatform already shutdown (_scene is null).');
            return;
        }
        Log.info("CocosPlatform.instance.shutdown..");

        if (rootCocosNode != null) {
            rootCocosNode.unscheduleUpdate();
            rootCocosNode = null;
        }

        if (_cocosListeners != null) {
            for (listener in _cocosListeners) {
                CC.eventManager.removeEventListener(listener);
            }
            _cocosListeners = null;
        }

        flambe.System.root.disposeChildren();
        var comp = flambe.System.root.firstComponent;
        while (comp != null) {
            flambe.System.root.remove(comp);
            comp = comp.next;
        }
        Log.info("Disposed of flambe.System.root children and components...");
        if (_scene != null) {
            _scene.removeAllChildren(true);
            _scene = null;
        }
    }

    public function init ()
    {
        Log.info("init");
        _cocosListeners.push(CC.eventManager.addCustomListener(CC.game.EVENT_HIDE,
            function() {
                Log.info("HIDDEN!!!!!");
                System.hidden._ = true;
            }));
        _cocosListeners.push(CC.eventManager.addCustomListener(CC.game.EVENT_SHOW,
            function() {
                Log.info("SHOWING!!!!!");
                System.hidden._ = false;
            }));

        NativeDispatcher.getWritablePath(
            function(path :String) {
                if (!this.writablePath.hasResult) {
                    this.writablePath.result = path;
                }

                // Log.info('this.writablePath=${this.writablePath} path=$path');
                var G = Global.object();
                if (G.isCocosInitialized) {
                    Log.info("already initialized");
                    initializeInternal();
                    isCocosInitialized.result = true;
                } else {
                    Log.info("CC.game.onStart");
                    CC.game.onStart = function() {
                        Log.info('CC.game.onStart called, now initializeInternal()');
                        initializeInternal();
                        G.isCocosInitialized = true;
                    };
                    CC.game.run();
                    isCocosInitialized.result = true;
                }
            });
    }

    private function initializeInternal()
    {
        Log.info("initializeInternal");

        _stage = new CocosStage();
        _pointer = new BasicPointer();
        _touch = new BasicTouch(_pointer);
        _renderer = new CocosRenderer();

        _scene = CCScene.create();
        if (CC.director.getRunningScene() != null) {
            Log.info("replaceScene");
            CC.director.replaceScene(_scene);
        } else {
            Log.info("pushScene");
            CC.director.pushScene(_scene);
        }

        initTouchLayer();

        //Root node for adding to the hierarchy. Children of this node can be safely removed
        var rootSprite = new RootSprite();
        System.root.add(rootSprite);
        _scene.addChild(rootSprite.ccnode);
        rootCocosNode = rootSprite.ccnode;
        // rootSprite.ccnode;
        // this.rootCocosNode.setPositionY(CC.director.getWinSize().height);
        // _scene.addChild(rootCocosNode);

        //Update every frame
        rootCocosNode.update = update;
        rootCocosNode.scheduleUpdate();

        mainLoop = new MainLoop();
#if debug
        // new DebugLogic(this);
        // _catapult = new CocosCatapultClient();
#end
        Log.info("Initialized Cocos2d-x platform.");
    }

    public function loadAssetPack (manifest :Manifest) :Promise<AssetPack>
    {
        // Log.info('loadAssetPack ${this.writablePath}');
        return new CocosAssetPackLoader(this, manifest).promise;
    }

    public function getStage () :StageSystem
    {
        return _stage;
    }

    public function getStorage () :StorageSystem
    {
        // if (_storage == null) {
        //     // Safely access localStorage (browsers may throw an error on direct access)
        //     // http://dev.w3.org/html5/webstorage/#dom-localstorage
        //     var localStorage = Browser.getLocalStorage();
        //     if (localStorage != null) {
        //         _storage = new HtmlStorage(localStorage);
        //     } else {
        //         Log.warn("localStorage is unavailable, falling back to unpersisted storage");
        //         _storage = new DummyStorage();
        //     }
        // }
        return _storage;
    }

    public function getLocale () :String
    {
        // // https://developer.mozilla.org/en-US/docs/DOM/window.navigator.language
        // var locale = Browser.navigator.language;
        // if (locale == null) {
        //     // IE uses the non-standard userLanguage (or browserLanguage or systemLanguage, but
        //     // userLanguage seems to match String's locale-aware methods)
        //     locale = (untyped Browser.navigator).userLanguage;
        // }
        // return locale;
        return null;
    }

    public function createLogHandler (tag :String) :LogHandler
    {
#if (debug || flambe_keep_logs)
        return new CocosLogHandler(tag);
#else
        return null;
#end
    }

    public function getTime () :Float
    {
        return (untyped Date).now() / 1000;
    }

    public function getCatapultClient ()
    {
        return _catapult;
    }

    private function initTouchLayer()
    {
        if (_touchLayer != null) {
            _touchLayer.removeFromParent(true);
            _touchLayer = null;
        }

        _touchLayer = CCLayerColor.create(CC.color(255, 255, 0, 100), _stage.width, _stage.height);
        _scene.addChild(_touchLayer, 0);

        CC.eventManager.addListener(
            {
                event:CCEventListener.TOUCH_ONE_BY_ONE,
                swallowTouches:true,
                onTouchBegan:function(touch :CCTouch, event :Dynamic) {
                    // Log.info('down [${touch.getLocationX()} ${touch.getLocationY()}]');
                    _touch.submitDown(touch.getId(), touch.getLocationX(), _stage.height - touch.getLocationY());
                    return true;
                },
                onTouchMoved:function(touch :CCTouch, event :Dynamic) {
                    // Log.info('move [${touch.getLocationX()} ${touch.getLocationY()}]');
                    _touch.submitMove(touch.getId(), touch.getLocationX(), _stage.height - touch.getLocationY());
                    return true;
                },
                onTouchEnded:function(touch :CCTouch, event :Dynamic) {
                    // Log.info('up [${touch.getLocationX()} ${touch.getLocationY()}]');
                    _touch.submitUp(touch.getId(), touch.getLocationX(), _stage.height - touch.getLocationY());
                    return true;
                }
            }, _touchLayer);
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
        try {
            mainLoop.update(dt);
        } catch (e :Dynamic) {
            Log.error("Exception in update " + e + "\n" + haxe.CallStack.toString(haxe.CallStack.callStack()));
        }
        // trace(flambe.platform.cocos2dx.CocosTools.getHierarchyString().toString());
        //Cocos uses retained mode rendering, not immediate mode.
        // mainLoop.render(_renderer);
    }

    public function getPointer () :PointerSystem
    {
        return _pointer;
    }

    public function getMouse () :MouseSystem
    {
        return _mouse;
    }

    public function getTouch () :TouchSystem
    {
        return _touch;
    }

    public function getKeyboard () :KeyboardSystem
    {
        // if (_keyboard == null) {
        //     _keyboard = new BasicKeyboard();
        //     var onKey = function (event :KeyboardEvent) {
        //         switch (event.type) {
        //         case "keydown":
        //             if (_keyboard.submitDown(event.keyCode)) {
        //                 event.preventDefault();
        //             }
        //         case "keyup":
        //             _keyboard.submitUp(event.keyCode);
        //         }
        //     };
        //     _canvas.addEventListener("keydown", onKey, false);
        //     _canvas.addEventListener("keyup", onKey, false);
        // }
        return _keyboard;
    }

    public function getWeb () :WebSystem
    {
        // if (_web == null) {
        //     _web = new HtmlWeb(_container);
        // }
        return _web;
    }

    public function getExternal () :ExternalSystem
    {
        // if (_external == null) {
        //     _external = new HtmlExternal();
        // }
        return _external;
    }

    public function getMotion () :MotionSystem
    {
        // if (_motion == null) {
        //     _motion = new HtmlMotion();
        // }
        return _motion;
    }

    public function getRenderer () :InternalRenderer<Dynamic>
    {
        return _renderer;
    }

    // Statically initialized subsystems
    private var _mouse :BasicMouse;
    private var _pointer :BasicPointer;
    private var _renderer :InternalRenderer<Dynamic>;
    private var _stage :CocosStage;
    private var _touch :BasicTouch;

    // Lazily initialized subsystems
    private var _external :ExternalSystem;
    private var _keyboard :BasicKeyboard;
    private var _motion :MotionSystem;
    private var _storage :StorageSystem;
    private var _web :WebSystem;

    private var _skipFrame :Bool;

    public var _scene :CCScene;
    private var _touchLayer :CCLayer;

    private var _catapult :CocosCatapultClient;

    private var _cocosListeners :Array<CCEventListenerCustom>;
}

class RootSprite extends flambe.display.Sprite //flambe.display.FillSprite
{
    public function new()
    {
        super();
        ccnode = createCCNode();
        ccnode.retain();
        // super(2, 100, 100);
    }

    override public function onAdded()
    {
        super.onAdded();
        ccnode = cc.Cocos2dx.CCNode.create();
        flambe.display.Sprite.NODE_SPRITE_MAP[ccnode] = this;
        ccnode.retain();
        trace("height=" + CC.director.getWinSize().height);
        ccnode.setPositionY(CC.director.getWinSize().height);
// #if debug
//         for (i in 0...10) {
//             for (j in 0...10) {
//                 var dot :cc.Cocos2dx.CCNode = untyped __js__('cc.LayerColor.create(cc.color(255,255,255,255), 2, 2)');
//                 dot.setPosition(i * 100 - 1, j * -100 - 1);
//                 ccnode.addChild(dot);
//             }
//         }
// #end
        cocosYOffset = 0;
    }

    override public function validateCCNode() {}

    override public function onUpdate (dt :Float)
    {
        // super.onUpdate(dt);
        // Log.info("ccnode.getPositionY" + ccnode.getPositionY());
    }

    override public function getCocosChildrenOffsetX() :Float
    {
        return 0;
    }
    override public function getCocosChildrenOffsetY() :Float
    {
        return 0;
    }
}
