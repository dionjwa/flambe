//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.cocos2dx;

import flambe.display.BlendMode;
import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.math.FMath;

// TODO(bruno): Remove pixel snapping once most browsers get canvas acceleration.
class CocosGraphics
    implements InternalGraphics
{
    public function new ()
    {
    }

    public function save ()
    {
    }

    public function translate (x :Float, y :Float)
    {
    }

    public function scale (x :Float, y :Float)
    {
    }

    public function rotate (rotation :Float)
    {
    }

    public function transform (m00 :Float, m10 :Float, m01 :Float, m11 :Float, m02 :Float, m12 :Float)
    {
    }

    public function restore ()
    {
    }

    public function drawTexture (texture :Texture, destX :Float, destY :Float)
    {
    }

    public function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
    }

    public function drawPattern (texture :Texture, x :Float, y :Float, width :Float, height :Float)
    {
    }

    public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
    }

    public function multiplyAlpha (factor :Float)
    {
    }

    public function setAlpha (alpha :Float)
    {
    }

    public function setBlendMode (blendMode :BlendMode)
    {
    }

    public function applyScissor (x :Float, y :Float, width :Float, height :Float)
    {
    }

    public function willRender ()
    {
    }

    public function didRender ()
    {
        // Nothing at all
    }

    public function onResize (width :Int, height :Int)
    {
        // Nothing at all
    }

}
