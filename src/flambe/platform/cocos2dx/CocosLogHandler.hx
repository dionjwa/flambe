//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.cocos2dx;

import flambe.util.Logger;

import cc.Cocos2dx;

class CocosLogHandler
    implements LogHandler
{
    public function new (tag :String)
    {
        _tagPrefix = " " + tag + ": ";
        _trace = untyped cc.log;
    }

    public function log (level :LogLevel, message :Dynamic)
    {
        message = _tagPrefix + message;
        var t = DateTools.format(Date.now(),"%Y-%m-%d_%H:%M:%S");
        _trace(transition9.util.Log.NO_FORWARD + t + message);
        // switch (level) {
        //     case Info:
        //         _trace(t + GREEN + message + RESET);
        //     case Warn:
        //         _trace(t + BLUE + message + RESET);
        //     case Error:
        //         _trace(t + RED + message + RESET);
        // }
    }

    private var _tagPrefix :String;
    private var _trace :String -> Void;

    private static var RED = '\033[31m';
    private static var BLUE = '\033[34m';
    private static var RESET = '\033[0m';
    private static var GREEN = '\033[1;32;40m';
}