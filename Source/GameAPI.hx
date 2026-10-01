package;

@:expose("GameAPI")
@:keep
class GameAPI {
    private static var game:Game;

    public static function setGame(game:Game):Void {
        GameAPI.game = game;
    }

    public static function logVersion():Void {
        js.Browser.console.log("Breakout v1.0.0");
    }
}

