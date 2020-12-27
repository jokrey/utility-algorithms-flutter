import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../vcall_1to1_observer_widget.dart';


///TEST ONLY
class TestConnectAsObserverWidget extends StatefulWidget {
  _TestConnectAsObserverWidgetState createState() =>
      _TestConnectAsObserverWidgetState();
}

class _TestConnectAsObserverWidgetState
    extends State<TestConnectAsObserverWidget> {
  final _enterHost = TextEditingController()
    ..text = kIsWeb ? "localhost" : "jokrey-manj-lap.fritz.box";
  final _enterPort = TextEditingController()..text = "8086";
  final _ownName = TextEditingController()..text = "parent";
  final _enterRemoteName1 = TextEditingController()..text = "c";
  final _enterRemoteName2 = TextEditingController()..text = "s";
  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return VCall1to1AsObserverWidget(
            ownName: _ownName.text,
            remoteNames: [_enterRemoteName1.text, _enterRemoteName2.text],
            host: _enterHost.text,
            port: int.parse(_enterPort.text),
          );
        }
      )
    );

    if(!initialConnectSuccessful) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Could not connect to Signaling-Server"),
            duration: Duration(seconds: 25)
          )
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if(kIsWeb) {
            return Text("CURRENTLY IMPOSSIBLE ON WEB - SEE BUG REPORT:\n"
                "https://github.com/flutter-webrtc/flutter-webrtc/issues/437");
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _enterHost,
                autocorrect: true,
                decoration: InputDecoration(hintText: 'Enter server address'),
              ),
              TextField(
                controller: _enterPort,
                autocorrect: false,
                decoration: InputDecoration(hintText: 'Enter server port'),
              ),
              TextField(
                controller: _ownName,
                autocorrect: true,
                decoration: InputDecoration(hintText: 'Enter own name'),
              ),
              TextField(
                controller: _enterRemoteName1,
                autocorrect: true,
                decoration: InputDecoration(hintText:'Enter observed remote 1'),
              ),
              TextField(
                controller: _enterRemoteName2,
                autocorrect: true,
                decoration: InputDecoration(hintText:'Enter observed remote 2'),
              ),

              RaisedButton(
                onPressed: () => _sendLobby(context),
                color: Color(0xffFF1744),
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text('Connect'),
              )
            ],
          );
        }
      )
    );
  }
}
