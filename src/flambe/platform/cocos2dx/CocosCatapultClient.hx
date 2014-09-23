package flambe.platform.cocos2dx;

import cc.Cocos2dx;

import haxe.Json;

import transition9.websockets.WebSocketConnection;

using StringTools;

class CocosCatapultClient extends CatapultClient
{
    public function new ()
    {
        super();

        Log.warn("CocosCatapultClient");
        var G = Global.object();
        _socket = WebSocketConnection.get("ws://" + G.serverAddress).setAsGlobalPrimary();
        // untyped __js__('var WebSocket = WebSocket || window.WebSocket || window.MozWebSocket');
        // _socket = untyped __js__('new WebSocket("ws://localhost:8000", [])');
        // Log.info("cc.loader=" + untyped cc.loader);
        // Log.info("cc.loader=" + CC.loader);
        // var xhr = untyped __js__('cc.loader.getXMLHttpRequest()');
        // Log.info("xhr=" + xhr);
        // // Log.info("cc.loader.getXMLHttpRequest()=" + untyped cc.loader.getXMLHttpRequest());
        // // untyped __js__('for (i in CC.loader) cc.log(i);');
        // // var xhr = CC.loader.getXMLHttpRequest();

        // // xhr.open("GET", "http://httpbin.org/get");

        // untyped __js__('cc.log("" + WebSocket)');
        // _socket = new WebSocket("ws://localhost:8000");
        Log.info("" + _socket);
        _socket.registerOnError(function (event) {
            // onError("error: " + event);
            Log.error("CocosCatapultClient on websocket error: " + untyped JSON.stringify(event));
        });

        // _socket.onerror = function (event) {
        //     // onError("error: " + event);
        //     Log.error("CocosCatapultClient on websocket error: " + untyped JSON.stringify(event));
        // };

        _socket.registerOnOpen(function () {
            Log.info("Catapult connected");
        });
        // _socket.onopen = function (event) {
        //     Log.info("Catapult connected " + event);
        //     Log.info("onopen ");
        //     _socket.send("test_message");

        //     untyped setInterval(function() {
        //         if (_socket.readyState == 1) {
        //             _socket.send("keep_alive");
        //         }
        //     }, 25000);
        // };
        // _socket.onmessage = function (event :MessageEvent) {
        // _socket.onmessage = function (event) {
        //     Log.info("onmessage " + untyped event.data);
        //     onMessage(untyped event.data);
        // };

        _socket.registerOnMessage(function (event) {
            Log.info("onmessage " + untyped event.data);
            onMessage(untyped event.data);
        });

        // _socket.onclose = function (event) {
        //     Log.info("onclose " + untyped JSON.stringify(event));
        // };
    }

    override private function onMessage (message :String)
    {
        var message = Json.parse(message);
        switch (message.type) {
        case "file_changed":
            var url = message.name + "?v=" + message.md5;
            url = url.replace("\\", "/"); // Handle backslash paths in Windows
            for (loader in _loaders) {
                loader.reload(url);
            }
        case "restart":
            onRestart();
        }
    }

    override private function onRestart ()
    {
        Log.info("Cannot restart Cocos (yet)");
        // Browser.window.top.location.reload();
    }

    private var _socket :WebSocketConnection;
}
