package cc;

import js.html.XMLHttpRequest;

@:native("jsb")
extern class JSB
{
	public static var fileUtils :CCFileUtils;
}

@:native("Ref")
extern class Ref
{
	public function retain() :Void;
	public function release() :Void;
	public function autorelease () :Ref;
	public function getReferenceCount() :Int;
}

@:native("cc.kmMat4")
extern class CCMat4
{
	public var mat :Array<Float>;//16 elements
}

@:native("cc.Rect")
extern class CCRect
{
	public var x :Float;
	public var y :Float;
	public var width :Float;
	public var height :Float;
}

@:native("cc.Point")
extern class CCPoint
{
	public var x :Float;
	public var y :Float;
}

@:native("cc.Size")
extern class CCSize
{
	public var width :Float;
	public var height :Float;
}

@:native("cc.Touch")
extern class CCTouch
{
	public function getLocationX() :Float;
	public function getLocationY() :Float;
	public function getLocation() :CCPoint;
	public function getId() :Int;
}

@:native("cc.Color")
extern class CCColor
{
}

extern class Game
{
	public var EVENT_HIDE :String;
	public var EVENT_SHOW :String;
	public var onStart :Void->Void;
	public function run() :Void;
}

@:native("cc.Image")
extern class CCImage
{
	public static function initWithImageFile (path :String) :CCImage;
	public function getWidth() :Int;
	public function getHidth() :Int;
}

@:native("cc.Texture2D")
extern class CCTexture2D
{
	public static function initWithImage (image :CCImage) :CCTexture2D;
	public function getPixelsWide() :Int;
	public function getPixelsHigh() :Int;
	public var url :String;
}

@:native("cc.SpriteFrame")
extern class CCSpriteFrame extends Ref
{
	public static function create (texture :CCTexture2D, rect :CCRect) :CCSpriteFrame;
}

@:native("cc.Sprite")
extern class CCSprite extends CCNode
{
	// public static function initWithTexture (texture :CCTexture2D, rect :CCRect) :CCSprite;
	public static function create (spriteFrame :CCSpriteFrame) :CCSprite;
	public var textureAtlas :Dynamic;
	//{src: cc.BLEND_SRC, dst: cc.BLEND_DST};
	//src=cc.SRC_ALPHA
	//dst=cc.ONE,cc.BLEND_SRC, cc.BLEND_DST
	public function setBlendFunc(src :Dynamic, dst :Dynamic) :Void;
}

@:native("cc.Node")
extern class CCNode extends Ref
{
	public static function create() :CCNode;
	@:overload(function(node :CCNode,?zOrder:Int):Void {})
	public function addChild(node :CCNode) :Void;
	public function removeFromParent(cleanup :Bool) :Void;
	public function removeAllChildren(cleanup :Bool) :Void;
	public function setAnchorPoint(x :Float, y :Float) :Void;
	public function setOpacity(x :Int) :Void;
	public function getOpacity() :Int;
	public function setRotation(x :Float) :Void;
	public function setScaleX(x :Float) :Void;
	public function setScaleY(y :Float) :Void;
	public function getScaleX() :Void;
	public function getScaleY() :Void;
	public function setRotationSkewX(x :Float) :Void;
	public function setRotationSkewY(y :Float) :Void;
	public function setVisible(visible :Bool) :Void;
	public function isVisible() :Bool;
	// public function getParent() :CCNode;
	public var parent :CCNode;
	public var children :Array<CCNode>;
	public var childrenCount :Int;
	public var x :Float;
	public var y :Float;

	public function setPositionX(val :Float) :Void;
	public function setPositionY(val :Float) :Void;
	public function setPosition(x :Float, y :Float) :Void;
	public function getPositionY() :Float;
	public function getPositionX() :Float;
	public function setAdditionalTransform(arguments :Dynamic):Void;

	public function scheduleUpdate() :Void;
	public function unscheduleUpdate() :Void;
	dynamic public function update(dt :Float) :Void;

	public var userData :Dynamic;
}

@:native("cc.Layer")
extern class CCLayer extends CCNode
{
	public static function create() :CCLayer;

	// public function setTouchEnabled(val :Bool) :Void;
	public function changeWidthAndHeight(width :Float, height :Float) :Void;

	// public var onTouchesBegan :Array<CCTouch>->Dynamic->Bool;
	// public var onTouchesMoved :Array<CCTouch>->Dynamic->Bool;
	// public var onTouchesEnded :Array<CCTouch>->Dynamic->Bool;
}

