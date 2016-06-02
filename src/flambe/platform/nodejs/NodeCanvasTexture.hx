//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import js.npm.NodeCanvas;

import js.Node;

class NodeCanvasTexture extends BasicTexture<NodeCanvasTextureRoot>
{
    public function new (root :NodeCanvasTextureRoot, width :Int, height :Int)
    {
        super(root, width, height);
    }

    public function getPattern () :Dynamic//CanvasPattern
    {
        if (_rootUpdateCount != root.updateCount || _pattern == null) {
            _rootUpdateCount = root.updateCount;
            _pattern = root.createPattern(rootX, rootY, width, height);
        }
        return _pattern;
    }

    private var _pattern :Dynamic = null;
    private var _rootUpdateCount :Int = 0;
}
