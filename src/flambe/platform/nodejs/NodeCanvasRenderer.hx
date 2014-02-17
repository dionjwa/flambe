//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import haxe.io.Bytes;

import flambe.asset.AssetEntry;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.util.Assert;

import js.node.NodeCanvasImage;

class NodeCanvasRenderer
    implements Renderer
{
    public var graphics :InternalGraphics;
    public var frame (get, null) :Int;

    public function new (width :Int, height :Int)
    {
        graphics = new NodeCanvasGraphics(width, height);
        System.hasGPU._ = false;
    }

    public function createTexture (image :Dynamic) :Texture
    {
        return new NodeCanvasTexture(image);
    }

    public function createEmptyTexture (width :Int, height :Int) :Texture
    {
        var textureGraphics = new NodeCanvasGraphics(width, height);
        textureGraphics.setAlpha(0);
        textureGraphics.fillRect(0x000000, 0, 0, width, height);
        textureGraphics.setAlpha(1);
        var image = new NodeCanvasImage();
        image.src = textureGraphics.canvas.toBuffer();
        return new NodeCanvasTexture(image);
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
}
