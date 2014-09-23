//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.display;

import flambe.animation.AnimatedFloat;
import flambe.util.Value;

/**
 * A sprite that displays a rectangle filled with a given color.
 */
class FillSprite extends Sprite
{
    public var color :Int;
    public var width (default, null) :AnimatedFloat;
    public var height (default, null) :AnimatedFloat;

    public function new (color :Int, width :Float, height :Float)
    {
        super();
        this.color = color;
        this.width = new AnimatedFloat(width);
        this.height = new AnimatedFloat(height);
    }

    override public function draw (g :Graphics)
    {
        g.fillRect(color, 0, 0, width._, height._);
    }

    override public function getNaturalWidth () :Float
    {
        return width._;
    }

    override public function getNaturalHeight () :Float
    {
        return height._;
    }

    /**
     * Chainable convenience method to set the width and height.
     * @returns This instance, for chaining.
     */
    public function setSize (width :Float, height :Float) :FillSprite
    {
        this.width._ = width;
        this.height._ = height;
        return this;
    }

    override public function onUpdate (dt :Float)
    {
        width.update(dt);
        height.update(dt);
#if cocos2dx
        cast(ccnode, cc.Cocos2dx.CCLayerColor).changeWidthAndHeight(width._, height._);
        ccnode.setPositionY(ccnode.getPositionY() - (height._ - anchorY._));
        var Blue = color & 255;
        var Green = (color >> 8) & 255;
        var Red = (color >> 16) & 255;
        var color = cc.Cocos2dx.CC.color(Red, Green, Blue, ccnode.getOpacity());
        cast(ccnode, cc.Cocos2dx.CCLayerColor).setColor(color);
#end
        super.onUpdate(dt);
    }

#if cocos2dx
    override function createCCNode()
    {
        var Blue = color & 255;
        var Green = (color >> 8) & 255;
        var Red = (color >> 16) & 255;
        var color = cc.Cocos2dx.CC.color(Red, Green, Blue, 255);
        return new cc.Cocos2dx.CCLayerColor(color, Std.int(width._), Std.int(height._));
    }

    override public function getCocosChildrenOffsetX() :Float
    {
        return anchorX._;
    }
    override public function getCocosChildrenOffsetY() :Float
    {
        return getNaturalHeight() - anchorY._;
    }

    override public function getCocosOffsetX() :Float
    {
        return -anchorX._ + super.getCocosOffsetX();
    }
    override public function getCocosOffsetY() :Float
    {
        return -(getNaturalHeight() - anchorY._);
    }
#end
}
