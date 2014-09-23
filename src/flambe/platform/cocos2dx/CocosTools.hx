package flambe.platform.cocos2dx;

import cc.Cocos2dx;

import flambe.display.Sprite;
import flambe.display.ImageSprite;

class CocosTools
{
	public static function getHierarchyString(?node :CCNode, ?tabSize :Int = 0, ?stringbuf : StringBuf) :StringBuf
	{
		node = node == null ? CC.director.getRunningScene() : node;
		stringbuf = stringbuf == null ? new StringBuf() : stringbuf;
		stringbuf.add("\n");
		for (i in 0...tabSize) {
			stringbuf.add(" ");
		}

		stringbuf.add(nodeToString(node));
		if (node.childrenCount > 0) {
			for (child in node.children) {
				getHierarchyString(child, tabSize + 2, stringbuf);
			}
		}
		return stringbuf;
	}

	public static function nodeToString(node :CCNode) :String
	{
		// return '[[x=${node.x} y=${node.y}] children=${node.childrenCount} userData=${node.userData}]';
		var sprite = flambe.display.Sprite.NODE_SPRITE_MAP[node];
		var componentString = "";
		var textureString = "";
		if (sprite != null) {
			switch (Type.getClassName(Type.getClass(sprite))) {
				case "flambe.display.Sprite": componentString = spriteToString(sprite);
				case "flambe.display.ImageSprite":
					componentString = imageSpriteToString(cast sprite);
					textureString = "" + untyped node.textureAtlas;
				case "flambe.swf.MovieSprite": componentString = "MovieSprite";
				default: "Unknown, don't care?";
			}
		}
		// textureAtlast=${node.textureAtlas}
		//type=${componentString}
		return '[[tex=$textureString x=${node.x} y=${node.y} vis=${node.isVisible()} alpha=${node.getOpacity()} scale=[${node.getScaleX()} ${node.getScaleY()}]] ${node} children=${node.childrenCount} ]';
	}

	static function spriteToString(sprite :Sprite) :String
	{
		return '[[x=${sprite.x} y=${sprite.y}] type=Sprite]';
	}

	static function imageSpriteToString(sprite :ImageSprite) :String
	{
		var spriteFrameTexture :flambe.platform.cocos2dx.CocosSpriteFrameTexture = cast sprite.texture;
		return '[[x=${sprite.x} y=${sprite.y}] texture=[${spriteFrameTexture.width} ${spriteFrameTexture.height}] type=ImageSprite]';
	}
}