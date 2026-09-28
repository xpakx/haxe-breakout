package;

import openfl.display.Sprite;
import starling.core.Starling;

class Main extends Sprite
{
    private var _starling:Starling;

    public function new()
    {
        super();
	trace("Hello world!");
        trace("Registered assets:", openfl.utils.Assets.list());
        _starling = new Starling(Game, stage);
        _starling.start();
    }
}
