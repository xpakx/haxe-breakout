import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.Color;

import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.EnterFrameEvent;
import starling.utils.Color;

import openfl.ui.Keyboard;
import openfl.utils.Assets;

class Game extends Sprite
{
    private var paddle:Image;
    private var ball:Image;

    private var leftPressed:Bool = false;
    private var rightPressed:Bool = false;

    private static inline var PADDLE_SPEED:Float = 500.0;


    // simple paddle physics
    private var vx:Float = 0.0;
    private static inline var ACCELERATION:Float = 4500.0;
    private static inline var MAX_SPEED:Float = 800.0;
    private static inline var FRICTION:Float = 14.0;

    // ball physics
    private var ballVx:Float = 0.0;
    private var ballVy:Float = 0.0;
    private static inline var BALL_SPEED:Float = 450.0;

    public function new()
    {
        super();
	addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

	var paddleTexture:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/paddle.png"));
        var ballTexture:Texture   = Texture.fromBitmapData(Assets.getBitmapData("assets/ball.png"));


        paddle = new Image(paddleTexture);
	paddle.width = 100;
	paddle.scaleY = paddle.scaleX;
	paddle.textureSmoothing = TextureSmoothing.NONE;
        paddle.x = (stage.stageWidth - paddle.width) / 2;
        paddle.y = stage.stageHeight - 50;
        addChild(paddle);

        ball = new Image(ballTexture);
	ball.width = 14;
	ball.scaleY = ball.scaleX;
	ball.textureSmoothing = TextureSmoothing.NONE;
        resetBall();
        addChild(ball);

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
        updatePaddle(e.passedTime);
        updateBall(e.passedTime);
    }

    private function updatePaddle(dt:Float):Void {
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

    private function resetBall():Void {
        ball.x = (stage.stageWidth - ball.width) / 2;
        ball.y = stage.stageHeight / 2;

        var angle:Float = (Math.PI / 4) + (Math.random() * Math.PI / 2);
        ballVx = BALL_SPEED * Math.cos(angle);
        ballVy = BALL_SPEED * Math.sin(angle);
    }

    private function updateBall(dt:Float):Void {
        ball.x += ballVx * dt;
        ball.y += ballVy * dt;

        if (ball.x < 0) {
            ball.x = 0;
            ballVx = -ballVx;
        } else if (ball.x + ball.width > stage.stageWidth) {
            ball.x = stage.stageWidth - ball.width;
            ballVx = -ballVx;
        }

        if (ball.y < 0) {
            ball.y = 0;
            ballVy = -ballVy;
        }

        if (ball.y > stage.stageHeight) {
            resetBall();
        }

        if (ball.getBounds(stage).intersects(paddle.getBounds(stage)) && ballVy > 0) {
            ball.y = paddle.y - ball.height;
            ballVy = -Math.abs(ballVy);

            var paddleCenter:Float = paddle.x + (paddle.width / 2);
            var ballCenter:Float = ball.x + (ball.width / 2);
            var normalizedOffset:Float = (ballCenter - paddleCenter) / (paddle.width / 2);

            ballVx = (normalizedOffset * BALL_SPEED) + (vx * 0.25);
        }
    }
}
