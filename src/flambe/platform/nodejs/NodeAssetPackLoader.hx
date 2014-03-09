//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import js.Node;
import js.node.NodeCanvasImage;

import flambe.asset.AssetEntry;
import flambe.asset.Manifest;
import flambe.util.Assert;
import flambe.util.Promise;
import flambe.util.Signal0;
import flambe.util.Signal1;

class NodeAssetPackLoader extends BasicAssetPackLoader
{
    public function new (platform :NodePlatform, manifest :Manifest)
    {
        super(platform, manifest);
    }

    override private function loadEntry (url :String, entry :AssetEntry)
    {
        switch (entry.format) {
        case PNG, JPG, GIF:
            if (NodePlatform.instance.isCanvasRendererAvailable) {
                var data = Node.fs.readFileSync(url);
                var image = new NodeCanvasImage();
                image.src = cast data;
                var texture = _platform.getRenderer().createTextureFromImage(image);
                if (texture != null) {
                    Node.setImmediate(handleLoad.bind(entry, texture));
                } else {
                    handleTextureError(entry);
                }
            } else {
                Node.setImmediate(handleLoad.bind(entry, _platform.getRenderer().createTexture(0, 0)));
            }

        case WEBP, JXR, DDS, PVR, PKM:
            Log.warn("Unsupported image format: " + url);
            handleLoad(entry, new NodeCanvasImage());

        case MP3, M4A, OPUS, OGG, WAV:
            Log.warn("No sound support in nodejs: " + url);
            handleLoad(entry, null);

        case Data:
            var options :NodeFsFileOptions = {encoding:NodeC.UTF8, flag:'r'};
            Node.fs.readFile(url, options, function(err, data) {
                if (err != null) {
                    throw "Missing file " + url;
                }
                handleLoad(entry, new BasicFile(data));
            });
        }
    }

    override private function getAssetFormats (fn :Array<AssetFormat> -> Void)
    {
        //Well, we'll load everything even though we certainly don't support much
        fn(Type.allEnums(AssetFormat));
    }
}