package flambe.platform.cocos2dx;

import cc.Cocos2dx;

import flambe.display.Texture;

import haxe.io.Bytes;

class CocosSpriteFrameTexture extends BasicTexture<CocosTextureRoot>
{
	public var spriteFrame (get, null):CCSpriteFrame;

	public function new (root :CocosTextureRoot, width :Int, height :Int)
    {
        super(root, width, height);
    }

    override public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
    	throw "readPixels not implemented";
        return null;
    }

    override public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        throw "writePixels not implemented";
        return null;
    }

    function get_spriteFrame() :CCSpriteFrame
    {
    	if (_spriteFrame == null) {
            Log.info('Creating CCSpriteFrame[${rootX + x} ${rootY + y} ${width} ${height}] rootX=$rootX rootY=$rootY');
    		// _spriteFrame = CCSpriteFrame.create(root.ccTexture, CC.rect(rootX + x, rootY + y, width, height));
            // _spriteFrame = CCSpriteFrame.create(root.ccTexture, CC.rect(1, 1, 100, 100));
            _spriteFrame = CCSpriteFrame.create(root.ccTexture, CC.rect(x, y, width, height));
            _spriteFrame.retain();
    	}
    	return _spriteFrame;
    }

    override private function onDisposed ()
    {
        super.onDisposed();
        if (_spriteFrame != null) {
            _spriteFrame.release();
            _spriteFrame = null;
        }
    }

    var _spriteFrame :CCSpriteFrame;
}