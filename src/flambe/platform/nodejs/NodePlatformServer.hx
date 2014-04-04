//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform.nodejs;

import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.Texture;
import flambe.util.Assert;
import flambe.util.Logger;
import flambe.util.Promise;
import flambe.util.Signal1;
import flambe.platform.BasicMouse;

import js.Node;
import js.node.WebSocketServer;
import js.node.NodeCanvasElement;

import haxe.Json;

using StringTools;

/**
 * Creates a web server that servers a single simple canvas.
 * The canvas is rendered via frame buffers sent via websockets
 * that are actually rendered by the node.js canvas renderer.
 * Mouse events are detected by the canvas and sent to the platform.
 *
 * Howto:
 *	1) set "-D node_flambe_server_enabled" in your build.hxml
 *	2) Point your browser to http://localhost:7000
 *  3) Build and run your flambe game with the nodejs platform
 */
class NodePlatformServer
{
	public var isConnections (get, null) :Bool;

	private static var HTTP_PORT = 7000;
	private static var WEBSOCKET_PORT = HTTP_PORT ;//+ 1;

	private static var MSG_STAGE_SIZE = "stage_size";
	private static var MSG_CANVAS_BUFFER = "canvas_buf";
	private static var MSG_MOUSE_MOVE = "mouse_move";
	private static var MSG_MOUSE_DOWN = "mouse_down";
	private static var MSG_MOUSE_UP = "mouse_up";

	private var _connections :Array<WebSocketConnection>;

	public function new(platform :NodePlatform)
	{
		_connections = [];
		_platform = platform;
		var httpServer = Node.http.createServer(handleRequest);
		httpServer.listen(HTTP_PORT,
			function() {
			    Log.info((Date.now()) + ' Server is listening at http://localhost:$HTTP_PORT');
			});

		var websocketServer = new WebSocketServer({httpServer:httpServer, autoAcceptConnections:false});
		websocketServer.on('connectFailed',
			function onConnectFailed (error :Dynamic) {
				trace("WebSocketServer connection failed: " + error);
			});
		websocketServer.on('request', onWebsocketRequest);
	}

	private function get_isConnections() :Bool
	{
		return _connections != null && _connections.length > 0;
	}

	public function sendCanvasBufferToClients()
	{
		if (!isConnections) {
			return;
		}

		var canvas :NodeCanvasElement = cast(cast(_platform.getRenderer(), NodeCanvasRenderer).graphics, NodeCanvasGraphics).canvas;
		var data = canvas.toBuffer();

		for (connection in _connections) {
			connection.sendBytes(data);
		}
	}

	function handleRequest(request :NodeHttpServerReq, response :NodeHttpServerResp)
	{
		response.writeHead(200, {"Content-Type": "text/html"});
		response.write(HTML_TEMPLATE);
		response.end();
	}

	function onWebsocketRequest (request :WebSocketRequest) :Void
	{
		Log.info("request.requestedProtocols: " + request.requestedProtocols);
		var protocol :String = null; ////For now, accept all requests.  This could be limited if required.
		var connection :WebSocketConnection = request.accept(protocol, request.origin);

		_connections.push(connection);
		var onError = function(error) {
			Log.error(' Peer ' + connection.remoteAddress + ' error: ' + error);
		}
		connection.on('error', onError);

		connection.once('close', function(reasonCode, description) {
			Log.info(Date.now() + ' client at "' + connection.remoteAddress + '" disconnected.');
			connection.removeListener('error', onError);
			_connections.remove(connection);
		});

		connection.on('message',
			function(message) {
		        if (message.type == 'utf8') {
		            // trace("Received: '" + message.utf8Data + "'");
		            var jsonResponse :{type:String, x :Int, y :Int} = Json.parse(message.utf8Data);
		            if (jsonResponse.type == MSG_MOUSE_MOVE) {
		            	var basicMouse :BasicMouse = cast _platform.getMouse();
		            	basicMouse.submitMove(jsonResponse.x, jsonResponse.y);
		            } else if (jsonResponse.type == MSG_MOUSE_DOWN) {
		            	Log.info('Mouse down [${jsonResponse.x}, ${jsonResponse.y}]');
		            	var basicMouse :BasicMouse = cast _platform.getMouse();
		            	basicMouse.submitDown(jsonResponse.x, jsonResponse.y, 0);
		            } else if (jsonResponse.type == MSG_MOUSE_UP) {
		            	Log.info('Mouse up [${jsonResponse.x}, ${jsonResponse.y}]');
		            	var basicMouse :BasicMouse = cast _platform.getMouse();
		            	basicMouse.submitUp(jsonResponse.x, jsonResponse.y, 0);
		            }
		        }
		    });

		var message = Json.stringify({type:MSG_STAGE_SIZE, width:System.stage.width, height:System.stage.height});
		Log.info("Sending: " + message);
		connection.sendUTF(message);
	}

