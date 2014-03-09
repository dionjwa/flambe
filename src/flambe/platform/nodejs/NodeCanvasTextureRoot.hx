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

class NodeCanvasTextureRoot extends BasicAsset<NodeCanvasTextureRoot>
    implements TextureRoot
{
    public var width (default, null) :Int;
    public var height (default, null) :Int;

    // The Image used for draw calls
    public var image (default, null) :NodeCanvasImage;

    public var updateCount :Int = 0;

    public function new (image :NodeCanvasImage)
    {
        super();
        this.image = image;
        this.width = image.width;
        this.height = image.height;
        Assert.that(this.image != null);
    }

    public function getGraphics () :Graphics
    {
        assertNotDisposed();

        if (_graphics == null) {
            _graphics = new InternalGraphics(this);
        }
        return _graphics;
    }

    public function createTexture (width :Int, height :Int) :Texture
    {
        return new NodeCanvasTexture(this, width, height);
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

        // Draw the pixels, and invalidate our contents
        ctx2d.putImageData(imageData, x, y);
        dirtyContents();
    }

    public function createPattern (x :Int, y :Int, width :Int, height :Int) :Dynamic//CanvasPattern
    {
        var ctx2d = getContext2d();
        var source = image;
        if (x != 0 || y != 0 || width != this.width || height != this.height) {
            // Create a temporary canvas if the size doesn't match this root
            var canvas = new NodeCanvasElement(width, height);
            var crop = canvas.getContext2d();
            crop.globalCompositeOperation = "copy";
            crop.drawImage(image, -x, -y);
            source = new NodeCanvasImage();
            source.src = canvas.toBuffer();
        }
        return ctx2d.createPattern(source, "repeat");
    }

    // Invalidates the cached patterns of all textures using this root
    inline public function dirtyContents ()
    {
        ++updateCount;
        if (_graphics != null) {
            this.image.src = _graphics.canvas.toBuffer();
        }
    }

    private function getContext2d () :NodeCanvasRenderingContext2D
    {
        getGraphics();
        return _graphics.canvas.getContext2d();
    }

    override private function copyFrom (that :NodeCanvasTextureRoot)
    {
        this.image = that.image;
        this._graphics = that._graphics;
        dirtyContents();
    }

    override private function onDisposed ()
    {
        this.image = null;
        _graphics = null;
    }

    //The optional canvas graphics.  This is only instantiated if draw calls were done
    private var _graphics :InternalGraphics = null;
}

// A Graphics that invalidates its texture's cached pattern after every draw call
private class InternalGraphics extends NodeCanvasGraphics
{
    public function new (renderTarget :NodeCanvasTextureRoot)
    {
        super(renderTarget.width, renderTarget.height);
        this.canvas.getContext2d().drawImage(renderTarget.image, 0, 0);
        _renderTarget = renderTarget;
    }

    override public function drawTexture (texture :Texture, x :Float, y :Float)
    {
        super.drawTexture(texture, x, y);
        _renderTarget.dirtyContents();
    }

    override public function drawSubTexture (texture :Texture, destX :Float, destY :Float,
        sourceX :Float, sourceY :Float, sourceW :Float, sourceH :Float)
    {
        super.drawSubTexture(texture, destX, destY, sourceX, sourceY, sourceW, sourceH);
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

    private var _renderTarget :NodeCanvasTextureRoot;
}
