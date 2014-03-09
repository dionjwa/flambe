package flambe.platform.nodejs;

import flambe.display.Texture;
import flambe.asset.AssetEntry;
import flambe.platform.InternalRenderer;
import flambe.subsystem.RendererSystem;
import flambe.display.Graphics;
import flambe.util.Value;

import haxe.io.Bytes;

class DummyRenderer
	implements InternalRenderer<Dynamic>
{
	public var graphics :InternalGraphics;
    public var type (get, null) :RendererType;
    public var hasGPU (get, null) :Value<Bool>;

	public function new() {}

    public function createTexture (width :Int, height :Int) :Texture
    {
    	return new DummyTexture();
    }

    public function createTextureFromImage (image :Dynamic) :Texture
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

    function get_type():RendererType
    {
        return null;
    }

    function get_hasGPU() :Value<Bool>
    {
        return null;
    }
}
