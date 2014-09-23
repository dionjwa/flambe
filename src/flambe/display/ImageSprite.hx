//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

/**
 * A fixed-size sprite that displays a single texture.
 */
class ImageSprite extends Sprite
{
    /**
     * The texture being displayed, or null if none.
     */
    public var texture :Texture;

    override public function createCCNode()
    {
        // Log.info("ImageSprite.createCCNode");
        var spriteFrameTexture :flambe.platform.cocos2dx.CocosSpriteFrameTexture = cast texture;
        // Log.info("spriteFrameTexture=" + spriteFrameTexture);
        cocosYOffset = spriteFrameTexture.height;
        // Log.info("spriteFrameTexture.spriteFrame=" + spriteFrameTexture.spriteFrame);
        // var spriteFrame = spriteFrameTexture.get_spriteFrame();
        return cc.Cocos2dx.CCSprite.create(spriteFrameTexture.spriteFrame);
    }

    public function new (texture :Texture)
    {
        super();
        this.texture = texture;
    }

    override public function draw (g :Graphics)
    {
        if (texture != null) {
            g.drawTexture(texture, 0, 0);
        }
    }

    override public function getNaturalWidth () :Float
    {
        return (texture != null) ? texture.width : 0;
    }

    override public function getNaturalHeight () :Float
    {
        return (texture != null) ? texture.height : 0;
    }
}