	var _platform :NodePlatform;

	static var HTML_TEMPLATE = '<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Flambe node.js Canvas</title>
	<meta name="description" content="Flambe node.js Canvas">
	<meta name="author" content="dionjwa">
</head>

<body style="margin:10px;">
	<script type="text/javascript">
		//local variables
		var pointerX = 0;
		var pointerY = 0;

		var canvas = document.createElement("canvas");
		document.body.appendChild(canvas);

		var image = new Image(); //Data from the websocket is PNG data
		var ctx = canvas.getContext("2d");

		canvas.id     = "FlambeCanvas";
		canvas.width  = 300;
		canvas.height = 300;
		canvas.style.borderWidth="1px";

		//Reconnecting websocket for communication
		var connection = null;
		var connectWebsocket = null;
		connectWebsocket = function() {
			console.log("Attempting to connect the websocket");
			if (connection != null) {
				connection.close();
				connection = null;
			}
			connection = new WebSocket("ws://localhost:$WEBSOCKET_PORT");
			connection.binaryType = "arraybuffer";

			// When the connection is open, send some data to the server
			connection.onopen = function () {
				console.log("on socket open");
			};

			// When the connection is closed, reattempt to connect
			connection.onclose = function () {
				console.log("onclose, retrying in 1");
				setTimeout(connectWebsocket, 1000);
			};

			connection.onmessage = function (evt) {
				// console.log("Message is received... (typeof=" + (typeof evt.data) + ")" + evt.data);
				if ((typeof evt.data) == "string") {
					//Parse json
					var messageJson = JSON.parse(evt.data);
					if (messageJson.type == "$MSG_STAGE_SIZE") {
						console.log("Changing canvas size to [" + messageJson.width + ", " + messageJson.height + "]");
						canvas.width = messageJson.width;
						canvas.height = messageJson.height;
					} else if (messageJson.type == "$MSG_CANVAS_BUFFER") {
						var data = messageJson.data;
						image.src = messageJson.data;
						image.onload = function() {
						    ctx.drawImage(image, 0, 0);
						};
					}
				} else {
					//If its binary, assume it is a canvas blob.  Not very sophistacated I know, but cmon, this is the thinnest client imaginable!
					//Try this http://stackoverflow.com/questions/13950865/javascript-render-png-stored-as-uint8array-onto-canvas-element-without-data-uri
					var myArray; //= your data in a UInt8Array
					var blob = new Blob([evt.data], {"type": "image/png"});
					var url = window.URL.createObjectURL(blob);
					// var URL = webkitURL.createObjectURL(blob);
					image.src = url;
					image.onload = function() {
					    ctx.drawImage(image, 0, 0);
					};
				}
			};

			// Log errors
			connection.onerror = function (error) {
				console.log("onerror");
			};
		}
		connectWebsocket();

		//Input.  The will get sent to the websocket
		canvas.onmousemove = function(e) {
			pointerX = e.clientX - canvas.offsetLeft;
			pointerY = e.clientY - canvas.offsetTop;
			if (connection != null) {
				connection.send(JSON.stringify({type:"$MSG_MOUSE_MOVE", x:pointerX, y:pointerY}));
			}
			// console.log("pointer [" + pointerX + ", " + pointerY + "]");
		};

		canvas.onmousedown = function(e) {
			if (connection != null) {
				connection.send(JSON.stringify({type:"$MSG_MOUSE_DOWN", x:pointerX, y:pointerY}));
			}
		};

		canvas.onmouseup = function(e) {
			if (connection != null) {
				connection.send(JSON.stringify({type:"$MSG_MOUSE_UP", x:pointerX, y:pointerY}));
			}
		};
	</script>
	Hello  World.
</body>
</html>
	';
}
