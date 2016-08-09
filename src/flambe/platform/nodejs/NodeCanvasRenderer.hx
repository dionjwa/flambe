//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.subsystem.RendererSystem;
import flambe.util.Assert;
import flambe.util.Value;

import js.npm.canvas.NodeCanvas;

class NodeCanvasRenderer
    implements InternalRenderer<Dynamic>
{
    public var graphics :InternalGraphics;
    public var hasGPU (get, null) :Value<Bool>;
    public var type (get, null) :RendererType;

    public var frame (get, null) :Int;

    public function new (width :Int, height :Int)
    {
        graphics = new NodeCanvasGraphics(width, height);
        _hasGPU = new Value(false);
        _type = RendererType.Canvas;
    }

    public function createTextureFromImage (data :Dynamic) :Texture
    {
        var root = new NodeCanvasTextureRoot(data);
        return root.createTexture(root.width, root.height);
    }

    public function createTexture (width :Int, height :Int) :Texture
    {
        var textureGraphics = new NodeCanvasGraphics(width, height);
        textureGraphics.setAlpha(0);
        textureGraphics.fillRect(0x000000, 0, 0, width, height);
        textureGraphics.setAlpha(1);
        var image = new NodeCanvasImage();
        image.src = textureGraphics.canvas.toBuffer();
        return createTextureFromImage(image);
    }

    public function getCompressedTextureFormats () :Array<AssetFormat>
    {
        return [];
    }

    public function createCompressedTexture (format :AssetFormat, data :Bytes) :Texture
    {
        Assert.fail(); // Unsupported
        return null;
    }

    public function willRender ()
    {
        graphics.willRender();
    }

    public function didRender ()
    {
        graphics.didRender();
    }

    public function getName () :String
    {
        return "NodeCanvas";
    }

    private function get_frame() :Int
    {
        return cast (graphics, NodeCanvasGraphics).frame;
    }

    private function get_hasGPU() :Value<Bool>
    {
        return _hasGPU;
    }

    private function get_type() :RendererType
    {
        return _type;
    }

    private var _hasGPU :Value<Bool>;
    private var _type :RendererType;
}