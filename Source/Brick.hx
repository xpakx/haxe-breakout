import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.Color;
import starling.text.TextField;

import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.EnterFrameEvent;
import starling.utils.Color;

import openfl.ui.Keyboard;
import openfl.utils.Assets;
import openfl.geom.Rectangle;

class Brick extends Sprite
{
    public static inline var BRICK_WIDTH:Float = 48.0;
    public static inline var BRICK_HEIGHT:Float = 24.0;
    private var image:Image;
    private var lives:Int = 2;

    private var healthyTexture:Texture;
    private var scratchedTexture:Texture;
    private var destroyedTexture:Texture;

    public function new()
    {
        super();
    }

    public function setTextures(
        healthy:Texture,
	scratched:Texture,
	destroyed:Texture
    ):Void {
        healthyTexture = healthy;
	scratchedTexture = scratched;
	destroyedTexture = destroyed;
        setTexture(healthyTexture);
    }

    private function setTexture(brickTexture:Texture):Void {
	if (image == null) 
        {
	    image = new Image(brickTexture);
	    image.width = BRICK_WIDTH;
	    image.height = BRICK_HEIGHT;
	    image.textureSmoothing = TextureSmoothing.NONE;
	    addChild(image);
	    return;
        } 

	image.texture = brickTexture;
	image.readjustSize();
	image.width = BRICK_WIDTH;
	image.height = BRICK_HEIGHT;
    }

    override public function dispose():Void 
    {
        super.dispose();
        image.dispose();
    }

    public function hit():Bool {
        lives -= 1;
	if (lives == 1) {
	    setTexture(destroyedTexture);
	} if (lives == 2) {
	    setTexture(scratchedTexture);
	}
	return lives <= 0 ;
    }
}
