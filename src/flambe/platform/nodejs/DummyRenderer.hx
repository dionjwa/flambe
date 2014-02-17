package flambe.platform.nodejs;

import flambe.display.Texture;
import flambe.asset.AssetEntry;
import haxe.io.Bytes;
import flambe.display.Graphics;
import flambe.platform.Renderer;

class DummyRenderer
	implements Renderer
{
	public var graphics :InternalGraphics;

	public function new() {}

    public function createTexture (data :Dynamic) :Texture
    {
    	return new DummyTexture();
    }

    public function createEmptyTexture (width :Int, height :Int) :Texture
    {
    	return new DummyTexture();
    }

    public function getCompressedTextureFormats () :Array<AssetFormat>
    {
    	return [];
    }

    public function createCompressedTexture (format :AssetFormat, data :Bytes) :Texture
    {
    	return new DummyTexture();
    }

    public function willRender () :Void
    {
    }

    public function didRender () :Void
    {
    }

    public function getName () :String
    {
    	return "Headless";
    }

    public function onResize (width :Int, height :Int) :Void
    {
    }
}
