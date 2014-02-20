package flambe.platform.nodejs;

import flambe.display.Texture;
import flambe.display.SubTexture;
import flambe.asset.AssetEntry;
import flambe.platform.BasicAsset;
import haxe.io.Bytes;
import flambe.display.Graphics;

class DummyTexture extends flambe.platform.BasicAsset<DummyTexture>
	implements Texture

{
	public var width (get, null) :Int;
    public var height (get, null) :Int;
    public var graphics (get, null) :Graphics;

	public function new ()
	{
		super();
	}

	function get_width() :Int
	{
		return 0;
	}

	function get_height() :Int
	{
		return 0;
	}

	function get_graphics() :Graphics
	{
		return null;
	}

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
    	return Bytes.ofString("");
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int) :Void
    {
    }

    public function subTexture (x :Int, y :Int, width :Int, height :Int) :SubTexture
    {
    	return new DummySubTexture(this);
    }
}