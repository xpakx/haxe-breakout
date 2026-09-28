import starling.display.Quad;
import starling.display.Sprite;
import starling.utils.Color;

class Game extends Sprite
{
    public function new()
    {
        super();

        var quad:Quad = new Quad(200, 200, Color.RED);
        quad.x = 100;
        quad.y = 50;
        addChild(quad);
    }
}
