//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import haxe.io.Bytes;
import js.node.NodeCanvasImage;
import js.node.NodeCanvasElement;
import js.node.NodeCanvasRenderingContext2D;

import js.Node;

import flambe.display.Graphics;
import flambe.display.Texture;
import flambe.util.Assert;

class NodeCanvasTexture extends BasicAsset<NodeCanvasTexture>
    implements Texture
{
    public var width (get, null) :Int;
    public var height (get, null) :Int;
    public var graphics (get, null) :Graphics;

    // The Image used for draw calls
    public var image (default, null) :NodeCanvasImage;

    // The CanvasPattern required for drawPattern, lazily created on demand
    public var pattern :CanvasPattern = null;

    public function new (image :NodeCanvasImage)//, ?canvas :NodeCanvasElement)
    {
        super();
        this.image = image;
    }

    public function readPixels (x :Int, y :Int, width :Int, height :Int) :Bytes
    {
        assertNotDisposed();

        var data :NodeBuffer = getContext2d().getImageData(x, y, width, height).data;
        return Bytes.ofData(data);
    }

    public function writePixels (pixels :Bytes, x :Int, y :Int, sourceW :Int, sourceH :Int)
    {
        assertNotDisposed();

        var ctx2d = getContext2d();
        var imageData = ctx2d.createImageData(sourceW, sourceH);
        var data :Dynamic = imageData.data;
        if (data.set != null) {
            // Data is a Uint8ClampedArray, copy it in one swoop
            data.set(pixels.getData());
        } else {
            // Data is a normal array, copy it manually
            var size = 4*sourceW*sourceH;
            for (ii in 0...size) {
                data[ii] = pixels.get(ii);
            }
        }

        // // Draw the pixels, and invalidate our contents
        ctx2d.putImageData(imageData, x, y);
        dirtyContents();
    }

    inline public function dirtyContents ()
    {
        pattern = null;
        if (_graphics != null) {
            this.image.src = _graphics.canvas.toBuffer();
        }
    }

    inline private function get_width () :Int
    {
        assertNotDisposed();

        return this.image.width;
    }

    inline private function get_height () :Int
    {
        assertNotDisposed();

        return this.image.height;
    }

    private function get_graphics () :NodeCanvasGraphics
    {
        assertNotDisposed();

        if (_graphics == null) {
            _graphics = new InternalGraphics(this);
        }
        return _graphics;
    }

    private function getContext2d () :NodeCanvasRenderingContext2D
    {
        return get_graphics().canvas.getContext2d();
    }

    override private function copyFrom (that :NodeCanvasTexture)
    {
        this.image = that.image;
        this.pattern = that.pattern;
        this._graphics = that._graphics;
    }

    override private function onDisposed ()
    {
        this.image = null;
        pattern = null;
        _graphics = null;
    }

    //The optional canvas graphics.  This is only instantiated if draw calls were done
    private var _graphics :InternalGraphics = null;
}

// A Graphics that invalidates its texture's cached pattern after every draw call
private class InternalGraphics extends NodeCanvasGraphics
{
    public function new (renderTarget :NodeCanvasTexture)
    {
        super(renderTarget.width, renderTarget.height);
        this.canvas.getContext2d().drawImage(renderTarget.image, 0, 0);
        _renderTarget = renderTarget;
    }

    override public function drawImage (texture :Texture, x :Float, y :Float)
    {
        super.drawImage(texture, x, y);
        _renderTarget.dirtyContents();
    }

    override public function drawSubImage (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        super.drawSubImage(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
        _renderTarget.dirtyContents();
    }

    override public function drawPattern (texture :Texture, x :Float, y :Float,
        width :Float, height :Float)
    {
        super.drawPattern(texture, x, y, width, height);
        _renderTarget.dirtyContents();
    }

    override public function fillRect (color :Int, x :Float, y :Float, width :Float, height :Float)
    {
        super.fillRect(color, x, y, width, height);
        _renderTarget.dirtyContents();
    }

    private var _renderTarget :NodeCanvasTexture;
}