@:native("cc.LayerColor")
extern class CCLayerColor extends CCLayer
{
	public static function create(color :CCColor, width :Int, height :Int) :CCLayerColor;
	public function new(color :CCColor, width :Int, height :Int) :Void;
	public function setColor(color :CCColor) :Void;
}

@:native("cc.Scene")
extern class CCScene extends CCNode
{
	public static function create() :CCScene;
}

@:native("cc.CCScheduler")
extern class CCScheduler
{
	public function scheduleCallbackForTarget(target :Dynamic, callback_fn :Dynamic, interval :Float, repeat :Bool, delay :Float, paused :Bool) :Void;
	public function unscheduleCallbackForTarget(target :Dynamic, callback_fn :Dynamic) :Void;
}

@:native("cc.Director")
extern class CCDirector
{
	public function getWinSize() :CCSize;
	public function pushScene(ccnode :CCScene) :Void;
	public function replaceScene(ccnode :CCScene) :Void;
	public function getScheduler() :CCScheduler;
	public function getRunningScene() :CCScene;
}

@:native("cc.CCTextureCache")
extern class CCTextureCache
{
	@:overload(function(imagePath :String):CCTexture2D {})
	public function addImage(imagePath :String, cb :CCTexture2D->Void) :CCTexture2D;
}

// @:native("cc.EGLView")
// extern class EGLView
// {
// 	public function getFrameSize() :CCSize;
// }

@:native("cc.Loader")
extern class CCLoader
{
	public function getXMLHttpRequest() :XMLHttpRequest;
}

@:native("cc.FileUtils")
extern class CCFileUtils
{
	public static function getInstance() :CCFileUtils;
	public function fullPathFromRelativeFile(arg1 :String, arg2 :String) :String;
	public function purgeCachedEntries() :Void;
	public function isFileExist(path :String) :Bool;
	public function isAbsolutePath(path :String) :Bool;
	public function getStringFromFile(path :String) :String;
	public function fullPathForFilename(path :String) :String;
	public function addSearchPath(path :String) :Void;
	public function addSearchResolutionsOrder(path :String) :Void;
	public function getValueMapFromFile(key :String) :Dynamic;
	public function writeToFile(map :Dynamic, path :String) :Dynamic;
	public function getValueVectorFromFile(key :String) :Array<Dynamic>;
	public function loadFilenameLookupDictionaryFromFile(key :String) :Void;
}

@:native("cc.EventListenerCustom")
extern class CCEventListenerCustom
{
	public function addCustomListener(eventId :String, cb :Dynamic) :CC;
}


typedef EventListenerJson = {
	var event :Int;
	var swallowTouches: Bool;
	var onTouchBegan :CCTouch->Dynamic->Void;
	var onTouchMoved :CCTouch->Dynamic->Void;
	var onTouchEnded :CCTouch->Dynamic->Void;
}

@:native("cc.EventListener")
extern class CCEventListener
{
	public static var TOUCH_ONE_BY_ONE :Int;
	public static var TOUCH_ALL_AT_ONCE :Int;
	public static var KEYBOARD :Int;
	public static var MOUSE :Int;
	public static var ACCELERATION :Int;
	public static var FOCUS :Int;
	public static var CUSTOM :Int;
}

@:native("cc.EventManager")
extern class CCEventManager
{
	public function addCustomListener(eventId :String, cb :Dynamic) :CCEventListenerCustom;
	public function addListener(eventListenerObject :EventListenerJson, node :Dynamic) :CCEventListenerCustom;
	public function removeEventListener(listener :CCEventListenerCustom) :Void;
}

@:native("cc")
extern class CC
{
	public static function rect(x :Float, y :Float, width :Float, height :Float) :CCRect;
	public static function color(r :Int, g :Int, b :Int, a :Int) :CCColor;
	public static function p(x :Float, y :Float) :CCPoint;
	public static function log(msg :String) :Void;
	public static var game :Game;
	// public static var view :EGLView;
	public static var director :CCDirector;
	public static var textureCache :CCTextureCache;
	public static var loader :CCLoader;
	public static var FileUtils :CCFileUtils;
	public static var eventManager :CCEventManager;
	public static var sys :Dynamic;

	/* Matrix methods*/
	public static function kmMat4Fill(pOut :CCMat4, pMat :Array<Float>) :Void;
}

@:native("WebSocket")
extern class WebSocket
{
	public function new (address :String) :Void;
	public var readyState :Int;
	public var onopen :Dynamic->Void;
	public var onmessage :Dynamic->Void;
	public var onerror :Dynamic->Void;
	public var onclose :Dynamic->Void;
	public function send (message :String) :Void;
	public function close () :Void;
}
