package flambe.platform.cocos2dx;

import cc.Cocos2dx;

import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.util.Assert;

import haxe.io.Bytes;

class CocosTextureRoot extends BasicAsset<CocosTextureRoot>
    implements TextureRoot
{
    public var width (default, null) :Int;
    public var height (default, null) :Int;

    // The Image (or sometimes Canvas) used for most draw calls
    public var ccTexture (get, null) :CCTexture2D;

    public var updateCount :Int = 0;

    public function new (texture2D :CCTexture2D, fileName :String)
    {
        super();
        _textureFileName = fileName;
        Assert.that(texture2D != null, "texture2D is null");
        Log.info("CocosTextureRoot.new texture2D=" + texture2D);
        width = ccTexture.getPixelsWide();
        height = ccTexture.getPixelsHigh();
        _graphics = new CocosGraphics();
    }

    public function createTexture (width :Int, height :Int) :CocosSpriteFrameTexture
    {
        return new CocosSpriteFrameTexture(this, width, height);
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
    	throw "readPixels unimplemented";
    	return null;
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
    	throw "writePixels unimplemented";
    	return null;
    }

    public function getGraphics () :CocosGraphics
    {
        assertNotDisposed();
        if (_graphics == null) {
            _graphics = new CocosGraphics();
        }
        return _graphics;
    }

    override private function copyFrom (that :CocosTextureRoot)
    {
        this.ccTexture = that.ccTexture;
    }

    override private function onDisposed ()
    {
        ccTexture = null;
    }

    function get_ccTexture() :CCTexture2D
    {
        var texture2d :CCTexture2D = CC.textureCache.addImage(_textureFileName);
        return texture2d;
    }

    private var _textureFileName :String;
    private var _graphics :CocosGraphics = null;
}
