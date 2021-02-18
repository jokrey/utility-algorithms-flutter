import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

///WSClientable Client
///  allows a easy to use and encapsulated access to a wsclientable server
///
/// Will not ping server by default
/// Not thread safe
///
///  Clients can send json messages over the websocket connection.
///    Base-Format:
///      {"type":"<mType>", "data":"<arbitrary implementation specific data>"}
///  The server implementation will handle those messages according to the type.
class ClientConnection {
  final WebSocketChannel _conn;

  ///Called when this client is closed.
  Function(ClientConnection, int, String) onClosedHandler;

  // ignore: lines_longer_than_80_chars
  final Map<String, Function(String, ClientConnection, Map<String, dynamic>)>
      _messageHandlers = {};

  ///Always instantiate using 'connect'
  ClientConnection(this._conn) {
    _conn.stream.listen((message) {
      try {
        var messageJson = json.decode(message);
        var mType = messageJson["type"];
        var handler = _messageHandlers[mType];
        if (handler != null) {
          handler(mType, this, messageJson["data"]);
        } else {
          print("Received unrecognised type $mType "
              "from server,  closing connection");
          close();
        }
      } on Exception {
        print("Received unparsable json from server, closing connection");
        print('message: $message');
        close();
      }
    }, onError: (error) {
      print("error in wsclientable client websocket connectino: $error");
      _remoteClosed();
    }, onDone: () {
      _remoteClosed();
    });
    _isConnected = true;
  }

  ///Adds a message handler to this client connection
  // ignore: lines_longer_than_80_chars
  void addMessageHandler(String mType,
      Function(String, ClientConnection, Map<String, dynamic>) messageHandler) {
    _messageHandlers[mType] = messageHandler;
  }

  ///Internal/Expert use only
  void sendRaw(String text) {
    if (isConnected()) {
      _conn.sink.add(text);
    }
  }

  ///Send the given unencoded json in the data field
  void sendMap(String mType, dynamic jsonData) {
    sendTyped(mType, json.encode(jsonData));
  }

  ///Sends the given encoded data field with the given type
  void sendTyped(String mType, String data) {
    sendRaw("{\"type\":\"$mType\", \"data\":$data}");
  }

  bool _isConnected = false;

  ///Returns whether this socket is currently connected
  bool isConnected() => _isConnected;

  void _remoteClosed() async {
    _isConnected = false;
    if (onClosedHandler != null) {
      onClosedHandler(this, _conn.closeCode, _conn.closeReason);
      onClosedHandler = null;
    }
  }

  ///closes this web socket connection if not already and
  ///  always calls onClosedHandler, unless null
  Future<void> close() async {
    print("client close");
    _isConnected = false;
    if (_conn.closeCode == null) {
      await _conn.sink.close(WebSocketStatus.normalClosure);
    }
    if (onClosedHandler != null) {
      onClosedHandler(this, _conn.closeCode, _conn.closeReason);
      onClosedHandler = null;
    }
  }
}

///Connect to given url
Future<ClientConnection> connectToWSClientableServer(String url) async {
  if (url.startsWith("http")) {
    url = "ws${url.substring(4)}";
  }

  return ClientConnection(WebSocketChannel.connect(Uri.parse(url)));
}

///Adds the certificate (X.509) to the list of accepted certificates.
///Asset must be defined in pubspec.yaml
///Only add trusted i.e. self signed certificates
Future<void> addCertificateFromAssets(String assetURI) async {
  try {
    await rootBundle.load(assetURI).then((data) {
      SecurityContext.defaultContext
          .setTrustedCertificatesBytes(data.buffer.asUint8List());
      print(
          "Added certificate: ${Utf8Decoder().convert(data.buffer.asUint8List())}");
    });
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    print("error adding cert: $e");
    print("On some devices(for example browsers) it may be illegal"
        " for applications to add certificates."
        "In that case add them manually.");
  }
}
