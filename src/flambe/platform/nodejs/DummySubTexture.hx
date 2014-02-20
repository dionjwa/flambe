package flambe.platform.nodejs;

import flambe.display.Texture;
import flambe.display.SubTexture;

class DummySubTexture extends DummyTexture
	implements SubTexture
{
	public var parent (get, null) :Texture;
	public var x (get, null) :Int;
	public var y (get, null) :Int;

	public function new(parent :Texture)
	{
		super();
		_parent = parent;
		_x = 0;
		_y = 0;
	}

	function get_parent() :Texture
	{
		return _parent;
	}

	function get_x() :Int
	{
		return _x;
	}

	function get_y() :Int
	{
		return _y;
	}

	private var _parent :Texture;
	private var _x :Int;
	private var _y :Int;
}