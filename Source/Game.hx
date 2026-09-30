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

using ArraySwapRemove;

class Game extends Sprite
{
    private var paddle:Image;
    private var ball:Image;
    private var bricks:Array<Image> = [];

    private var leftPressed:Bool = false;
    private var rightPressed:Bool = false;

    private static inline var PADDLE_SPEED:Float = 500.0;

    var brickTextures:Array<Texture>;


    // simple paddle physics
    private var vx:Float = 0.0;
    private static inline var ACCELERATION:Float = 4500.0;
    private static inline var MAX_SPEED:Float = 800.0;
    private static inline var FRICTION:Float = 14.0;

    // ball physics
    private var ballVx:Float = 0.0;
    private var ballVy:Float = 0.0;
    private static inline var BALL_SPEED:Float = 450.0;


    private static inline var BRICK_ROWS:Int = 6;
    private static inline var BRICK_COLS:Int = 8;
    private static inline var BRICK_WIDTH:Float = 48.0;
    private static inline var BRICK_HEIGHT:Float = 24.0;
    private static inline var BRICK_PADDING:Float = 1.0;
    private static inline var GRID_TOP_OFFSET:Float = 60.0;


    private var scoreLabel:TextField;
    private var livesLabel:TextField;
    private var score:Int = 0;
    private var lives:Int = 3;


    private var statusLabel:TextField;
    private var gameState:GameState;


    public function new()
    {
        super();
	addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

	var paddleTexture:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/paddle.png"));
        var ballTexture:Texture   = Texture.fromBitmapData(Assets.getBitmapData("assets/ball.png"));
        var brickAtlas = Texture.fromBitmapData(Assets.getBitmapData("assets/bricks.png"));
	var blueBrick:Texture = getBrickTexture(brickAtlas, 0, 0);
	var greenBrick:Texture = getBrickTexture(brickAtlas, 0, 1);
	var yellowBrick:Texture = getBrickTexture(brickAtlas, 0, 2);
	var orangeBrick:Texture = getBrickTexture(brickAtlas, 0, 3);
	var redBrick:Texture = getBrickTexture(brickAtlas, 0, 4);
	var purpleBrick:Texture = getBrickTexture(brickAtlas, 0, 5);
	brickTextures = [
		blueBrick,
		greenBrick,
		yellowBrick,
		orangeBrick,
		redBrick,
		purpleBrick,
	];


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

        createBricks();

	stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);

        scoreLabel = new TextField(200, 40, "");
        scoreLabel.format.setTo("Arial", 18, 0x000000);
        scoreLabel.x = 10;
        scoreLabel.y = 10;
        addChild(scoreLabel);

        livesLabel = new TextField(200, 40, "");
        livesLabel.format.setTo("Arial", 18, 0x000000);
        livesLabel.x = stage.stageWidth - 210;
        livesLabel.y = 10;
        addChild(livesLabel);

        statusLabel = new TextField(600, 80, "");
        statusLabel.format.setTo("Arial", 28, 0x000000);
        statusLabel.x = (stage.stageWidth - 600) / 2;
        statusLabel.y = (stage.stageHeight - 80) / 2;
        statusLabel.visible = false;
        addChild(statusLabel);

        resetGame();
    }

    private function updateUI():Void {
        scoreLabel.text = "SCORE: " + score;
        livesLabel.text = "LIVES: " + lives;
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A) {
	    leftPressed = true;
	}
        if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D) {
	    rightPressed = true;
	}
        if ((gameState != InProgress) && e.keyCode == Keyboard.SPACE) {
            resetGame();
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
        if (gameState != InProgress) return;

        updatePaddle(e.passedTime);
	checkBrickCollisions();
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
	    lives--;
	    updateUI();

	    if (lives <= 0) {
                switchToLost();
	    } else {
               resetBall();
	    }
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


    private function getBrickTexture(brickAtlas:Texture, column:Int, row:Int):Texture {
	return Texture.fromTexture(
			brickAtlas, new Rectangle(0, row*(96/6), 96/3, 96/6)
	);
    }

    private function createBricks():Void {

        var totalGridWidth:Float = (BRICK_COLS * BRICK_WIDTH) + ((BRICK_COLS - 1) * BRICK_PADDING);
        var startX:Float = (stage.stageWidth - totalGridWidth) / 2;

        for (row in 0...BRICK_ROWS) {
            for (col in 0...BRICK_COLS) {
                var brickTexture = brickTextures[row % brickTextures.length];
                var brick:Image = new Image(brickTexture);
                brick.width = BRICK_WIDTH;
                brick.height = BRICK_HEIGHT;
                brick.textureSmoothing = TextureSmoothing.NONE;



                brick.x = startX + col * (BRICK_WIDTH + BRICK_PADDING);
                brick.y = GRID_TOP_OFFSET + row * (BRICK_HEIGHT + BRICK_PADDING);

                addChild(brick);
                bricks.push(brick);
            }
        }
    }

    private function addScore(dPoints:Int):Void {
        score += dPoints;
        updateUI();
    }

    private function checkBrickCollisions():Void {
        var ballBounds = ball.getBounds(stage);

        var i:Int = bricks.length - 1;
        while (i >= 0) {
            var brick:Image = bricks[i];
            if (ballBounds.intersects(brick.getBounds(stage))) {
	        // TODO ???
                ballVy = -ballVy;

		addScore(10);

                // TODO: multiple hits?
                removeChild(brick);
                brick.dispose();
                bricks.swapRemoveAt(i);

		if (bricks.length == 0) {
		    switchToWon();
		}
            }
            i--;
        }
    }

    private function resetGame():Void {
        score = 0;
        lives = 3;
	gameState = InProgress;

        paddle.x = (stage.stageWidth - paddle.width) / 2;
        paddle.y = stage.stageHeight - 50;
	vx = 0.0;

        updateUI();
        statusLabel.visible = false;

        clearBricks();
        createBricks();
        resetBall();
    }

    private function clearBricks():Void {
        for (brick in bricks) {
            removeChild(brick);
            brick.dispose();
        }
        bricks = [];
    }

    private function switchToLost():Void {
        gameState = Lost;
        statusLabel.text = "You lost";
        statusLabel.visible = true;
    }

    private function switchToWon():Void {
        gameState = Won;
        statusLabel.text = "You won";
        statusLabel.visible = true;
    }

}
