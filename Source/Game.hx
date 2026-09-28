import starling.display.Quad;
import starling.display.Sprite;
import starling.utils.Color;

import starling.events.Event;

class Game extends Sprite
{
    private var paddle:Quad;
    private var leftPressed:Bool = false;
    private var rightPressed:Bool = false;

    private static inline var PADDLE_SPEED:Float = 500.0;

    public function new()
    {
        super();
	addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        paddle = new Quad(100, 20, Color.RED);
        paddle.x = (stage.stageWidth - paddle.width) / 2;
        paddle.y = stage.stageHeight - 50;
        addChild(paddle);
    }
}
