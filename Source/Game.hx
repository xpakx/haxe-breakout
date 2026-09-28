import starling.display.Quad;
import starling.display.Sprite;
import starling.utils.Color;

import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.EnterFrameEvent;
import starling.utils.Color;
import openfl.ui.Keyboard;

class Game extends Sprite
{
    private var paddle:Quad;
    private var leftPressed:Bool = false;
    private var rightPressed:Bool = false;

    private static inline var PADDLE_SPEED:Float = 500.0;


    // simple physics
    private var vx:Float = 0.0;
    private static inline var ACCELERATION:Float = 4500.0;
    private static inline var MAX_SPEED:Float = 800.0;
    private static inline var FRICTION:Float = 14.0;

    public function new()
    {
        super();
	addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        paddle = new Quad(100, 20, Color.RED);
        paddle.x = (stage.stageWidth - paddle.width) / 2;
        paddle.y = stage.stageHeight - 50;
        addChild(paddle);

	stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    leftPressed = true;
	}
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    rightPressed = true;
	}
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    leftPressed = false;
	}
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    rightPressed = false;
	}
    }

    private function onEnterFrame(e:EnterFrameEvent):Void {
        var dt:Float = e.passedTime;

        var moveDir:Float = 0.0;
        if (leftPressed) moveDir -= 1.0;
        if (rightPressed) moveDir += 1.0;

        if (moveDir != 0.0) {
            vx += moveDir * ACCELERATION * dt;
        } else {
            vx -= vx * FRICTION * dt;
        }

        if (vx > MAX_SPEED) vx = MAX_SPEED;
        if (vx < -MAX_SPEED) vx = -MAX_SPEED;

        paddle.x += vx * dt;

        if (paddle.x < 0) {
            paddle.x = 0;
	    vx = 0;
        } else if (paddle.x + paddle.width > stage.stageWidth) {
            paddle.x = stage.stageWidth - paddle.width;
	    vx = 0;
        }
    }
    
}
