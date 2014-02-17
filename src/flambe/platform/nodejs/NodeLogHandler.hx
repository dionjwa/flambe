//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import flambe.util.Logger;

class NodeLogHandler
    implements LogHandler
{
    public function new (tag :String)
    {
        _tagPrefix = tag + ": ";
    }

    public function log (level :LogLevel, message :Dynamic)
    {
        message = _tagPrefix + message;
        switch (level) {
            case Info:
                (untyped console).info(GREEN + message + RESET);
            case Warn:
                (untyped console).warn(BLUE + message + RESET);
            case Error:
                (untyped console).error(RED + message + RESET);
        }
    }

    private var _tagPrefix :String;

    private static var RED = '\033[31m';
    private static var BLUE = '\033[34m';
    private static var RESET = '\033[0m';
    private static var GREEN = '\033[1;32;40m';
}
