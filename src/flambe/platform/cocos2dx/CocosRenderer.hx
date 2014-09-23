//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.cocos2dx;

import cc.Cocos2dx;

import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.subsystem.RendererSystem;
import flambe.util.Assert;
import flambe.util.Value;

class CocosRenderer
    implements InternalRenderer<CCTexture2D>
{
    public var type (get, null) :RendererType;
    public var hasGPU (get, null) :Value<Bool>;

    public var graphics :InternalGraphics;

    public function new ()
    {
        // graphics = new CanvasGraphics(canvas);
        _hasGPU = new Value<Bool>(true);//Always true
    }

    inline private function get_type () :RendererType
    {
        return Canvas;
    }

    inline private function get_hasGPU () :Value<Bool>
    {
        return _hasGPU;
    }

    public function createTextureFromImage (image :CCTexture2D) :CocosSpriteFrameTexture
    {
        var root = new CocosTextureRoot(image, image.url);
        return root.createTexture(root.width, root.height);
    }

    public function createTexture (width :Int, height :Int) :CocosSpriteFrameTexture
    {
        throw "createTextureFromImage not implemented";
        return null;
        // var root = new CanvasTextureRoot(HtmlUtil.createEmptyCanvas(width, height));
        // return root.createTexture(width, height);
    }

    public function getCompressedTextureFormats () :Array<AssetFormat>
    {
        return [];
    }

    public function createCompressedTexture (format :AssetFormat, data :Bytes) :CocosSpriteFrameTexture
    {
        Assert.fail(); // Unsupported
        return null;
    }

    public function willRender ()
    {
        throw "willRender not implemented";
        // graphics.willRender();
    }

    public function didRender ()
    {
        throw "didRender not implemented";
        // graphics.didRender();
    }

    public function getName () :String
    {
        return "Cocos2dx";
    }

    private var _hasGPU :Value<Bool>;
}
