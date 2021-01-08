import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../network/webrtc/calls/observable_vcall_1to1.dart';
import '../../../network/webrtc/signaling/signaling_room_impl.dart';
import '../observable_vcall_1to1_widget.dart';

///TEST ONLY
class TestConnectTo1to1ObservableCallInRoomWidget extends StatefulWidget {
  _TestConnectTo1to1ObservableCallInRoomWidgetState createState() =>
      _TestConnectTo1to1ObservableCallInRoomWidgetState();
}

///TEST ONLY
class _TestConnectTo1to1ObservableCallInRoomWidgetState
    extends State<TestConnectTo1to1ObservableCallInRoomWidget> {
  final _enterHost = TextEditingController()
    ..text = kIsWeb ? "localhost" : "jokrey-manj-lap.fritz.box";
  final _enterPort = TextEditingController()..text = "8086";
  final _enterRoomName = TextEditingController()..text = "testAndDebug56c238cd";
  final _enterOwnName = TextEditingController()..text = kIsWeb ? "c" : "s";
  final _enterRemoteName = TextEditingController()..text = kIsWeb ? "s" : "c";
  final _enterAllowedRemoteObserver = TextEditingController()
    ..text = "parent";
  _sendLobby(BuildContext context) async {
    var initialConnectSuccessful = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ObservableVCall1to1Widget(
            call: ObservableVCall1to1(
              _enterOwnName.text, _enterRemoteName.text,
              _enterAllowedRemoteObserver.text,
              RoomSignalerImpl(
                _enterRoomName.text, _enterOwnName.text,
                true, _enterHost.text, int.parse(_enterPort.text)
              )
            )
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
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _enterHost,
              decoration: InputDecoration(hintText: 'Enter server address'),
            ),
            TextField(
              controller: _enterPort,
              decoration: InputDecoration(hintText: 'Enter server port'),
            ),
            TextField(
              controller: _enterRoomName,
              decoration: InputDecoration(hintText: 'Enter the room name'),
            ),
            TextField(
              controller: _enterOwnName,
              decoration: InputDecoration(hintText: 'Enter your name'),
            ),
            TextField(
              controller: _enterRemoteName,
              decoration: InputDecoration(hintText: 'Enter the remote name'),
            ),
            TextField(
              controller: _enterAllowedRemoteObserver,
              decoration: InputDecoration(
                hintText: 'Enter the allowed remote observer name'
              ),
            ),

            RaisedButton(
              onPressed: () => _sendLobby(context),
              color: Color(0xffFF1744),
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text('Connect'),
            )
          ],
        )
      )
    );
  }
}
